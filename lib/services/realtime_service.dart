import 'package:cloud_firestore/cloud_firestore.dart';

class RealtimeService {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> listenCameras(String familyId) {
    return _db
        .collection('cameras')
        .where('familyId', isEqualTo: familyId)
        .snapshots();
  }

  Stream<QuerySnapshot> listenAlerts(String familyId) {
    return _db
        .collection('alerts')
        .where('familyId', isEqualTo: familyId)
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  Stream<QuerySnapshot> listenSessions(String cameraId) {
    return _db
        .collection('sessions')
        .where('cameraId', isEqualTo: cameraId)
        .where('status', isEqualTo: 'waiting')
        .snapshots();
  }
}