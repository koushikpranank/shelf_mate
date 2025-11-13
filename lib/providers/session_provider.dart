import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import 'package:collection/collection.dart';

/// SessionProvider manages the logged-in user session.
/// It persists the current user using Hive boxes and notifies listeners on changes.
class SessionProvider extends ChangeNotifier {
  User? _loggedInUser;
  final Box<User> _userBox;
  final Box<String> _sessionBox;

  /// Constructor requires opened Hive boxes for users and session storage.
  SessionProvider(this._userBox, this._sessionBox) {
    _loadPersistedUser();
  }

  /// Returns the currently logged-in user, or null if none.
  User? get loggedInUser => _loggedInUser;

  /// Indicates whether a user is currently logged in.
  bool get isLoggedIn => _loggedInUser != null;

  /// Loads persisted username from session box and fetches the corresponding user.
  Future<void> _loadPersistedUser() async {
    final username = _sessionBox.get('logged_in_user');
    if (username != null) {
      final user = _userBox.values.cast<User?>().firstWhereOrNull(
        (u) => u?.username == username,
      );
      _loggedInUser = user;
    } else {
      _loggedInUser = null;
    }
    notifyListeners();
  }

  /// Logs in a user and persists the username.
  Future<void> login(User user) async {
    _loggedInUser = user;
    await _sessionBox.put('logged_in_user', user.username);
    notifyListeners();
  }

  /// Logs out the current user, removing persisted username.
  Future<void> logout() async {
    _loggedInUser = null;
    await _sessionBox.delete('logged_in_user');
    notifyListeners();
  }

  /// Clears session completely, including all stored session data.
  Future<void> clearSession() async {
    _loggedInUser = null;
    await _sessionBox.clear();
    notifyListeners();
  }
}
