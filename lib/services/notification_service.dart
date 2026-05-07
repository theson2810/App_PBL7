import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final _messaging = FirebaseMessaging.instance;

  Future<void> initFCM() async {
    await _messaging.requestPermission();

    String? token = await _messaging.getToken();

    if (token != null) {
      await saveDeviceToken(token);
    }

    FirebaseMessaging.onMessage.listen((message) {
      print("NOTI: ${message.notification?.title}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("OPENED APP FROM NOTI");
    });
  }

  Future<void> saveDeviceToken(String token) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'fcmToken': token});
  }
}