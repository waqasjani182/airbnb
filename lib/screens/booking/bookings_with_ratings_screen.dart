import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/bookings_with_ratings_provider.dart';
import '../../models/bookings_with_ratings_response.dart';
import '../../utils/constants.dart';

class BookingsWithRatingsScreen extends ConsumerStatefulWidget {
  const BookingsWithRatingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BookingsWithRatingsScreen> createState() =>
      _BookingsWithRatingsScreenState();
}

class _BookingsWithRatingsScreenState
    extends ConsumerState<BookingsWithRatingsScreen> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default date range (current year)
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);

    _fromDateController.text = _formatDate(startOfYear);
    _toDateController.text = _formatDate(endOfYear);
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.text = _formatDate(picked);
    }
  }

  void _searchBookings() {
    final fromDate = _fromDateController.text.trim();
    final toDate = _toDateController.text.trim();

    if (fromDate.isNotEmpty && toDate.isNotEmpty) {
      ref
          .read(bookingsWithRatingsProvider.notifier)
          .getBookingsWithRatingsByDateRange(
            fromDate: fromDate,
            toDate: toDate,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(bookingsWithRatingsLoadingProvider);
    final errorMessage = ref.watch(bookingsWithRatingsErrorProvider);
    final bookings = ref.watch(bookingsWithRatingsListProvider);
    final statistics = ref.watch(bookingsStatisticsProvider);
    final dateRange = ref.watch(bookingsDateRangeProvider);
    final totalCount = ref.watch(bookingsWithRatingsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings Analytics'),
      ),
      body: Column(
        children: [
          // Date range selection section
          Container(
            padding: const EdgeInsets.all(AppSpacing.medium),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fromDateController,
                        decoration: InputDecoration(
                          labelText: 'From Date',
                          hintText: 'YYYY-MM-DD',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.medium),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(_fromDateController),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _toDateController,
                        decoration: InputDecoration(
                          labelText: 'To Date',
                          hintText: 'YYYY-MM-DD',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.medium),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(_toDateController),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _searchBookings,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.medium),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Get Bookings Analytics'),
                  ),
                ),
              ],
            ),
          ),

          // Results section
          Expanded(
            child: _buildResultsSection(
              isLoading: isLoading,
              errorMessage: errorMessage,
              bookings: bookings,
              statistics: statistics,
              dateRange: dateRange,
              totalCount: totalCount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection({
    required bool isLoading,
    required String? errorMessage,
    required List<BookingWithRatings> bookings,
    required BookingStatistics? statistics,
    required DateRange? dateRange,
    required int totalCount,
  }) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading bookings analytics...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(bookingsWithRatingsProvider.notifier).clearData();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (dateRange == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Bookings Analytics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a date range to view booking analytics with ratings',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Statistics summary
        if (statistics != null) _buildStatisticsCard(statistics, dateRange),

        // Bookings list
        Expanded(
          child: bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Bookings Found',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No bookings found for the selected date range',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _buildBookingCard(booking);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(
      BookingStatistics statistics, DateRange dateRange) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.medium),
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Summary',
            style: AppTextStyles.heading3.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${dateRange.fromDate} to ${dateRange.toDate}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),

          // Statistics grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildStatItem(
                  'Total Bookings', statistics.totalBookings.toString()),
              _buildStatItem(
                  'With Ratings', statistics.bookingsWithRatings.toString()),
              _buildStatItem(
                  'Avg Property Rating', statistics.averagePropertyRating),
              _buildStatItem('Total Revenue', 'Rs ${statistics.totalRevenue}'),
              _buildStatItem('Avg User Rating', statistics.averageUserRating),
              _buildStatItem('Avg Host Rating', statistics.averageOwnerRating),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingWithRatings booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.bookingId}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Property and guest info
            Text(
              booking.propertyTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${booking.propertyAddress}, ${booking.propertyCity}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Text('Guest: ${booking.guestName}'),
                const SizedBox(width: 16),
                Text('Host: ${booking.hostName}'),
              ],
            ),

            const SizedBox(height: 8),

            // Dates and amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${booking.startDate} to ${booking.endDate}'),
                Text(
                  'Rs ${booking.totalAmount.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                ),
              ],
            ),

            // Ratings section
            if (booking.userRating != null ||
                booking.ownerRating != null ||
                booking.propertyRating != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Ratings',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              if (booking.propertyRating != null)
                _buildRatingRow('Property', booking.propertyRating!,
                    booking.propertyReview),
              if (booking.userRating != null)
                _buildRatingRow(
                    'Guest to Host', booking.userRating!, booking.userReview),
              if (booking.ownerRating != null)
                _buildRatingRow(
                    'Host to Guest', booking.ownerRating!, booking.ownerReview),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(String label, double rating, String? review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber[600], size: 16),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          if (review != null && review.isNotEmpty) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                review,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
