import 'package:flutter/material.dart';
import '../../models/property2.dart';
import '../../utils/constants.dart';

class UserPropertyInfoSection extends StatelessWidget {
  final Property2 property;

  const UserPropertyInfoSection({
    super.key,
    required this.property,
  });

  Widget _buildInfoCard(String title, String value, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color ?? AppColors.primary,
            size: 24,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: color ?? AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    // Determine status styling
    switch (status.toLowerCase()) {
      case 'active':
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        icon = Icons.check_circle;
        break;
      case 'inactive':
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        icon = Icons.cancel;
        break;
      case 'pending':
        backgroundColor = AppColors.accent.withValues(alpha: 0.1);
        textColor = AppColors.accent;
        icon = Icons.pending;
        break;
      default:
        backgroundColor = AppColors.textLight.withValues(alpha: 0.1);
        textColor = AppColors.textLight;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            status,
            style: AppTextStyles.bodySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property title and status
        Row(
          children: [
            Expanded(
              child: Text(
                property.title,
                style: AppTextStyles.heading2,
              ),
            ),
            _buildStatusChip('Active'), // TODO: Get actual status from API
          ],
        ),

        const SizedBox(height: AppSpacing.small),

        // Property type and location
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.small,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Text(
                property.propertyType,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      property.address,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.large),

        // Property metrics grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.medium,
          mainAxisSpacing: AppSpacing.medium,
          childAspectRatio: 1.2,
          children: [
            _buildInfoCard(
              'Price per Night',
              '\$${property.rentPerDay.toStringAsFixed(0)}',
              Icons.attach_money,
            ),
            _buildInfoCard(
              'Guest Capacity',
              '${property.guest}',
              Icons.people,
            ),
            _buildInfoCard(
              'Average Rating',
              property.avgRating > 0 
                  ? property.avgRating.toStringAsFixed(1)
                  : 'No ratings',
              Icons.star,
              color: property.avgRating > 0 ? AppColors.accent : AppColors.textLight,
            ),
            _buildInfoCard(
              'Total Reviews',
              '${property.reviewCount}',
              Icons.rate_review,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.large),

        // Property description
        Text(
          'Description',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          property.description,
          style: AppTextStyles.body,
        ),

        const SizedBox(height: AppSpacing.medium),

        // Property details
        if (property.totalBedrooms != null || 
            property.totalRooms != null || 
            property.totalBeds != null) ...[
          Text(
            'Property Details',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.small),
          Wrap(
            spacing: AppSpacing.medium,
            runSpacing: AppSpacing.small,
            children: [
              if (property.totalBedrooms != null)
                _buildDetailChip(
                  Icons.king_bed,
                  '${property.totalBedrooms} ${property.totalBedrooms! > 1 ? 'Bedrooms' : 'Bedroom'}',
                ),
              if (property.totalRooms != null)
                _buildDetailChip(
                  Icons.room,
                  '${property.totalRooms} ${property.totalRooms! > 1 ? 'Rooms' : 'Room'}',
                ),
              if (property.totalBeds != null)
                _buildDetailChip(
                  Icons.bed,
                  '${property.totalBeds} ${property.totalBeds! > 1 ? 'Beds' : 'Bed'}',
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
