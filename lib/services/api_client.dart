import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
  });
}

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
  })  : baseUrl = baseUrl ?? _getAppropriateBaseUrl(),
        _httpClient = httpClient ?? http.Client();

  // Helper method to get the appropriate base URL based on platform
  static String _getAppropriateBaseUrl() {
    final config = AppConfig();

    if (Platform.isAndroid) {
      return config.baseUrl; // 10.0.2.2 for Android emulator
    } else if (Platform.isIOS) {
      return config.iosBaseUrl; // 127.0.0.1 for iOS simulator
    } else {
      // For web or desktop, use localhost
      return 'http://localhost:3004';
    }
  }

  // Helper method to get auth token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    bool requiresAuth = false,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
      };

      if (requiresAuth) {
        final token = await _getToken();
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // Log request details if logging is enabled
      if (kEnableApiLogging) {
        developer.log(
          'GET REQUEST: $uri\nHeaders: $requestHeaders\nQuery Params: $queryParams',
          name: 'API',
        );
      }

      final response = await _httpClient.get(uri, headers: requestHeaders);

      // Log response if logging is enabled
      if (kEnableApiLogging) {
        developer.log(
          'GET RESPONSE: ${response.statusCode}\nBody: ${response.body}',
          name: 'API',
        );
      }

      return _handleResponse(response, fromJson);
    } catch (e) {
      if (kEnableApiLogging) {
        developer.log('GET ERROR: $e', name: 'API', error: e);
      }
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
      };

      if (requiresAuth) {
        final token = await _getToken();
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // Log request details if logging is enabled
      if (kEnableApiLogging) {
        developer.log(
          'POST REQUEST: $uri\nHeaders: $requestHeaders\nBody: ${body != null ? json.encode(body) : 'null'}',
          name: 'API',
        );
      }

      final response = await _httpClient.post(
        uri,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );

      // Log response if logging is enabled
      if (kEnableApiLogging) {
        developer.log(
          'POST RESPONSE: ${response.statusCode}\nBody: ${response.body}',
          name: 'API',
        );
      }

      return _handleResponse(response, fromJson);
    } catch (e) {
      if (kEnableApiLogging) {
        developer.log('POST ERROR: $e', name: 'API', error: e);
      }
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
      };

      if (requiresAuth) {
        final token = await _getToken();
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // Log request details if logging is enabled
      if (kEnableApiLogging) {
        developer.log(
          'PUT REQUEST: $uri\nHeaders: $requestHeaders\nBody: ${body != null ? json.encode(body) : 'null'}',
          name: 'API',
        );
      }

      final response = await _httpClient.put(
        uri,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      );

      // Log response if logging is enabled
      if (kEnableApiLogging) {
        developer.log(
          'PUT RESPONSE: ${response.statusCode}\nBody: ${response.body}',
          name: 'API',
        );
      }

      return _handleResponse(response, fromJson);
    } catch (e) {
      if (kEnableApiLogging) {
        developer.log('PUT ERROR: $e', name: 'API', error: e);
      }
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = false,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
      };

      if (requiresAuth) {
        final token = await _getToken();
        if (token != null) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // Log request details if logging is enabled
      if (kEnableApiLogging) {
        developer.log(
          'DELETE REQUEST: $uri\nHeaders: $requestHeaders',
          name: 'API',
        );
      }

      final response = await _httpClient.delete(uri, headers: requestHeaders);

      // Log response if logging is enabled
      if (kEnableApiLogging) {
        developer.log(
          'DELETE RESPONSE: ${response.statusCode}\nBody: ${response.body}',
          name: 'API',
        );
      }

      return _handleResponse(response, fromJson);
    } catch (e) {
      if (kEnableApiLogging) {
        developer.log('DELETE ERROR: $e', name: 'API', error: e);
      }
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        if (kEnableApiLogging) {
          developer.log('RESPONSE PROCESSING: Empty body, returning success',
              name: 'API');
        }
        return ApiResponse<T>(success: true);
      }

      try {
        final jsonData = json.decode(response.body);

        if (fromJson != null) {
          if (kEnableApiLogging) {
            developer.log('RESPONSE PROCESSING: Using fromJson converter',
                name: 'API');
          }
          final data = fromJson(jsonData);
          return ApiResponse<T>(success: true, data: data);
        }

        if (kEnableApiLogging) {
          developer.log('RESPONSE PROCESSING: Using direct cast', name: 'API');
        }
        return ApiResponse<T>(success: true, data: jsonData as T);
      } catch (e) {
        if (kEnableApiLogging) {
          developer.log('RESPONSE PROCESSING ERROR: Failed to parse JSON: $e',
              name: 'API', error: e);
        }
        return ApiResponse<T>(
            success: false, error: 'Failed to parse response: $e');
      }
    } else {
      String errorMessage;
      try {
        final jsonData = json.decode(response.body);
        errorMessage = jsonData['message'] ?? 'Unknown error occurred';
        if (kEnableApiLogging) {
          developer.log(
              'RESPONSE ERROR: $errorMessage (${response.statusCode})',
              name: 'API');
        }
      } catch (e) {
        errorMessage = 'Error: ${response.statusCode}';
        if (kEnableApiLogging) {
          developer.log(
              'RESPONSE ERROR: $errorMessage (Failed to parse error response)',
              name: 'API',
              error: e);
        }
      }
      return ApiResponse<T>(success: false, error: errorMessage);
    }
  }
}
