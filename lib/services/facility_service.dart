import 'package:flutter/foundation.dart';
import '../models/facility.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class FacilityService {
  final ApiClient _apiClient;

  FacilityService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: kBaseUrl);

  Future<List<Facility>> getAllFacilities(String? token) async {
    debugPrint(
        'Fetching facilities from API with token: ${token != null ? 'Available' : 'Not available'}');

    final response = await _apiClient.get<List<dynamic>>(
      '/api/facilities',
      requiresAuth: token != null,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );

    debugPrint(
        'Facilities API response: success=${response.success}, data=${response.data != null ? 'Available' : 'Null'}');

    if (response.success && response.data != null) {
      try {
        // The API returns a direct array of facilities
        final facilities = response.data!.map((json) {
          debugPrint('Parsing facility: $json');
          return Facility.fromJson(json as Map<String, dynamic>);
        }).toList();

        debugPrint('Successfully parsed ${facilities.length} facilities');
        return facilities;
      } catch (e) {
        debugPrint('Error parsing facilities: $e');
        throw Exception('Failed to parse facilities: $e');
      }
    } else {
      debugPrint('Failed to load facilities: ${response.error}');
      throw Exception(response.error ?? 'Failed to load facilities');
    }
  }

  Future<Facility> getFacilityById(String id, String? token) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/facilities/$id',
      requiresAuth: token != null,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );

    if (response.success && response.data != null) {
      return Facility.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to load facility');
    }
  }
}
