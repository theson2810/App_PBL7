import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyMemberModel {
  final String id;
  final String familyId;
  final String userId;
  final String role;
  final String status;
  final String? email;
  final String? displayName;

  FamilyMemberModel({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
    this.status = 'active',
    this.email,
    this.displayName,
  });

  factory FamilyMemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawRole = (data['role'] ?? 'member') as String;
    final normalized = rawRole == 'owner' ? 'admin' : rawRole;

    return FamilyMemberModel(
      id: doc.id,
      familyId: data['familyId'] ?? '',
      userId: data['userId'] ?? '',
      role: normalized,
      status: (data['status'] ?? 'active') as String,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'familyId': familyId,
      'userId': userId,
      'role': role,
      'status': status,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
    };
  }
}
