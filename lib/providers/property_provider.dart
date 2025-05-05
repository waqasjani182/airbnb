import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import 'auth_provider.dart';
import 'api_provider.dart';

// Property state
enum PropertyStatus {
  initial,
  loading,
  success,
  error,
}

class PropertyState {
  final PropertyStatus status;
  final List<Property> properties;
  final Property? selectedProperty;
  final String? errorMessage;
  final bool isLoading;

  PropertyState({
    this.status = PropertyStatus.initial,
    this.properties = const [],
    this.selectedProperty,
    this.errorMessage,
    this.isLoading = false,
  });

  PropertyState copyWith({
    PropertyStatus? status,
    List<Property>? properties,
    Property? selectedProperty,
    String? errorMessage,
    bool? isLoading,
  }) {
    return PropertyState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      selectedProperty: selectedProperty ?? this.selectedProperty,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Property notifier
class PropertyNotifier extends StateNotifier<PropertyState> {
  final PropertyService _propertyService;
  final String? _authToken;

  PropertyNotifier(this._propertyService, this._authToken)
      : super(PropertyState());

  Future<void> fetchProperties() async {
    state = state.copyWith(
      status: PropertyStatus.loading,
      isLoading: true,
    );
    try {
      final properties = await _propertyService.getProperties(_authToken);
      state = state.copyWith(
        status: PropertyStatus.success,
        properties: properties,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: PropertyStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> fetchPropertyById(String id) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      final property = await _propertyService.getPropertyById(id, _authToken);
      state = state.copyWith(
        selectedProperty: property,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<Property> createProperty(Property property) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      final newProperty =
          await _propertyService.createProperty(property, _authToken!);
      state = state.copyWith(
        properties: [...state.properties, newProperty],
        isLoading: false,
      );
      return newProperty;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
      throw Exception('Failed to create property: $e');
    }
  }

  Future<void> updateProperty(Property property) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      final updatedProperty =
          await _propertyService.updateProperty(property, _authToken!);
      final updatedProperties = state.properties.map((p) {
        return p.id == updatedProperty.id ? updatedProperty : p;
      }).toList();
      state = state.copyWith(
        properties: updatedProperties,
        selectedProperty: updatedProperty,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> deleteProperty(String idStr) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      await _propertyService.deleteProperty(idStr, _authToken!);
      // Convert string id to int for comparison
      final id = int.tryParse(idStr) ?? 0;
      final updatedProperties =
          state.properties.where((p) => p.id != id).toList();
      state = state.copyWith(
        properties: updatedProperties,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> searchProperties(
    String query, {
    String? location,
    String? city,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String? propertyType,
    int? page,
    int? limit,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null, // Clear previous errors
    );
    try {
      final properties = await _propertyService.searchProperties(
        query,
        location: location,
        city: city,
        minPrice: minPrice,
        maxPrice: maxPrice,
        bedrooms: bedrooms,
        propertyType: propertyType,
        page: page,
        limit: limit,
        token: _authToken,
      );
      state = state.copyWith(
        properties: properties,
        isLoading: false,
        status: PropertyStatus.success,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
        status: PropertyStatus.error,
      );
    }
  }

  // Method to toggle property favorite status
  Future<void> toggleFavorite(String propertyIdStr) async {
    if (_authToken == null) {
      state = state.copyWith(
        errorMessage: 'You must be logged in to favorite properties',
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // Convert string id to int for comparison
      final propertyId = int.tryParse(propertyIdStr) ?? 0;

      // Find the property in the list
      final updatedProperties = state.properties.map((property) {
        if (property.id == propertyId) {
          // Toggle the favorite status
          return property.copyWith(
            isFavorite: !property.isFavorite,
          );
        }
        return property;
      }).toList();

      state = state.copyWith(
        properties: updatedProperties,
        isLoading: false,
      );

      // If the selected property is the one being favorited, update it too
      if (state.selectedProperty?.id == propertyId) {
        final property =
            updatedProperties.firstWhere((p) => p.id == propertyId);
        state = state.copyWith(
          selectedProperty: property,
        );
      }

      // In a real app, you would make an API call to update the favorite status
      // For example:
      // await _propertyService.toggleFavorite(propertyIdStr, _authToken!);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<Property> createPropertyWithImages({
    required Property property,
    required List<File> imageFiles,
  }) async {
    if (_authToken == null) {
      state = state.copyWith(
        errorMessage: 'You must be logged in to create a property',
        status: PropertyStatus.error,
      );
      throw Exception('You must be logged in to create a property');
    }

    state = state.copyWith(
      isLoading: true,
      status: PropertyStatus.loading,
    );

    try {
      final newProperty = await _propertyService.createPropertyWithImages(
        property,
        imageFiles,
        _authToken,
      );

      state = state.copyWith(
        properties: [...state.properties, newProperty],
        isLoading: false,
        status: PropertyStatus.success,
      );

      return newProperty;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
        status: PropertyStatus.error,
      );
      rethrow; // Rethrow to allow the UI to handle the error
    }
  }

  /// Create a property with images in a single API request
  /// This is the recommended approach for creating properties with images
  Future<Property> createPropertyWithImagesInOneRequest({
    required Property property,
    required List<File> imageFiles,
  }) async {
    if (_authToken == null) {
      state = state.copyWith(
        errorMessage: 'You must be logged in to create a property',
        status: PropertyStatus.error,
      );
      throw Exception('You must be logged in to create a property');
    }

    state = state.copyWith(
      isLoading: true,
      status: PropertyStatus.loading,
    );

    try {
      final newProperty =
          await _propertyService.createPropertyWithImagesInOneRequest(
        property,
        imageFiles,
        _authToken,
      );

      state = state.copyWith(
        properties: [...state.properties, newProperty],
        isLoading: false,
        status: PropertyStatus.success,
      );

      return newProperty;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
        status: PropertyStatus.error,
      );
      rethrow; // Rethrow to allow the UI to handle the error
    }
  }
}

// Providers
final propertyServiceProvider = Provider<PropertyService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PropertyService(apiClient: apiClient);
});

final propertyProvider =
    StateNotifierProvider<PropertyNotifier, PropertyState>((ref) {
  final propertyService = ref.watch(propertyServiceProvider);
  final authState = ref.watch(authProvider);
  return PropertyNotifier(propertyService, authState.token);
});
