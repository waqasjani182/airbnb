import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class RetryImage extends StatefulWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;
  final int? cacheWidth;
  final int? cacheHeight;

  const RetryImage({
    Key? key,
    required this.imageUrl,
    required this.height,
    required this.width,
    required this.fit,
    this.cacheWidth,
    this.cacheHeight,
  }) : super(key: key);

  @override
  State<RetryImage> createState() => _RetryImageState();
}

class _RetryImageState extends State<RetryImage> {
  bool _hasError = false;
  int _retryCount = 0;
  static const int maxRetries = 3;

  // Helper method to check if we're likely running on an emulator/simulator
  bool get _isEmulatorOrSimulator {
    // This is a simple heuristic - not 100% accurate
    // For a more accurate detection, you would need to use platform-specific code
    if (Platform.isAndroid) {
      // Android emulator typically uses 10.0.2.2 for localhost
      return true; // Assume emulator for now, will be fixed if it's a physical device
    } else if (Platform.isIOS) {
      // iOS simulator typically uses 127.0.0.1
      return true; // Assume simulator for now, will be fixed if it's a physical device
    }
    return false;
  }

  // Helper method to fix localhost URLs for emulators
  String _fixLocalhostUrl(String url) {
    // Check if the URL contains localhost
    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      debugPrint('URL contains localhost, fixing for emulator: $url');

      // Use RegExp to handle different port numbers
      final localhostRegex = RegExp(r'http://(localhost|127\.0\.0\.1):(\d+)');
      final match = localhostRegex.firstMatch(url);

      if (match != null) {
        final port = match.group(2);
        debugPrint('Found localhost with port: $port');

        // Replace localhost with the correct IP for the platform, preserving the port
        if (Platform.isAndroid) {
          // For Android emulator, replace localhost with 10.0.2.2
          final fixedUrl =
              url.replaceFirst(localhostRegex, 'http://10.0.2.2:$port');
          debugPrint('Fixed URL for Android: $fixedUrl');
          return fixedUrl;
        } else if (Platform.isIOS) {
          // For iOS simulator, replace localhost with 127.0.0.1
          final fixedUrl =
              url.replaceFirst(localhostRegex, 'http://127.0.0.1:$port');
          debugPrint('Fixed URL for iOS: $fixedUrl');
          return fixedUrl;
        }
      } else {
        // Simple replacement without port specification
        if (Platform.isAndroid) {
          return url
              .replaceAll('localhost', '10.0.2.2')
              .replaceAll('127.0.0.1', '10.0.2.2');
        } else if (Platform.isIOS) {
          return url.replaceAll('localhost', '127.0.0.1');
        }
      }
    }

    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _retryCount >= maxRetries) {
      return Container(
        height: widget.height,
        width: widget.width,
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            const Text(
              'Failed to load image',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _retryCount = 0;
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Fix the URL before passing it to Image.network
    final fixedImageUrl = _fixLocalhostUrl(widget.imageUrl);

    return Image.network(
      fixedImageUrl,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          height: widget.height,
          width: widget.width,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image: $error');
        debugPrint('Stack trace: $stackTrace');
        debugPrint('Original URL: ${widget.imageUrl}');
        debugPrint('Fixed URL: $fixedImageUrl');

        // Check if the error is related to localhost or connection issues
        final errorString = error.toString();
        if (errorString.contains('localhost') ||
            errorString.contains('Connection refused') ||
            errorString.contains('Failed host lookup') ||
            errorString.contains('SocketException')) {
          debugPrint('Detected connection error, showing error message');

          // Check if we're running on an emulator/simulator
          final isEmulator = Platform.isAndroid && _isEmulatorOrSimulator;
          final isSimulator = Platform.isIOS && _isEmulatorOrSimulator;

          return Container(
            height: widget.height,
            width: widget.width,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.red,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Server connection error',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        'Error: ${errorString.substring(0, errorString.length > 50 ? 50 : errorString.length)}...',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isEmulator || isSimulator)
                        Text(
                          isEmulator
                              ? 'Running on Android emulator'
                              : 'Running on iOS simulator',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _retryCount = 0;
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // For other errors, increment retry count
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _retryCount++;
              if (_retryCount >= maxRetries) {
                _hasError = true;
              }
            });
          }
        });

        return Container(
          height: widget.height,
          width: widget.width,
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.refresh,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  'Retrying... ($_retryCount/$maxRetries)',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
