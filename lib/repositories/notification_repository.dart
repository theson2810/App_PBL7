import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepository {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // INIT FCM
  Future<void> initFCM() async {
    await _fcm.requestPermission();

    FirebaseMessaging.onMessage.listen((message) {
      print("NOTIFICATION: ${message.notification?.title}");
    });
  }

  // SAVE TOKEN
  Future<void> saveToken(String userId) async {
    final token = await _fcm.getToken();

    if (token != null) {
      await _db.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }
}
