import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/image_service.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

// Image upload state
enum ImageUploadStatus {
  initial,
  uploading,
  success,
  error,
}

class ImageUploadState {
  final ImageUploadStatus status;
  final String? imageUrl;
  final String? errorMessage;
  final bool isLoading;

  ImageUploadState({
    this.status = ImageUploadStatus.initial,
    this.imageUrl,
    this.errorMessage,
    this.isLoading = false,
  });

  ImageUploadState copyWith({
    ImageUploadStatus? status,
    String? imageUrl,
    String? errorMessage,
    bool? isLoading,
  }) {
    return ImageUploadState(
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Image notifier
class ImageNotifier extends StateNotifier<ImageUploadState> {
  final ImageService _imageService;
  final String? _authToken;

  ImageNotifier(this._imageService, this._authToken)
      : super(ImageUploadState());

  Future<void> uploadProfileImage(File imageFile) async {
    if (_authToken == null) {
      state = state.copyWith(
        status: ImageUploadStatus.error,
        errorMessage: 'Authentication token is missing',
      );
      return;
    }

    state = state.copyWith(
      status: ImageUploadStatus.uploading,
      isLoading: true,
      errorMessage: null, // Clear previous errors
    );

    try {
      final imageUrl = await _imageService.uploadProfileImage(
        imageFile,
        _authToken,
      );

      state = state.copyWith(
        status: ImageUploadStatus.success,
        imageUrl: imageUrl,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: ImageUploadStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<String?> uploadPropertyImage(File imageFile) async {
    if (_authToken == null) {
      state = state.copyWith(
        status: ImageUploadStatus.error,
        errorMessage: 'Authentication token is missing',
      );
      return null;
    }

    state = state.copyWith(
      status: ImageUploadStatus.uploading,
      isLoading: true,
      errorMessage: null, // Clear previous errors
    );

    try {
      final imageUrl = await _imageService.uploadPropertyImage(
        imageFile,
        _authToken,
      );

      state = state.copyWith(
        status: ImageUploadStatus.success,
        imageUrl: imageUrl,
        isLoading: false,
      );

      return imageUrl;
    } catch (e) {
      state = state.copyWith(
        status: ImageUploadStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
      return null;
    }
  }

  void reset() {
    state = ImageUploadState();
  }
}

// Providers
final imageServiceProvider = Provider<ImageService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ImageService(apiClient: apiClient);
});

final imageProvider =
    StateNotifierProvider<ImageNotifier, ImageUploadState>((ref) {
  final imageService = ref.watch(imageServiceProvider);
  final authState = ref.watch(authProvider);
  return ImageNotifier(imageService, authState.token);
});
