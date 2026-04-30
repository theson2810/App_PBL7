import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String cameraId;
  final String viewerId;
  final String status;
  final DateTime createdAt;

  SessionModel({
    required this.id,
    required this.cameraId,
    required this.viewerId,
    required this.status,
    required this.createdAt,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SessionModel(
      id: doc.id,
      cameraId: data['cameraId'] ?? '',
      viewerId: data['viewerId'] ?? '',
      status: data['status'] ?? 'waiting',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cameraId': cameraId,
      'viewerId': viewerId,
      'status': status,
      'createdAt': createdAt,
    };
  }
}