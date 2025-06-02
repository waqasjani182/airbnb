import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/booking.dart';
import '../../../utils/constants.dart';
import 'booking_status_badge.dart';

class ConfirmedBookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCancel;

  const ConfirmedBookingCard({
    super.key,
    required this.booking,
    this.onMarkComplete,
    this.onViewDetails,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final dateFormat = DateFormat('MMM dd');
      final status = booking.status.toLowerCase();

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          side: BorderSide(
            color: _getStatusBorderColor(status),
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
                // Header with status and actions
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(status),
                            size: 20,
                            color: _getStatusColor(status),
                          ),
                          const SizedBox(width: AppSpacing.small),
                          Text(
                            _getStatusTitle(status),
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(status),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.medium),
                      child: _buildPropertyImage(),
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

                // Action Buttons (only for confirmed bookings)
                if (status == 'confirmed') ...[
                  const SizedBox(height: AppSpacing.medium),
                  Row(
                    children: [
                      if (onCancel != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                      ],
                      if (onMarkComplete != null)
                        Expanded(
                          flex: onCancel != null ? 1 : 2,
                          child: ElevatedButton(
                            onPressed: onMarkComplete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('Mark Complete'),
                          ),
                        ),
                    ],
                  ),
                ],

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
    } catch (e) {
      print('[CONFIRMED BOOKING CARD] Error building card: $e');
      // Return a simple error card
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Error loading booking',
                style: AppTextStyles.body,
              ),
              Text(
                'Booking ID: ${booking.bookingId ?? 'Unknown'}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildPropertyImage() {
    // Get the image URL safely
    String? imageUrl;

    if (booking.propertyImages?.isNotEmpty == true) {
      imageUrl = booking.propertyImages!.first;
    } else if (booking.propertyImage != null) {
      imageUrl = booking.propertyImage!;
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        _getImageUrl(imageUrl),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    } else {
      return _buildPlaceholderImage();
    }
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

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green.shade200;
      case 'completed':
        return Colors.blue.shade200;
      case 'cancelled':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green.shade700;
      case 'completed':
        return Colors.blue.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'confirmed':
        return 'Active Booking';
      case 'completed':
        return 'Completed Stay';
      case 'cancelled':
        return 'Cancelled Booking';
      default:
        return 'Booking';
    }
  }
}
