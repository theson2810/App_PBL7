import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';

class AlertService {
  final _db = FirebaseFirestore.instance;

  Future<void> sendFallAlert(String familyId, String cameraId) async {
    await _db.collection('alerts').add({
      'familyId': familyId,
      'cameraId': cameraId,
      'type': 'fall',
      'message': 'Fall detected',
      'status': 'active',
      'createdAt': DateTime.now(),
    });
  }

  // model
  Stream<List<AlertModel>> listenAlerts(String familyId) {
    return _db
        .collection('alerts')
        .where('familyId', isEqualTo: familyId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList());
  }

  Future<void> resolveAlert(String alertId) async {
    await _db.collection('alerts').doc(alertId).update({
      'status': 'resolved',
    });
  }
}