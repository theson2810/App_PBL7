import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/camera_model.dart';

class CameraRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ADD CAMERA (gắn vào CHIP)
  Future<String?> addCamera(String familyId, String chipId, String name) async {
    try {
      final doc = await _db.collection('cameras').add({
        'familyId': familyId,
        'chipId': chipId,
        'name': name,
        'status': 'offline',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return doc.id;
    } catch (e) {
      print("ADD CAMERA ERROR: $e");
      return null;
    }
  }

  // GET CAMERAS THEO FAMILY (REALTIME)
  Stream<List<CameraModel>> getCameras(String familyId) {
    return _db
        .collection('cameras')
        .where('familyId', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CameraModel.fromFirestore(doc))
            .toList());
  }

  // GET CAMERAS THEO CHIP (REALTIME)
  Stream<List<CameraModel>> getCamerasByChip(String chipId) {
    return _db
        .collection('cameras')
        .where('chipId', isEqualTo: chipId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CameraModel.fromFirestore(doc))
            .toList());
  }

  // GET SINGLE CAMERA
  Future<CameraModel?> getCameraById(String cameraId) async {
    try {
      final doc = await _db.collection('cameras').doc(cameraId).get();

      if (!doc.exists) return null;

      return CameraModel.fromFirestore(doc);
    } catch (e) {
      print("GET CAMERA ERROR: $e");
      return null;
    }
  }

  // UPDATE CAMERA STATUS
  Future<void> updateCameraStatus(String cameraId, String status) async {
    try {
      await _db.collection('cameras').doc(cameraId).update({
        'status': status, // online | offline
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("UPDATE CAMERA ERROR: $e");
    }
  }

  // DELETE CAMERA
  Future<void> deleteCamera(String cameraId) async {
    try {
      await _db.collection('cameras').doc(cameraId).delete();
    } catch (e) {
      print("DELETE CAMERA ERROR: $e");
    }
  }
}
