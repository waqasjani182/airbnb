import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform, SocketException;
import 'dart:async' show TimeoutException;
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
        _httpClient = httpClient ?? http.Client() {
    // Check if the server is running when the client is created
    if (Platform.isMacOS) {
      _checkServerConnection();
    }
  }

  // Helper method to check if the API server is running
  Future<bool> _checkServerConnection() async {
    try {
      // Try to connect to the API server
      final response = await http.get(
        Uri.parse('http://127.0.0.1:3004/api/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Connection check timed out');
        },
      );

      // Log the result
      if (response.statusCode >= 200 && response.statusCode < 300) {
        developer.log('API server is running at http://127.0.0.1:3004',
            name: 'API');
        return true;
      } else {
        developer.log('API server returned error: ${response.statusCode}',
            name: 'API');
        return false;
      }
    } catch (e) {
      developer.log('API server connection check failed: $e',
          name: 'API', error: e);
      return false;
    }
  }

  // Helper method to get the appropriate base URL based on platform
  static String _getAppropriateBaseUrl() {
    final config = AppConfig();

    try {
      // Check platform and environment
      if (Platform.isAndroid) {
        // For Android emulator use 10.0.2.2, for physical device use the device IP
        const bool isEmulator =
            bool.fromEnvironment('IS_EMULATOR', defaultValue: true);
        return isEmulator ? config.baseUrl : config.deviceBaseUrl;
      } else if (Platform.isIOS) {
        // For iOS simulator use 127.0.0.1, for physical device use the device IP
        const bool isSimulator =
            bool.fromEnvironment('IS_SIMULATOR', defaultValue: true);
        return isSimulator ? config.iosBaseUrl : config.deviceBaseUrl;
      } else if (Platform.isMacOS) {
        // For macOS, always use 127.0.0.1 instead of localhost
        // This avoids potential DNS resolution issues
        return 'http://127.0.0.1:3004';
      } else {
        // For web or other platforms, use localhost
        return 'http://localhost:3004';
      }
    } catch (e) {
      developer.log('Error determining base URL: $e', name: 'API', error: e);
      // Fallback to loopback address if there's an error
      return 'http://127.0.0.1:3004';
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
      // For macOS, always use 127.0.0.1 instead of the baseUrl
      final String effectiveBaseUrl =
          Platform.isMacOS ? 'http://127.0.0.1:3004' : baseUrl;

      final uri = Uri.parse('$effectiveBaseUrl$endpoint').replace(
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

      // Create a custom client with a longer timeout for macOS
      final client = Platform.isMacOS ? http.Client() : _httpClient;

      final response = await client.get(uri, headers: requestHeaders).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out after 30 seconds');
        },
      );

      // Close the custom client if we created one
      if (Platform.isMacOS) {
        client.close();
      }

      // Log response if logging is enabled
      if (kEnableApiLogging) {
        developer.log(
          'GET RESPONSE: ${response.statusCode}\nBody: ${response.body}',
          name: 'API',
        );
      }

      return _handleResponse(response, fromJson);
    } catch (e) {
      String errorMessage;

      if (e is SocketException) {
        // Handle socket exceptions (network connectivity issues)
        errorMessage =
            'Network error: Unable to connect to the server. Please check your internet connection and server status.';

        if (e.message.contains('Operation not permitted')) {
          // This specific error often occurs when trying to connect to localhost on a physical device
          errorMessage =
              'Network error: Cannot connect to localhost. Try using 127.0.0.1 directly or check your network permissions.';
        }
      } else if (e is TimeoutException) {
        errorMessage =
            'Network error: Request timed out. The server may be down or unreachable.';
      } else {
        // Handle other exceptions
        errorMessage = 'An error occurred: ${e.toString()}';
      }

      if (kEnableApiLogging) {
        developer.log('GET ERROR: $errorMessage\nOriginal error: $e',
            name: 'API', error: e);
      }

      return ApiResponse(success: false, error: errorMessage);
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
      // For macOS, always use 127.0.0.1 instead of the baseUrl
      final String effectiveBaseUrl =
          Platform.isMacOS ? 'http://127.0.0.1:3004' : baseUrl;

      final uri = Uri.parse('$effectiveBaseUrl$endpoint');

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

      // Create a custom client with a longer timeout for macOS
      final client = Platform.isMacOS ? http.Client() : _httpClient;

      final response = await client
          .post(
        uri,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out after 30 seconds');
        },
      );

      // Close the custom client if we created one
      if (Platform.isMacOS) {
        client.close();
      }

      // Log response if logging is enabled
      if (kEnableApiLogging) {
        developer.log(
          'POST RESPONSE: ${response.statusCode}\nBody: ${response.body}',
          name: 'API',
        );
      }

      return _handleResponse(response, fromJson);
    } catch (e) {
      String errorMessage;

      if (e is SocketException) {
        // Handle socket exceptions (network connectivity issues)
        errorMessage =
            'Network error: Unable to connect to the server. Please check your internet connection and server status.';

        if (e.message.contains('Operation not permitted')) {
          // This specific error often occurs when trying to connect to localhost on a physical device
          errorMessage =
              'Network error: Cannot connect to localhost. Try using 127.0.0.1 directly or check your network permissions.';
        }
      } else if (e is TimeoutException) {
        errorMessage =
            'Network error: Request timed out. The server may be down or unreachable.';
      } else {
        // Handle other exceptions
        errorMessage = 'An error occurred: ${e.toString()}';
      }

      if (kEnableApiLogging) {
        developer.log('POST ERROR: $errorMessage\nOriginal error: $e',
            name: 'API', error: e);
      }

      return ApiResponse(success: false, error: errorMessage);
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
      String errorMessage;

      if (e is SocketException) {
        // Handle socket exceptions (network connectivity issues)
        errorMessage =
            'Network error: Unable to connect to the server. Please check your internet connection and server status.';

        if (e.message.contains('Operation not permitted')) {
          // This specific error often occurs when trying to connect to localhost on a physical device
          errorMessage =
              'Network error: Cannot connect to localhost from a physical device. Please use the device IP address instead.';
        }
      } else {
        // Handle other exceptions
        errorMessage = 'An error occurred: ${e.toString()}';
      }

      if (kEnableApiLogging) {
        developer.log('PUT ERROR: $errorMessage\nOriginal error: $e',
            name: 'API', error: e);
      }

      return ApiResponse(success: false, error: errorMessage);
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
      String errorMessage;

      if (e is SocketException) {
        // Handle socket exceptions (network connectivity issues)
        errorMessage =
            'Network error: Unable to connect to the server. Please check your internet connection and server status.';

        if (e.message.contains('Operation not permitted')) {
          // This specific error often occurs when trying to connect to localhost on a physical device
          errorMessage =
              'Network error: Cannot connect to localhost from a physical device. Please use the device IP address instead.';
        }
      } else {
        // Handle other exceptions
        errorMessage = 'An error occurred: ${e.toString()}';
      }

      if (kEnableApiLogging) {
        developer.log('DELETE ERROR: $errorMessage\nOriginal error: $e',
            name: 'API', error: e);
      }

      return ApiResponse(success: false, error: errorMessage);
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
