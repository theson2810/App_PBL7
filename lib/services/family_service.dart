import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/family_model.dart';
import '../models/family_member_model.dart';

class FamilyService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

 
  /// CREATE FAMILY
  Future<String?> createFamily(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      /// Tạo family
      final familyRef = await _firestore.collection('families').add({
        'name': name,
        'ownerId': user.uid,
        'createdAt': DateTime.now(),
      });

      final familyId = familyRef.id;

      /// Thêm owner vào members
      await _firestore.collection('family_members').add({
        'familyId': familyId,
        'userId': user.uid,
        'role': 'owner',
      });

      ///Tạo mã mời
      String code = _generateCode();

      await _firestore.collection('invites').add({
        'familyId': familyId,
        'code': code,
        'createdAt': DateTime.now(),
      });

      print("INVITE CODE: $code");

      return familyId;
    } catch (e) {
      print("CREATE FAMILY ERROR: $e");
      return null;
    }
  }


  /// JOIN FAMILY
  Future<String?> joinFamily(String code) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      /// tìm invite
      final query = await _firestore
          .collection('invites')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("Invalid code");
      }

      final inviteData = query.docs.first.data();
      final familyId = inviteData['familyId'];

      /// thêm member
      await _firestore.collection('family_members').add({
        'familyId': familyId,
        'userId': user.uid,
        'role': 'viewer',
      });

      return familyId;
    } catch (e) {
      print("JOIN FAMILY ERROR: $e");
      rethrow;
    }
  }


  /// GENERATE CODE
  String _generateCode() {
    return DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);
  }
}