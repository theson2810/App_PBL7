import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/auth_models.dart';
import 'device_session_service.dart';

/// AuthService maps UI flows to Firebase Auth + Firestore `users/{uid}`.
class AuthService {
  final _auth = FirebaseAuth.instance;

  DateTime _asDateTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  UserType _asUserType(String? s) {
    final v = (s ?? '').toLowerCase();
    return v == 'admin' ? UserType.admin : UserType.familyMember;
  }

  AccountStatus _asStatus(String? s) {
    final v = (s ?? '').toLowerCase();
    if (v == 'inactive') return AccountStatus.inactive;
    if (v == 'suspended') return AccountStatus.suspended;
    if (v == 'pending') return AccountStatus.pending;
    return AccountStatus.active;
  }

  Future<UserAccount?> _userFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data();
    if (data == null) return null;

    return UserAccount(
      id: doc.id,
      email: (data['email'] ?? '') as String,
      fullName: (data['fullName'] ?? (data['email'] ?? '')) as String,
      password: (data['password'] ?? '') as String,
      userType: _asUserType(data['userType'] as String?),
      status: _asStatus(data['status'] as String?),
      phone: data['phone'] as String?,
      avatar: data['avatar'] as String?,
      createdAt: _asDateTime(data['createdAt']),
      lastLogin: _asDateTime(data['lastLogin']),
      assignedPatients: (data['assignedPatients'] as List<dynamic>?)?.cast<String>(),
      assignedCaregivers: (data['assignedCaregivers'] as List<dynamic>?)?.cast<String>(),
      metadata: data['metadata'] as Map<String, dynamic>?,
      emailVerified: (data['emailVerified'] ?? false) as bool,
      verificationCode: data['verificationCode'] as String?,
      verificationCodeExpiry: data['verificationCodeExpiry'] != null
          ? _asDateTime(data['verificationCodeExpiry'])
          : null,
      resetCode: data['resetCode'] as String?,
      resetCodeExpiry: data['resetCodeExpiry'] != null
          ? _asDateTime(data['resetCodeExpiry'])
          : null,
      familyCode: data['familyCode'] as String?,
      familyId: data['familyId'] as String?,
    );
  }

  Future<UserAccount?> loadSavedUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;
    await fbUser.reload();
    final refreshedFbUser = _auth.currentUser;
    if (refreshedFbUser == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(refreshedFbUser.uid).get();
    if (!doc.exists) return null;

    final data = doc.data() ?? {};
    final firebaseVerified = refreshedFbUser.emailVerified;
    final firestoreVerified = (data['emailVerified'] ?? false) == true;

    if (firebaseVerified && !firestoreVerified) {
      await FirebaseFirestore.instance.collection('users').doc(refreshedFbUser.uid).set({
        'emailVerified': true,
      }, SetOptions(merge: true));
    }

    final latest = await FirebaseFirestore.instance.collection('users').doc(refreshedFbUser.uid).get();
    final account = await _userFromDoc(latest);
    if (account == null) return null;

    if (account.emailVerified) {
      final sessionOk =
          await DeviceSessionService.instance.verifyLocalSession(account.id);
      if (!sessionOk) {
        DeviceSessionService.instance.stopWatching();
        await _auth.signOut();
        return null;
      }
    }

    await refreshedFbUser.reload();
    final firebaseVerifiedNow = _auth.currentUser?.emailVerified ?? false;
    return account.copyWith(emailVerified: account.emailVerified || firebaseVerifiedNow);
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final fbUserCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = fbUserCred.user;
      if (fbUser == null) {
        return const AuthResponse(success: false, error: 'Login failed');
      }
      await fbUser.reload();
      final isEmailVerified = _auth.currentUser?.emailVerified ?? false;

      final doc = await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).get();
      final now = DateTime.now();
      final docData = doc.data();
      final firestoreVerified = (docData?['emailVerified'] ?? false) == true;
      final mergedVerified = firestoreVerified || isEmailVerified;

      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set({
          'email': email,
          'fullName': email,
          'userType': 'familyMember',
          'status': 'active',
          'createdAt': now,
          'lastLogin': now,
          'emailVerified': mergedVerified,
          'fcmToken': null,
        }, SetOptions(merge: true));
      } else {
        await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set({
          'lastLogin': now,
          'emailVerified': mergedVerified,
        }, SetOptions(merge: true));
      }

      final refreshed = await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).get();
      final userAccount = await _userFromDoc(refreshed);

      if (userAccount != null && userAccount.emailVerified) {
        await DeviceSessionService.instance.registerActiveSession(fbUser.uid);
      }

      return AuthResponse(success: true, user: userAccount, error: null);
    } catch (e) {
      return AuthResponse(success: false, error: e.toString());
    }
  }

  Future<AuthResponse> register(RegistrationRequest request) async {
    User? created;
    var profileWritten = false;
    try {
      final fbUserCred = await _auth
          .createUserWithEmailAndPassword(
            email: request.email,
            password: request.password,
          )
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () => throw TimeoutException(
              'Tạo tài khoản quá lâu. Kiểm tra mạng / VPN / Google Play Services trên máy ảo.',
            ),
          );

      created = fbUserCred.user;
      if (created == null) {
        return const AuthResponse(success: false, error: 'Đăng ký thất bại (user null).');
      }
      if (kDebugMode) {
        debugPrint('AuthService.register: Firebase user OK uid=${created.uid}');
      }

      final now = DateTime.now();
      final userTypeStr = request.userType.toLowerCase();
      final statusStr = 'active';

      await FirebaseFirestore.instance.collection('users').doc(created.uid).set({
        'email': request.email,
        'fullName': request.fullName,
        'userType': userTypeStr,
        'status': statusStr,
        'phone': request.phone,
        'createdAt': now,
        'lastLogin': now,
        'emailVerified': false,
        'verificationCode': null,
        'verificationCodeExpiry': null,
        'resetCode': null,
        'resetCodeExpiry': null,
        'fcmToken': null,
        'familyId': null,
        'familyCode': null,
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(
          'Ghi hồ sơ Firestore quá lâu. Kiểm tra mạng và quy tắc Firestore.',
        ),
      );
      profileWritten = true;

      if (kDebugMode) {
        debugPrint('AuthService.register: Firestore users/${created.uid} OK');
      }

      try {
        await created.sendEmailVerification().timeout(
          const Duration(seconds: 40),
          onTimeout: () => throw TimeoutException('sendEmailVerification'),
        );
        if (kDebugMode) {
          debugPrint('AuthService.register: sendEmailVerification OK');
        }
      } on TimeoutException catch (_) {
        if (kDebugMode) {
          debugPrint(
            'AuthService.register: sendEmailVerification timeout — tài khoản đã tạo; dùng "Gửi lại email" trên màn xác thực.',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('AuthService.register: sendEmailVerification error (bỏ qua): $e');
        }
      }

      final account = UserAccount(
        id: created.uid,
        email: request.email,
        fullName: request.fullName,
        password: request.password,
        userType: _asUserType(userTypeStr),
        status: _asStatus(statusStr),
        phone: request.phone,
        createdAt: now,
        lastLogin: now,
        emailVerified: false,
        verificationCode: null,
        verificationCodeExpiry: null,
        resetCode: null,
        resetCodeExpiry: null,
      );

      return AuthResponse(success: true, user: account);
    } on FirebaseAuthException catch (e) {
      return AuthResponse(
        success: false,
        error: e.message ?? e.code,
      );
    } on TimeoutException catch (e) {
      return AuthResponse(success: false, error: e.message ?? e.toString());
    } catch (e) {
      if (created != null && !profileWritten) {
        try {
          await created.delete();
        } catch (_) {}
      }
      return AuthResponse(success: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await DeviceSessionService.instance.releaseSession(uid);
    }
    DeviceSessionService.instance.stopWatching();
    await _auth.signOut();
  }

  /// Sends Firebase Auth password reset email (link in inbox).
  Future<AuthResponse> requestPasswordReset(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return const AuthResponse(success: false, error: 'Email is required');
    }
    try {
      await _auth.sendPasswordResetEmail(email: trimmed);
      return const AuthResponse(
        success: true,
        message: 'Password reset email sent',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return const AuthResponse(
          success: true,
          message: 'If the account exists, a reset email was sent',
        );
      }
      return AuthResponse(success: false, error: e.message ?? e.code);
    } catch (e) {
      return AuthResponse(success: false, error: e.toString());
    }
  }

  /// Confirms email only after user opens the link in the Gmail / Firebase verification email.
  Future<AuthResponse> verifyEmail(String email, String code) async {
    try {
      final fbUser = _auth.currentUser;
      if (fbUser == null) {
        return const AuthResponse(success: false, error: 'No active session');
      }
      await fbUser.reload();
      final refreshed = _auth.currentUser;
      if (refreshed == null) return const AuthResponse(success: false, error: 'No active session');

      if (!refreshed.emailVerified) {
        return const AuthResponse(
          success: false,
          error: 'Email chưa được xác thực. Mở hộp thư, bấm liên kết trong email Firebase, rồi thử lại.',
        );
      }

      final docRef = FirebaseFirestore.instance.collection('users').doc(refreshed.uid);
      await docRef.set({
        'emailVerified': true,
        'verificationCode': null,
        'verificationCodeExpiry': null,
      }, SetOptions(merge: true));

      final refreshedDoc = await docRef.get();
      final refreshedUser = await _userFromDoc(refreshedDoc);
      if (refreshedUser == null) {
        return const AuthResponse(
          success: false,
          error: 'Không tìm thấy hồ sơ người dùng. Thử đăng nhập lại hoặc liên hệ hỗ trợ.',
        );
      }

      return AuthResponse(success: true, user: refreshedUser);
    } catch (e) {
      return AuthResponse(success: false, error: e.toString());
    }
  }

  Future<AuthResponse> resendVerificationCode(String email) async {
    try {
      final fbUser = _auth.currentUser;
      if (fbUser == null) {
        return const AuthResponse(success: false, error: 'No active session');
      }
      final currentEmail = fbUser.email;
      if (currentEmail == null || currentEmail.toLowerCase() != email.toLowerCase()) {
        return const AuthResponse(success: false, error: 'Email does not match current user');
      }

      await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set({
        'verificationCode': null,
        'verificationCodeExpiry': null,
      }, SetOptions(merge: true));

      await fbUser.sendEmailVerification().timeout(
        const Duration(seconds: 40),
        onTimeout: () => throw TimeoutException('sendEmailVerification'),
      );

      return const AuthResponse(
        success: true,
        message: 'Verification email resent',
      );
    } on TimeoutException catch (_) {
      return const AuthResponse(
        success: false,
        error: 'Gửi email quá lâu. Kiểm tra mạng và thử lại.',
      );
    } catch (e) {
      return AuthResponse(success: false, error: e.toString());
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      var result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'email': email,
          'createdAt': DateTime.now(),
          'fcmToken': null,
        });
      }

      return user;
    } catch (e) {
      // ignore: avoid_print
      print('SIGNUP ERROR: $e');
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      var result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } catch (e) {
      // ignore: avoid_print
      print('LOGIN ERROR: $e');
      return null;
    }
  }

  User? getCurrentUser() => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Reloads profile from Firestore after family changes.
  Future<UserAccount?> refreshCurrentUserProfile() async {
    final fb = _auth.currentUser;
    if (fb == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(fb.uid).get();
    if (!doc.exists) return null;
    return _userFromDoc(doc);
  }

  /// Updates display name and phone on Firestore user profile.
  Future<AuthResponse> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final trimmedName = fullName.trim();
    if (trimmedName.isEmpty) {
      return const AuthResponse(success: false, error: 'Full name is required');
    }

    final fb = _auth.currentUser;
    if (fb == null) {
      return const AuthResponse(success: false, error: 'No active session');
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(fb.uid).set({
        'fullName': trimmedName,
        if (phone != null) 'phone': phone.trim().isEmpty ? null : phone.trim(),
        if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar': avatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      try {
        await fb.updateDisplayName(trimmedName);
      } catch (_) {}

      final user = await refreshCurrentUserProfile();
      if (user == null) {
        return const AuthResponse(success: false, error: 'Profile not found');
      }
      return AuthResponse(success: true, user: user, message: 'Profile updated');
    } on FirebaseException catch (e) {
      return AuthResponse(success: false, error: e.message ?? e.code);
    } catch (e) {
      return AuthResponse(success: false, error: e.toString());
    }
  }
}
