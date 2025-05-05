import 'package:flutter/material.dart';

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

    return Image.network(
      widget.imageUrl,
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

        // Check if the error is related to localhost
        final errorString = error.toString();
        if (errorString.contains('localhost') ||
            errorString.contains('Connection refused') ||
            errorString.contains('Failed host lookup')) {
          debugPrint(
              'Detected localhost or connection error, showing error message');
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
                  child: Text(
                    'Error: ${errorString.substring(0, errorString.length > 50 ? 50 : errorString.length)}...',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
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
