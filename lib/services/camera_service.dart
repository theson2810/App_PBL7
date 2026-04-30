import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/camera_model.dart';

class CameraService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String?> addCamera(String familyId, String name) async {
    try {
      String userId = _auth.currentUser!.uid;

      DocumentReference doc = await _db.collection('cameras').add({
        'name': name,
        'familyId': familyId,
        'serverUserId': userId,
        'status': 'online',
        'createdAt': DateTime.now(),
      });

      return doc.id;
    } catch (e) {
      print("ADD CAMERA ERROR: $e");
      return null;
    }
  }

  // NEW: trả về model
  Stream<List<CameraModel>> getCameras(String familyId) {
    return _db
        .collection('cameras')
        .where('familyId', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CameraModel.fromFirestore(doc)).toList());
  }

  Future<void> updateStatus(String cameraId, String status) async {
    await _db.collection('cameras').doc(cameraId).update({
      'status': status,
    });
  }
}