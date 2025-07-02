import 'package:flutter/material.dart';
import '../../models/property_review.dart';
import '../../utils/constants.dart';
import 'star_rating.dart';

class ReviewCard extends StatelessWidget {
  final PropertyReview review;
  final bool showPropertyInfo;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int? currentUserId;
  final bool showActions;

  const ReviewCard({
    super.key,
    required this.review,
    this.showPropertyInfo = false,
    this.onEdit,
    this.onDelete,
    this.currentUserId,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final reviewerName = _getReviewerName();
    final isOwner = currentUserId == review.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and actions
            _buildHeader(context, reviewerName, isOwner),
            
            const SizedBox(height: AppSpacing.medium),

            // Property info (if needed)
            if (showPropertyInfo && review.propertyTitle != null) ...[
              _buildPropertyInfo(),
              const SizedBox(height: AppSpacing.medium),
            ],

            // Property review section
            if (review.propertyRating != null && review.propertyReview != null)
              _buildReviewSection(
                'Property Review',
                review.propertyRating!,
                review.propertyReview!,
              ),

            // Host review section (if exists)
            if (review.userRating != null && review.userReview != null) ...[
              const SizedBox(height: AppSpacing.medium),
              const Divider(),
              const SizedBox(height: AppSpacing.small),
              _buildReviewSection(
                'Host Review',
                review.userRating!,
                review.userReview!,
              ),
            ],

            // Guest review section (if exists and this is a host review)
            if (review.ownerRating != null && review.ownerReview != null) ...[
              const SizedBox(height: AppSpacing.medium),
              const Divider(),
              const SizedBox(height: AppSpacing.small),
              _buildReviewSection(
                'Guest Review',
                review.ownerRating!,
                review.ownerReview!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String reviewerName, bool isOwner) {
    return Row(
      children: [
        // User avatar
        CircleAvatar(
          backgroundColor: AppColors.primary,
          radius: 20,
          backgroundImage: review.userProfileImage != null
              ? NetworkImage(review.userProfileImage!)
              : null,
          child: review.userProfileImage == null
              ? Text(
                  reviewerName.isNotEmpty ? reviewerName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        
        const SizedBox(width: AppSpacing.medium),
        
        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reviewerName,
                style: AppTextStyles.heading3.copyWith(fontSize: 16),
              ),
              if (review.createdAt.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _formatDate(review.createdAt),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ],
          ),
        ),
        
        // Actions menu (if owner and actions enabled)
        if (isOwner && showActions && (onEdit != null || onDelete != null))
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit' && onEdit != null) onEdit!();
              if (value == 'delete' && onDelete != null) onDelete!();
            },
            itemBuilder: (context) => [
              if (onEdit != null)
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit Review'),
                    ],
                  ),
                ),
              if (onDelete != null)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete Review', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildPropertyInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Property image
          if (review.propertyImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              child: Image.network(
                review.propertyImage!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
          
          const SizedBox(width: AppSpacing.medium),
          
          // Property details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.propertyTitle!,
                  style: AppTextStyles.heading3.copyWith(fontSize: 14),
                ),
                if (review.propertyCity != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    review.propertyCity!,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, double rating, String reviewText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(fontSize: 14),
            ),
            const SizedBox(width: AppSpacing.small),
            StarRating(
              rating: rating,
              size: 16,
              showRatingText: true,
              ratingTextStyle: AppTextStyles.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          reviewText,
          style: AppTextStyles.body.copyWith(height: 1.4),
        ),
      ],
    );
  }

  String _getReviewerName() {
    if (review.name != null && review.name!.isNotEmpty) {
      return review.name!;
    }
    
    final firstName = review.userFirstName;
    final lastName = review.userLastName;
    
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    }
    
    return 'Anonymous';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return months == 1 ? '1 month ago' : '$months months ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return years == 1 ? '1 year ago' : '$years years ago';
      }
    } catch (e) {
      return dateString;
    }
  }
}
