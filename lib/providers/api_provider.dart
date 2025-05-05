import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/image_upload_service.dart';

// Provider for the API client
final apiClientProvider = Provider<ApiClient>((ref) {
  // Let the ApiClient determine the appropriate base URL
  return ApiClient();
});

// Provider for the image upload service
final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ImageUploadService(baseUrl: apiClient.baseUrl);
});
