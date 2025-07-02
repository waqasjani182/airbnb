import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../models/booking.dart';
import '../../components/common/review_form.dart';
import 'components/booking_status_badge.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch booking details when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider.notifier).fetchBookingById(widget.bookingId);
    });
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
    final bookingState = ref.watch(bookingProvider);
    final authState = ref.watch(authProvider);
    final booking = bookingState.selectedBooking;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: bookingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingState.errorMessage != null
              ? _buildErrorState(bookingState.errorMessage!)
              : booking == null
                  ? _buildNotFoundState()
                  : _buildBookingDetails(
                      booking, authState.user?.isHost ?? false),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Error loading booking details',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            error,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.large),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(bookingProvider.notifier)
                  .fetchBookingById(widget.bookingId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Booking not found',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'The booking you\'re looking for doesn\'t exist or has been removed.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.large),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails(Booking booking, bool isHost) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Image and Basic Info
          _buildPropertyHeader(booking),
          const SizedBox(height: AppSpacing.large),

          // Booking Status
          _buildStatusSection(booking),
          const SizedBox(height: AppSpacing.large),

          // Booking Details
          _buildBookingInfo(booking),
          const SizedBox(height: AppSpacing.large),

          // Guest/Host Information
          if (isHost) _buildGuestInfo(booking) else _buildHostInfo(booking),
          const SizedBox(height: AppSpacing.large),

          // Payment Information
          _buildPaymentInfo(booking),
          const SizedBox(height: AppSpacing.large),

          // Action Buttons
          _buildActionButtons(booking, isHost),
        ],
      ),
    );
  }

  Widget _buildPropertyHeader(Booking booking) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Image
          if (booking.propertyImages?.isNotEmpty == true ||
              booking.propertyImage != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                _getImageUrl(booking.propertyImages?.isNotEmpty == true
                    ? booking.propertyImages!.first
                    : booking.propertyImage!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.title ?? 'Property',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSpacing.small),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.address ??
                            booking.city ??
                            'Location not available',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
                if (booking.propertyType != null) ...[
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    booking.propertyType!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(Booking booking) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            const SizedBox(width: AppSpacing.small),
            Text(
              'Booking Status',
              style: AppTextStyles.heading3,
            ),
            const Spacer(),
            BookingStatusBadge(status: booking.status),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfo(Booking booking) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Information',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildInfoRow('Check-in', dateFormat.format(booking.startDate)),
            _buildInfoRow('Check-out', dateFormat.format(booking.endDate)),
            _buildInfoRow('Duration',
                '${booking.numberOfDays} night${booking.numberOfDays != 1 ? 's' : ''}'),
            _buildInfoRow('Guests',
                '${booking.guests} guest${booking.guests != 1 ? 's' : ''}'),
            _buildInfoRow('Booked on', dateFormat.format(booking.bookingDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestInfo(Booking booking) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guest Information',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.medium),
            if (booking.guestName != null)
              _buildInfoRow('Guest Name', booking.guestName!),
            _buildInfoRow('Guest ID', '#${booking.userId}'),
            _buildInfoRow('Number of Guests', '${booking.guests}'),
          ],
        ),
      ),
    );
  }

  Widget _buildHostInfo(Booking booking) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Host Information',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildInfoRow('Host', booking.hostName ?? 'Host'),
            // Add contact options here
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(Booking booking) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Information',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.medium),
            if (booking.rentPerDay != null)
              _buildInfoRow('Rate per night',
                  'RS ${booking.rentPerDay!.toStringAsFixed(2)}'),
            _buildInfoRow(
                'Total amount', 'RS ${booking.totalAmount.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Booking booking, bool isHost) {
    final status = booking.status.toLowerCase();

    return Column(
      children: [
        if (isHost && status == 'pending') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _updateStatus(booking, BookingStatus.confirmed),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Confirm Booking'),
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _updateStatus(booking, BookingStatus.cancelled),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancel Booking'),
            ),
          ),
        ] else if (isHost && status == 'confirmed') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _updateStatus(booking, BookingStatus.completed),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mark as Completed'),
            ),
          ),
        ] else if (status == 'completed') ...[
          // Review button for completed bookings
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showReviewDialog(booking),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isHost ? 'Review Guest' : 'Write Review'),
            ),
          ),
        ] else if (!isHost &&
            (status == 'pending' || status == 'confirmed')) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _updateStatus(booking, BookingStatus.cancelled),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancel Booking'),
            ),
          ),
        ],
      ],
    );
  }

  void _updateStatus(Booking booking, BookingStatus newStatus) {
    ref.read(bookingProvider.notifier).updateBookingStatus(
          booking.bookingId.toString(),
          newStatus,
        );

    String message = '';
    switch (newStatus) {
      case BookingStatus.confirmed:
        message = 'Booking confirmed successfully';
        break;
      case BookingStatus.cancelled:
        message = 'Booking cancelled successfully';
        break;
      case BookingStatus.completed:
        message = 'Booking marked as completed';
        break;
      default:
        message = 'Booking status updated';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showReviewDialog(Booking booking) {
    final authState = ref.read(authProvider);
    final isHost = authState.user?.isHost ?? false;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ReviewForm(
            bookingId: booking.bookingId ?? 0,
            propertyId: booking.propertyId,
            propertyTitle: booking.title ?? 'Property',
            isHostReview: isHost,
            onSuccess: (review) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Review submitted successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
