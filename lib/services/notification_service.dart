import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final _messaging = FirebaseMessaging.instance;

  Future<void> initFCM() async {
    await _messaging.requestPermission();

    final token = await _messaging.getToken();
    if (token != null) {
      await saveDeviceToken(token);
    }

    _messaging.onTokenRefresh.listen(saveDeviceToken);

    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'Elderly Care Monitor';
      final body = message.notification?.body ?? '';
      // ignore: avoid_print
      print('FCM foreground: $title — $body');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // ignore: avoid_print
      print('FCM opened: ${message.data}');
    });
  }

  Future<void> saveDeviceToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }
}