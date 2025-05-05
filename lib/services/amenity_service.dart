import '../models/amenity.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class AmenityService {
  final ApiClient _apiClient;

  AmenityService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: kBaseUrl);

  Future<List<Amenity>> getAllAmenities(String? token) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/api/amenities',
      requiresAuth: token != null,
    );

    if (response.success && response.data != null) {
      try {
        // The API returns a direct array of amenities
        return response.data!
            .map((json) => Amenity.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw Exception('Failed to parse amenities: $e');
      }
    } else {
      throw Exception(response.error ?? 'Failed to load amenities');
    }
  }

  Future<Amenity> getAmenityById(String id, String? token) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/amenities/$id',
      requiresAuth: token != null,
    );

    if (response.success && response.data != null) {
      return Amenity.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to load amenity');
    }
  }

  Future<Amenity> createAmenity(Amenity amenity, String token) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/amenities',
      requiresAuth: true,
      body: {
        'name': amenity.name,
        'icon': amenity.icon,
      },
    );

    if (response.success && response.data != null) {
      return Amenity.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to create amenity');
    }
  }

  Future<Amenity> updateAmenity(Amenity amenity, String token) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/amenities/${amenity.id}',
      requiresAuth: true,
      body: {
        'name': amenity.name,
        'icon': amenity.icon,
      },
    );

    if (response.success && response.data != null) {
      return Amenity.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to update amenity');
    }
  }

  Future<void> deleteAmenity(String id, String token) async {
    final response = await _apiClient.delete(
      '/api/amenities/$id',
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Failed to delete amenity');
    }
  }
}
