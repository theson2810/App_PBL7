import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chip_model.dart';

class ChipRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Pi gọi khi khởi động
  Future<void> registerChip(String serial) async {
    final query =
        await _db.collection('chips').where('serial', isEqualTo: serial).get();

    if (query.docs.isEmpty) {
      await _db.collection('chips').add({
        'serial': serial,
        'status': 'pending',
        'familyId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Admin link chip với family
  Future<bool> linkChip(String serial, String familyId, String name) async {
    final query =
        await _db.collection('chips').where('serial', isEqualTo: serial).get();

    if (query.docs.isEmpty) return false;

    final docId = query.docs.first.id;

    await _db.collection('chips').doc(docId).update({
      'familyId': familyId,
      'name': name,
      'status': 'offline',
    });

    return true;
  }

  // Chips trong family
  Stream<List<ChipModel>> getChips(String familyId) {
    return _db
        .collection('chips')
        .where('familyId', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((e) => ChipModel.fromFirestore(e)).toList());
  }

  // Chip pending
  Stream<List<ChipModel>> getPendingChips() {
    return _db
        .collection('chips')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((e) => ChipModel.fromFirestore(e)).toList());
  }

  // Update status (online/offline)
  Future<void> updateStatus(String chipId, String status) async {
    await _db.collection('chips').doc(chipId).update({
      'status': status,
    });
  }
}
