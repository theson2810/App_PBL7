import '../models/user_model.dart';
import '../services/user_service.dart';

class UserRepository {
final UserService _userService = UserService();

Future<UserModel?> getUser(String uid) {
  return _userService.getUser(uid);
}

Future<void> updateUser(String uid, Map<String, dynamic> data) {
  return _userService.updateUser(uid, data);
}
}
