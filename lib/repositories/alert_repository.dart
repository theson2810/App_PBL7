import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';

class AlertRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // SEND FALL ALERT=
  Future<void> sendFallAlert(String familyId, String cameraId) async {
    await _db.collection('alerts').add({
      'familyId': familyId,
      'cameraId': cameraId,
      'type': 'fall',
      'message': 'Fall-type alert recorded',
      'status': 'active', // active | resolved
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // LISTEN ALERTS REALTIME
  Stream<List<AlertModel>> listenAlerts(String familyId) {
    return _db
        .collection('alerts')
        .where('familyId', isEqualTo: familyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList());
  }

  // RESOLVE ALERT
  Future<void> resolveAlert(String alertId) async {
    await _db.collection('alerts').doc(alertId).update({
      'status': 'resolved',
    });
  }
}
