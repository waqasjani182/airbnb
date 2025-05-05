import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

/// A service for uploading images to the server
class ImageUploadService {
  final String baseUrl;

  ImageUploadService({required this.baseUrl});

  /// Try uploading an image using URL parameters
  /// Some APIs expect the field name as a URL parameter
  Future<String?> uploadImageWithUrlParam(
    int propertyId,
    File imageFile,
    String token,
  ) async {
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

      // Create the URL with a parameter
      final url = '$baseUrl/api/properties/$propertyId/images?fieldName=image';
      debugPrint('Uploading image using URL parameter to: $url');

      // Create a multipart request
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Get file extension and determine MIME type
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final mimeType = _getMimeType(fileExtension);

      // Add the file with a simple field name
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', mimeType),
      );
      request.files.add(multipartFile);

      debugPrint('Sending request with URL parameter');

      // Send the request
      final streamedResponse = await request.send();
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
            debugPrint(
                'Image uploaded successfully with URL parameter: $imageUrl');
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
            'Failed to upload image with URL parameter: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception in uploadImageWithUrlParam: $e');
      return null;
    }
  }

  /// Upload an image using a direct HTTP request (not using MultipartRequest)
  /// This is an alternative approach that might work if the MultipartRequest approach fails
  Future<String?> uploadImageDirect(
    int propertyId,
    File imageFile,
    String token,
  ) async {
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

      // Get file extension and determine MIME type
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final mimeType = _getMimeType(fileExtension);

      // Read the file as bytes
      final bytes = await imageFile.readAsBytes();

      // Create the URL
      final url = '$baseUrl/api/properties/$propertyId/images';
      debugPrint('Uploading image to: $url');

      // Create headers
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Encode the image as base64
      final base64Image = base64Encode(bytes);
      debugPrint('Image encoded as base64, length: ${base64Image.length}');

      // Create the request body
      final body = jsonEncode({
        'image': base64Image,
        'filename': path.basename(imageFile.path),
        'contentType': 'image/$mimeType',
      });

      // Send the request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

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
        return null;
      }
    } catch (e) {
      debugPrint('Exception in uploadImageDirect: $e');
      return null;
    }
  }

  /// Try uploading an image using a very simple approach
  /// This method tries to upload the image with a minimal request structure
  Future<String?> uploadImageSimple(
    int propertyId,
    File imageFile,
    String token,
  ) async {
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

      // Create the URL
      final url = '$baseUrl/api/properties/$propertyId/images';
      debugPrint('Uploading image using simple approach to: $url');

      // Read the file as bytes
      final bytes = await imageFile.readAsBytes();

      // Create a very simple request with just the file content
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add the file without a field name (some servers expect this)
      final multipartFile = http.MultipartFile.fromBytes(
        '', // Empty field name
        bytes,
        filename: path.basename(imageFile.path),
        contentType:
            MediaType('image', _getMimeType(path.extension(imageFile.path))),
      );

      request.files.add(multipartFile);

      debugPrint('Sending simple request with file only');

      // Send the request
      final streamedResponse = await request.send();
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
            debugPrint(
                'Image uploaded successfully with simple approach: $imageUrl');
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
            'Failed to upload image with simple approach: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception in uploadImageSimple: $e');
      return null;
    }
  }

  /// Try uploading an image using a form-data approach
  Future<String?> uploadImageFormData(
    int propertyId,
    File imageFile,
    String token,
  ) async {
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

      // Create the URL
      final url = '$baseUrl/api/properties/$propertyId/images';
      debugPrint('Uploading image using form-data to: $url');

      // Create a multipart request
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Get file extension and determine MIME type
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final mimeType = _getMimeType(fileExtension);

      // Try different field names
      final fieldNames = ['file', 'image', 'photo', 'picture'];

      for (final fieldName in fieldNames) {
        try {
          // Create a new request for each field name
          final newRequest = http.MultipartRequest('POST', Uri.parse(url));
          newRequest.headers['Authorization'] = 'Bearer $token';

          // Add the file to the request
          final multipartFile = await http.MultipartFile.fromPath(
            fieldName,
            imageFile.path,
            contentType: MediaType('image', mimeType),
          );
          newRequest.files.add(multipartFile);

          debugPrint('Trying field name: $fieldName');

          // Send the request
          final streamedResponse = await newRequest.send();
          final response = await http.Response.fromStream(streamedResponse);

          // Log the response
          debugPrint('Response status code: ${response.statusCode}');
          debugPrint('Response body: ${response.body}');

          // If successful, return the URL
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
                debugPrint(
                    'Image uploaded successfully with field name $fieldName: $imageUrl');
                return imageUrl;
              }
            } catch (e) {
              debugPrint('Error parsing response: $e');
            }
          } else {
            debugPrint(
                'Failed with field name $fieldName: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          debugPrint('Error with field name $fieldName: $e');
        }
      }

      // If all field names failed, return null
      debugPrint('All field names failed');
      return null;
    } catch (e) {
      debugPrint('Exception in uploadImageFormData: $e');
      return null;
    }
  }

  /// Helper method to determine MIME type from file extension
  String _getMimeType(String extension) {
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
}
