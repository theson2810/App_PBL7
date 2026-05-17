import 'dart:async';

import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

/// Authentication Provider
/// Manages authentication state and notifies listeners of changes
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // State
  UserAccount? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  String? _pendingVerificationEmail;

  UserAccount? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String? get pendingVerificationEmail => _pendingVerificationEmail;
  AuthService get authService => _authService;

  // ─── Initialize Saved User (Persistent Login) ────────
  /// Check and restore saved user session on app startup
  Future<bool> initializeSavedUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedUser = await _authService.loadSavedUser();
      
      if (savedUser != null) {
        _user = savedUser;
        _isAuthenticated = savedUser.emailVerified;
        // Nếu đã đăng nhập Firebase nhưng chưa xác thực email, đưa lại vào luồng xác thực.
        _pendingVerificationEmail =
            savedUser.emailVerified ? null : (savedUser.email.isNotEmpty ? savedUser.email : null);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Login ────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);

      if (response.success) {
        _user = response.user;
        final verified = response.user?.emailVerified ?? false;
        _isAuthenticated = verified;
        _pendingVerificationEmail = verified
            ? null
            : ((response.user?.email ?? '').isNotEmpty ? response.user!.email : null);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Register ─────────────────────────────────────────
  Future<bool> register(RegistrationRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(request).timeout(
        const Duration(seconds: 90),
        onTimeout: () => const AuthResponse(
          success: false,
          error:
              'Hết thời gian chờ (90s). Kiểm tra mạng, Stop app rồi Run lại, hoặc thử máy thật.',
        ),
      );

      if (response.success) {
        _user = response.user;
        _isAuthenticated = false;
        _pendingVerificationEmail = request.email;
        return true;
      } else {
        _error = response.error ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Logout ────────────────────────────────────────────
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    _error = null;
    _pendingVerificationEmail = null;
    _isLoading = false;
    notifyListeners();
  }

  // ─── Clear Error ──────────────────────────────────────
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reload Firestore user profile (e.g. after family join).
  Future<void> refreshUserProfile() async {
    final u = await _authService.refreshCurrentUserProfile();
    if (u != null) {
      _user = u;
      _isAuthenticated = u.emailVerified;
      notifyListeners();
    }
  }

  // ─── Request Password Reset ───────────────────────────
  Future<bool> requestPasswordReset(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.requestPasswordReset(email);

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Password reset request failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Verify Email ─────────────────────────────────────
  Future<bool> verifyEmail(String email, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.verifyEmail(email, code);

      if (response.success) {
        _user = response.user;
        _isAuthenticated = true; // Now authenticated after email verification
        _pendingVerificationEmail = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Email verification failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Resend Verification Code ──────────────────────────
  Future<bool> resendVerificationCode(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.resendVerificationCode(email);

      if (response.success) {
        _isLoading = false;
        final u = await _authService.refreshCurrentUserProfile();
        if (u != null) {
          _user = u;
        }
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to resend verification code';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
