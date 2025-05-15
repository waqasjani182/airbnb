import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/user.dart';
import '../models/user2.dart';
import '../utils/constants.dart';
import 'api_client.dart';
import 'auth_service_direct.dart';

class AuthResult {
  final User user;
  final String token;
  final String? message;

  AuthResult({required this.user, required this.token, this.message});
}

class AuthService {
  final ApiClient _apiClient;
  final AuthServiceDirect? _directService;
  final bool _useDirect;

  AuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: kBaseUrl),
        _useDirect = Platform.isMacOS,
        _directService = Platform.isMacOS ? AuthServiceDirect() : null;

  Future<AuthResult> login(String email, String password) async {
    try {
      if (_useDirect && _directService != null) {
        // Use direct implementation on macOS
        final data = await _directService.login(email, password);

        // Parse the user data using the new User2 model
        final user2 = User2.fromJson(data['user']);

        // Convert to the original User model for backward compatibility
        return AuthResult(
          user: user2.toUser(),
          token: data['token'],
          message: data['message'],
        );
      } else {
        // Use ApiClient on other platforms
        final response = await _apiClient.post<Map<String, dynamic>>(
          '/api/auth/login',
          body: {
            'email': email,
            'password': password,
          },
        );

        if (response.success && response.data != null) {
          final data = response.data!;

          // Parse the user data using the new User2 model
          final user2 = User2.fromJson(data['user']);

          // Convert to the original User model for backward compatibility
          return AuthResult(
            user: user2.toUser(),
            token: data['token'],
            message: data['message'],
          );
        } else {
          throw Exception(response.error ?? 'Failed to login');
        }
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<AuthResult> signup(
      String username, String email, String password) async {
    try {
      if (_useDirect && _directService != null) {
        // Use direct implementation on macOS
        final data = await _directService.signup(username, email, password);

        // Parse the user data using the new User2 model
        final user2 = User2.fromJson(data['user']);

        // Convert to the original User model for backward compatibility
        return AuthResult(
          user: user2.toUser(),
          token: data['token'],
          message: data['message'],
        );
      } else {
        // Use ApiClient on other platforms
        final response = await _apiClient.post<Map<String, dynamic>>(
          '/api/auth/register',
          body: {
            'name': username,
            'email': email,
            'password': password,
          },
        );

        if (response.success && response.data != null) {
          final data = response.data!;
          // Parse the user data using the new User2 model
          final user2 = User2.fromJson(data['user']);

          // Convert to the original User model for backward compatibility
          return AuthResult(
            user: user2.toUser(),
            token: data['token'],
            message: data['message'],
          );
        } else {
          throw Exception(response.error ?? 'Failed to signup');
        }
      }
    } catch (e) {
      throw Exception('Failed to signup: $e');
    }
  }

  Future<User> getCurrentUser(String token) async {
    try {
      if (_useDirect && _directService != null) {
        // Use direct implementation on macOS
        return await _directService.getCurrentUser(token);
      } else {
        // Use ApiClient on other platforms
        final response = await _apiClient.get<Map<String, dynamic>>(
          '/api/auth/me',
          requiresAuth: true,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.success && response.data != null) {
          final data = response.data!;
          // Check if the response has a nested 'user' object
          final userData = data.containsKey('user') ? data['user'] : data;

          // Debug the user data
          debugPrint('User data from API: $userData');

          // Check if we have the new API format (with user_ID, name, etc.)
          if (userData.containsKey('user_ID')) {
            // Create a User2 object from the new API format
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
          } else {
            // Use the old format parsing
            return User(
              id: userData['id'] is String
                  ? int.parse(userData['id'])
                  : userData['id'],
              firstName: userData['first_name'] ?? '',
              lastName: userData['last_name'] ?? '',
              email: userData['email'],
              phone: userData['phone'],
              isHost: userData['is_host'] ?? false,
              profileImage: userData['profile_image'],
              address: userData['address'],
              createdAt: userData['created_at'],
            );
          }
        } else {
          throw Exception(response.error ?? 'Failed to get current user');
        }
      }
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<User> updateProfile(User user, String token) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/users/${user.id}',
      requiresAuth: true,
      body: {
        'first_name': user.firstName,
        'last_name': user.lastName,
        'email': user.email,
        'phone': user.phone,
        'address': user.address,
      },
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      return User(
        id: data['id'] is String ? int.parse(data['id']) : data['id'],
        firstName: data['first_name'] ?? '',
        lastName: data['last_name'] ?? '',
        email: data['email'],
        phone: data['phone'],
        isHost: data['is_host'] ?? false,
        profileImage: data['profile_image'],
        address: data['address'],
        createdAt: data['created_at'],
      );
    } else {
      throw Exception(response.error ?? 'Failed to update profile');
    }
  }

  Future<User> updateProfileImage(String imageUrl, String token) async {
    // First, get the current user to have all the necessary data
    final userResponse = await _apiClient.get<Map<String, dynamic>>(
      '/api/auth/me',
      requiresAuth: true,
    );

    if (!userResponse.success || userResponse.data == null) {
      throw Exception(userResponse.error ?? 'Failed to get current user data');
    }

    final userData = userResponse.data!.containsKey('user')
        ? userResponse.data!['user']
        : userResponse.data!;

    debugPrint('User data for profile image update: $userData');

    // Handle both API formats
    final userId = userData.containsKey('user_ID')
        ? (userData['user_ID'] is String
            ? int.parse(userData['user_ID'].toString())
            : userData['user_ID'])
        : (userData['id'] is String
            ? int.parse(userData['id'])
            : userData['id']);

    // Now update the profile with the new image URL
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/users/$userId',
      requiresAuth: true,
      body: {
        'profile_image': imageUrl,
      },
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      return User(
        id: data['id'] is String ? int.parse(data['id']) : data['id'],
        firstName: data['first_name'] ?? '',
        lastName: data['last_name'] ?? '',
        email: data['email'],
        phone: data['phone'],
        isHost: data['is_host'] ?? false,
        profileImage: data['profile_image'] ??
            imageUrl, // Use the returned image URL or the one we sent
        address: data['address'],
        createdAt: data['created_at'],
      );
    } else {
      throw Exception(response.error ?? 'Failed to update profile image');
    }
  }
}
