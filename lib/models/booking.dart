enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

class Booking {
  final int? bookingId;
  final int propertyId;
  final int userId;
  final String status;
  final DateTime bookingDate;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final int guests;
  final int numberOfDays;

  // Property details (included in API response)
  final String? title;
  final String? city;
  final double? rentPerDay;
  final String? address;
  final String? propertyType;
  final String? hostName;
  final String? propertyImage;

  // Legacy fields for backward compatibility
  final double? rating;
  final String? review;

  Booking({
    this.bookingId,
    required this.propertyId,
    required this.userId,
    required this.status,
    required this.bookingDate,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.guests,
    required this.numberOfDays,
    this.title,
    this.city,
    this.rentPerDay,
    this.address,
    this.propertyType,
    this.hostName,
    this.propertyImage,
    this.rating,
    this.review,
  });

  // Legacy getters for backward compatibility
  String get id => bookingId?.toString() ?? '';
  String get propertyIdString => propertyId.toString();
  String get userIdString => userId.toString();
  DateTime get checkIn => startDate;
  DateTime get checkOut => endDate;
  int get guestCount => guests;
  double get totalPrice => totalAmount;
  DateTime get createdAt => bookingDate;

  Booking copyWith({
    int? bookingId,
    int? propertyId,
    int? userId,
    String? status,
    DateTime? bookingDate,
    DateTime? startDate,
    DateTime? endDate,
    double? totalAmount,
    int? guests,
    int? numberOfDays,
    String? title,
    String? city,
    double? rentPerDay,
    String? address,
    String? propertyType,
    String? hostName,
    String? propertyImage,
    double? rating,
    String? review,
  }) {
    return Booking(
      bookingId: bookingId ?? this.bookingId,
      propertyId: propertyId ?? this.propertyId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalAmount: totalAmount ?? this.totalAmount,
      guests: guests ?? this.guests,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      title: title ?? this.title,
      city: city ?? this.city,
      rentPerDay: rentPerDay ?? this.rentPerDay,
      address: address ?? this.address,
      propertyType: propertyType ?? this.propertyType,
      hostName: hostName ?? this.hostName,
      propertyImage: propertyImage ?? this.propertyImage,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'start_date':
          startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'end_date': endDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'guests': guests,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    print('[BOOKING MODEL] Parsing JSON: $json'); // Debug log
    try {
      final booking = Booking(
        bookingId: json['booking_id'],
        propertyId: json['property_id'] ?? 0,
        userId: json['user_ID'] ?? 0, // Handle null user_ID
        status: json['status'] ?? 'Pending',
        bookingDate: DateTime.parse(json['booking_date']),
        startDate: DateTime.parse(json['start_date']),
        endDate: DateTime.parse(json['end_date']),
        totalAmount: json['total_amount'] != null
            ? double.parse(json['total_amount'].toString())
            : 0.0,
        guests: json['guests'] ?? 1,
        numberOfDays: json['number_of_days'] ?? 0,
        title: json['title'],
        city: json['city'],
        rentPerDay: json['rent_per_day'] != null
            ? double.parse(json['rent_per_day'].toString())
            : null,
        address: json['address'],
        propertyType: json['property_type'],
        hostName: json['host_name'],
        propertyImage: json['property_image'],
        rating: json['rating'] != null
            ? double.parse(json['rating'].toString())
            : null,
        review: json['review'],
      );
      print(
          '[BOOKING MODEL] Successfully created booking: ${booking.bookingId}'); // Debug log
      return booking;
    } catch (e) {
      print('[BOOKING MODEL] Error parsing JSON: $e'); // Debug log
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking &&
        other.id == id &&
        other.propertyId == propertyId &&
        other.userId == userId &&
        other.checkIn == checkIn &&
        other.checkOut == checkOut &&
        other.guestCount == guestCount &&
        other.totalPrice == totalPrice &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.rating == rating &&
        other.review == review;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        propertyId.hashCode ^
        userId.hashCode ^
        checkIn.hashCode ^
        checkOut.hashCode ^
        guestCount.hashCode ^
        totalPrice.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        rating.hashCode ^
        review.hashCode;
  }
}
