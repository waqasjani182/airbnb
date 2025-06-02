import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_property.dart';
import '../services/property_service2.dart';
import 'auth_provider.dart';
import 'property_provider2.dart';

// User Properties State
enum UserPropertiesStatus {
  initial,
  loading,
  success,
  error,
}

class UserPropertiesState {
  final UserPropertiesStatus status;
  final List<UserProperty> properties;
  final String? errorMessage;
  final bool isLoading;

  UserPropertiesState({
    this.status = UserPropertiesStatus.initial,
    this.properties = const [],
    this.errorMessage,
    this.isLoading = false,
  });

  UserPropertiesState copyWith({
    UserPropertiesStatus? status,
    List<UserProperty>? properties,
    String? errorMessage,
    bool? isLoading,
  }) {
    return UserPropertiesState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPropertiesState &&
        other.status == status &&
        listEquals(other.properties, properties) &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        properties.hashCode ^
        errorMessage.hashCode ^
        isLoading.hashCode;
  }
}

// User Properties Notifier
class UserPropertiesNotifier extends StateNotifier<UserPropertiesState> {
  final PropertyService2 _propertyService;
  final String? _authToken;

  UserPropertiesNotifier(this._propertyService, this._authToken)
      : super(UserPropertiesState());

  Future<void> fetchUserProperties() async {
    state = state.copyWith(
      status: UserPropertiesStatus.loading,
      isLoading: true,
      errorMessage: null,
    );

    try {
      final response =
          await _propertyService.getUserProperties(token: _authToken);
      state = state.copyWith(
        status: UserPropertiesStatus.success,
        properties: response.properties,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error fetching user properties: $e');
      state = state.copyWith(
        status: UserPropertiesStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    state = UserPropertiesState();
  }
}

// Providers
final userPropertiesProvider =
    StateNotifierProvider<UserPropertiesNotifier, UserPropertiesState>((ref) {
  final propertyService = ref.watch(propertyService2Provider);
  final authState = ref.watch(authProvider);
  final authToken = authState.token;

  return UserPropertiesNotifier(propertyService, authToken);
});

// Convenience provider for just the properties list
final userPropertiesListProvider = Provider<List<UserProperty>>((ref) {
  return ref.watch(userPropertiesProvider).properties;
});

// Convenience provider for loading state
final userPropertiesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userPropertiesProvider).isLoading;
});

// Convenience provider for error message
final userPropertiesErrorProvider = Provider<String?>((ref) {
  return ref.watch(userPropertiesProvider).errorMessage;
});
