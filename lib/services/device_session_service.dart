import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// One active login per account: `users/{uid}.activeDeviceId`.
class DeviceSessionService {
  DeviceSessionService._();

  static final DeviceSessionService instance = DeviceSessionService._();

  static const _kInstallDeviceId = 'install_device_id';

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? _cachedDeviceId;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;
  VoidCallback? _onKicked;

  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_kInstallDeviceId);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_kInstallDeviceId, id);
    }
    _cachedDeviceId = id;
    return id;
  }

  /// Registers this device as the sole active session for [uid].
  Future<void> registerActiveSession(String uid) async {
    final deviceId = await getDeviceId();
    await _firestore.collection('users').doc(uid).set({
      'activeDeviceId': deviceId,
      'activeDeviceUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Returns false if another device holds the active session.
  Future<bool> verifyLocalSession(String uid) async {
    final deviceId = await getDeviceId();
    final doc = await _firestore.collection('users').doc(uid).get();
    final active = doc.data()?['activeDeviceId'] as String?;
    if (active == null || active.isEmpty) return true;
    return active == deviceId;
  }

  void startWatching(String uid, {required VoidCallback onKicked}) {
    stopWatching();
    _onKicked = onKicked;
    _sub = _firestore.collection('users').doc(uid).snapshots().listen((snap) async {
      final active = snap.data()?['activeDeviceId'] as String?;
      if (active == null || active.isEmpty) return;
      final local = await getDeviceId();
      if (active != local) {
        _onKicked?.call();
      }
    });
  }

  void stopWatching() {
    _sub?.cancel();
    _sub = null;
    _onKicked = null;
  }

  Future<void> releaseSession(String uid) async {
    final deviceId = await getDeviceId();
    final ref = _firestore.collection('users').doc(uid);
    final doc = await ref.get();
    final active = doc.data()?['activeDeviceId'] as String?;
    if (active == deviceId) {
      await ref.set({
        'activeDeviceId': FieldValue.delete(),
        'activeDeviceUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
