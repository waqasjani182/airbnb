import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../../models/property2.dart';
import '../../config/app_config.dart';
import 'retry_image.dart';

class PropertyImageGallery extends StatefulWidget {
  final Property2 property;

  const PropertyImageGallery({
    super.key,
    required this.property,
  });

  @override
  State<PropertyImageGallery> createState() => _PropertyImageGalleryState();
}

class _PropertyImageGalleryState extends State<PropertyImageGallery> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getImageUrl(String imageUrl) {
    // Check if the URL is already absolute
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }

    // Otherwise, prepend the base URL
    final config = AppConfig();
    final baseUrl = Platform.isAndroid
        ? config.baseUrl
        : Platform.isIOS
            ? config.iosBaseUrl
            : config.deviceBaseUrl;

    return '$baseUrl/$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.property.images.isNotEmpty
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: widget.property.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return RetryImage(
                        imageUrl: _getImageUrl(widget.property.images[index].imageUrl),
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),

            // Image indicators
            if (widget.property.images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.property.images.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Gradient overlay for better text visibility
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
