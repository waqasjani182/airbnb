import 'package:flutter/material.dart';
import '../../models/property2.dart';
import '../../screens/property/property_reviews_screen.dart';
import '../../utils/constants.dart';

class PropertyReviewsSection extends StatelessWidget {
  final Property2 property;

  const PropertyReviewsSection({
    super.key,
    required this.property,
  });

  Widget _buildReviewCard(review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info and ratings
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  review.name?.isNotEmpty == true
                      ? review.name!.substring(0, 1).toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name ?? 'Anonymous',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (review.propertyRating != null)
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < (review.propertyRating ?? 0).floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            '${review.propertyRating?.toStringAsFixed(1) ?? 'N/A'}',
                            style: const TextStyle(
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

          const SizedBox(height: 12),

          // Property review
          if (review.propertyReview?.isNotEmpty == true) ...[
            Text(
              review.propertyReview!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Additional ratings if available
          if (review.userRating != null || review.ownerRating != null)
            Wrap(
              spacing: 16,
              children: [
                if (review.userRating != null)
                  _buildRatingChip('Guest', review.userRating!),
                if (review.ownerRating != null)
                  _buildRatingChip('Host', review.ownerRating!),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRatingChip(String label, double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.star,
            size: 12,
            color: Colors.amber,
          ),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAllReviews(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PropertyReviewsScreen(
          propertyId: property.propertyId,
          propertyTitle: property.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reviews header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews (${property.reviewCount})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (property.avgRating > 0)
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    property.avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (property.reviews.isNotEmpty) ...[
          ...property.reviews.take(3).map((review) {
            return _buildReviewCard(review);
          }),
          if (property.reviews.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => _navigateToAllReviews(context),
                child: Text(
                  'Show all ${property.reviewCount} reviews',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No reviews yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This property hasn\'t been reviewed yet.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
