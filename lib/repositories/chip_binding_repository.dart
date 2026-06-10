import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChipBindingRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>?> watchFamilyChip(
    String familyId,
  ) {
    return _db.collection('families').doc(familyId).snapshots().asyncMap(
      (familyDoc) async {
        final chipId = familyDoc.data()?['boundChipId'] as String?;
        if (chipId == null || chipId.trim().isEmpty) return null;
        return _db.collection('chips').doc(chipId.trim()).get();
      },
    );
  }

  Future<String?> getBoundChipId(String familyId) async {
    final doc = await _db.collection('families').doc(familyId).get();
    return (doc.data()?['boundChipId'] as String?)?.trim();
  }

  Future<void> bindChipToFamily({
    required String familyId,
    required String chipId,
  }) async {
    final admin = _auth.currentUser;
    if (admin == null) throw Exception('not_signed_in');

    final normalizedChipId = chipId.trim();
    if (normalizedChipId.isEmpty) throw Exception('chip_id_required');

    final familyRef = _db.collection('families').doc(familyId);
    final chipRef = _db.collection('chips').doc(normalizedChipId);

    await _db.runTransaction((tx) async {
      final familySnap = await tx.get(familyRef);
      if (!familySnap.exists) throw Exception('family_not_found');

      final family = familySnap.data()!;
      final adminUid = family['adminUid'] ?? family['ownerId'];
      if (adminUid != admin.uid) throw Exception('not_admin');

      final currentFamilyChip = (family['boundChipId'] as String?)?.trim();

      final chipSnap = await tx.get(chipRef);
      if (!chipSnap.exists) {
        throw Exception('chip_not_registered');
      }

      final chipAuthUid = (chipSnap.data()?['chipAuthUid'] as String?)?.trim();
      if (chipAuthUid == null || chipAuthUid.isEmpty) {
        throw Exception('chip_not_registered');
      }

      final chipFamilyId = (chipSnap.data()?['familyId'] as String?)?.trim();
      if (chipFamilyId != null &&
          chipFamilyId.isNotEmpty &&
          chipFamilyId != familyId) {
        throw Exception('chip_already_bound');
      }

      tx.set(
        familyRef,
        {
          'boundChipId': normalizedChipId,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      tx.set(
        chipRef,
        {
          'chipId': normalizedChipId,
          'familyId': familyId,
          'boundByUid': admin.uid,
          'status': 'bound',
          'boundAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (currentFamilyChip != null &&
          currentFamilyChip.isNotEmpty &&
          currentFamilyChip != normalizedChipId) {
        tx.set(
          _db.collection('chips').doc(currentFamilyChip),
          {
            'familyId': FieldValue.delete(),
            'status': 'replaced',
            'replacedByChipId': normalizedChipId,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    });

    final cameras = await _db
        .collection('cameras')
        .where('familyId', isEqualTo: familyId)
        .get();
    if (cameras.docs.isNotEmpty) {
      final batch = _db.batch();
      for (final camera in cameras.docs) {
        batch.update(camera.reference, {
          'chipId': normalizedChipId,
          'status': 'offline',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }

  Future<void> unbindChipFromFamily(String familyId) async {
    final admin = _auth.currentUser;
    if (admin == null) throw Exception('not_signed_in');

    final familyRef = _db.collection('families').doc(familyId);

    await _db.runTransaction((tx) async {
      final familySnap = await tx.get(familyRef);
      if (!familySnap.exists) throw Exception('family_not_found');

      final family = familySnap.data()!;
      final adminUid = family['adminUid'] ?? family['ownerId'];
      if (adminUid != admin.uid) throw Exception('not_admin');

      final chipId = (family['boundChipId'] as String?)?.trim();
      if (chipId == null || chipId.isEmpty) return;

      tx.update(familyRef, {
        'boundChipId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.set(
        _db.collection('chips').doc(chipId),
        {
          'familyId': FieldValue.delete(),
          'status': 'unbound',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    final cameras = await _db
        .collection('cameras')
        .where('familyId', isEqualTo: familyId)
        .get();
    if (cameras.docs.isNotEmpty) {
      final batch = _db.batch();
      for (final camera in cameras.docs) {
        batch.update(camera.reference, {
          'chipId': '',
          'status': 'offline',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }
}
