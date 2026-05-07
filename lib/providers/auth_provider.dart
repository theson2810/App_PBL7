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
  String? _pendingVerificationEmail; // Track email waiting for verification
  String? _testVerificationCode; // For testing - stores the verification code

  // Getters
  UserAccount? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String? get pendingVerificationEmail => _pendingVerificationEmail;
  String? get testVerificationCode => _testVerificationCode; // For testing
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
        _isAuthenticated = true;
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
        _isAuthenticated = true;
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
      final response = await _authService.register(request);

      if (response.success) {
        _user = response.user;
        _isAuthenticated = false; // NOT authenticated yet - waiting for email verification
        _pendingVerificationEmail = request.email; // Store email for verification
        _testVerificationCode = _user?.verificationCode; // Store code for testing
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Registration failed';
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

  // ─── Logout ────────────────────────────────────────────
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // ─── Clear Error ──────────────────────────────────────
  void clearError() {
    _error = null;
    notifyListeners();
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
        _pendingVerificationEmail = null; // Clear pending email
        _testVerificationCode = null; // Clear test code
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

  // ─── Verify Password Reset Code ────────────────────────
  Future<bool> verifyPasswordResetCode(String email, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.verifyPasswordResetCode(email, code);

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Password reset code verification failed';
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

  // ─── Reset Password ────────────────────────────────────
  Future<bool> resetPassword(String email, String code, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(email, code, newPassword);

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Password reset failed';
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
