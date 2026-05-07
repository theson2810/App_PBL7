import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    try {
      var result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'email': email,
          'createdAt': DateTime.now(),
          'fcmToken': null,
        });
      }

      return user;
    } catch (e) {
      print("SIGNUP ERROR: $e");
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      var result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return null;
    }
  }

  User? getCurrentUser() => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }
}