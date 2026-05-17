import 'package:cloud_firestore/cloud_firestore.dart';

class CameraModel {
final String id;
final String name;
final String familyId;
final String chipId; // 🔥 QUAN TRỌNG
final String status;
final DateTime createdAt;

CameraModel({
required this.id,
required this.name,
required this.familyId,
required this.chipId,
required this.status,
required this.createdAt,
});

factory CameraModel.fromFirestore(DocumentSnapshot doc) {
final data = doc.data() as Map<String, dynamic>;

return CameraModel(
  id: doc.id,
  name: data['name'] ?? '',
  familyId: data['familyId'] ?? '',
  chipId: data['chipId'] ?? '',
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
'status': status,
'createdAt': createdAt,
};
}
}
