import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property.dart';
import '../models/property_image.dart';
import '../models/property_amenity.dart';
import '../models/property_review.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class PropertyService {
  final ApiClient _apiClient;

  PropertyService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: kBaseUrl);

  Future<List<Property>> getProperties(String? token) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/properties',
      requiresAuth: token != null,
    );

    if (response.success && response.data != null) {
      // Check if the response contains a 'properties' key
      if (response.data!.containsKey('properties') &&
          response.data!['properties'] is List) {
        final propertiesList = response.data!['properties'] as List;
        return propertiesList.map((json) => _mapJsonToProperty(json)).toList();
      } else {
        // Fallback to the old implementation if the response format is different
        if (response.data! is List) {
          return (response.data! as List)
              .map((json) => _mapJsonToProperty(json))
              .toList();
        }
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception(response.error ?? 'Failed to load properties');
    }
  }

  // Helper method to map JSON to Property
  Property _mapJsonToProperty(Map<String, dynamic> json) {
    // Handle images
    List<PropertyImage> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = (json['images'] as List)
          .map((imageJson) => PropertyImage.fromJson(imageJson))
          .toList();
    }

    // Handle amenities
    List<PropertyAmenity> amenitiesList = [];
    if (json['amenities'] != null && json['amenities'] is List) {
      amenitiesList = (json['amenities'] as List)
          .map((amenityJson) => PropertyAmenity.fromJson(amenityJson))
          .toList();
    }

    // Handle reviews
    List<PropertyReview> reviewsList = [];
    if (json['reviews'] != null && json['reviews'] is List) {
      reviewsList = (json['reviews'] as List)
          .map((reviewJson) => PropertyReview.fromJson(reviewJson))
          .toList();
    }

    // Parse numeric values safely
    double parseDoubleValue(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int parseIntValue(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return Property(
      id: parseIntValue(json['id']),
      hostId: parseIntValue(json['host_id'] ?? json['owner_id']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zipCode: json['zip_code'] ?? '',
      latitude: parseDoubleValue(json['latitude']),
      longitude: parseDoubleValue(json['longitude']),
      pricePerNight: parseDoubleValue(json['price_per_night'] ?? json['price']),
      bedrooms: parseIntValue(json['bedrooms']),
      bathrooms: parseIntValue(json['bathrooms']),
      maxGuests: parseIntValue(json['max_guests'] ?? json['maxGuests']),
      propertyType: json['property_type'] ?? json['type'] ?? 'other',
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
      hostFirstName: json['host_first_name'] ?? '',
      hostLastName: json['host_last_name'] ?? '',
      primaryImage: json['primary_image'],
      avgRating: parseDoubleValue(json['avg_rating'] ?? json['rating']),
      reviewCount: parseIntValue(json['review_count'] ?? json['reviewCount']),
      images: imagesList,
      amenities: amenitiesList,
      reviews: reviewsList,
      isAvailable: json['is_available'] ?? true,
    );
  }

  Future<Property> getPropertyById(String id, String? token) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/properties/$id',
      requiresAuth: token != null,
    );

    if (response.success && response.data != null) {
      return _mapJsonToProperty(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to load property');
    }
  }

  Future<Property> createProperty(Property property, String token) async {
    debugPrint('Creating property with title: ${property.title}');

    // Format the request body according to the server's expected format
    final requestBody = {
      'title': property.title,
      'description': property.description,
      'price_per_night': property.pricePerNight,
      'address': property.address,
      'city': property.city,
      'state': property.state,
      'country': property.country,
      'zip_code': property.zipCode,
      'latitude': property.latitude,
      'longitude': property.longitude,
      'bedrooms': property.bedrooms,
      'bathrooms': property.bathrooms,
      'max_guests': property.maxGuests,
      'property_type': property.propertyType,
    };

    // Add amenities as a separate field if there are any
    if (property.amenities.isNotEmpty) {
      requestBody['amenities'] = property.amenities.map((a) => a.id).toList();
    }

    // Add images as a separate field if there are any
    if (property.images.isNotEmpty) {
      requestBody['images'] =
          property.images.map((i) => {'url': i.imageUrl}).toList();
    }

    debugPrint('Request body: $requestBody');

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/properties',
      requiresAuth: true,
      body: requestBody,
    );

    if (response.success && response.data != null) {
      debugPrint('Property created successfully');
      debugPrint('Response data: ${response.data}');

      // Check if the response has a nested 'property' object
      if (response.data!.containsKey('property') &&
          response.data!['property'] is Map<String, dynamic>) {
        // Extract the property object from the response
        final propertyData = response.data!['property'] as Map<String, dynamic>;
        debugPrint('Extracted property data: $propertyData');
        return _mapJsonToProperty(propertyData);
      } else {
        // Fallback to the old implementation
        return _mapJsonToProperty(response.data!);
      }
    } else {
      debugPrint('Failed to create property: ${response.error}');
      throw Exception(response.error ?? 'Failed to create property');
    }
  }

  Future<Property> updateProperty(Property property, String token) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/properties/${property.id}',
      requiresAuth: true,
      body: {
        'title': property.title,
        'description': property.description,
        'price_per_night': property.pricePerNight,
        'address': property.address,
        'city': property.city,
        'state': property.state,
        'country': property.country,
        'zip_code': property.zipCode,
        'latitude': property.latitude,
        'longitude': property.longitude,
        'bedrooms': property.bedrooms,
        'bathrooms': property.bathrooms,
        'max_guests': property.maxGuests,
        'property_type': property.propertyType,
        'is_available': property.isAvailable,
      },
    );

    if (response.success && response.data != null) {
      return _mapJsonToProperty(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to update property');
    }
  }

  Future<void> deleteProperty(String id, String token) async {
    final response = await _apiClient.delete(
      '/api/properties/$id',
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Failed to delete property');
    }
  }

  Future<Property> createPropertyWithImages(
    Property property,
    List<File> imageFiles,
    String token,
  ) async {
    try {
      // First, create the property without images
      final propertyData = {
        'title': property.title,
        'description': property.description,
        'price_per_night': property.pricePerNight,
        'address': property.address,
        'city': property.city,
        'state': property.state,
        'country': property.country,
        'zip_code': property.zipCode,
        'latitude': property.latitude,
        'longitude': property.longitude,
        'bedrooms': property.bedrooms,
        'bathrooms': property.bathrooms,
        'max_guests': property.maxGuests,
        'property_type': property.propertyType,
        'amenities': property.amenities.map((a) => a.id).toList(),
      };

      debugPrint('Creating property with data: $propertyData');

      // Create the property first
      final propertyResponse = await _apiClient.post<Map<String, dynamic>>(
        '/api/properties',
        requiresAuth: true,
        body: propertyData,
      );

      if (!propertyResponse.success || propertyResponse.data == null) {
        throw Exception('Failed to create property: ${propertyResponse.error}');
      }

      // Check if the response has a nested 'property' object
      Property createdProperty;
      if (propertyResponse.data!.containsKey('property') &&
          propertyResponse.data!['property'] is Map<String, dynamic>) {
        // Extract the property object from the response
        final propertyData =
            propertyResponse.data!['property'] as Map<String, dynamic>;
        debugPrint('Extracted property data: $propertyData');
        createdProperty = _mapJsonToProperty(propertyData);
      } else {
        // Fallback to the old implementation
        createdProperty = _mapJsonToProperty(propertyResponse.data!);
      }

      final propertyId = createdProperty.id;
      debugPrint('Property created with ID: $propertyId');

      // Check if the property ID is valid
      if (propertyId <= 0) {
        debugPrint('WARNING: Invalid property ID: $propertyId');
        debugPrint('This might cause issues with image uploads');
        debugPrint('Response data: ${propertyResponse.data}');
      }

      // Now upload all images at once using the multiple images endpoint
      final List<PropertyImage> uploadedImages = [];

      if (imageFiles.isNotEmpty) {
        // Try a different endpoint format based on the error
        // The server might be expecting a simpler endpoint structure
        final uri = Uri.parse(
            '${_apiClient.baseUrl}/api/properties/$propertyId/images');
        final request = http.MultipartRequest('POST', uri);

        debugPrint('Using endpoint: ${uri.toString()}');

        // Add authorization header
        request.headers['Authorization'] = 'Bearer $token';

        // Add content type header for multipart form data
        request.headers['Content-Type'] = 'multipart/form-data';

        debugPrint(
            'Uploading ${imageFiles.length} images for property $propertyId');
        debugPrint('Upload URL: ${uri.toString()}');

        // Add all image files to the request
        for (int i = 0; i < imageFiles.length; i++) {
          final fileExtension =
              path.extension(imageFiles[i].path).toLowerCase();
          final mimeType = getMimeType(fileExtension);

          // Check if file exists and is readable
          final file = imageFiles[i];
          final fileExists = await file.exists();
          if (!fileExists) {
            debugPrint('WARNING: File does not exist: ${file.path}');
            continue;
          }

          // Check file size
          final fileSize = await file.length();
          debugPrint('File size: $fileSize bytes');

          // Check if file size is too large (10MB limit is common)
          if (fileSize > 10 * 1024 * 1024) {
            debugPrint(
                'WARNING: File size is very large (${fileSize / (1024 * 1024)} MB)');
            // Continue anyway, but log the warning
          }

          // Check if file extension is supported
          final supportedExtensions = [
            '.jpg',
            '.jpeg',
            '.png',
            '.gif',
            '.webp',
            '.bmp'
          ];
          if (!supportedExtensions.contains(fileExtension.toLowerCase())) {
            debugPrint(
                'WARNING: File extension $fileExtension may not be supported');
            // Continue anyway, but log the warning
          }

          // The server is returning "Unexpected field" error
          // Let's try the simplest field name format: 'image'
          // This is likely what the server is expecting based on the error
          final fieldName = 'image';

          try {
            final multipartFile = await http.MultipartFile.fromPath(
              fieldName,
              file.path,
              contentType: MediaType('image', mimeType),
            );
            request.files.add(multipartFile);
            debugPrint(
                'Added image $i: ${file.path} with field name $fieldName');
          } catch (e) {
            debugPrint('Error adding file to request: $e');
            continue;
          }
        }

        // Set the primary image index (first image is primary by default)
        request.fields['primary_image_index'] = '0';

        // Log the request details for debugging
        debugPrint('Sending multipart request to: ${uri.toString()}');
        debugPrint('Headers: ${request.headers}');
        debugPrint('Number of files in request: ${request.files.length}');
        debugPrint('Fields: ${request.fields}');

        // Send the request with a timeout
        debugPrint('Sending request with timeout of 30 seconds');
        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            debugPrint('Request timed out after 30 seconds');
            throw TimeoutException(
                'Image upload request timed out after 30 seconds');
          },
        );

        debugPrint('Request sent successfully, awaiting response');
        final response = await http.Response.fromStream(streamedResponse);

        // Log the response
        debugPrint('Response status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');

        // Handle the response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          try {
            final jsonData = json.decode(response.body);
            debugPrint('Multiple images upload response: $jsonData');

            // Check if the response contains an array of images
            if (jsonData is Map &&
                jsonData.containsKey('images') &&
                jsonData['images'] is List) {
              final imagesList = jsonData['images'] as List;

              for (int i = 0; i < imagesList.length; i++) {
                final imageData = imagesList[i];
                final isPrimary = i == 0; // First image is primary

                final imageUrl = imageData['url'] ??
                    (imageData['image_url'] ??
                        (imageData['image'] != null
                            ? imageData['image']['url']
                            : null));

                if (imageUrl != null) {
                  uploadedImages.add(PropertyImage(
                    id: imageData['id'] ?? 0,
                    propertyId: propertyId,
                    imageUrl: imageUrl,
                    isPrimary: isPrimary,
                    createdAt: DateTime.now().toIso8601String(),
                  ));
                  debugPrint('Image $i uploaded successfully: $imageUrl');
                }
              }
            } else {
              debugPrint(
                  'Unexpected response format for multiple images upload');
            }
          } catch (parseError) {
            debugPrint(
                'Error parsing multiple images upload response: $parseError');
            debugPrint('Response body: ${response.body}');
          }
        } else {
          debugPrint(
              'Failed to upload multiple images: ${response.statusCode} - ${response.body}');
        }
      }

      // Return the property with the uploaded images
      return createdProperty.copyWith(images: uploadedImages);
    } catch (e) {
      debugPrint('Exception in createPropertyWithImages: $e');
      throw Exception('Error creating property with images: $e');
    }
  }

  /// Helper method to determine MIME type from file extension
  String getMimeType(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'jpeg';
      case '.png':
        return 'png';
      case '.gif':
        return 'gif';
      case '.webp':
        return 'webp';
      case '.bmp':
        return 'bmp';
      default:
        return 'jpeg'; // Default to JPEG
    }
  }

  /// Upload a single image to a property
  /// Returns the URL of the uploaded image or null if upload failed
  ///
  /// @param propertyId The ID of the property to upload the image to
  /// @param imageFile The image file to upload
  /// @param token The authentication token
  /// @param fieldName The field name to use in the multipart request (default: 'file')
  Future<String?> uploadSingleImage(
      int propertyId, File imageFile, String token,
      [String fieldName = 'file']) async {
    try {
      // Validate inputs
      if (token.isEmpty) {
        debugPrint('Authentication token is empty');
        return null;
      }

      if (propertyId <= 0) {
        debugPrint('Invalid property ID: $propertyId');
        return null;
      }

      debugPrint(
          'Uploading image to property $propertyId with field name: $fieldName');

      // Create a multipart request
      // Try the endpoint format from the API response
      final uri =
          Uri.parse('${_apiClient.baseUrl}/api/properties/$propertyId/images');
      final request = http.MultipartRequest('POST', uri);

      debugPrint('Using image upload endpoint: ${uri.toString()}');

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Check if file exists
      if (!await imageFile.exists()) {
        debugPrint('File does not exist: ${imageFile.path}');
        return null;
      }

      // Get file extension and determine MIME type
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final mimeType = getMimeType(fileExtension);

      // Use the provided field name
      debugPrint('Using field name: $fieldName for image upload');

      final multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        imageFile.path,
        contentType: MediaType('image', mimeType),
      );
      request.files.add(multipartFile);

      debugPrint('Sending single image upload request to: ${uri.toString()}');
      debugPrint(
          'File: ${imageFile.path}, size: ${await imageFile.length()} bytes');

      // Send the request with a timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('Request timed out after 30 seconds');
          throw TimeoutException(
              'Image upload request timed out after 30 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      // Log the response
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

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
        final errorMessage =
            'Failed to upload image: ${response.statusCode} - ${response.body}';
        debugPrint(errorMessage);

        // Check for specific error messages
        if (response.body.contains('Unexpected field')) {
          debugPrint(
              'The server is reporting "Unexpected field" error. Field name "$fieldName" is not accepted.');
          debugPrint(
              'Try a different field name like "image", "file", "photo", etc.');
        }

        return null;
      }
    } catch (e) {
      debugPrint('Exception in uploadSingleImage: $e');
      return null;
    }
  }

  /// Create a property with images in a single API request
  /// This method uses a multipart request to send both property data and image files
  ///
  /// @param property The property to create
  /// @param imageFiles The list of image files to upload
  /// @param token The authentication token
  Future<Property> createPropertyWithImagesInOneRequest(
    Property property,
    List<File> imageFiles,
    String token,
  ) async {
    try {
      debugPrint('Creating property with images in one request');

      // Validate inputs
      if (token.isEmpty) {
        throw Exception('Authentication token is empty');
      }

      if (imageFiles.isEmpty) {
        debugPrint('Warning: No image files provided');
      }

      // Create a multipart request
      final uri = Uri.parse('${_apiClient.baseUrl}/api/properties');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add property data fields
      request.fields['title'] = property.title;
      request.fields['description'] = property.description;
      request.fields['address'] = property.address;
      request.fields['city'] = property.city;
      request.fields['state'] = property.state;
      request.fields['country'] = property.country;
      request.fields['zip_code'] = property.zipCode;
      request.fields['latitude'] = property.latitude.toString();
      request.fields['longitude'] = property.longitude.toString();
      request.fields['price_per_night'] = property.pricePerNight.toString();
      request.fields['bedrooms'] = property.bedrooms.toString();
      request.fields['bathrooms'] = property.bathrooms.toString();
      request.fields['max_guests'] = property.maxGuests.toString();
      request.fields['property_type'] = property.propertyType;

      // Add amenities as JSON array
      if (property.amenities.isNotEmpty) {
        final amenitiesIds = property.amenities.map((a) => a.id).toList();
        request.fields['amenities'] = jsonEncode(amenitiesIds);
      }

      // Add image files
      for (var i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final fileExtension = path.extension(file.path).toLowerCase();
        final mimeType = getMimeType(fileExtension);

        // Check if file exists
        if (!await file.exists()) {
          debugPrint('Warning: File does not exist: ${file.path}');
          continue;
        }

        // Create a multipart file
        final multipartFile = await http.MultipartFile.fromPath(
          'property_images', // Field name must match backend expectation
          file.path,
          contentType: MediaType('image', mimeType),
        );

        request.files.add(multipartFile);
        debugPrint('Added image $i: ${file.path}');
      }

      // Log request details
      debugPrint('Sending request to: ${uri.toString()}');
      debugPrint('Headers: ${request.headers}');
      debugPrint('Fields: ${request.fields}');
      debugPrint('Number of files: ${request.files.length}');

      // Send the request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('Request timed out after 60 seconds');
          throw TimeoutException('Request timed out after 60 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      // Log response
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check if the response has a nested 'property' object
        if (responseData is Map &&
            responseData.containsKey('property') &&
            responseData['property'] is Map<String, dynamic>) {
          // Extract the property object from the response
          final propertyData = responseData['property'] as Map<String, dynamic>;
          debugPrint('Extracted property data: $propertyData');
          return _mapJsonToProperty(propertyData);
        } else {
          // Fallback to the old implementation
          return _mapJsonToProperty(responseData);
        }
      } else {
        final errorMessage =
            'Failed to create property: ${response.statusCode} - ${response.body}';
        debugPrint(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Exception in createPropertyWithImagesInOneRequest: $e');
      throw Exception('Error creating property with images: $e');
    }
  }

  // Define the searchProperties method to fix the compilation error
  Future<List<Property>> searchProperties(
    String query, {
    String? location,
    String? city,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String? propertyType,
    int? page,
    int? limit,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{
      'query': query,
      if (location != null) 'location': location,
      if (city != null) 'city': city,
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
      if (bedrooms != null) 'bedrooms': bedrooms.toString(),
      if (propertyType != null) 'property_type': propertyType,
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/properties/search',
      queryParams: queryParams,
      requiresAuth: token != null,
    );

    if (response.success && response.data != null) {
      // Check if the response contains a 'properties' key
      if (response.data!.containsKey('properties') &&
          response.data!['properties'] is List) {
        final propertiesList = response.data!['properties'] as List;
        return propertiesList
            .map((json) => _mapJsonToProperty(json as Map<String, dynamic>))
            .toList();
      } else {
        // Fallback to the old implementation if the response format is different
        if (response.data! is List) {
          final dataList = response.data! as List;
          return dataList
              .map((json) => _mapJsonToProperty(json as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception(response.error ?? 'Failed to search properties');
    }
  }
}
