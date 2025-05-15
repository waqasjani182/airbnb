import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A service that provides direct HTTP requests without using the ApiClient
/// This is useful for macOS where the ApiClient might have issues with App Sandbox
class DirectHttpService {
  final String baseUrl;
  final http.Client _httpClient;
  
  DirectHttpService({
    String? baseUrl,
  }) : baseUrl = baseUrl ?? 'http://127.0.0.1:3004',
       _httpClient = http.Client();
  
  /// Dispose the HTTP client
  void dispose() {
    _httpClient.close();
  }
  
  /// Make a direct GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
      
      if (headers != null) {
        requestHeaders.addAll(headers);
      }
      
      debugPrint('DIRECT GET REQUEST: $uri');
      
      final response = await _httpClient.get(
        uri,
        headers: requestHeaders,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );
      
      debugPrint('DIRECT GET RESPONSE: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {};
        }
        
        try {
          return json.decode(response.body);
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('DIRECT GET ERROR: $e');
      rethrow;
    }
  }
  
  /// Make a direct POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
      
      if (headers != null) {
        requestHeaders.addAll(headers);
      }
      
      debugPrint('DIRECT POST REQUEST: $uri');
      debugPrint('DIRECT POST BODY: ${body != null ? json.encode(body) : 'null'}');
      
      final response = await _httpClient.post(
        uri,
        headers: requestHeaders,
        body: body != null ? json.encode(body) : null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );
      
      debugPrint('DIRECT POST RESPONSE: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {};
        }
        
        try {
          return json.decode(response.body);
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('DIRECT POST ERROR: $e');
      rethrow;
    }
  }
}
