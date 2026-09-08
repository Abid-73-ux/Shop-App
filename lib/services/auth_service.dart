import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // In-memory storage (in real app, use local storage or backend)
  static final Map<String, String> _registeredAccounts = {};
  String? _currentUser;

  String? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Check if email already registered
  bool isEmailRegistered(String email) {
    return _registeredAccounts.containsKey(email.toLowerCase());
  }

  /// Sign Up - Create new account
  Future<bool> signUp(String email, String password) async {
    try {
      final emailLower = email.toLowerCase();

      // Check if account already exists
      if (_registeredAccounts.containsKey(emailLower)) {
        throw Exception('Account already exists with this email');
      }

      // Validate email format
      if (!_isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      // Validate password strength
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Store account
      _registeredAccounts[emailLower] = password;
      notifyListeners();

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Log In - Existing account
  Future<bool> logIn(String email, String password) async {
    try {
      final emailLower = email.toLowerCase();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Check if account exists
      if (!_registeredAccounts.containsKey(emailLower)) {
        throw Exception('Account not found. Please sign up first');
      }

      // Validate password
      if (_registeredAccounts[emailLower] != password) {
        throw Exception('Invalid password');
      }

      _currentUser = emailLower;
      notifyListeners();

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Log Out
  void logOut() {
    _currentUser = null;
    notifyListeners();
  }

  /// Get user display name
  String getUserDisplayName() {
    if (_currentUser == null) return '';
    return _currentUser!.split('@')[0];
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Clear all accounts (for testing)
  void clearAll() {
    _registeredAccounts.clear();
    _currentUser = null;
    notifyListeners();
  }
}
