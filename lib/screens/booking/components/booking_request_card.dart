import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/booking.dart';
import '../../../utils/constants.dart';
import 'booking_status_badge.dart';

class BookingRequestCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final VoidCallback? onViewDetails;

  const BookingRequestCard({
    super.key,
    required this.booking,
    this.onConfirm,
    this.onReject,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        side: BorderSide(
          color: Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with urgent indicator
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.small),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'NEW REQUEST',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  BookingStatusBadge(status: booking.status, isCompact: true),
                ],
              ),

              const SizedBox(height: AppSpacing.medium),

              // Property and Guest Info
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

                  // Property and Guest Details
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
                        if (booking.guestName != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 14,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Guest: ${booking.guestName}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
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

              const SizedBox(height: AppSpacing.medium),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),

              // View Details Link
              const SizedBox(height: AppSpacing.small),
              Center(
                child: TextButton(
                  onPressed: onViewDetails,
                  child: Text(
                    'View Full Details',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
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
