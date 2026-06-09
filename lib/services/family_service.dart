import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/family_member_model.dart';
import '../utils/wifi_match_helper.dart';
import 'wifi_network_service.dart';

/// Firestore-backed family flows:
/// - One admin per family (`families.adminUid`).
/// - Members join via [requestJoinFamily] (pending until admin accepts) or
///   [acceptEmailInvite] after opening the Gmail invite link (also pending admin).
class FamilyService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final _random = Random.secure();

  String _sixDigit() =>
      (100000 + _random.nextInt(900000)).toString();

  String _inviteToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      32,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  DateTime _asDateTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  /// Active member may belong to at most one family ([exceptFamilyId] allowed).
  Future<void> _ensureSingleFamilyMembership(
    String uid, {
    String? exceptFamilyId,
    bool checkUserProfile = true,
  }) async {
    final memberships = await _firestore
        .collection('family_members')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .get();

    for (final doc in memberships.docs) {
      final fid = doc.data()['familyId'] as String? ?? '';
      if (fid.isEmpty) continue;
      if (exceptFamilyId != null && fid == exceptFamilyId) continue;
      throw Exception('already_in_other_family');
    }

    if (!checkUserProfile) return;

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userFamilyId = userDoc.data()?['familyId'] as String?;
    if (userFamilyId != null &&
        userFamilyId.isNotEmpty &&
        userFamilyId != exceptFamilyId) {
      final stillMember = await _firestore
          .collection('family_members')
          .where('userId', isEqualTo: uid)
          .where('familyId', isEqualTo: userFamilyId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      if (stillMember.docs.isNotEmpty &&
          (exceptFamilyId == null || userFamilyId != exceptFamilyId)) {
        throw Exception('already_in_other_family');
      }
    }
  }

  /// Returns true if this user is already admin of any family.
  Future<bool> isUserFamilyAdmin(String uid) async {
    final q = await _firestore
        .collection('family_members')
        .where('userId', isEqualTo: uid)
        .where('role', isEqualTo: 'admin')
        .limit(1)
        .get();
    return q.docs.isNotEmpty;
  }

  /// Admin's active family id, if any.
  Future<String?> getAdminFamilyId(String uid) async {
    final q = await _firestore
        .collection('family_members')
        .where('userId', isEqualTo: uid)
        .where('role', isEqualTo: 'admin')
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return q.docs.first.data()['familyId'] as String?;
  }

  Future<String> _uniqueJoinCode() async {
    for (var i = 0; i < 20; i++) {
      final code = _sixDigit();
      final dup = await _firestore
          .collection('families')
          .where('joinCode', isEqualTo: code)
          .limit(1)
          .get();
      if (dup.docs.isEmpty) return code;
    }
    return '${DateTime.now().millisecondsSinceEpoch % 1000000}'.padLeft(6, '0');
  }

  /// CREATE FAMILY — current user becomes the only admin.
  Future<String?> createFamily(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      if (await isUserFamilyAdmin(user.uid)) {
        throw Exception('already_admin');
      }

      final joinCode = await _uniqueJoinCode();

      final familyRef = await _firestore.collection('families').add({
        'name': name,
        'adminUid': user.uid,
        'ownerId': user.uid,
        'joinCode': joinCode,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final familyId = familyRef.id;

      await _firestore.collection('family_members').add({
        'familyId': familyId,
        'userId': user.uid,
        'role': 'admin',
        'status': 'active',
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('invites').doc(familyId).set({
        'familyId': familyId,
        'code': joinCode,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(user.uid).set({
        'familyId': familyId,
        'familyCode': joinCode,
      }, SetOptions(merge: true));

      return familyId;
    } catch (e) {
      // ignore: avoid_print
      print('CREATE FAMILY ERROR: $e');
      return null;
    }
  }

  Future<String?> _resolveFamilyIdFromCode(String raw) async {
    final code = raw.trim();
    if (code.isEmpty) return null;

    final famDoc = await _firestore.collection('families').doc(code).get();
    if (famDoc.exists) return famDoc.id;

    final byJoin = await _firestore
        .collection('families')
        .where('joinCode', isEqualTo: code)
        .limit(1)
        .get();
    if (byJoin.docs.isNotEmpty) return byJoin.docs.first.id;

    final legacy = await _firestore
        .collection('invites')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();
    if (legacy.docs.isNotEmpty) {
      return legacy.docs.first.data()['familyId'] as String?;
    }
    return null;
  }

  /// Family member requests to join (pending admin approval). Returns [familyId].
  Future<String> requestJoinFamily(String codeOrFamilyId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('not_signed_in');

    await _ensureSingleFamilyMembership(user.uid);

    final familyId = await _resolveFamilyIdFromCode(codeOrFamilyId);
    if (familyId == null) throw Exception('invalid_code');

    final fam = await _firestore.collection('families').doc(familyId).get();
    if (!fam.exists) throw Exception('invalid_code');

    final existing = await _firestore
        .collection('family_members')
        .where('familyId', isEqualTo: familyId)
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) throw Exception('already_member');

    final pending = await _firestore
        .collection('family_join_requests')
        .where('familyId', isEqualTo: familyId)
        .where('requesterUid', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    if (pending.docs.isNotEmpty) throw Exception('already_pending');

    final joinCode = fam.data()?['joinCode'] as String? ?? codeOrFamilyId.trim();

    await _firestore.collection('family_join_requests').add({
      'familyId': familyId,
      'familyJoinCode': joinCode,
      'requesterUid': user.uid,
      'requesterEmail': user.email,
      'requesterName': user.displayName ?? user.email ?? '',
      'status': 'pending',
      'source': 'join_code',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return familyId;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> joinRequestsStream(String familyId) {
    return _firestore
        .collection('family_join_requests')
        .where('familyId', isEqualTo: familyId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myPendingJoinRequestsStream() async* {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    yield* _firestore
        .collection('family_join_requests')
        .where('requesterUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Future<void> acceptJoinRequest(String requestDocId) async {
    final admin = _auth.currentUser;
    if (admin == null) throw Exception('not_signed_in');

    final reqRef = _firestore.collection('family_join_requests').doc(requestDocId);
    final req = await reqRef.get();
    if (!req.exists) throw Exception('not_found');

    final data = req.data()!;
    final familyId = data['familyId'] as String;
    final requesterUid = data['requesterUid'] as String;

    final fam = await _firestore.collection('families').doc(familyId).get();
    final adminUid = fam.data()?['adminUid'] ?? fam.data()?['ownerId'];
    if (adminUid != admin.uid) throw Exception('not_admin');

    final joinCode = fam.data()?['joinCode'] as String? ?? '';

    await _ensureSingleFamilyMembership(
      requesterUid,
      exceptFamilyId: familyId,
      checkUserProfile: false,
    );

    final memberRef = _firestore.collection('family_members').doc();
    final userRef = _firestore.collection('users').doc(requesterUid);

    await _firestore.runTransaction((tx) async {
      tx.update(reqRef, {
        'status': 'accepted',
        'resolvedAt': FieldValue.serverTimestamp(),
      });

      tx.set(memberRef, {
        'familyId': familyId,
        'userId': requesterUid,
        'role': 'member',
        'status': 'active',
        'email': data['requesterEmail'],
        'displayName': data['requesterName'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.set(
        userRef,
        {
          'familyId': familyId,
          'familyCode': joinCode,
        },
        SetOptions(merge: true),
      );
    });

    final emailInviteId = data['emailInviteId'] as String?;
    if (emailInviteId != null && emailInviteId.isNotEmpty) {
      await _firestore.collection('family_email_invites').doc(emailInviteId).update({
        'status': 'accepted',
        'finalizedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> rejectJoinRequest(String requestDocId) async {
    final admin = _auth.currentUser;
    if (admin == null) throw Exception('not_signed_in');

    final reqRef = _firestore.collection('family_join_requests').doc(requestDocId);
    final req = await reqRef.get();
    if (!req.exists) return;

    final familyId = req.data()!['familyId'] as String;
    final fam = await _firestore.collection('families').doc(familyId).get();
    final adminUid = fam.data()?['adminUid'] ?? fam.data()?['ownerId'];
    if (adminUid != admin.uid) throw Exception('not_admin');

    final inviteId = req.data()?['emailInviteId'] as String?;

    await reqRef.update({
      'status': 'rejected',
      'resolvedAt': FieldValue.serverTimestamp(),
    });

    if (inviteId != null && inviteId.isNotEmpty) {
      await _firestore.collection('family_email_invites').doc(inviteId).update({
        'status': 'rejected_by_admin',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Admin invites an email — member opens link in app, then waits for admin (same queue as join-by-code).
  Future<Map<String, String>> inviteMemberByEmail(String familyId, String invitedEmail) async {
    final admin = _auth.currentUser;
    if (admin == null) throw Exception('not_signed_in');

    final fam = await _firestore.collection('families').doc(familyId).get();
    final adminUid = fam.data()?['adminUid'] ?? fam.data()?['ownerId'];
    if (adminUid != admin.uid) throw Exception('not_admin');

    final email = invitedEmail.trim().toLowerCase();
    if (email.isEmpty) throw Exception('invalid_email');

    final token = _inviteToken();
    final expires = DateTime.now().add(const Duration(days: 7));

    final docRef = await _firestore.collection('family_email_invites').add({
      'familyId': familyId,
      'invitedByUid': admin.uid,
      'invitedEmail': email,
      'inviteToken': token,
      'expiresAt': Timestamp.fromDate(expires),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return {
      'inviteToken': token,
      'inviteLink': 'elderlycare://family-invite?t=$token',
      'inviteId': docRef.id,
    };
  }

  /// After invitee opens the invite link in the app: submits a **pending** join request (admin must accept).
  Future<void> acceptEmailInvite(String token) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('not_signed_in');

    final q = await _firestore
        .collection('family_email_invites')
        .where('inviteToken', isEqualTo: token.trim())
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (q.docs.isEmpty) throw Exception('invalid_invite');

    final inviteSnap = q.docs.first;
    final d = inviteSnap.data();
    final familyId = d['familyId'] as String;
    final invitedEmail = (d['invitedEmail'] as String? ?? '').toLowerCase();
    final myEmail = (user.email ?? '').toLowerCase();
    if (invitedEmail.isNotEmpty && myEmail != invitedEmail) {
      throw Exception('email_mismatch');
    }

    await _ensureSingleFamilyMembership(user.uid, exceptFamilyId: familyId);

    DateTime exp;
    if (d['expiresAt'] != null) {
      exp = _asDateTime(d['expiresAt']);
    } else if (d['otpExpiresAt'] != null) {
      exp = _asDateTime(d['otpExpiresAt']);
    } else {
      exp = DateTime.now().add(const Duration(days: 365));
    }
    if (DateTime.now().isAfter(exp)) {
      await inviteSnap.reference.update({'status': 'expired'});
      throw Exception('expired');
    }

    final fam = await _firestore.collection('families').doc(familyId).get();
    final joinCode = fam.data()?['joinCode'] as String? ?? '';

    final existingMember = await _firestore
        .collection('family_members')
        .where('familyId', isEqualTo: familyId)
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (existingMember.docs.isNotEmpty) throw Exception('already_member');

    final pending = await _firestore
        .collection('family_join_requests')
        .where('familyId', isEqualTo: familyId)
        .where('requesterUid', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    if (pending.docs.isNotEmpty) throw Exception('already_pending');

    await _firestore.runTransaction((tx) async {
      tx.update(inviteSnap.reference, {
        'status': 'awaiting_admin',
        'claimedByUid': user.uid,
        'claimedAt': FieldValue.serverTimestamp(),
      });

      final reqRef = _firestore.collection('family_join_requests').doc();
      tx.set(reqRef, {
        'familyId': familyId,
        'familyJoinCode': joinCode,
        'requesterUid': user.uid,
        'requesterEmail': user.email,
        'requesterName': user.displayName ?? user.email ?? '',
        'status': 'pending',
        'source': 'email_invite',
        'emailInviteId': inviteSnap.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Submits a join request and returns the resolved [familyId].
  Future<String?> joinFamily(String code) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      return await requestJoinFamily(code);
    } catch (e) {
      // ignore: avoid_print
      print('JOIN FAMILY ERROR: $e');
      rethrow;
    }
  }

  Stream<List<FamilyMemberModel>> membersStream(String familyId) {
    return _firestore
        .collection('family_members')
        .where('familyId', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FamilyMemberModel.fromFirestore(doc))
            .where((m) => m.status == 'active')
            .toList());
  }

  static String buildWifiJoinUri(String sessionId) =>
      'elderlycare://family-wifi-join?s=$sessionId';

  /// Admin: create a 5-minute QR session tied to current Wi-Fi SSID.
  Future<Map<String, dynamic>> createWifiJoinSession(String familyId) async {
    final admin = _auth.currentUser;
    if (admin == null) throw Exception('not_signed_in');

    final fam = await _firestore.collection('families').doc(familyId).get();
    if (!fam.exists) throw Exception('invalid_code');
    final adminUid = fam.data()?['adminUid'] ?? fam.data()?['ownerId'];
    if (adminUid != admin.uid) throw Exception('not_admin');

    final adminUserRef = _firestore.collection('users').doc(admin.uid);
    final adminUserSnap = await adminUserRef.get();
    final lastQr = adminUserSnap.data()?['lastWifiQrCreatedAt'];
    if (lastQr != null) {
      final last = _asDateTime(lastQr);
      if (DateTime.now().difference(last) < const Duration(minutes: 1)) {
        throw Exception('qr_refresh_cooldown');
      }
    }

    final network = await WifiNetworkService.instance.getCurrentNetwork();
    if (!network.isValid) throw Exception('wifi_unavailable');

    final expires = DateTime.now().add(const Duration(minutes: 5));
    final docRef = _firestore.collection('family_wifi_join_sessions').doc();

    await docRef.set({
      'familyId': familyId,
      'adminUid': admin.uid,
      'networkId': network.ssidFingerprint,
      'bssidId': network.bssidFingerprint ?? '',
      'networkLabel': network.ssid.isNotEmpty ? network.ssid : 'Wi-Fi',
      'status': 'active',
      'expiresAt': Timestamp.fromDate(expires),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await adminUserRef.set({
      'lastWifiQrCreatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final sessionId = docRef.id;
    return {
      'sessionId': sessionId,
      'uri': buildWifiJoinUri(sessionId),
      'networkLabel': network.ssid.isNotEmpty ? network.ssid : 'Wi-Fi',
      'expiresAt': expires,
    };
  }

  /// Member: join immediately when on the same Wi-Fi as the admin QR session.
  Future<String> joinFamilyViaWifiSession(String sessionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('not_signed_in');

    final network = await WifiNetworkService.instance.getCurrentNetwork();
    if (!network.isValid) throw Exception('wifi_unavailable');

    final sessionRef =
        _firestore.collection('family_wifi_join_sessions').doc(sessionId.trim());

    final sessionSnap = await sessionRef.get();
    if (!sessionSnap.exists) throw Exception('invalid_session');

    final data = sessionSnap.data()!;
    if (data['status'] != 'active') throw Exception('session_used');

    final exp = _asDateTime(data['expiresAt']);
    if (DateTime.now().isAfter(exp)) throw Exception('session_expired');

    if (!WifiMatchHelper.matches(
      sessionSsidFp: data['networkId'] as String?,
      sessionBssidFp: data['bssidId'] as String?,
      member: network,
    )) {
      throw Exception('wifi_mismatch');
    }

    final familyId = data['familyId'] as String;
    final adminUid = data['adminUid'] as String;
    if (user.uid == adminUid) throw Exception('cannot_join_own_family');

    await _ensureSingleFamilyMembership(user.uid, exceptFamilyId: familyId);

    final existingMember = await _firestore
        .collection('family_members')
        .where('familyId', isEqualTo: familyId)
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (existingMember.docs.isNotEmpty) throw Exception('already_member');

    final fam = await _firestore.collection('families').doc(familyId).get();
    if (!fam.exists) throw Exception('invalid_session');
    final joinCode = fam.data()?['joinCode'] as String? ?? '';

    final memberRef = _firestore.collection('family_members').doc();
    final userRef = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((tx) async {
      final freshSession = await tx.get(sessionRef);
      if (!freshSession.exists) throw Exception('invalid_session');
      final fresh = freshSession.data()!;
      if (fresh['status'] != 'active') throw Exception('session_used');
      final freshExp = _asDateTime(fresh['expiresAt']);
      if (DateTime.now().isAfter(freshExp)) throw Exception('session_expired');
      if (!WifiMatchHelper.matches(
        sessionSsidFp: fresh['networkId'] as String?,
        sessionBssidFp: fresh['bssidId'] as String?,
        member: network,
      )) {
        throw Exception('wifi_mismatch');
      }

      tx.update(sessionRef, {
        'status': 'used',
        'usedByUid': user.uid,
        'usedAt': FieldValue.serverTimestamp(),
      });

      tx.set(memberRef, {
        'familyId': familyId,
        'userId': user.uid,
        'role': 'member',
        'status': 'active',
        'email': user.email,
        'displayName': user.displayName ?? user.email ?? '',
        'joinedVia': 'wifi_qr',
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.set(
        userRef,
        {
          'familyId': familyId,
          'familyCode': joinCode,
        },
        SetOptions(merge: true),
      );
    });

    return familyId;
  }

  /// Admin removes a non-admin member from the family.
  Future<void> removeFamilyMember(String familyId, String memberUserId) async {
    final admin = _auth.currentUser;
    if (admin == null) throw Exception('not_signed_in');

    final fam = await _firestore.collection('families').doc(familyId).get();
    if (!fam.exists) throw Exception('invalid_code');
    final adminUid = fam.data()?['adminUid'] ?? fam.data()?['ownerId'];
    if (adminUid != admin.uid) throw Exception('not_admin');
    if (memberUserId == adminUid) throw Exception('cannot_remove_admin');

    final memberQ = await _firestore
        .collection('family_members')
        .where('familyId', isEqualTo: familyId)
        .where('userId', isEqualTo: memberUserId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (memberQ.docs.isEmpty) throw Exception('member_not_found');

    final memberDoc = memberQ.docs.first;
    if ((memberDoc.data()['role'] as String?) == 'admin') {
      throw Exception('cannot_remove_admin');
    }

    await _firestore.runTransaction((tx) async {
      tx.update(memberDoc.reference, {
        'status': 'removed',
        'removedAt': FieldValue.serverTimestamp(),
        'removedBy': admin.uid,
      });
      tx.set(
        _firestore.collection('users').doc(memberUserId),
        {
          'familyId': FieldValue.delete(),
          'familyCode': FieldValue.delete(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<String?> getInviteCode(String familyId) async {
    try {
      final fam = await _firestore.collection('families').doc(familyId).get();
      final jc = fam.data()?['joinCode'] as String?;
      if (jc != null && jc.isNotEmpty) return jc;

      final query = await _firestore
          .collection('invites')
          .where('familyId', isEqualTo: familyId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return query.docs.first.data()['code'] as String?;
    } catch (e) {
      // ignore: avoid_print
      print('GET INVITE ERROR: $e');
      return null;
    }
  }
}
