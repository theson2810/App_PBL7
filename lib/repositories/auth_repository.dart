import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthRepository {
final AuthService _authService = AuthService();
final UserService _userService = UserService();

/// SIGN UP
Future<UserModel?> signUp(String email, String password) async {
  final user = await _authService.signUp(email, password);


  if (user == null) return null;

  return await _userService.getUser(user.uid);
}

/// SIGN IN
Future<UserModel?> signIn(String email, String password) async {
  final user = await _authService.signIn(email, password);
  if (user == null) return null;
  return await _userService.getUser(user.uid);
}

/// SIGN OUT
Future<void> signOut() async {
  await _authService.signOut();
}

/// CURRENT USER
User? getCurrentUser() {
  return _authService.getCurrentUser();
}
}
