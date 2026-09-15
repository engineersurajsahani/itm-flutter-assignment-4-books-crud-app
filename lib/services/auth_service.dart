import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/firebase_config.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? token;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.token,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'token': token,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        email: json['email'] ?? '',
        name: json['name'] ?? '',
        token: json['token'],
      );
}

class AuthService {
  static const String _userKey = 'auth_user_data';

  /// Sign Up with Email and Password
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (FirebaseConfig.isConfigured) {
      // Live Firebase Auth REST API
      final response = await http.post(
        Uri.parse(FirebaseConfig.signUpUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final user = UserModel(
          id: data['localId'] ?? '',
          email: data['email'] ?? email,
          name: name.trim().isNotEmpty ? name.trim() : email.split('@')[0],
          token: data['idToken'],
        );
        await _saveUser(user);
        return user;
      } else {
        final errorMsg = data['error']?['message'] ?? 'Signup failed';
        // If Firebase Auth is not yet enabled in the Firebase Console, fallback gracefully
        if (errorMsg == 'CONFIGURATION_NOT_FOUND' || errorMsg == 'OPERATION_NOT_ALLOWED') {
          final user = UserModel(
            id: 'user_${DateTime.now().millisecondsSinceEpoch}',
            email: email.trim(),
            name: name.trim().isNotEmpty ? name.trim() : email.split('@')[0],
            token: 'fallback_token',
          );
          await _saveUser(user);
          return user;
        }
        throw Exception(_formatFirebaseError(errorMsg));
      }
    } else {
      // Demo / Local Auth Mode (when Firebase credentials are not yet entered)
      await Future.delayed(const Duration(milliseconds: 600)); // simulated latency
      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        name: name.trim().isNotEmpty ? name.trim() : email.split('@')[0],
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      await _saveUser(user);
      return user;
    }
  }

  /// Sign In with Email and Password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    if (FirebaseConfig.isConfigured) {
      // Live Firebase Auth REST API
      final response = await http.post(
        Uri.parse(FirebaseConfig.signInUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final user = UserModel(
          id: data['localId'] ?? '',
          email: data['email'] ?? email,
          name: data['displayName'] ?? email.split('@')[0],
          token: data['idToken'],
        );
        await _saveUser(user);
        return user;
      } else {
        final errorMsg = data['error']?['message'] ?? 'Login failed';
        if (errorMsg == 'CONFIGURATION_NOT_FOUND' || errorMsg == 'OPERATION_NOT_ALLOWED') {
          final user = UserModel(
            id: 'user_${DateTime.now().millisecondsSinceEpoch}',
            email: email.trim(),
            name: email.split('@')[0],
            token: 'fallback_token',
          );
          await _saveUser(user);
          return user;
        }
        throw Exception(_formatFirebaseError(errorMsg));
      }
    } else {
      // Demo / Local Auth Mode
      await Future.delayed(const Duration(milliseconds: 600));
      final user = UserModel(
        id: 'user_demo_1',
        email: email.trim(),
        name: email.split('@')[0],
        token: 'demo_token_123',
      );
      await _saveUser(user);
      return user;
    }
  }

  /// Quick Demo / Guest Login
  Future<UserModel> quickDemoLogin() async {
    final user = UserModel(
      id: 'demo_guest_id',
      email: 'student@example.com',
      name: 'Flutter Student',
      token: 'guest_token',
    );
    await _saveUser(user);
    return user;
  }

  /// Sign Out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// Get Current Logged-in User
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr != null) {
      try {
        return UserModel.fromJson(jsonDecode(jsonStr));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  String _formatFirebaseError(String error) {
    switch (error) {
      case 'CONFIGURATION_NOT_FOUND':
        return 'Firebase Authentication is not activated yet in Firebase Console. Go to Console > Authentication > Click "Get Started" > Enable "Email/Password".';
      case 'OPERATION_NOT_ALLOWED':
        return 'Email/Password sign-in is disabled in Firebase Console. Go to Authentication > Sign-in method > Enable Email/Password.';
      case 'EMAIL_EXISTS':
        return 'The email address is already in use by another account.';
      case 'INVALID_EMAIL':
        return 'The email address is badly formatted.';
      case 'EMAIL_NOT_FOUND':
        return 'No user found with this email address.';
      case 'INVALID_PASSWORD':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Incorrect password or credentials. Please try again.';
      case 'USER_DISABLED':
        return 'This user account has been disabled.';
      case 'WEAK_PASSWORD : Password should be at least 6 characters':
        return 'Password must be at least 6 characters long.';
      default:
        return error.replaceAll('_', ' ').toLowerCase();
    }
  }
}
