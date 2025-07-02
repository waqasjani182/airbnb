import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property2.dart';
import '../models/property_response.dart';
import '../services/property_service2.dart';
import '../utils/property_converter.dart';
import 'auth_provider.dart';
import 'api_provider.dart';

// Property state
enum PropertyStatus {
  initial,
  loading,
  success,
  error,
}

class PropertyState2 {
  final PropertyStatus status;
  final List<Property2> properties;
  final Property2? selectedProperty;
  final String? errorMessage;
  final bool isLoading;
  final Map<String, dynamic>? pagination;

  PropertyState2({
    this.status = PropertyStatus.initial,
    this.properties = const [],
    this.selectedProperty,
    this.errorMessage,
    this.isLoading = false,
    this.pagination,
  });

  PropertyState2 copyWith({
    PropertyStatus? status,
    List<Property2>? properties,
    Property2? selectedProperty,
    String? errorMessage,
    bool? isLoading,
    Map<String, dynamic>? pagination,
  }) {
    return PropertyState2(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      selectedProperty: selectedProperty ?? this.selectedProperty,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      pagination: pagination ?? this.pagination,
    );
  }
}

// Property notifier
class PropertyNotifier2 extends StateNotifier<PropertyState2> {
  final PropertyService2 _propertyService;
  final String? _authToken;

  PropertyNotifier2(this._propertyService, this._authToken)
      : super(PropertyState2());

  Future<void> fetchProperties() async {
    state = state.copyWith(
      status: PropertyStatus.loading,
      isLoading: true,
    );
    try {
      final response = await _propertyService.getProperties(token: _authToken);
      state = state.copyWith(
        status: PropertyStatus.success,
        properties: response.properties,
        pagination: response.pagination,
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
      final property =
          await _propertyService.getPropertyById(id, token: _authToken);
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

  Future<Property2> createProperty(Property2 property) async {
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

  Future<void> updateProperty(Property2 property) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      final updatedProperty =
          await _propertyService.updateProperty(property, _authToken!);
      final updatedProperties = state.properties.map((p) {
        return p.propertyId == updatedProperty.propertyId ? updatedProperty : p;
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

  Future<void> deleteProperty(int propertyId) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      await _propertyService.deleteProperty(propertyId, _authToken!);
      final updatedProperties =
          state.properties.where((p) => p.propertyId != propertyId).toList();
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
    String? city,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String? propertyType,
    double? minRating,
    double? maxRating,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? page,
    int? limit,
  }) async {
    print(
        'PropertyProvider2.searchProperties - Starting search with query: $query');
    print(
        'PropertyProvider2.searchProperties - Parameters: city=$city, minPrice=$minPrice, maxPrice=$maxPrice, bedrooms=$bedrooms, propertyType=$propertyType');

    state = state.copyWith(
      isLoading: true,
      errorMessage: null, // Clear previous errors
    );
    try {
      final response = await _propertyService.searchProperties(
        query,
        city: city,
        minPrice: minPrice,
        maxPrice: maxPrice,
        bedrooms: bedrooms,
        propertyType: propertyType,
        minRating: minRating,
        maxRating: maxRating,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        page: page,
        limit: limit,
        token: _authToken,
      );

      print(
          'PropertyProvider2.searchProperties - Response received: ${response.properties.length} properties');
      print(
          'PropertyProvider2.searchProperties - Properties: ${response.properties.map((p) => p.title).toList()}');

      state = state.copyWith(
        properties: response.properties,
        pagination: response.pagination,
        isLoading: false,
        status: PropertyStatus.success,
      );

      print(
          'PropertyProvider2.searchProperties - State updated with ${state.properties.length} properties');
    } catch (e) {
      print('PropertyProvider2.searchProperties - Error: $e');
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
        status: PropertyStatus.error,
      );
    }
  }

  // Create a property with images in a single request
  Future<Property2> createPropertyWithImages({
    required Property2 property,
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
      // Create property with images in a single request
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
      throw Exception('Failed to create property with images: $e');
    }
  }
}

// Providers
final propertyService2Provider = Provider<PropertyService2>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PropertyService2(apiClient: apiClient);
});

final propertyProvider2 =
    StateNotifierProvider<PropertyNotifier2, PropertyState2>((ref) {
  final propertyService = ref.watch(propertyService2Provider);
  final authState = ref.watch(authProvider);
  return PropertyNotifier2(propertyService, authState.token);
});
