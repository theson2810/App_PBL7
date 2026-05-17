import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyModel {
  final String id;
  final String name;
  final String ownerId;
  final DateTime createdAt;
  final String? joinCode;

  FamilyModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
    this.joinCode,
  });

  String get adminUid => ownerId;

  factory FamilyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FamilyModel(
      id: doc.id,
      name: data['name'] ?? '',
      ownerId: (data['adminUid'] ?? data['ownerId'] ?? '') as String,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      joinCode: data['joinCode'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'adminUid': ownerId,
      if (joinCode != null) 'joinCode': joinCode,
      'createdAt': createdAt,
    };
  }
}
