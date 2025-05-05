import 'dart:convert';
import '../models/booking.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: kBaseUrl);

  Future<List<Booking>> getUserBookings(String token) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/api/bookings/user',
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!.map((json) => _mapJsonToBooking(json)).toList();
    } else {
      throw Exception(response.error ?? 'Failed to load user bookings');
    }
  }

  // Helper method to map JSON to Booking
  Booking _mapJsonToBooking(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      propertyId: json['property_id'].toString(),
      userId: json['user_id'].toString(),
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      guestCount: json['guest_count'],
      totalPrice: double.parse(json['total_price'].toString()),
      status: _getBookingStatus(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      rating: json['rating'] != null
          ? double.parse(json['rating'].toString())
          : null,
      review: json['review'],
    );
  }

  // Helper method to convert string to BookingStatus
  BookingStatus _getBookingStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }

  Future<List<Booking>> getPropertyBookings(
      String propertyId, String token) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/api/bookings/property/$propertyId',
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!.map((json) => _mapJsonToBooking(json)).toList();
    } else {
      throw Exception(response.error ?? 'Failed to load property bookings');
    }
  }

  Future<Booking> getBookingById(String id, String token) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/bookings/$id',
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return _mapJsonToBooking(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to load booking');
    }
  }

  Future<Booking> createBooking(Booking booking, String token) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/bookings',
      requiresAuth: true,
      body: {
        'property_id': booking.propertyId,
        'check_in': booking.checkIn.toIso8601String(),
        'check_out': booking.checkOut.toIso8601String(),
        'guest_count': booking.guestCount,
        'total_price': booking.totalPrice,
      },
    );

    if (response.success && response.data != null) {
      return _mapJsonToBooking(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to create booking');
    }
  }

  Future<Booking> updateBookingStatus(
      String id, BookingStatus status, String token) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/bookings/$id/status',
      requiresAuth: true,
      body: {
        'status': status.toString().split('.').last,
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
}
