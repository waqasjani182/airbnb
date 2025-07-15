import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bookings_with_ratings_response.dart';
import '../services/booking_service.dart';
import 'auth_provider.dart';
import 'api_provider.dart';

// Bookings with ratings state
enum BookingsWithRatingsStatus {
  initial,
  loading,
  success,
  error,
}

class BookingsWithRatingsState {
  final BookingsWithRatingsStatus status;
  final BookingsWithRatingsResponse? response;
  final String? errorMessage;
  final bool isLoading;
  final String? currentFromDate;
  final String? currentToDate;

  BookingsWithRatingsState({
    this.status = BookingsWithRatingsStatus.initial,
    this.response,
    this.errorMessage,
    this.isLoading = false,
    this.currentFromDate,
    this.currentToDate,
  });

  BookingsWithRatingsState copyWith({
    BookingsWithRatingsStatus? status,
    BookingsWithRatingsResponse? response,
    String? errorMessage,
    bool? isLoading,
    String? currentFromDate,
    String? currentToDate,
  }) {
    return BookingsWithRatingsState(
      status: status ?? this.status,
      response: response ?? this.response,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      currentFromDate: currentFromDate ?? this.currentFromDate,
      currentToDate: currentToDate ?? this.currentToDate,
    );
  }
}

// Bookings with ratings notifier
class BookingsWithRatingsNotifier extends StateNotifier<BookingsWithRatingsState> {
  final BookingService _bookingService;
  final Ref _ref;

  BookingsWithRatingsNotifier(this._bookingService, this._ref)
      : super(BookingsWithRatingsState());

  /// Get bookings with ratings by date range
  Future<void> getBookingsWithRatingsByDateRange({
    required String fromDate,
    required String toDate,
  }) async {
    // Validate date format (basic validation)
    if (!_isValidDateFormat(fromDate) || !_isValidDateFormat(toDate)) {
      state = state.copyWith(
        status: BookingsWithRatingsStatus.error,
        errorMessage: 'Invalid date format. Use YYYY-MM-DD format',
        isLoading: false,
      );
      return;
    }

    // Validate date range
    if (!_isValidDateRange(fromDate, toDate)) {
      state = state.copyWith(
        status: BookingsWithRatingsStatus.error,
        errorMessage: 'from_date cannot be later than to_date',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      status: BookingsWithRatingsStatus.loading,
      isLoading: true,
      errorMessage: null,
      currentFromDate: fromDate,
      currentToDate: toDate,
    );

    try {
      // Get auth token (optional for this endpoint)
      final authState = _ref.read(authProvider);
      final token = authState.token;

      final response = await _bookingService.getBookingsWithRatingsByDateRange(
        fromDate: fromDate,
        toDate: toDate,
        token: token,
      );

      state = state.copyWith(
        status: BookingsWithRatingsStatus.success,
        response: response,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: BookingsWithRatingsStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Clear the current bookings data
  void clearData() {
    state = BookingsWithRatingsState();
  }

  /// Refresh the current date range data
  Future<void> refresh() async {
    if (state.currentFromDate != null && state.currentToDate != null) {
      await getBookingsWithRatingsByDateRange(
        fromDate: state.currentFromDate!,
        toDate: state.currentToDate!,
      );
    }
  }

  /// Validate date format (YYYY-MM-DD)
  bool _isValidDateFormat(String date) {
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(date)) return false;
    
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate that fromDate is not later than toDate
  bool _isValidDateRange(String fromDate, String toDate) {
    try {
      final from = DateTime.parse(fromDate);
      final to = DateTime.parse(toDate);
      return from.isBefore(to) || from.isAtSameMomentAs(to);
    } catch (e) {
      return false;
    }
  }
}

// Provider for booking service
final bookingServiceProvider = Provider<BookingService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingService(apiClient: apiClient);
});

// Provider for bookings with ratings
final bookingsWithRatingsProvider =
    StateNotifierProvider<BookingsWithRatingsNotifier, BookingsWithRatingsState>((ref) {
  final bookingService = ref.watch(bookingServiceProvider);
  return BookingsWithRatingsNotifier(bookingService, ref);
});

// Convenience providers for specific data
final bookingsWithRatingsListProvider = Provider<List<BookingWithRatings>>((ref) {
  final state = ref.watch(bookingsWithRatingsProvider);
  return state.response?.bookings ?? [];
});

final bookingsWithRatingsLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(bookingsWithRatingsProvider);
  return state.isLoading;
});

final bookingsWithRatingsErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(bookingsWithRatingsProvider);
  return state.errorMessage;
});

final bookingsStatisticsProvider = Provider<BookingStatistics?>((ref) {
  final state = ref.watch(bookingsWithRatingsProvider);
  return state.response?.statistics;
});

final bookingsDateRangeProvider = Provider<DateRange?>((ref) {
  final state = ref.watch(bookingsWithRatingsProvider);
  return state.response?.dateRange;
});

final bookingsWithRatingsCountProvider = Provider<int>((ref) {
  final state = ref.watch(bookingsWithRatingsProvider);
  return state.response?.totalCount ?? 0;
});
