import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/amenity.dart';
import '../services/amenity_service.dart';
import 'auth_provider.dart';
import 'api_provider.dart';

// Amenity state
enum AmenityStatus {
  initial,
  loading,
  success,
  error,
}

class AmenityState {
  final AmenityStatus status;
  final List<Amenity> amenities;
  final Amenity? selectedAmenity;
  final String? errorMessage;
  final bool isLoading;

  AmenityState({
    this.status = AmenityStatus.initial,
    this.amenities = const [],
    this.selectedAmenity,
    this.errorMessage,
    this.isLoading = false,
  });

  AmenityState copyWith({
    AmenityStatus? status,
    List<Amenity>? amenities,
    Amenity? selectedAmenity,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AmenityState(
      status: status ?? this.status,
      amenities: amenities ?? this.amenities,
      selectedAmenity: selectedAmenity ?? this.selectedAmenity,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Amenity notifier
class AmenityNotifier extends StateNotifier<AmenityState> {
  final AmenityService _amenityService;
  final String? _authToken;

  AmenityNotifier(this._amenityService, this._authToken)
      : super(AmenityState());

  Future<void> fetchAmenities() async {
    state = state.copyWith(
      status: AmenityStatus.loading,
      isLoading: true,
    );
    try {
      final amenities = await _amenityService.getAllAmenities(_authToken);
      state = state.copyWith(
        status: AmenityStatus.success,
        amenities: amenities,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: AmenityStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> fetchAmenityById(String id) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      final amenity = await _amenityService.getAmenityById(id, _authToken);
      state = state.copyWith(
        selectedAmenity: amenity,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> createAmenity(Amenity amenity) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      final newAmenity =
          await _amenityService.createAmenity(amenity, _authToken!);
      state = state.copyWith(
        amenities: [...state.amenities, newAmenity],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> updateAmenity(Amenity amenity) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      final updatedAmenity =
          await _amenityService.updateAmenity(amenity, _authToken!);
      final updatedAmenities = state.amenities.map((a) {
        return a.id == updatedAmenity.id ? updatedAmenity : a;
      }).toList();
      state = state.copyWith(
        amenities: updatedAmenities,
        selectedAmenity: updatedAmenity,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> deleteAmenity(String idStr) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      await _amenityService.deleteAmenity(idStr, _authToken!);
      // Convert string id to int for comparison
      final id = int.tryParse(idStr) ?? 0;
      final updatedAmenities =
          state.amenities.where((a) => a.id != id).toList();
      state = state.copyWith(
        amenities: updatedAmenities,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }
}

// Providers
final amenityServiceProvider = Provider<AmenityService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AmenityService(apiClient: apiClient);
});

final amenityProvider =
    StateNotifierProvider<AmenityNotifier, AmenityState>((ref) {
  final amenityService = ref.watch(amenityServiceProvider);
  final authState = ref.watch(authProvider);
  return AmenityNotifier(amenityService, authState.token);
});
