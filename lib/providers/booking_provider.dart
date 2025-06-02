import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import 'auth_provider.dart';
import 'api_provider.dart';

// Booking state
enum BookingProviderStatus {
  initial,
  loading,
  success,
  error,
}

class BookingState {
  final BookingProviderStatus status;
  final List<Booking> bookings;
  final Booking? selectedBooking;
  final String? errorMessage;
  final bool isLoading;

  BookingState({
    this.status = BookingProviderStatus.initial,
    this.bookings = const [],
    this.selectedBooking,
    this.errorMessage,
    this.isLoading = false,
  });

  BookingState copyWith({
    BookingProviderStatus? status,
    List<Booking>? bookings,
    Booking? selectedBooking,
    String? errorMessage,
    bool? isLoading,
  }) {
    return BookingState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      selectedBooking: selectedBooking ?? this.selectedBooking,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Booking notifier
class BookingNotifier extends StateNotifier<BookingState> {
  final BookingService _bookingService;
  final String? _authToken;

  BookingNotifier(this._bookingService, this._authToken)
      : super(BookingState());

  Future<void> fetchUserBookings() async {
    state = state.copyWith(
      status: BookingProviderStatus.loading,
      isLoading: true,
    );
    try {
      final bookings = await _bookingService.getUserBookings(_authToken!);
      state = state.copyWith(
        status: BookingProviderStatus.success,
        bookings: bookings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: BookingProviderStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> fetchPropertyBookings(String propertyId) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      final bookings =
          await _bookingService.getPropertyBookings(propertyId, _authToken!);
      state = state.copyWith(
        bookings: bookings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> fetchHostBookings() async {
    state = state.copyWith(
      status: BookingProviderStatus.loading,
      isLoading: true,
    );
    try {
      final bookings = await _bookingService.getHostBookings(_authToken!);
      state = state.copyWith(
        status: BookingProviderStatus.success,
        bookings: bookings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: BookingProviderStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  // Get pending bookings count for notifications
  int get pendingBookingsCount {
    return state.bookings
        .where((booking) => booking.status.toLowerCase() == 'pending')
        .length;
  }

  // Get pending bookings list
  List<Booking> get pendingBookings {
    return state.bookings
        .where((booking) => booking.status.toLowerCase() == 'pending')
        .toList();
  }

  Future<void> fetchBookingById(String id) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      final booking = await _bookingService.getBookingById(id, _authToken!);
      state = state.copyWith(
        selectedBooking: booking,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> createBooking(Booking booking) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null, // Clear previous errors
    );
    try {
      final newBooking =
          await _bookingService.createBooking(booking, _authToken!);
      state = state.copyWith(
        bookings: [...state.bookings, newBooking],
        selectedBooking: newBooking,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
      rethrow; // Rethrow the error so the UI can handle it
    }
  }

  Future<void> updateBookingStatus(String id, BookingStatus status) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      final updatedBooking =
          await _bookingService.updateBookingStatus(id, status, _authToken!);
      final updatedBookings = state.bookings.map((b) {
        return b.id == updatedBooking.id ? updatedBooking : b;
      }).toList();
      state = state.copyWith(
        bookings: updatedBookings,
        selectedBooking: updatedBooking,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> addReview(String bookingId, double rating, String review) async {
    state = state.copyWith(
      isLoading: true,
    );
    try {
      final updatedBooking = await _bookingService.addReview(
        bookingId,
        rating,
        review,
        _authToken!,
      );
      final updatedBookings = state.bookings.map((b) {
        return b.id == updatedBooking.id ? updatedBooking : b;
      }).toList();
      state = state.copyWith(
        bookings: updatedBookings,
        selectedBooking: updatedBooking,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  // Method to get bookings for a specific date range
  List<Booking> getBookingsForDateRange(
      String propertyId, DateTime startDate, DateTime endDate) {
    // Check if the booking is for the specified property and overlaps with the date range
    return state.bookings.where((booking) {
      if (booking.propertyId.toString() != propertyId) {
        return false;
      }

      return (booking.checkIn.isBefore(endDate) ||
              booking.checkIn.isAtSameMomentAs(endDate)) &&
          (booking.checkOut.isAfter(startDate) ||
              booking.checkOut.isAtSameMomentAs(startDate));
    }).toList();
  }

  // Method to check if a property is available for a specific date range
  bool isPropertyAvailable(
      String propertyId, DateTime startDate, DateTime endDate) {
    // Get bookings for the property
    final bookings = getBookingsForDateRange(propertyId, startDate, endDate);

    // Check if there are any confirmed or pending bookings that overlap with the date range
    return !bookings.any((booking) =>
        booking.status.toLowerCase() == 'confirmed' ||
        booking.status.toLowerCase() == 'pending');
  }
}

// Providers
final bookingServiceProvider = Provider<BookingService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingService(apiClient: apiClient);
});

final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final bookingService = ref.watch(bookingServiceProvider);
  final authState = ref.watch(authProvider);
  return BookingNotifier(bookingService, authState.token);
});
