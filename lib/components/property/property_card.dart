import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../../models/property.dart';
import '../../utils/constants.dart';
import '../../config/app_config.dart';
import 'retry_image.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final bool showRating;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showRating = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image with favorite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppBorderRadius.medium),
                    topRight: Radius.circular(AppBorderRadius.medium),
                  ),
                  child: RetryImage(
                    imageUrl: _getImageUrl(property),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: 800,
                    cacheHeight: 600,
                  ),
                ),
                if (onFavoriteToggle != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? AppColors.primary : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Property details
            Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showRating)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.accent,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              property.avgRating.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Property title
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Property features
                  Row(
                    children: [
                      _buildFeature(Icons.king_bed,
                          '${property.bedrooms} ${property.bedrooms > 1 ? 'beds' : 'bed'}'),
                      const SizedBox(width: 16),
                      _buildFeature(Icons.bathtub,
                          '${property.bathrooms} ${property.bathrooms > 1 ? 'baths' : 'bath'}'),
                      const SizedBox(width: 16),
                      _buildFeature(Icons.person,
                          '${property.maxGuests} ${property.maxGuests > 1 ? 'guests' : 'guest'}'),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Row(
                    children: [
                      Text(
                        '\$${property.pricePerNight.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        ' / night',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textLight,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  String _getImageUrl(Property property) {
    String imageUrl = '';
    final config = AppConfig();

    // First check if primaryImage is available
    if (property.primaryImage != null && property.primaryImage!.isNotEmpty) {
      debugPrint('Using primary image: ${property.primaryImage}');
      imageUrl = property.primaryImage!;

      // Check if the URL is valid (has http:// or https://)
      if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
        debugPrint('Invalid URL format for primary image: $imageUrl');
        // Try to fix the URL by adding http:// prefix
        imageUrl = 'http://$imageUrl';
        debugPrint('Fixed URL: $imageUrl');
      }

      // Fix localhost URLs for emulators
      imageUrl = _fixLocalhostUrl(imageUrl);
      debugPrint('Final primary image URL: $imageUrl');
      return imageUrl;
    }

    // Then check if there are any images in the images list
    if (property.images.isNotEmpty) {
      imageUrl = property.images[0].imageUrl;
      debugPrint('Using first image from list: $imageUrl');

      // Check if the URL is valid (has http:// or https://)
      if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
        debugPrint('Invalid URL format for image from list: $imageUrl');
        // Try to fix the URL by adding http:// prefix
        imageUrl = 'http://$imageUrl';
        debugPrint('Fixed URL: $imageUrl');
      }

      // Fix localhost URLs for emulators
      imageUrl = _fixLocalhostUrl(imageUrl);
      debugPrint('Final image list URL: $imageUrl');
      return imageUrl;
    }

    // Use a fallback image URL that works on both emulators and physical devices
    // Use platform detection to determine the correct URL
    final baseUrl = Platform.isAndroid
        ? config.baseUrl
        : Platform.isIOS
            ? config.iosBaseUrl
            : 'http://localhost:3004';

    final fallbackUrl =
        '$baseUrl/uploads/property-images/property-1746371110286-49156490.jpg';
    debugPrint('Using fallback image: $fallbackUrl');
    return fallbackUrl;
  }

  // Helper method to fix localhost URLs for emulators
  String _fixLocalhostUrl(String url) {
    // Check if the URL contains localhost
    if (url.contains('localhost')) {
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
          return url.replaceAll('localhost', '10.0.2.2');
        } else if (Platform.isIOS) {
          return url.replaceAll('localhost', '127.0.0.1');
        }
      }
    }

    return url;
  }
}
