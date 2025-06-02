import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/booking_provider.dart';
import '../../utils/constants.dart';
import '../../models/booking.dart';
import 'components/booking_card.dart';

class HostBookingsScreen extends ConsumerStatefulWidget {
  const HostBookingsScreen({super.key});

  @override
  ConsumerState<HostBookingsScreen> createState() => _HostBookingsScreenState();
}

class _HostBookingsScreenState extends ConsumerState<HostBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

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
          'Property Bookings',
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
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Completed'),
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
                    _buildBookingsList(bookingState.bookings),
                    _buildBookingsList(_filterBookingsByStatus(
                        bookingState.bookings, 'Pending')),
                    _buildBookingsList(_filterBookingsByStatus(
                        bookingState.bookings, 'Confirmed')),
                    _buildBookingsList(_filterBookingsByStatus(
                        bookingState.bookings, 'Completed')),
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
          final booking = bookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: BookingCard(
              booking: booking,
              isHostView: true,
              onTap: () => _navigateToBookingDetails(booking),
              onStatusUpdate: _canUpdateStatus(booking)
                  ? () => _showStatusUpdateDialog(booking)
                  : null,
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
            Icons.home_outlined,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'No bookings found',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Bookings for your properties will appear here.',
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

  List<Booking> _filterBookingsByStatus(List<Booking> bookings, String status) {
    return bookings
        .where(
            (booking) => booking.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  bool _canUpdateStatus(Booking booking) {
    final status = booking.status.toLowerCase();
    return status == 'pending' || status == 'confirmed';
  }

  void _navigateToBookingDetails(Booking booking) {
    Navigator.pushNamed(
      context,
      '${AppRoutes.bookingDetails}/${booking.bookingId}',
    );
  }

  void _showStatusUpdateDialog(Booking booking) {
    final currentStatus = booking.status.toLowerCase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Booking Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentStatus == 'pending') ...[
              ListTile(
                leading:
                    const Icon(Icons.check_circle, color: AppColors.success),
                title: const Text('Confirm Booking'),
                onTap: () {
                  Navigator.pop(context);
                  _updateBookingStatus(booking, BookingStatus.confirmed);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: AppColors.error),
                title: const Text('Cancel Booking'),
                onTap: () {
                  Navigator.pop(context);
                  _updateBookingStatus(booking, BookingStatus.cancelled);
                },
              ),
            ],
            if (currentStatus == 'confirmed') ...[
              ListTile(
                leading: const Icon(Icons.done_all, color: AppColors.primary),
                title: const Text('Mark as Completed'),
                onTap: () {
                  Navigator.pop(context);
                  _updateBookingStatus(booking, BookingStatus.completed);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: AppColors.error),
                title: const Text('Cancel Booking'),
                onTap: () {
                  Navigator.pop(context);
                  _updateBookingStatus(booking, BookingStatus.cancelled);
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _updateBookingStatus(Booking booking, BookingStatus newStatus) {
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
}
