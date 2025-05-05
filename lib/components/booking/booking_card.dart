import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';
import '../../models/property.dart';
import '../../utils/constants.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final Property property;
  final VoidCallback onTap;
  final VoidCallback? onCancelPressed;
  final VoidCallback? onReviewPressed;

  const BookingCard({
    Key? key,
    required this.booking,
    required this.property,
    required this.onTap,
    this.onCancelPressed,
    this.onReviewPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

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
            // Property image with status badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppBorderRadius.medium),
                    topRight: Radius.circular(AppBorderRadius.medium),
                  ),
                  child: Image.network(
                    property.primaryImage != null
                        ? property.primaryImage!
                        : (property.images.isNotEmpty
                            ? property.images[0].imageUrl
                            : 'https://via.placeholder.com/300x200'),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status),
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.small),
                    ),
                    child: Text(
                      _getStatusText(booking.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Booking details
            Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
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
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Check-in',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(booking.checkIn),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Check-out',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(booking.checkOut),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Guests and total price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${booking.guestCount} ${booking.guestCount > 1 ? 'guests' : 'guest'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${booking.totalPrice.toStringAsFixed(0)} total',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Action buttons based on booking status
                  if (_shouldShowActionButtons())
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          if (onCancelPressed != null &&
                              booking.status == BookingStatus.pending)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: onCancelPressed,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side:
                                      const BorderSide(color: AppColors.error),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                          if (onReviewPressed != null &&
                              booking.status == BookingStatus.completed &&
                              booking.rating == null)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: onReviewPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Leave Review'),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return AppColors.secondary;
      case BookingStatus.cancelled:
        return AppColors.error;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  bool _shouldShowActionButtons() {
    return (onCancelPressed != null &&
            booking.status == BookingStatus.pending) ||
        (onReviewPressed != null &&
            booking.status == BookingStatus.completed &&
            booking.rating == null);
  }
}
