import 'package:flutter/material.dart';
import 'dart:math';

// ─── User Types ────────────────────────────────────────────
enum UserType { familyMember, admin }
enum AccountStatus { active, inactive, suspended, pending }

// ─── Helper Functions ──────────────────────────────────────
String generateFamilyCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return 'FAM-${String.fromCharCodes(
    Iterable<int>.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
  )}';
}

// ─── User Account Model ────────────────────────────────────
class UserAccount {
  final String id;
  final String email;
  final String fullName;
  final String password; // In production, never store in app!
  final UserType userType;
  final AccountStatus status;
  final String? phone;
  final String? avatar;
  final DateTime createdAt;
  final DateTime lastLogin;
  final List<String>? assignedPatients; // For caregivers
  final List<String>? assignedCaregivers; // For family members
  final Map<String, dynamic>? metadata;
  final bool emailVerified;
  final String? verificationCode; // For email verification
  final DateTime? verificationCodeExpiry;
  final String? resetCode; // Legacy / optional (password reset uses Firebase email)
  final DateTime? resetCodeExpiry;
  final String? familyCode; // Human-readable join code (e.g. 6 digits)
  final String? familyId; // Firestore families/{id}

  const UserAccount({
    required this.id,
    required this.email,
    required this.fullName,
    required this.password,
    required this.userType,
    this.status = AccountStatus.active,
    this.phone,
    this.avatar,
    required this.createdAt,
    required this.lastLogin,
    this.assignedPatients,
    this.assignedCaregivers,
    this.metadata,
    this.emailVerified = false,
    this.verificationCode,
    this.verificationCodeExpiry,
    this.resetCode,
    this.resetCodeExpiry,
    this.familyCode,
    this.familyId,
  });

  // Create a copy with some fields changed
  UserAccount copyWith({
    String? id,
    String? email,
    String? fullName,
    String? password,
    UserType? userType,
    AccountStatus? status,
    String? phone,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastLogin,
    List<String>? assignedPatients,
    List<String>? assignedCaregivers,
    Map<String, dynamic>? metadata,
    bool? emailVerified,
    String? verificationCode,
    DateTime? verificationCodeExpiry,
    String? resetCode,
    DateTime? resetCodeExpiry,
    String? familyCode,
    String? familyId,
  }) {
    return UserAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      assignedPatients: assignedPatients ?? this.assignedPatients,
      assignedCaregivers: assignedCaregivers ?? this.assignedCaregivers,
      metadata: metadata ?? this.metadata,
      emailVerified: emailVerified ?? this.emailVerified,
      verificationCode: verificationCode ?? this.verificationCode,
      verificationCodeExpiry: verificationCodeExpiry ?? this.verificationCodeExpiry,
      resetCode: resetCode ?? this.resetCode,
      resetCodeExpiry: resetCodeExpiry ?? this.resetCodeExpiry,
      familyCode: familyCode ?? this.familyCode,
      familyId: familyId ?? this.familyId,
    );
  }

  // Get user type label
  String get userTypeLabel {
    switch (userType) {
      case UserType.familyMember:
        return 'Family Member';
      case UserType.admin:
        return 'Administrator';
    }
  }

  // Get initials for avatar
  String get initials {
    final parts = fullName.split(' ');
    return parts.length > 1
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : parts.first.substring(0, 2).toUpperCase();
  }

  // Get avatar color based on user type
  Color get avatarColor {
    switch (userType) {
      case UserType.familyMember:
        return const Color(0xFFE8F5E9); // Light green
      case UserType.admin:
        return const Color(0xFFFFF8E1); // Light yellow
    }
  }
}

// ─── Login Request ─────────────────────────────────────────
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });
}

// ─── Registration Request ──────────────────────────────────
class RegistrationRequest {
  final String email;
  final String password;
  final String fullName;
  final String userType; // 'familyMember', 'admin'
  final String? phone;
  final String? organizationCode; // For linking to facilities

  const RegistrationRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.userType,
    this.phone,
    this.organizationCode,
  });
}

// ─── Auth Response ────────────────────────────────────────
class AuthResponse {
  final bool success;
  final String? message;
  final UserAccount? user;
  final String? token; // JWT or session token
  final String? error;

  const AuthResponse({
    required this.success,
    this.message,
    this.user,
    this.token,
    this.error,
  });
}

// ─── Mock Users for Testing ───────────────────────────────
final List<UserAccount> mockUsers = [
  UserAccount(
    id: 'user_family_1',
    email: 'family@example.com',
    fullName: 'John Smith',
    password: 'password123',
    userType: UserType.familyMember,
    status: AccountStatus.active,
    phone: '+1-555-0102',
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
    lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
    assignedCaregivers: ['admin_1'],
    familyCode: '123456',
    familyId: 'fam_demo',
    emailVerified: true, // Already verified for testing
  ),
  UserAccount(
    id: 'user_admin_1',
    email: 'admin@example.com',
    fullName: 'System Administrator',
    password: 'password123',
    userType: UserType.admin,
    status: AccountStatus.active,
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
    lastLogin: DateTime.now(),
    familyCode: '123456',
    familyId: 'fam_demo',
    emailVerified: true, // Already verified for testing
  ),
];
