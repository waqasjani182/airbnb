import '../models/booking.dart';
import '../models/availability.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: kBaseUrl);

  Future<List<Booking>> getUserBookings(String token) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/bookings/user',
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      final bookingsData = response.data!['bookings'] as List<dynamic>;
      return bookingsData.map((json) => _mapJsonToBooking(json)).toList();
    } else {
      throw Exception(response.error ?? 'Failed to load user bookings');
    }
  }

  // Helper method to map JSON to Booking
  Booking _mapJsonToBooking(Map<String, dynamic> json) {
    return Booking.fromJson(json);
  }

  Future<List<Booking>> getPropertyBookings(
      String propertyId, String token) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/bookings/property/$propertyId',
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      // Handle both array and object response formats
      if (response.data! is List) {
        return (response.data! as List<dynamic>)
            .map((json) => _mapJsonToBooking(json))
            .toList();
      } else {
        final bookingsData = response.data!['bookings'] as List<dynamic>;
        return bookingsData.map((json) => _mapJsonToBooking(json)).toList();
      }
    } else {
      throw Exception(response.error ?? 'Failed to load property bookings');
    }
  }

  Future<List<Booking>> getHostBookings(String token) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/bookings/host',
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      final bookingsData = response.data!['bookings'] as List<dynamic>;
      return bookingsData.map((json) => _mapJsonToBooking(json)).toList();
    } else {
      throw Exception(response.error ?? 'Failed to load host bookings');
    }
  }

  Future<Booking> getBookingById(String id, String token) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/bookings/$id',
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      final bookingData = response.data!['booking'] as Map<String, dynamic>;
      return _mapJsonToBooking(bookingData);
    } else {
      throw Exception(response.error ?? 'Failed to load booking');
    }
  }

  Future<Booking> createBooking(Booking booking, String token) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/bookings',
      requiresAuth: true,
      body: booking.toJson(),
    );

    if (response.success && response.data != null) {
      // The API response includes a 'booking' field
      final bookingData = response.data!['booking'] ?? response.data!;
      print('[BOOKING SERVICE] Booking data: $bookingData'); // Debug log
      return _mapJsonToBooking(bookingData);
    } else {
      print('[BOOKING SERVICE] Error: ${response.error}'); // Debug log
      throw Exception(response.error ?? 'Failed to create booking');
    }
  }

  Future<Booking> updateBookingStatus(
      String id, BookingStatus status, String token) async {
    // Convert enum to proper string format
    String statusString;
    switch (status) {
      case BookingStatus.pending:
        statusString = 'Pending';
        break;
      case BookingStatus.confirmed:
        statusString = 'Confirmed';
        break;
      case BookingStatus.cancelled:
        statusString = 'Cancelled';
        break;
      case BookingStatus.completed:
        statusString = 'Completed';
        break;
    }

    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/bookings/$id/status',
      requiresAuth: true,
      body: {
        'status': statusString,
      },
    );

    if (response.success && response.data != null) {
      return _mapJsonToBooking(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to update booking status');
    }
  }

  Future<Booking> addReview(
      String bookingId, double rating, String review, String token) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/bookings/$bookingId/review',
      requiresAuth: true,
      body: {
        'rating': rating,
        'review': review,
      },
    );

    if (response.success && response.data != null) {
      return _mapJsonToBooking(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to add review');
    }
  }

  // Check property availability
  Future<PropertyAvailability> checkAvailability({
    required String propertyId,
    required String startDate,
    required String endDate,
    required int guests,
    String? token,
  }) async {
    final queryParams = {
      'property_id': propertyId,
      'start_date': startDate,
      'end_date': endDate,
      'guests': guests.toString(),
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/bookings/availability',
      requiresAuth: token != null,
      queryParams: queryParams,
    );

    if (response.success && response.data != null) {
      return PropertyAvailability.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to check availability');
    }
  }
}
