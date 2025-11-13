import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthService {
  final Box<User> userBox = Hive.box<User>('users');
  final Box<String> sessionBox = Hive.box<String>('session');

  // Hash password using sha256 with username as salt
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Sign up user with username and password; returns false if username exists
  Future<bool> signUp(String username, String password) async {
    final exists = userBox.values.any((user) => user.username == username);
    if (exists) return false;

    final hashed = _hashPassword(password, username);
    final newUser = User(username: username, passwordHash: hashed);

    await userBox.add(newUser);
    return true;
  }

  // Attempt login; return User if success, null if fail. Stores login session.
  Future<User?> login(String username, String password) async {
    final users = userBox.values.cast<User?>();

    final user = users.firstWhere(
      (u) => u?.username == username,
      orElse: () => null,
    );

    if (user == null) return null;

    final hashed = _hashPassword(password, username);
    if (user.passwordHash == hashed) {
      await sessionBox.put('logged_in_user', username);
      return user;
    }

    return null; // Wrong password
  }

  // Logout by deleting the logged-in user from session box
  Future<void> logout() async {
    await sessionBox.delete('logged_in_user');
  }

  // Get currently logged-in User, if any
  User? currentUser() {
    final username = sessionBox.get('logged_in_user');
    if (username == null) return null;

    final users = userBox.values.cast<User?>();
    return users.firstWhere((u) => u?.username == username, orElse: () => null);
  }

  // Check if logged in
  bool get isLoggedIn => sessionBox.get('logged_in_user') != null;
}
