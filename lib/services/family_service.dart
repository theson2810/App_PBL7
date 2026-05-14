import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/family_member_model.dart';

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
            .toList());
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
