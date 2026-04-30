import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String familyId;
  final String cameraId;
  final String type;
  final String message;
  final String status;
  final DateTime createdAt;

  AlertModel({
    required this.id,
    required this.familyId,
    required this.cameraId,
    required this.type,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AlertModel(
      id: doc.id,
      familyId: data['familyId'] ?? '',
      cameraId: data['cameraId'] ?? '',
      type: data['type'] ?? 'fall',
      message: data['message'] ?? '',
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'familyId': familyId,
      'cameraId': cameraId,
      'type': type,
      'message': message,
      'status': status,
      'createdAt': createdAt,
    };
  }
}