import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/booking.dart';
import '../../../utils/constants.dart';
import 'booking_status_badge.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isHostView;
  final VoidCallback? onTap;
  final VoidCallback? onStatusUpdate;

  const BookingCard({
    super.key,
    required this.booking,
    required this.isHostView,
    this.onTap,
    this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with property info and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    child: (booking.propertyImages?.isNotEmpty == true ||
                            booking.propertyImage != null)
                        ? Image.network(
                            _getImageUrl(
                                booking.propertyImages?.isNotEmpty == true
                                    ? booking.propertyImages!.first
                                    : booking.propertyImage!),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                  ),
                  const SizedBox(width: AppSpacing.medium),

                  // Property Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.title ?? 'Property',
                          style: AppTextStyles.heading3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        if (booking.city != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  booking.city!,
                                  style: AppTextStyles.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                        if (isHostView && booking.hostName != null) ...[
                          Text(
                            'Guest: #${booking.userId}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ] else if (!isHostView && booking.hostName != null) ...[
                          Text(
                            'Host: ${booking.hostName}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Status Badge
                  BookingStatusBadge(status: booking.status),
                ],
              ),

              const SizedBox(height: AppSpacing.medium),

              // Booking Details
              Container(
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                child: Row(
                  children: [
                    // Dates
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Check-in',
                            style: AppTextStyles.bodySmall,
                          ),
                          Text(
                            dateFormat.format(booking.startDate),
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.textLight,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Check-out',
                            style: AppTextStyles.bodySmall,
                          ),
                          Text(
                            dateFormat.format(booking.endDate),
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Guests and Total
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${booking.guests} guest${booking.guests != 1 ? 's' : ''}',
                            style: AppTextStyles.bodySmall,
                          ),
                          Text(
                            '\$${booking.totalAmount.toStringAsFixed(0)}',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action Button (if available)
              if (onStatusUpdate != null) ...[
                const SizedBox(height: AppSpacing.medium),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onStatusUpdate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _getActionButtonColor(),
                      side: BorderSide(color: _getActionButtonColor()),
                    ),
                    child: Text(_getActionButtonText()),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: Icon(
        Icons.home_outlined,
        size: 32,
        color: AppColors.textLight,
      ),
    );
  }

  Color _getActionButtonColor() {
    final status = booking.status.toLowerCase();
    if (isHostView) {
      if (status == 'pending') return AppColors.primary;
      if (status == 'confirmed') return AppColors.success;
    }
    return AppColors.error; // For cancel actions
  }

  String _getActionButtonText() {
    final status = booking.status.toLowerCase();
    if (isHostView) {
      if (status == 'pending') return 'Manage Request';
      if (status == 'confirmed') return 'Mark Complete';
    }
    return 'Cancel Booking';
  }

  String _getImageUrl(String imageUrl) {
    // Fix localhost URLs for Android emulator and iOS simulator
    if (imageUrl.contains('localhost:3004')) {
      // For Android emulator, use 10.0.2.2
      if (Platform.isAndroid) {
        return imageUrl.replaceAll('localhost:3004', '10.0.2.2:3004');
      }
      // For iOS simulator, use 127.0.0.1
      else if (Platform.isIOS) {
        return imageUrl.replaceAll('localhost:3004', '127.0.0.1:3004');
      }
    }

    return imageUrl;
  }
}
