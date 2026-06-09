import 'package:cloud_firestore/cloud_firestore.dart';

class CameraModel {
  final String id;
  final String name;
  final String familyId;
  final String chipId;
  /// ID trên relay VPS (`CAMERA_ID` trong publisher), vd. `tenda_192_168_0_102`.
  final String relayCameraId;
  /// IP LAN camera Tenda (vd. `192.168.0.102`).
  final String cameraIp;
  final String rtspMainUrl;
  final String rtspSubUrl;
  final String status;
  final DateTime createdAt;

  CameraModel({
    required this.id,
    required this.name,
    required this.familyId,
    required this.chipId,
    required this.relayCameraId,
    this.cameraIp = '',
    this.rtspMainUrl = '',
    this.rtspSubUrl = '',
    required this.status,
    required this.createdAt,
  });

  factory CameraModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final chipId = data['chipId'] as String? ?? '';
    final relayId = (data['relayCameraId'] as String?)?.trim();

    final cameraIp = (data['cameraIp'] as String?)?.trim() ?? '';

    return CameraModel(
      id: doc.id,
      name: data['name'] ?? '',
      familyId: data['familyId'] ?? '',
      chipId: chipId,
      relayCameraId: (relayId != null && relayId.isNotEmpty)
          ? relayId
          : (chipId.isNotEmpty ? chipId : doc.id),
      cameraIp: cameraIp,
      rtspMainUrl: (data['rtspMainUrl'] as String?)?.trim() ?? '',
      rtspSubUrl: (data['rtspSubUrl'] as String?)?.trim() ?? '',
      status: data['status'] ?? 'offline',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'familyId': familyId,
      'chipId': chipId,
      'relayCameraId': relayCameraId,
      if (cameraIp.isNotEmpty) 'cameraIp': cameraIp,
      if (rtspMainUrl.isNotEmpty) 'rtspMainUrl': rtspMainUrl,
      if (rtspSubUrl.isNotEmpty) 'rtspSubUrl': rtspSubUrl,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
