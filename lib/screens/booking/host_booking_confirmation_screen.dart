import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/booking_provider.dart';
import '../../utils/constants.dart';
import '../../models/booking.dart';
import 'components/confirmed_booking_card.dart';

class HostBookingConfirmationScreen extends ConsumerStatefulWidget {
  const HostBookingConfirmationScreen({super.key});

  @override
  ConsumerState<HostBookingConfirmationScreen> createState() =>
      _HostBookingConfirmationScreenState();
}

class _HostBookingConfirmationScreenState
    extends ConsumerState<HostBookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch host bookings when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider.notifier).fetchHostBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking Management',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Confirmed'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: bookingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingState.errorMessage != null
              ? _buildErrorState(bookingState.errorMessage!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingsList(_filterBookingsByStatus(
                        bookingState.bookings, 'Confirmed')),
                    _buildBookingsList(_filterBookingsByStatus(
                        bookingState.bookings, 'Completed')),
                    _buildBookingsList(_filterBookingsByStatus(
                        bookingState.bookings, 'Cancelled')),
                  ],
                ),
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
            'Error loading bookings',
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

  Widget _buildBookingsList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(bookingProvider.notifier).fetchHostBookings();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.medium),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          try {
            final booking = bookings[index];
            print(
                '[HOST BOOKING] Building card for booking ${booking.bookingId} with status: ${booking.status}');

            // Safe status check
            final isConfirmed = booking.status.toLowerCase() == 'confirmed';

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.medium),
              child: ConfirmedBookingCard(
                booking: booking,
                onMarkComplete:
                    isConfirmed ? () => _markAsComplete(booking) : null,
                onViewDetails: () => _navigateToBookingDetails(booking),
                onCancel: isConfirmed ? () => _cancelBooking(booking) : null,
              ),
            );
          } catch (e) {
            print(
                '[HOST BOOKING] Error building booking card at index $index: $e');
            // Return a placeholder card for this booking
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Text('Error loading booking: $e'),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final currentTab = _tabController.index;
    String title = '';
    String subtitle = '';
    IconData icon = Icons.inbox_outlined;

    switch (currentTab) {
      case 0: // Confirmed
        title = 'No confirmed bookings';
        subtitle = 'Confirmed bookings will appear here when guests check in.';
        icon = Icons.check_circle_outline;
        break;
      case 1: // Completed
        title = 'No completed bookings';
        subtitle = 'Completed stays will appear here after checkout.';
        icon = Icons.done_all_outlined;
        break;
      case 2: // Cancelled
        title = 'No cancelled bookings';
        subtitle = 'Cancelled bookings will appear here.';
        icon = Icons.cancel_outlined;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            title,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.large),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.requestPendingManagement);
            },
            child: const Text('View Pending Requests'),
          ),
        ],
      ),
    );
  }

  List<Booking> _filterBookingsByStatus(List<Booking> bookings, String status) {
    return bookings.where((booking) {
      // Add null safety check for booking status
      final bookingStatus = booking.status;
      if (bookingStatus.isEmpty) return false;
      return bookingStatus.toLowerCase() == status.toLowerCase();
    }).toList();
  }

  void _navigateToBookingDetails(Booking booking) {
    if (booking.bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Invalid booking ID'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '${AppRoutes.bookingDetails}/${booking.bookingId}',
    );
  }

  void _markAsComplete(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Are you sure you want to mark this booking as completed?'),
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
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (booking.guestName != null)
                    Text('Guest: ${booking.guestName}'),
                  Text('Check-out: ${_formatDate(booking.endDate)}'),
                  Text('Amount: \$${booking.totalAmount.toStringAsFixed(2)}'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'This action will finalize the booking and cannot be undone.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
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
              _updateBookingStatus(booking, BookingStatus.completed,
                  'Booking marked as completed');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Are you sure you want to cancel this confirmed booking?'),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'The guest will be notified and may be eligible for a refund.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateBookingStatus(booking, BookingStatus.cancelled,
                  'Booking cancelled successfully');
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  void _updateBookingStatus(
      Booking booking, BookingStatus newStatus, String successMessage) {
    // Ensure bookingId is not null before proceeding
    if (booking.bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Invalid booking ID'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ref.read(bookingProvider.notifier).updateBookingStatus(
          booking.bookingId.toString(),
          newStatus,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage),
        backgroundColor: newStatus == BookingStatus.completed
            ? AppColors.success
            : AppColors.error,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
