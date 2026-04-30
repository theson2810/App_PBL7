import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyMemberModel {
  final String id;
  final String familyId;
  final String userId;
  final String role;

  FamilyMemberModel({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
  });

  factory FamilyMemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FamilyMemberModel(
      id: doc.id,
      familyId: data['familyId'] ?? '',
      userId: data['userId'] ?? '',
      role: data['role'] ?? 'viewer',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'familyId': familyId,
      'userId': userId,
      'role': role,
    };
  }
}