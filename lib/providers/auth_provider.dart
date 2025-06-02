import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../utils/constants.dart';
import 'api_provider.dart';

// Auth state
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final String? token;
  final bool isLoading;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.token,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    String? token,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final SharedPreferences _prefs;
  final NavigationService? _navigationService;

  AuthNotifier(this._authService, this._prefs, [this._navigationService])
      : super(AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Start with loading state
    state = state.copyWith(
      status: AuthStatus.initial,
      isLoading: true,
    );

    final token = _prefs.getString('auth_token');
    if (token != null) {
      try {
        final user = await _authService.getCurrentUser(token);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: token,
          isLoading: false,
        );
      } catch (e) {
        // Clear invalid token
        await _prefs.remove('auth_token');
        await _prefs.remove('user_id');

        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
        );
      }
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null, // Clear previous errors
      isLoading: true,
    );
    try {
      final result = await _authService.login(email, password);

      // Save token to SharedPreferences
      await _prefs.setString('auth_token', result.token);

      // Also save user ID for quick access
      await _prefs.setInt('user_id', result.user.id);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        token: result.token,
        isLoading: false,
      );

      // Navigate using NavigationService if available
      if (_navigationService != null) {
        debugPrint('Using NavigationService to navigate after login');
        _navigationService.replaceTo(AppRoutes.dashboard);
      } else {
        debugPrint('NavigationService not available, relying on UI navigation');
        // The UI will handle navigation through state changes
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _formatErrorMessage(e.toString()),
        isLoading: false,
      );
    }
  }

  // Helper method to format error messages
  String _formatErrorMessage(String error) {
    // Remove technical details from error messages
    if (error.contains('Exception: ')) {
      return error.replaceAll('Exception: ', '');
    }
    return error;
  }

  Future<void> signup(String username, String email, String password,
      String address, String phoneNo) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null, // Clear previous errors
      isLoading: true,
    );
    try {
      final result = await _authService.signup(
          username, email, password, address, phoneNo);

      // Save token to SharedPreferences
      await _prefs.setString('auth_token', result.token);

      // Also save user ID for quick access
      await _prefs.setInt('user_id', result.user.id);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        token: result.token,
        isLoading: false,
      );

      // Navigate using NavigationService if available
      if (_navigationService != null) {
        debugPrint('Using NavigationService to navigate after signup');
        _navigationService.replaceTo(AppRoutes.dashboard);
      } else {
        debugPrint('NavigationService not available, relying on UI navigation');
        // The UI will handle navigation through state changes
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _formatErrorMessage(e.toString()),
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
    // Set loading state
    state = state.copyWith(
      isLoading: true,
    );

    // Clear all auth-related data from SharedPreferences
    await _prefs.remove('auth_token');
    await _prefs.remove('user_id');

    // Reset state
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      token: null,
      errorMessage: null,
      isLoading: false,
    );

    // Navigate using NavigationService if available
    if (_navigationService != null) {
      debugPrint('Using NavigationService to navigate after logout');
      _navigationService.replaceTo(AppRoutes.login);
    } else {
      debugPrint('NavigationService not available, relying on UI navigation');
      // The UI will handle navigation through state changes
    }
  }

  Future<void> updateProfile(User updatedUser) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null, // Clear previous errors
    );
    try {
      final user = await _authService.updateProfile(updatedUser, state.token!);
      state = state.copyWith(
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: _formatErrorMessage(e.toString()),
        isLoading: false,
      );
    }
  }

  Future<void> updateProfileImage(String imageUrl) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null, // Clear previous errors
    );
    try {
      final user =
          await _authService.updateProfileImage(imageUrl, state.token!);
      state = state.copyWith(
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: _formatErrorMessage(e.toString()),
        isLoading: false,
      );
    }
  }
}

// Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Should be overridden in main.dart');
});

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient: apiClient);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final navigationService = ref.watch(navigationServiceProvider);
  return AuthNotifier(authService, prefs, navigationService);
});
