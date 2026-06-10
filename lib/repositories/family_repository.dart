import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/family_service.dart';
import '../models/family_member_model.dart';

class FamilyRepository {
  final FamilyService _familyService = FamilyService();

  Future<String?> createFamily(String name) async {
    try {
      return await _familyService.createFamily(name);
    } catch (e) {
      // ignore: avoid_print
      print('CREATE FAMILY ERROR: $e');
      return null;
    }
  }

  Future<String?> joinFamily(String code) async {
    try {
      return await _familyService.joinFamily(code);
    } catch (e) {
      // ignore: avoid_print
      print('JOIN FAMILY ERROR: $e');
      rethrow;
    }
  }

  Future<String> requestJoinFamily(String code) => _familyService.requestJoinFamily(code);

  Stream<QuerySnapshot<Map<String, dynamic>>> joinRequests(String familyId) =>
      _familyService.joinRequestsStream(familyId);

  Future<void> acceptJoinRequest(String requestDocId) =>
      _familyService.acceptJoinRequest(requestDocId);

  Future<void> rejectJoinRequest(String requestDocId) =>
      _familyService.rejectJoinRequest(requestDocId);

  Future<Map<String, String>> inviteMemberByEmail(String familyId, String email) =>
      _familyService.inviteMemberByEmail(familyId, email);

  Future<void> acceptEmailInvite(String token) =>
      _familyService.acceptEmailInvite(token);

  Future<String?> getAdminFamilyId(String uid) => _familyService.getAdminFamilyId(uid);

  Future<bool> isUserFamilyAdmin(String uid) => _familyService.isUserFamilyAdmin(uid);

  Stream<List<FamilyMemberModel>> getMembers(String familyId) =>
      _familyService.membersStream(familyId);

  Future<Map<String, dynamic>> createWifiJoinSession(String familyId) =>
      _familyService.createWifiJoinSession(familyId);

  Future<Map<String, dynamic>> createJoinCode(String familyId) =>
      _familyService.createJoinCode(familyId);

  Future<String> joinFamilyViaWifiSession(String sessionId) =>
      _familyService.joinFamilyViaWifiSession(sessionId);

  Future<void> removeFamilyMember(String familyId, String memberUserId) =>
      _familyService.removeFamilyMember(familyId, memberUserId);

  Future<String?> getInviteCode(String familyId) async {
    try {
      return await _familyService.getInviteCode(familyId);
    } catch (e) {
      // ignore: avoid_print
      print('GET INVITE ERROR: $e');
      return null;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myPendingJoinRequests() =>
      _familyService.myPendingJoinRequestsStream();
}
