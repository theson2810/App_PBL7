import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/session_model.dart';

class SessionService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String?> createSession(String cameraId) async {
    try {
      String userId = _auth.currentUser!.uid;

      DocumentReference doc = await _db.collection('sessions').add({
        'cameraId': cameraId,
        'viewerId': userId,
        'status': 'waiting',
        'createdAt': DateTime.now(),
      });

      return doc.id;
    } catch (e) {
      print("CREATE SESSION ERROR: $e");
      return null;
    }
  }

  // dùng model
  Stream<List<SessionModel>> listenSessions() {
    return _db
        .collection('sessions')
        .where('status', isEqualTo: 'waiting')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SessionModel.fromFirestore(doc)).toList());
  }

  Future<void> sendOffer(String sessionId, String sdp) async {
    await _db.collection('webrtc_signals').add({
      'sessionId': sessionId,
      'type': 'offer',
      'data': sdp,
      'sender': _auth.currentUser!.uid,
      'createdAt': DateTime.now(),
    });
  }

  Future<void> sendAnswer(String sessionId, String sdp) async {
    await _db.collection('webrtc_signals').add({
      'sessionId': sessionId,
      'type': 'answer',
      'data': sdp,
      'sender': _auth.currentUser!.uid,
      'createdAt': DateTime.now(),
    });
  }

  Future<void> sendIce(String sessionId, String candidate) async {
    await _db.collection('webrtc_signals').add({
      'sessionId': sessionId,
      'type': 'ice',
      'data': candidate,
      'sender': _auth.currentUser!.uid,
      'createdAt': DateTime.now(),
    });
  }

  Stream<QuerySnapshot> listenSignals(String sessionId) {
    return _db
        .collection('webrtc_signals')
        .where('sessionId', isEqualTo: sessionId)
        .snapshots();
  }

  Future<void> updateStatus(String sessionId, String status) async {
    await _db.collection('sessions').doc(sessionId).update({
      'status': status,
    });
  }
}