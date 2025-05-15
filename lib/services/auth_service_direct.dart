import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/user2.dart';
import '../utils/constants.dart';
import 'direct_http_service.dart';

/// A direct implementation of AuthService that bypasses the ApiClient
/// This is useful for macOS where the ApiClient might have issues with App Sandbox
class AuthServiceDirect {
  final DirectHttpService _directHttpService;

  AuthServiceDirect()
      : _directHttpService =
            DirectHttpService(baseUrl: 'http://127.0.0.1:3004');

  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      debugPrint('Direct login attempt for: $email');

      final data = await _directHttpService.post(
        '/api/auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      debugPrint('Direct login successful');

      // Validate the response format
      if (!data.containsKey('user') || !data.containsKey('token')) {
        debugPrint('Invalid login response format: $data');
        throw Exception('Invalid login response format');
      }

      return data;
    } catch (e) {
      debugPrint('Direct login failed: $e');
      rethrow;
    }
  }

  /// Sign up with username, email, and password
  Future<Map<String, dynamic>> signup(
      String username, String email, String password) async {
    try {
      debugPrint('Direct signup attempt for: $email');

      final data = await _directHttpService.post(
        '/api/auth/register',
        body: {
          'name': username,
          'email': email,
          'password': password,
        },
      );

      debugPrint('Direct signup successful');

      // Validate the response format
      if (!data.containsKey('user') || !data.containsKey('token')) {
        debugPrint('Invalid signup response format: $data');
        throw Exception('Invalid signup response format');
      }

      return data;
    } catch (e) {
      debugPrint('Direct signup failed: $e');
      rethrow;
    }
  }

  /// Get current user
  Future<User> getCurrentUser(String token) async {
    try {
      final data = await _directHttpService.get(
        '/api/auth/me',
        token: token,
      );

      // Check if the response has a nested 'user' object
      final userData = data.containsKey('user') ? data['user'] : data;

      debugPrint('User data from API: $userData');

      // Create User2 object directly from the API response
      final user2 = User2(
        userId: userData['user_ID'] is String
            ? int.parse(userData['user_ID'].toString())
            : userData['user_ID'],
        name: userData['name'],
        email: userData['email'],
        address: userData['address'],
        phoneNo: userData['phone_No'],
        profileImage: userData['profile_image'],
      );

      // Convert to the original User model for backward compatibility
      return user2.toUser();
    } catch (e) {
      debugPrint('Failed to get current user: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _directHttpService.dispose();
  }
}
