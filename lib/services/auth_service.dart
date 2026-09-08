import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class User {
  final String name;
  final String email;
  final String password;

  User({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  String? _currentUser;
  late SharedPreferences _prefs;
  bool _initialized = false;

  String? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    notifyListeners();
  }

  /// Get all registered users
  List<User> _getRegisteredUsers() {
    final usersJson = _prefs.getString('users') ?? '{}';
    final Map<String, dynamic> usersMap = jsonDecode(usersJson);
    return usersMap.entries
        .map((e) => User.fromMap(e.value as Map<String, dynamic>))
        .toList();
  }

  /// Save users to storage
  Future<void> _saveUsers(Map<String, dynamic> users) async {
    await _prefs.setString('users', jsonEncode(users));
  }

  /// Check if email already registered
  bool isEmailRegistered(String email) {
    final usersJson = _prefs.getString('users') ?? '{}';
    final Map<String, dynamic> usersMap = jsonDecode(usersJson);
    return usersMap.containsKey(email.toLowerCase());
  }

  /// Sign Up - Create new account
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final emailLower = email.toLowerCase();

      // Check if account already exists
      if (isEmailRegistered(emailLower)) {
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

      if (name.isEmpty) {
        throw Exception('Name cannot be empty');
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Get existing users
      final usersJson = _prefs.getString('users') ?? '{}';
      final Map<String, dynamic> usersMap = jsonDecode(usersJson);

      // Add new user
      usersMap[emailLower] = {
        'name': name,
        'email': emailLower,
        'password': password,
      };

      // Save to storage
      await _saveUsers(usersMap);
      notifyListeners();

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Log In - Existing account
  Future<bool> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final emailLower = email.toLowerCase();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Check if account exists
      if (!isEmailRegistered(emailLower)) {
        throw Exception('Account not found. Please sign up first');
      }

      // Get users
      final usersJson = _prefs.getString('users') ?? '{}';
      final Map<String, dynamic> usersMap = jsonDecode(usersJson);
      final userData = usersMap[emailLower] as Map<String, dynamic>;

      // Validate password
      if (userData['password'] != password) {
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
    
    final usersJson = _prefs.getString('users') ?? '{}';
    final Map<String, dynamic> usersMap = jsonDecode(usersJson);
    final userData = usersMap[_currentUser] as Map<String, dynamic>?;
    
    return userData?['name'] ?? _currentUser!.split('@')[0];
  }

  /// Get user full details
  User? getCurrentUserDetails() {
    if (_currentUser == null) return null;
    
    final usersJson = _prefs.getString('users') ?? '{}';
    final Map<String, dynamic> usersMap = jsonDecode(usersJson);
    final userData = usersMap[_currentUser] as Map<String, dynamic>?;
    
    if (userData == null) return null;
    return User.fromMap(userData);
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Clear all users (for testing)
  Future<void> clearAll() async {
    await _prefs.remove('users');
    _currentUser = null;
    notifyListeners();
  }
}
