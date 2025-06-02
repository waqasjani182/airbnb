import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/booking_provider.dart';
import '../../utils/constants.dart';
import '../../models/booking.dart';
import 'components/booking_card.dart';

class UserBookingsScreen extends ConsumerStatefulWidget {
  const UserBookingsScreen({super.key});

  @override
  ConsumerState<UserBookingsScreen> createState() => _UserBookingsScreenState();
}

class _UserBookingsScreenState extends ConsumerState<UserBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Fetch user bookings when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider.notifier).fetchUserBookings();
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
          'My Bookings',
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
              ref.read(bookingProvider.notifier).fetchUserBookings();
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
              ref.read(bookingProvider.notifier).fetchUserBookings();
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
        ref.read(bookingProvider.notifier).fetchUserBookings();
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
              isHostView: false,
              onTap: () => _navigateToBookingDetails(booking),
              onStatusUpdate: _canCancelBooking(booking)
                  ? () => _showCancelDialog(booking)
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
            Icons.calendar_today_outlined,
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
            'Your bookings will appear here once you make a reservation.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.large),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
            child: const Text('Browse Properties'),
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

  bool _canCancelBooking(Booking booking) {
    final status = booking.status.toLowerCase();
    return status == 'pending' || status == 'confirmed';
  }

  void _navigateToBookingDetails(Booking booking) {
    Navigator.pushNamed(
      context,
      '${AppRoutes.bookingDetails}/${booking.bookingId}',
    );
  }

  void _showCancelDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(booking);
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

  void _cancelBooking(Booking booking) {
    ref.read(bookingProvider.notifier).updateBookingStatus(
          booking.bookingId.toString(),
          BookingStatus.cancelled,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking cancelled successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
