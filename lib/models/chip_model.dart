import 'package:cloud_firestore/cloud_firestore.dart';

class ChipModel {
  final String id;
  final String serial;
  final String? name;
  final String status;
  final String? familyId;
  final DateTime createdAt;

  ChipModel({
    required this.id,
    required this.serial,
    this.name,
    required this.status,
    this.familyId,
    required this.createdAt,
  });

  factory ChipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChipModel(
      id: doc.id,
      serial: data['serial'] ?? '',
      name: data['name'],
      status: data['status'] ?? 'pending',
      familyId: data['familyId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serial': serial,
      'name': name,
      'status': status,
      'familyId': familyId,
      'createdAt': createdAt,
    };
  }
}
