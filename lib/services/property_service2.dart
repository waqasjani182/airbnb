import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../models/property2.dart';
import '../models/property_response.dart';
import '../utils/constants.dart';
import 'api_client.dart';
import 'direct_http_service.dart';

class PropertyService2 {
  final ApiClient _apiClient;
  final DirectHttpService? _directHttpService;
  final bool _useDirect;

  PropertyService2({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: kBaseUrl),
        // Use DirectHttpService on macOS to bypass App Sandbox restrictions
        _useDirect = Platform.isMacOS,
        _directHttpService = Platform.isMacOS ? DirectHttpService() : null;

  // Get all properties
  Future<PropertyResponse> getProperties({String? token}) async {
    try {
      if (_useDirect && _directHttpService != null) {
        // Use direct HTTP service on macOS
        final data = await _directHttpService.get(
          '/api/properties',
          token: token,
        );
        return PropertyResponse.fromJson(data);
      } else {
        // Use ApiClient on other platforms
        final response = await _apiClient.get<Map<String, dynamic>>(
          '/api/properties',
          requiresAuth: token != null,
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        );

        if (response.success && response.data != null) {
          return PropertyResponse.fromJson(response.data!);
        } else {
          throw Exception(response.error ?? 'Failed to load properties');
        }
      }
    } catch (e) {
      debugPrint('Error getting properties: $e');
      throw Exception('Failed to load properties: $e');
    }
  }

  // Get property by ID
  Future<Property2> getPropertyById(String id, {String? token}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/properties/$id',
      requiresAuth: token != null,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );

    if (response.success && response.data != null) {
      return Property2.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to load property');
    }
  }

  // Create a new property
  Future<Property2> createProperty(Property2 property, String token) async {
    debugPrint('Creating property with title: ${property.title}');

    // Format the request body according to the server's expected format
    final requestBody = {
      'title': property.title,
      'description': property.description,
      'rent_per_day': property.rentPerDay,
      'address': property.address,
      'city': property.city,
      'property_type': property.propertyType,
      'longitude': property.longitude,
      'latitude': property.latitude,
      'guest': property.guest,
    };

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/properties',
      body: requestBody,
      requiresAuth: true,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.success && response.data != null) {
      debugPrint('Property created successfully');
      debugPrint('Response data: ${response.data}');

      return Property2.fromJson(response.data!);
    } else {
      debugPrint('Failed to create property: ${response.error}');
      throw Exception(response.error ?? 'Failed to create property');
    }
  }

  // Update an existing property
  Future<Property2> updateProperty(Property2 property, String token) async {
    debugPrint('Updating property with ID: ${property.propertyId}');

    // Format the request body according to the server's expected format
    final requestBody = {
      'title': property.title,
      'description': property.description,
      'rent_per_day': property.rentPerDay,
      'address': property.address,
      'city': property.city,
      'property_type': property.propertyType,
      'longitude': property.longitude,
      'latitude': property.latitude,
      'guest': property.guest,
    };

    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/properties/${property.propertyId}',
      body: requestBody,
      requiresAuth: true,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.success && response.data != null) {
      debugPrint('Property updated successfully');
      return Property2.fromJson(response.data!);
    } else {
      debugPrint('Failed to update property: ${response.error}');
      throw Exception(response.error ?? 'Failed to update property');
    }
  }

  // Delete a property
  Future<bool> deleteProperty(int propertyId, String token) async {
    debugPrint('Deleting property with ID: $propertyId');

    final response = await _apiClient.delete(
      '/api/properties/$propertyId',
      requiresAuth: true,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.success) {
      debugPrint('Property deleted successfully');
      return true;
    } else {
      debugPrint('Failed to delete property: ${response.error}');
      throw Exception(response.error ?? 'Failed to delete property');
    }
  }

  // Upload property image
  Future<String?> uploadPropertyImage(
    File imageFile,
    int propertyId,
    String token,
  ) async {
    debugPrint('Uploading image for property ID: $propertyId');

    // Create a multipart request
    final uri = Uri.parse('$kBaseUrl/api/properties/$propertyId/images');
    final request = http.MultipartRequest('POST', uri);

    // Add the authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Add the file to the request
    final fileStream = http.ByteStream(imageFile.openRead());
    final fileLength = await imageFile.length();
    final fileName = path.basename(imageFile.path);
    final contentType = MediaType('image', 'jpeg'); // Adjust as needed

    final multipartFile = http.MultipartFile(
      'image',
      fileStream,
      fileLength,
      filename: fileName,
      contentType: contentType,
    );

    request.files.add(multipartFile);

    // Send the request
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Handle the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final jsonData = json.decode(response.body);

          // Extract the image URL from the response
          String? imageUrl;

          if (jsonData is Map) {
            // Try different possible response formats
            if (jsonData.containsKey('image_url')) {
              imageUrl = jsonData['image_url'];
            } else if (jsonData.containsKey('url')) {
              imageUrl = jsonData['url'];
            } else if (jsonData.containsKey('image') &&
                jsonData['image'] is Map) {
              imageUrl = jsonData['image']['url'];
            }
          }

          if (imageUrl != null) {
            debugPrint('Image uploaded successfully: $imageUrl');
            return imageUrl;
          } else {
            debugPrint('Image URL not found in response');
            return null;
          }
        } catch (e) {
          debugPrint('Error parsing response: $e');
          return null;
        }
      } else {
        debugPrint(
            'Failed to upload image: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception during image upload: $e');
      return null;
    }
  }

  // Create property with images in a single request
  Future<Property2> createPropertyWithImages(
    Property2 property,
    List<File> imageFiles,
    String token,
  ) async {
    debugPrint('Creating property with images in a single request');

    // Create a multipart request
    final uri = Uri.parse('$kBaseUrl/api/properties');
    final request = http.MultipartRequest('POST', uri);

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Add property fields
    request.fields['title'] = property.title;
    request.fields['description'] = property.description;
    request.fields['rent_per_day'] = property.rentPerDay.toString();
    request.fields['address'] = property.address;
    request.fields['city'] = property.city;
    request.fields['property_type'] = property.propertyType;
    request.fields['longitude'] = property.longitude.toString();
    request.fields['latitude'] = property.latitude.toString();
    request.fields['guest'] = property.guest.toString();

    // Add facilities if available
    if (property.facilities.isNotEmpty) {
      final facilityIds =
          property.facilities.map((f) => f.facilityId.toString()).toList();
      request.fields['facilities'] = '[${facilityIds.join(',')}]';
      debugPrint('Adding facilities: [${facilityIds.join(',')}]');
    }

    // Add additional property details if available
    if (property.totalBedrooms != null) {
      request.fields['total_bedrooms'] = property.totalBedrooms.toString();
    }
    if (property.totalRooms != null) {
      request.fields['total_rooms'] = property.totalRooms.toString();
    }
    if (property.totalBeds != null) {
      request.fields['total_beds'] = property.totalBeds.toString();
    }

    // Add image files
    for (var i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];

      // Verify file exists before attempting to upload
      if (!await file.exists()) {
        debugPrint('Image file does not exist: ${file.path}');
        throw Exception('Image file not found: ${path.basename(file.path)}');
      }

      final fileName = path.basename(file.path);
      final fileExtension = path.extension(fileName).toLowerCase();
      String mimeType = 'jpeg';

      // Determine MIME type based on file extension
      if (fileExtension == '.png') {
        mimeType = 'png';
      } else if (fileExtension == '.jpg' || fileExtension == '.jpeg') {
        mimeType = 'jpeg';
      }

      try {
        final multipartFile = await http.MultipartFile.fromPath(
          'property_images', // Field name must match what the API expects
          file.path,
          contentType: MediaType('image', mimeType),
        );

        request.files.add(multipartFile);
        debugPrint('Added image $i: $fileName (${await file.length()} bytes)');
      } catch (e) {
        debugPrint('Failed to add image $i: $fileName - Error: $e');
        throw Exception(
            'Failed to process image: ${path.basename(file.path)} - $e');
      }
    }

    try {
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);

        if (jsonData != null && jsonData.containsKey('property')) {
          return Property2.fromJson(jsonData['property']);
        } else {
          throw Exception('Invalid response format from server');
        }
      } else {
        throw Exception(
            'Failed to create property: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception during property creation: $e');
      throw Exception('Failed to create property with images: $e');
    }
  }

  // Search properties
  Future<PropertyResponse> searchProperties(
    String query, {
    String? city,
    double? minPrice,
    double? maxPrice,
    String? propertyType,
    int? page,
    int? limit,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      'query': query,
      if (city != null) 'city': city,
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
      if (propertyType != null) 'property_type': propertyType,
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/properties/search',
      queryParams: queryParams,
      requiresAuth: token != null,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );

    if (response.success && response.data != null) {
      return PropertyResponse.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to search properties');
    }
  }
}
