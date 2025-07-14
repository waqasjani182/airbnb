import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../models/property2.dart';
import '../models/property_response.dart';
import '../models/user_property.dart';
import '../models/property_status.dart';
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

  // Get user properties
  Future<UserPropertiesResponse> getUserProperties({String? token}) async {
    try {
      if (_useDirect && _directHttpService != null) {
        // Use direct HTTP service on macOS
        final data = await _directHttpService.get(
          '/api/users/properties/',
          token: token,
        );
        return UserPropertiesResponse.fromJson(data);
      } else {
        // Use ApiClient on other platforms
        final response = await _apiClient.get<Map<String, dynamic>>(
          '/api/users/properties/',
          requiresAuth: token != null,
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        );

        if (response.success && response.data != null) {
          return UserPropertiesResponse.fromJson(response.data!);
        } else {
          throw Exception(response.error ?? 'Failed to load user properties');
        }
      }
    } catch (e) {
      debugPrint('Error getting user properties: $e');
      throw Exception('Failed to load user properties: $e');
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

  // Update property with images using multipart form data
  Future<Property2> updatePropertyWithImages({
    required Property2 property,
    required List<File> imageFiles,
    required String token,
    List<String>? existingImageUrls,
  }) async {
    debugPrint('Updating property with images, ID: ${property.propertyId}');
    debugPrint('Image files count: ${imageFiles.length}');
    debugPrint('Existing image URLs count: ${existingImageUrls?.length ?? 0}');

    try {
      // Create a multipart request for property update
      final uri = Uri.parse('$kBaseUrl/api/properties/${property.propertyId}');
      final request = http.MultipartRequest('PUT', uri);

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

      // Add property type specific fields
      if (property.totalBedrooms != null) {
        request.fields['total_bedrooms'] = property.totalBedrooms.toString();
      }
      if (property.totalRooms != null) {
        request.fields['total_rooms'] = property.totalRooms.toString();
      }
      if (property.totalBeds != null) {
        request.fields['total_beds'] = property.totalBeds.toString();
      }

      // Add facilities if any
      if (property.facilities.isNotEmpty) {
        request.fields['facilities'] = jsonEncode(
          property.facilities.map((f) => f.facilityId).toList(),
        );
      }

      // Add existing image URLs if provided (mixed approach)
      if (existingImageUrls != null && existingImageUrls.isNotEmpty) {
        request.fields['images'] = jsonEncode(
          existingImageUrls.map((url) => {'url': url}).toList(),
        );
      }

      // Add image files
      for (final imageFile in imageFiles) {
        final fileStream = http.ByteStream(imageFile.openRead());
        final fileLength = await imageFile.length();
        final fileName = path.basename(imageFile.path);

        final multipartFile = http.MultipartFile(
          'property_images', // Field name as per API guide
          fileStream,
          fileLength,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);
      }

      debugPrint('Sending property update request to: ${uri.toString()}');
      debugPrint('Request fields: ${request.fields}');
      debugPrint('Request files count: ${request.files.length}');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Update response status: ${response.statusCode}');
      debugPrint('Update response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body);

        // Handle different response formats
        if (jsonData['property'] != null) {
          return Property2.fromJson(jsonData['property']);
        } else if (jsonData is Map<String, dynamic>) {
          return Property2.fromJson(jsonData);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        String errorMessage;
        try {
          final jsonData = jsonDecode(response.body);
          errorMessage =
              jsonData['message'] ?? 'Failed to update property with images';
        } catch (e) {
          errorMessage =
              'Failed to update property with images: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error updating property with images: $e');
      throw Exception('Failed to update property with images: $e');
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

  // Upload single property image (dedicated endpoint)
  Future<String?> uploadSinglePropertyImage({
    required File imageFile,
    required int propertyId,
    required String token,
    bool isPrimary = false,
  }) async {
    debugPrint('Uploading single image for property ID: $propertyId');

    try {
      // Create a multipart request
      final uri = Uri.parse('$kBaseUrl/api/properties/$propertyId/images');
      final request = http.MultipartRequest('POST', uri);

      // Add the authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add the file to the request
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      final fileName = path.basename(imageFile.path);
      final contentType = MediaType('image', 'jpeg');

      final multipartFile = http.MultipartFile(
        'property_image', // Field name as per API guide
        fileStream,
        fileLength,
        filename: fileName,
        contentType: contentType,
      );

      request.files.add(multipartFile);

      // Add primary flag if specified
      if (isPrimary) {
        request.fields['is_primary'] = 'true';
      }

      debugPrint('Sending single image upload request to: ${uri.toString()}');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Upload response status: ${response.statusCode}');
      debugPrint('Upload response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body);

        // Check for different possible response formats
        if (jsonData['image_url'] != null) {
          return jsonData['image_url'];
        } else if (jsonData['url'] != null) {
          return jsonData['url'];
        } else if (jsonData['data'] != null &&
            jsonData['data']['url'] != null) {
          return jsonData['data']['url'];
        } else if (jsonData['image'] != null) {
          if (jsonData['image']['url'] != null) {
            return jsonData['image']['url'];
          } else if (jsonData['image']['image_url'] != null) {
            return jsonData['image']['image_url'];
          }
        } else {
          debugPrint('Unexpected response format: $jsonData');
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

  // Upload multiple property images (dedicated endpoint)
  Future<List<String>> uploadMultiplePropertyImages({
    required List<File> imageFiles,
    required int propertyId,
    required String token,
    bool setPrimary = false,
  }) async {
    debugPrint(
        'Uploading ${imageFiles.length} images for property ID: $propertyId');

    try {
      // Create a multipart request
      final uri =
          Uri.parse('$kBaseUrl/api/properties/$propertyId/images/multiple');
      final request = http.MultipartRequest('POST', uri);

      // Add the authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add all image files
      for (final imageFile in imageFiles) {
        final fileStream = http.ByteStream(imageFile.openRead());
        final fileLength = await imageFile.length();
        final fileName = path.basename(imageFile.path);
        final contentType = MediaType('image', 'jpeg');

        final multipartFile = http.MultipartFile(
          'property_images', // Field name as per API guide
          fileStream,
          fileLength,
          filename: fileName,
          contentType: contentType,
        );

        request.files.add(multipartFile);
      }

      // Add primary flag if specified
      if (setPrimary) {
        request.fields['set_primary'] = 'true';
      }

      debugPrint(
          'Sending multiple images upload request to: ${uri.toString()}');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Upload response status: ${response.statusCode}');
      debugPrint('Upload response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body);
        final List<String> uploadedUrls = [];

        // Handle different response formats
        if (jsonData['images'] != null && jsonData['images'] is List) {
          for (final image in jsonData['images']) {
            if (image['image_url'] != null) {
              uploadedUrls.add(image['image_url']);
            } else if (image['url'] != null) {
              uploadedUrls.add(image['url']);
            }
          }
        } else if (jsonData['urls'] != null && jsonData['urls'] is List) {
          uploadedUrls.addAll(List<String>.from(jsonData['urls']));
        }

        debugPrint('Successfully uploaded ${uploadedUrls.length} images');
        return uploadedUrls;
      } else {
        debugPrint(
            'Failed to upload images: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception during multiple images upload: $e');
      return [];
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
    int? bedrooms,
    String? propertyType,
    double? minRating,
    double? maxRating,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? page,
    int? limit,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      'query': query,
      if (city != null) 'city': city,
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
      if (bedrooms != null) 'bedrooms': bedrooms.toString(),
      if (propertyType != null) 'property_type': propertyType,
      if (minRating != null) 'min_rating': minRating.toString(),
      if (maxRating != null) 'max_rating': maxRating.toString(),
      if (checkInDate != null)
        'check_in_date': checkInDate.toIso8601String().split('T')[0],
      if (checkOutDate != null)
        'check_out_date': checkOutDate.toIso8601String().split('T')[0],
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

  // Property Status Management Methods

  // Get property status
  Future<PropertyStatus> getPropertyStatus(int propertyId, String token) async {
    debugPrint('Getting status for property ID: $propertyId');

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/properties/$propertyId/status',
        requiresAuth: true,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.success && response.data != null) {
        return PropertyStatus.fromJson(response.data!);
      } else {
        throw Exception(response.error ?? 'Failed to get property status');
      }
    } catch (e) {
      debugPrint('Error getting property status: $e');
      throw Exception('Failed to get property status: $e');
    }
  }

  // Set property to maintenance
  Future<PropertyStatusResponse> setPropertyMaintenance({
    required int propertyId,
    required String maintenanceReason,
    required String token,
  }) async {
    debugPrint('Setting property $propertyId to maintenance');

    try {
      final requestBody = SetMaintenanceRequest(
        maintenanceReason: maintenanceReason,
      ).toJson();

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/api/properties/$propertyId/maintenance',
        body: requestBody,
        requiresAuth: true,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.success && response.data != null) {
        return PropertyStatusResponse.fromJson(response.data!);
      } else {
        throw Exception(
            response.error ?? 'Failed to set property to maintenance');
      }
    } catch (e) {
      debugPrint('Error setting property to maintenance: $e');
      throw Exception('Failed to set property to maintenance: $e');
    }
  }

  // Activate property from maintenance
  Future<PropertyStatusResponse> activateProperty({
    required int propertyId,
    required String token,
  }) async {
    debugPrint('Activating property $propertyId from maintenance');

    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/api/properties/$propertyId/activate',
        requiresAuth: true,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.success && response.data != null) {
        return PropertyStatusResponse.fromJson(response.data!);
      } else {
        throw Exception(response.error ?? 'Failed to activate property');
      }
    } catch (e) {
      debugPrint('Error activating property: $e');
      throw Exception('Failed to activate property: $e');
    }
  }

  // Toggle property enable/disable
  Future<PropertyStatusResponse> togglePropertyStatus({
    required int propertyId,
    required bool isActive,
    required String token,
  }) async {
    debugPrint('Toggling property $propertyId status to: $isActive');

    try {
      final requestBody = ToggleStatusRequest(isActive: isActive).toJson();

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/api/properties/$propertyId/toggle',
        body: requestBody,
        requiresAuth: true,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.success && response.data != null) {
        return PropertyStatusResponse.fromJson(response.data!);
      } else {
        throw Exception(response.error ?? 'Failed to toggle property status');
      }
    } catch (e) {
      debugPrint('Error toggling property status: $e');
      throw Exception('Failed to toggle property status: $e');
    }
  }
}
