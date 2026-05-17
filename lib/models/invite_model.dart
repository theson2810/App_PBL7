import 'package:cloud_firestore/cloud_firestore.dart';

class InviteModel {
  final String id;
  final String familyId;
  final String code;
  final DateTime createdAt;

  InviteModel({
    required this.id,
    required this.familyId,
    required this.code,
    required this.createdAt,
  });

  factory InviteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return InviteModel(
      id: doc.id,
      familyId: data['familyId'],
      code: data['code'],
      createdAt:
          (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'familyId': familyId,
      'code': code,
      'createdAt': createdAt,
    };
  }
}