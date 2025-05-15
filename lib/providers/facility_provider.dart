import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/facility.dart';
import '../services/facility_service.dart';
import 'auth_provider.dart';
import 'api_provider.dart';

// Facility state
enum FacilityStatus {
  initial,
  loading,
  success,
  error,
}

class FacilityState {
  final FacilityStatus status;
  final List<Facility> facilities;
  final Facility? selectedFacility;
  final String? errorMessage;
  final bool isLoading;

  FacilityState({
    this.status = FacilityStatus.initial,
    this.facilities = const [],
    this.selectedFacility,
    this.errorMessage,
    this.isLoading = false,
  });

  FacilityState copyWith({
    FacilityStatus? status,
    List<Facility>? facilities,
    Facility? selectedFacility,
    String? errorMessage,
    bool? isLoading,
  }) {
    return FacilityState(
      status: status ?? this.status,
      facilities: facilities ?? this.facilities,
      selectedFacility: selectedFacility ?? this.selectedFacility,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Facility notifier
class FacilityNotifier extends StateNotifier<FacilityState> {
  final FacilityService _facilityService;
  final String? _authToken;

  FacilityNotifier(this._facilityService, this._authToken)
      : super(FacilityState());

  Future<void> fetchFacilities() async {
    state = state.copyWith(
      status: FacilityStatus.loading,
      isLoading: true,
    );
    try {
      final facilities = await _facilityService.getAllFacilities(_authToken);
      state = state.copyWith(
        status: FacilityStatus.success,
        facilities: facilities,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: FacilityStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> fetchFacilityById(String id) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      final facility = await _facilityService.getFacilityById(id, _authToken);
      state = state.copyWith(
        selectedFacility: facility,
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
final facilityServiceProvider = Provider<FacilityService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FacilityService(apiClient: apiClient);
});

final facilityProvider =
    StateNotifierProvider<FacilityNotifier, FacilityState>((ref) {
  final facilityService = ref.watch(facilityServiceProvider);
  final authState = ref.watch(authProvider);
  return FacilityNotifier(facilityService, authState.token);
});
