import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.fcmToken,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      fcmToken: data['fcmToken'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}