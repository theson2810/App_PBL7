import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/family_service.dart';
import '../models/family_member_model.dart';

class FamilyRepository {
  final FamilyService _familyService = FamilyService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;


// CREATE FAMILY

  Future<String?> createFamily(String name) async {
    try {
      return await _familyService.createFamily(name);
    } catch (e) {
      print("CREATE FAMILY ERROR: $e");
      return null;
    }
  }


// JOIN FAMILY BY CODE
  Future<String?> joinFamily(String code) async {
    try {
      return await _familyService.joinFamily(code);
    } catch (e) {
      print("JOIN FAMILY ERROR: $e");
      return null;
    }
  }

// GET FAMILY MEMBERS
  Stream<List<FamilyMemberModel>> getMembers(String familyId) {
    return _db
      .collection('family_members')
      .where('familyId', isEqualTo: familyId)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => FamilyMemberModel.fromFirestore(doc))
      .toList());
  }

// GET INVITE CODE
  Future<String?> getInviteCode(String familyId) async {
    try {
      final query = await _db
        .collection('invites')
        .where('familyId', isEqualTo: familyId)
        .limit(1)
        .get();

      if (query.docs.isEmpty) return null;
      return query.docs.first['code'];
    } catch (e) {
      print("GET INVITE ERROR: $e");
      return null;
    }
  }
}
