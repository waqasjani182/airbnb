import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../../models/property2.dart';
import '../../utils/constants.dart';
import '../../config/app_config.dart';
import 'retry_image.dart';

class PropertyCard2 extends StatelessWidget {
  final Property2 property;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final bool showRating;

  const PropertyCard2({
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
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
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
                          '${property.city}, ${property.address}',
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
                      _buildFeature(Icons.person, '${property.guest} guests'),
                      const SizedBox(width: 16),
                      _buildFeature(Icons.category, property.propertyType),
                      if (property.facilities.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        _buildFeature(
                            Icons.wifi, property.facilities.first.facilityType),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Row(
                    children: [
                      Text(
                        'RS ${property.rentPerDay.toStringAsFixed(0)}',
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

  String _getImageUrl(Property2 property) {
    // Get the first image URL or a placeholder
    final imageUrl = property.images.isNotEmpty
        ? property.images.first.imageUrl
        : 'https://via.placeholder.com/400x300';

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
}
