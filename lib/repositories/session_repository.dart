import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';

class SessionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CREATE SESSION
  Future<String?> createSession(String cameraId) async {
    try {
      final doc = await _db.collection('sessions').add({
        'cameraId': cameraId,
        'status': 'waiting', // waiting | active | ended
        'createdAt': FieldValue.serverTimestamp(),
      });

      return doc.id;
    } catch (e) {
      print("CREATE SESSION ERROR: $e");
      return null;
    }
  }

  // LISTEN SESSIONS (REALTIME)
  Stream<List<SessionModel>> listenSessions(String cameraId) {
    return _db
        .collection('sessions')
        .where('cameraId', isEqualTo: cameraId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }

  // SEND OFFER
  Future<void> sendOffer(String sessionId, String sdp) async {
    await _db.collection('sessions').doc(sessionId).collection('signals').add({
      'type': 'offer',
      'sdp': sdp,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // SEND ANSWER
  Future<void> sendAnswer(String sessionId, String sdp) async {
    await _db.collection('sessions').doc(sessionId).collection('signals').add({
      'type': 'answer',
      'sdp': sdp,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // SEND ICE CANDIDATE
  Future<void> sendIceCandidate(String sessionId, String candidate) async {
    await _db.collection('sessions').doc(sessionId).collection('signals').add({
      'type': 'ice',
      'candidate': candidate,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // LISTEN SIGNALS
  Stream<QuerySnapshot> listenSignals(String sessionId) {
    return _db
        .collection('sessions')
        .doc(sessionId)
        .collection('signals')
        .orderBy('createdAt')
        .snapshots();
  }

  // UPDATE SESSION STATUS
  Future<void> updateSessionStatus(String sessionId, String status) async {
    await _db.collection('sessions').doc(sessionId).update({
      'status': status,
    });
  }
}
