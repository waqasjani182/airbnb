import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/booking_provider.dart';
import '../../utils/constants.dart';
import '../../models/booking.dart';
import 'components/booking_request_card.dart';

class RequestPendingScreen extends ConsumerStatefulWidget {
  const RequestPendingScreen({super.key});

  @override
  ConsumerState<RequestPendingScreen> createState() => _RequestPendingScreenState();
}

class _RequestPendingScreenState extends ConsumerState<RequestPendingScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch host bookings when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider.notifier).fetchHostBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    
    // Filter only pending bookings
    final pendingBookings = bookingState.bookings
        .where((booking) => booking.status.toLowerCase() == 'pending')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking Requests',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(bookingProvider.notifier).fetchHostBookings();
            },
          ),
        ],
      ),
      body: bookingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingState.errorMessage != null
              ? _buildErrorState(bookingState.errorMessage!)
              : _buildRequestsList(pendingBookings),
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
            'Error loading requests',
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
              ref.read(bookingProvider.notifier).fetchHostBookings();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(List<Booking> pendingBookings) {
    if (pendingBookings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(bookingProvider.notifier).fetchHostBookings();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.medium),
        itemCount: pendingBookings.length,
        itemBuilder: (context, index) {
          final booking = pendingBookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: BookingRequestCard(
              booking: booking,
              onConfirm: () => _confirmBooking(booking),
              onReject: () => _rejectBooking(booking),
              onViewDetails: () => _navigateToBookingDetails(booking),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'No pending requests',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'New booking requests will appear here for your review.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.large),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.myProperties);
            },
            child: const Text('Manage Properties'),
          ),
        ],
      ),
    );
  }

  void _navigateToBookingDetails(Booking booking) {
    Navigator.pushNamed(
      context,
      '${AppRoutes.bookingDetails}/${booking.bookingId}',
    );
  }

  void _confirmBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to confirm this booking request?'),
            const SizedBox(height: AppSpacing.medium),
            Container(
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.title ?? 'Property',
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (booking.guestName != null)
                    Text('Guest: ${booking.guestName}'),
                  Text('Dates: ${_formatDateRange(booking)}'),
                  Text('Amount: \$${booking.totalAmount.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateBookingStatus(booking, BookingStatus.confirmed, 'Booking confirmed successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _rejectBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to reject this booking request?'),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'This action cannot be undone and the guest will be notified.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Request'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateBookingStatus(booking, BookingStatus.cancelled, 'Booking request rejected');
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _updateBookingStatus(Booking booking, BookingStatus newStatus, String successMessage) {
    ref.read(bookingProvider.notifier).updateBookingStatus(
      booking.bookingId.toString(),
      newStatus,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage),
        backgroundColor: newStatus == BookingStatus.confirmed 
            ? AppColors.success 
            : AppColors.error,
      ),
    );
  }

  String _formatDateRange(Booking booking) {
    final startDate = booking.startDate;
    final endDate = booking.endDate;
    return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
  }
}
