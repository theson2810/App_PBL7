import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

/// Email Service Helper
class EmailService {
  static final EmailService _instance = EmailService._internal();

  factory EmailService() {
    return _instance;
  }

  EmailService._internal();

  /// Generate a 6-digit verification code
  String generateVerificationCode() {
    return (Random().nextInt(900000) + 100000).toString();
  }

  /// Send verification email (Mock implementation)
  /// In production, use actual email service like SendGrid, Gmail API, etc.
  Future<bool> sendVerificationEmail({
    required String email,
    required String fullName,
    required String code,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock: In production, integrate with actual email service
      print('📧 Email sent to $email');
      print('Mã xác nhận: $code');
      print('Người nhận: $fullName');
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail({
    required String email,
    required String fullName,
    required String code,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock: In production, use actual email service
      print('📧 Email đặt lại mật khẩu sent to $email');
      print('Mã đặt lại: $code');
      print('Người nhận: $fullName');
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Authentication Service
/// Handles login, registration, session management, and email verification
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final EmailService _emailService = EmailService();

  // Simulated session storage
  UserAccount? _currentUser;
  String? _sessionToken;

  // ─── Getters ──────────────────────────────────────────
  UserAccount? get currentUser => _currentUser;
  String? get sessionToken => _sessionToken;
  bool get isAuthenticated => _currentUser != null && _sessionToken != null;

  // ─── Login ────────────────────────────────────────────
  /// Login with email and password
  /// Returns [AuthResponse] with success status and user data
  Future<AuthResponse> login(String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Mock authentication - check against mockUsers
      final user = mockUsers.firstWhere(
        (u) => u.email == email && u.password == password,
        orElse: () => throw Exception('Đăng nhập thất bại: Email hoặc mật khẩu không đúng'),
      );

      // Check if email is verified
      if (!user.emailVerified) {
        return AuthResponse(
          success: false,
          error: 'Email chưa được xác nhận. Vui lòng kiểm tra email của bạn để lấy mã xác nhận',
        );
      }

      if (user.status == AccountStatus.suspended) {
        return AuthResponse(
          success: false,
          error: 'Tài khoản đã bị khóa',
        );
      }

      // Generate mock token
      final token = _generateToken();
      _currentUser = user.copyWith(lastLogin: DateTime.now());
      _sessionToken = token;

      // Save user for persistent login
      await saveUser(_currentUser!, token);

      return AuthResponse(
        success: true,
        message: 'Đăng nhập thành công',
        user: _currentUser,
        token: token,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ─── Registration ─────────────────────────────────────
  /// Register a new account and send verification email
  /// Returns [AuthResponse] with verification pending status
  Future<AuthResponse> register(RegistrationRequest request) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Check if email already exists
      final existing = mockUsers.where((u) => u.email == request.email);
      if (existing.isNotEmpty) {
        return AuthResponse(
          success: false,
          error: 'Email đã được đăng ký',
        );
      }

      // Validate input
      if (request.fullName.isEmpty) {
        return AuthResponse(
          success: false,
          error: 'Tên đầy đủ không được để trống',
        );
      }

      if (request.password.length < 6) {
        return AuthResponse(
          success: false,
          error: 'Mật khẩu phải có ít nhất 6 ký tự',
        );
      }

      // Generate verification code
      final verificationCode = _emailService.generateVerificationCode();
      final verificationCodeExpiry = DateTime.now().add(const Duration(minutes: 10));

      // Create new user
      final userType = _stringToUserType(request.userType);
      final newUser = UserAccount(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: request.email,
        fullName: request.fullName,
        password: request.password, // In production, hash this!
        userType: userType,
        status: AccountStatus.pending, // Require email verification
        phone: request.phone,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        emailVerified: false,
        verificationCode: verificationCode,
        verificationCodeExpiry: verificationCodeExpiry,
        metadata: {
          if (request.organizationCode != null)
            'organizationCode': request.organizationCode,
        },
        familyCode: userType == UserType.admin ? generateFamilyCode() : null,
      );

      // Add to mock users (simulating database)
      mockUsers.add(newUser);

      // Send verification email
      await _emailService.sendVerificationEmail(
        email: request.email,
        fullName: request.fullName,
        code: verificationCode,
      );

      return AuthResponse(
        success: true,
        message: 'Đăng ký thành công! Vui lòng xác nhận email của bạn',
        user: newUser,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ─── Email Verification ────────────────────────────────
  /// Verify email with verification code
  Future<AuthResponse> verifyEmail(String email, String code) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      final userIndex = mockUsers.indexWhere((u) => u.email == email);
      if (userIndex == -1) {
        return AuthResponse(
          success: false,
          error: 'Email không tìm thấy',
        );
      }

      final user = mockUsers[userIndex];

      // Check if code matches
      if (user.verificationCode != code) {
        return AuthResponse(
          success: false,
          error: 'Mã xác nhận không đúng',
        );
      }

      // Check if code is expired
      if (user.verificationCodeExpiry != null &&
          DateTime.now().isAfter(user.verificationCodeExpiry!)) {
        return AuthResponse(
          success: false,
          error: 'Mã xác nhận đã hết hạn. Vui lòng yêu cầu mã mới',
        );
      }

      // Update user - mark email as verified
      final verifiedUser = user.copyWith(
        emailVerified: true,
        verificationCode: null,
        verificationCodeExpiry: null,
        status: AccountStatus.active,
      );

      mockUsers[userIndex] = verifiedUser;

      // Auto-login after email verification
      final token = _generateToken();
      _currentUser = verifiedUser;
      _sessionToken = token;

      // Save user for persistent login
      await saveUser(_currentUser!, token);

      return AuthResponse(
        success: true,
        message: 'Email đã được xác nhận thành công!',
        user: verifiedUser,
        token: token,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ─── Resend Verification Code ──────────────────────────
  /// Resend verification code to email
  Future<AuthResponse> resendVerificationCode(String email) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      final userIndex = mockUsers.indexWhere((u) => u.email == email);
      if (userIndex == -1) {
        return AuthResponse(
          success: false,
          error: 'Email không tìm thấy',
        );
      }

      final user = mockUsers[userIndex];

      if (user.emailVerified) {
        return AuthResponse(
          success: false,
          error: 'Email đã được xác nhận rồi',
        );
      }

      // Generate new verification code
      final newCode = _emailService.generateVerificationCode();
      final newExpiry = DateTime.now().add(const Duration(minutes: 10));

      final updatedUser = user.copyWith(
        verificationCode: newCode,
        verificationCodeExpiry: newExpiry,
      );

      mockUsers[userIndex] = updatedUser;

      // Send new verification email
      await _emailService.sendVerificationEmail(
        email: email,
        fullName: user.fullName,
        code: newCode,
      );

      return AuthResponse(
        success: true,
        message: 'Mã xác nhận mới đã được gửi tới email của bạn',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ─── Password Reset ────────────────────────────────────
  /// Request password reset - sends reset code to email
  Future<AuthResponse> requestPasswordReset(String email) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      final userIndex = mockUsers.indexWhere((u) => u.email == email);
      if (userIndex == -1) {
        return AuthResponse(
          success: false,
          error: 'Email không tìm thấy',
        );
      }

      final user = mockUsers[userIndex];

      // Generate reset code
      final resetCode = _emailService.generateVerificationCode();
      final resetCodeExpiry = DateTime.now().add(const Duration(minutes: 15));

      // Update user with reset code
      final updatedUser = user.copyWith(
        resetCode: resetCode,
        resetCodeExpiry: resetCodeExpiry,
      );

      mockUsers[userIndex] = updatedUser;

      // Send password reset email
      await _emailService.sendPasswordResetEmail(
        email: email,
        fullName: user.fullName,
        code: resetCode,
      );

      return AuthResponse(
        success: true,
        message: 'Mã đặt lại mật khẩu đã được gửi tới email của bạn',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ─── Verify Password Reset Code ────────────────────────
  /// Verify password reset code
  Future<AuthResponse> verifyPasswordResetCode(String email, String code) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final user = mockUsers.firstWhere(
        (u) => u.email == email,
        orElse: () => throw Exception('Email không tìm thấy'),
      );

      if (user.resetCode != code) {
        return AuthResponse(
          success: false,
          error: 'Mã đặt lại mật khẩu không đúng',
        );
      }

      if (user.resetCodeExpiry != null &&
          DateTime.now().isAfter(user.resetCodeExpiry!)) {
        return AuthResponse(
          success: false,
          error: 'Mã đặt lại mật khẩu đã hết hạn',
        );
      }

      return AuthResponse(
        success: true,
        message: 'Mã xác nhận hợp lệ',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ─── Reset Password ────────────────────────────────────
  /// Reset password with verification code
  Future<AuthResponse> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1200));

      final userIndex = mockUsers.indexWhere((u) => u.email == email);
      if (userIndex == -1) {
        return AuthResponse(
          success: false,
          error: 'Email không tìm thấy',
        );
      }

      final user = mockUsers[userIndex];

      // Verify code
      if (user.resetCode != code) {
        return AuthResponse(
          success: false,
          error: 'Mã đặt lại mật khẩu không đúng',
        );
      }

      if (user.resetCodeExpiry != null &&
          DateTime.now().isAfter(user.resetCodeExpiry!)) {
        return AuthResponse(
          success: false,
          error: 'Mã đặt lại mật khẩu đã hết hạn',
        );
      }

      // Validate new password
      if (newPassword.length < 6) {
        return AuthResponse(
          success: false,
          error: 'Mật khẩu mới phải có ít nhất 6 ký tự',
        );
      }

      // Update password and clear reset code
      final updatedUser = user.copyWith(
        password: newPassword,
        resetCode: null,
        resetCodeExpiry: null,
      );

      mockUsers[userIndex] = updatedUser;

      return AuthResponse(
        success: true,
        message: 'Mật khẩu đã được đặt lại thành công',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ─── Logout ────────────────────────────────────────────
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _sessionToken = null;
    // Clear saved user from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_user');
    await prefs.remove('session_token');
  }

  // ─── Save User (Persistent Login) ─────────────────────
  /// Save user data to SharedPreferences for persistent login
  Future<void> saveUser(UserAccount user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode({
        'id': user.id,
        'email': user.email,
        'fullName': user.fullName,
        'password': user.password,
        'userType': user.userType.toString(),
        'status': user.status.toString(),
        'phone': user.phone,
        'avatar': user.avatar,
        'createdAt': user.createdAt.toIso8601String(),
        'lastLogin': user.lastLogin.toIso8601String(),
        'assignedPatients': user.assignedPatients,
        'assignedCaregivers': user.assignedCaregivers,
        'metadata': user.metadata,
        'emailVerified': user.emailVerified,
      });
      
      await prefs.setString('saved_user', userJson);
      await prefs.setString('session_token', token);
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  // ─── Load User (Persistent Login) ─────────────────────
  /// Load user data from SharedPreferences for persistent login
  Future<UserAccount?> loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('saved_user');
      final token = prefs.getString('session_token');
      
      if (userJson == null || token == null) {
        return null;
      }
      
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      
      // Reconstruct UserType from string
      final userTypeStr = userData['userType'] as String;
      final userType = _stringToUserType(
        userTypeStr.replaceAll('UserType.', '')
      );
      
      // Reconstruct AccountStatus from string
      final statusStr = userData['status'] as String;
      final status = _stringToAccountStatus(
        statusStr.replaceAll('AccountStatus.', '')
      );
      
      final user = UserAccount(
        id: userData['id'] as String,
        email: userData['email'] as String,
        fullName: userData['fullName'] as String,
        password: userData['password'] as String,
        userType: userType,
        status: status,
        phone: userData['phone'] as String?,
        avatar: userData['avatar'] as String?,
        createdAt: DateTime.parse(userData['createdAt'] as String),
        lastLogin: DateTime.parse(userData['lastLogin'] as String),
        assignedPatients: userData['assignedPatients'] != null 
          ? List<String>.from(userData['assignedPatients'] as List)
          : null,
        assignedCaregivers: userData['assignedCaregivers'] != null 
          ? List<String>.from(userData['assignedCaregivers'] as List)
          : null,
        metadata: userData['metadata'] as Map<String, dynamic>?,
        emailVerified: userData['emailVerified'] as bool? ?? false,
      );
      
      _currentUser = user;
      _sessionToken = token;
      
      return user;
    } catch (e) {
      print('Error loading saved user: $e');
      return null;
    }
  }

  // ─── Session Recovery ─────────────────────────────────
  /// Check if there's an existing valid session
  Future<bool> checkSession(String? token) async {
    if (token == null) return false;
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // ─── Helper Methods ────────────────────────────────────
  String _generateToken() {
    // Mock token generation - in production use JWT
    return 'token_${DateTime.now().millisecondsSinceEpoch}';
  }

  UserType _stringToUserType(String type) {
    switch (type.toLowerCase()) {
      case 'familymember':
        return UserType.familyMember;
      case 'admin':
        return UserType.admin;
      default:
        return UserType.familyMember;
    }
  }

  AccountStatus _stringToAccountStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AccountStatus.active;
      case 'inactive':
        return AccountStatus.inactive;
      case 'suspended':
        return AccountStatus.suspended;
      case 'pending':
        return AccountStatus.pending;
      default:
        return AccountStatus.active;
    }
  }
}
