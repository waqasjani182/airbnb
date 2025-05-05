import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'api_client.dart';

class ImageService {
  final ApiClient _apiClient;
  late final String baseUrl;

  ImageService({ApiClient? apiClient, String? baseUrl})
      : _apiClient = apiClient ?? ApiClient() {
    // Initialize baseUrl after _apiClient is initialized
    this.baseUrl = baseUrl ?? _apiClient.baseUrl;
  }

  /// Uploads a profile image for the current user
  /// Returns the URL of the uploaded image
  Future<String> uploadProfileImage(File imageFile, String token) async {
    try {
      // Create a multipart request
      final uri = Uri.parse('$baseUrl/api/users/profile-image');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Get file extension and determine MIME type
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final mimeType = _getMimeType(fileExtension);

      // Add the file to the request
      final multipartFile = await http.MultipartFile.fromPath(
        'profile_image',
        imageFile.path,
        contentType: MediaType('image', mimeType),
      );
      request.files.add(multipartFile);

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Handle the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);
        // Check for both possible response formats
        return jsonData['user']['profile_image'] ??
            jsonData['profile_image_url'] ??
            '';
      } else {
        String errorMessage;
        try {
          final jsonData = json.decode(response.body);
          errorMessage = jsonData['message'] ?? 'Failed to upload image';
        } catch (e) {
          errorMessage = 'Failed to upload image: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Uploads a property image
  /// Returns the URL of the uploaded image
  Future<String> uploadPropertyImage(File imageFile, String token) async {
    try {
      // Create a multipart request
      final uri = Uri.parse('$baseUrl/api/properties/images');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Get file extension and determine MIME type
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final mimeType = _getMimeType(fileExtension);

      // Add the file to the request
      final multipartFile = await http.MultipartFile.fromPath(
        'property_image',
        imageFile.path,
        contentType: MediaType('image', mimeType),
      );
      request.files.add(multipartFile);

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Handle the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);
        // Check for both possible response formats
        return jsonData['image_url'] ??
            (jsonData['image'] != null ? jsonData['image']['url'] : '') ??
            '';
      } else {
        String errorMessage;
        try {
          final jsonData = json.decode(response.body);
          errorMessage =
              jsonData['message'] ?? 'Failed to upload property image';
        } catch (e) {
          errorMessage =
              'Failed to upload property image: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to upload property image: $e');
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
