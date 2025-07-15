import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city_properties_response.dart';
import '../services/property_service.dart';
import 'auth_provider.dart';
import 'api_provider.dart';

// City properties state
enum CityPropertiesStatus {
  initial,
  loading,
  success,
  error,
}

class CityPropertiesState {
  final CityPropertiesStatus status;
  final CityPropertiesResponse? response;
  final String? errorMessage;
  final bool isLoading;
  final String? currentCity;

  CityPropertiesState({
    this.status = CityPropertiesStatus.initial,
    this.response,
    this.errorMessage,
    this.isLoading = false,
    this.currentCity,
  });

  CityPropertiesState copyWith({
    CityPropertiesStatus? status,
    CityPropertiesResponse? response,
    String? errorMessage,
    bool? isLoading,
    String? currentCity,
  }) {
    return CityPropertiesState(
      status: status ?? this.status,
      response: response ?? this.response,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      currentCity: currentCity ?? this.currentCity,
    );
  }
}

// City properties notifier
class CityPropertiesNotifier extends StateNotifier<CityPropertiesState> {
  final PropertyService _propertyService;
  final Ref _ref;

  CityPropertiesNotifier(this._propertyService, this._ref)
      : super(CityPropertiesState());

  /// Get properties by city with ratings
  Future<void> getPropertiesByCity(String cityName) async {
    if (cityName.trim().isEmpty) {
      state = state.copyWith(
        status: CityPropertiesStatus.error,
        errorMessage: 'City name cannot be empty',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      status: CityPropertiesStatus.loading,
      isLoading: true,
      errorMessage: null,
      currentCity: cityName,
    );

    try {
      // Get auth token (optional for this endpoint)
      final authState = _ref.read(authProvider);
      final token = authState.token;

      final response = await _propertyService.getPropertiesByCity(
        cityName,
        token: token,
      );

      state = state.copyWith(
        status: CityPropertiesStatus.success,
        response: response,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: CityPropertiesStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Clear the current city properties data
  void clearData() {
    state = CityPropertiesState();
  }

  /// Refresh the current city data
  Future<void> refresh() async {
    if (state.currentCity != null) {
      await getPropertiesByCity(state.currentCity!);
    }
  }
}

// Provider for property service
final propertyServiceProvider = Provider<PropertyService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PropertyService(apiClient: apiClient);
});

// Provider for city properties
final cityPropertiesProvider =
    StateNotifierProvider<CityPropertiesNotifier, CityPropertiesState>((ref) {
  final propertyService = ref.watch(propertyServiceProvider);
  return CityPropertiesNotifier(propertyService, ref);
});

// Convenience providers for specific data
final cityPropertiesListProvider = Provider<List<CityProperty>>((ref) {
  final state = ref.watch(cityPropertiesProvider);
  return state.response?.properties ?? [];
});

final cityPropertiesLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(cityPropertiesProvider);
  return state.isLoading;
});

final cityPropertiesErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(cityPropertiesProvider);
  return state.errorMessage;
});

final currentCityProvider = Provider<String?>((ref) {
  final state = ref.watch(cityPropertiesProvider);
  return state.currentCity;
});

final averageCityRatingProvider = Provider<String?>((ref) {
  final state = ref.watch(cityPropertiesProvider);
  return state.response?.averageCityRating;
});

final cityPropertiesCountProvider = Provider<int>((ref) {
  final state = ref.watch(cityPropertiesProvider);
  return state.response?.totalCount ?? 0;
});
