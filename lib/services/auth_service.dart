import '../models/user.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class AuthResult {
  final User user;
  final String token;
  final String? message;

  AuthResult({required this.user, required this.token, this.message});
}

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: kBaseUrl);

  Future<AuthResult> login(String email, String password) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      return AuthResult(
        user: User(
          id: data['user']['id'] is String
              ? int.parse(data['user']['id'])
              : data['user']['id'],
          firstName: data['user']['first_name'] ?? '',
          lastName: data['user']['last_name'] ?? '',
          email: data['user']['email'],
          phone: data['user']['phone'],
          isHost: data['user']['is_host'] ?? false,
          profileImage: data['user']['profile_image'],
          createdAt: data['user']['created_at'],
        ),
        token: data['token'],
        message: data['message'],
      );
    } else {
      throw Exception(response.error ?? 'Failed to login');
    }
  }

  Future<AuthResult> signup(
      String username, String email, String password) async {
    final names = username.split(' ');
    final firstName = names.first;
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/auth/register',
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'phone': '',
        'is_host': true,
      },
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      return AuthResult(
        user: User(
          id: data['user']['id'] is String
              ? int.parse(data['user']['id'])
              : data['user']['id'],
          firstName: data['user']['first_name'] ?? '',
          lastName: data['user']['last_name'] ?? '',
          email: data['user']['email'],
          phone: data['user']['phone'],
          isHost: data['user']['is_host'] ?? false,
          profileImage: data['user']['profile_image'],
          createdAt: data['user']['created_at'],
        ),
        token: data['token'],
        message: data['message'],
      );
    } else {
      throw Exception(response.error ?? 'Failed to signup');
    }
  }

  Future<User> getCurrentUser(String token) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/auth/me',
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      // Check if the response has a nested 'user' object
      final userData = data.containsKey('user') ? data['user'] : data;

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
    } else {
      throw Exception(response.error ?? 'Failed to get current user');
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

    final userId =
        userData['id'] is String ? int.parse(userData['id']) : userData['id'];

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
