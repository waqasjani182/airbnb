/// Model for booking data with ratings returned by the date range API
class BookingWithRatings {
  final int bookingId;
  final int userId;
  final int propertyId;
  final String status;
  final String bookingDate;
  final String startDate;
  final String endDate;
  final double totalAmount;
  final int guests;
  final String propertyTitle;
  final String propertyCity;
  final String propertyAddress;
  final String propertyType;
  final double rentPerDay;
  final String guestName;
  final String guestEmail;
  final String? guestProfileImage;
  final String hostName;
  final String hostEmail;
  final String? hostProfileImage;
  final double? userRating;
  final String? userReview;
  final double? ownerRating;
  final String? ownerReview;
  final double? propertyRating;
  final String? propertyReview;
  final String? propertyImage;

  BookingWithRatings({
    required this.bookingId,
    required this.userId,
    required this.propertyId,
    required this.status,
    required this.bookingDate,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.guests,
    required this.propertyTitle,
    required this.propertyCity,
    required this.propertyAddress,
    required this.propertyType,
    required this.rentPerDay,
    required this.guestName,
    required this.guestEmail,
    this.guestProfileImage,
    required this.hostName,
    required this.hostEmail,
    this.hostProfileImage,
    this.userRating,
    this.userReview,
    this.ownerRating,
    this.ownerReview,
    this.propertyRating,
    this.propertyReview,
    this.propertyImage,
  });

  factory BookingWithRatings.fromJson(Map<String, dynamic> json) {
    // Helper function to parse double values
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Helper function to parse nullable double values
    double? parseNullableDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Helper function to parse int values
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return BookingWithRatings(
      bookingId: parseInt(json['booking_id']),
      userId: parseInt(json['user_ID']),
      propertyId: parseInt(json['property_id']),
      status: json['status'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalAmount: parseDouble(json['total_amount']),
      guests: parseInt(json['guests']),
      propertyTitle: json['property_title'] ?? '',
      propertyCity: json['property_city'] ?? '',
      propertyAddress: json['property_address'] ?? '',
      propertyType: json['property_type'] ?? '',
      rentPerDay: parseDouble(json['rent_per_day']),
      guestName: json['guest_name'] ?? '',
      guestEmail: json['guest_email'] ?? '',
      guestProfileImage: json['guest_profile_image'],
      hostName: json['host_name'] ?? '',
      hostEmail: json['host_email'] ?? '',
      hostProfileImage: json['host_profile_image'],
      userRating: parseNullableDouble(json['user_rating']),
      userReview: json['user_review'],
      ownerRating: parseNullableDouble(json['owner_rating']),
      ownerReview: json['owner_review'],
      propertyRating: parseNullableDouble(json['property_rating']),
      propertyReview: json['property_review'],
      propertyImage: json['property_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'user_ID': userId,
      'property_id': propertyId,
      'status': status,
      'booking_date': bookingDate,
      'start_date': startDate,
      'end_date': endDate,
      'total_amount': totalAmount,
      'guests': guests,
      'property_title': propertyTitle,
      'property_city': propertyCity,
      'property_address': propertyAddress,
      'property_type': propertyType,
      'rent_per_day': rentPerDay,
      'guest_name': guestName,
      'guest_email': guestEmail,
      'guest_profile_image': guestProfileImage,
      'host_name': hostName,
      'host_email': hostEmail,
      'host_profile_image': hostProfileImage,
      'user_rating': userRating,
      'user_review': userReview,
      'owner_rating': ownerRating,
      'owner_review': ownerReview,
      'property_rating': propertyRating,
      'property_review': propertyReview,
      'property_image': propertyImage,
    };
  }
}

/// Model for booking statistics
class BookingStatistics {
  final int totalBookings;
  final int bookingsWithRatings;
  final String averagePropertyRating;
  final String averageUserRating;
  final String averageOwnerRating;
  final String totalRevenue;

  BookingStatistics({
    required this.totalBookings,
    required this.bookingsWithRatings,
    required this.averagePropertyRating,
    required this.averageUserRating,
    required this.averageOwnerRating,
    required this.totalRevenue,
  });

  factory BookingStatistics.fromJson(Map<String, dynamic> json) {
    return BookingStatistics(
      totalBookings: json['total_bookings'] ?? 0,
      bookingsWithRatings: json['bookings_with_ratings'] ?? 0,
      averagePropertyRating:
          json['average_property_rating'].toString() ?? '0.0',
      averageUserRating: json['average_user_rating'].toString() ?? '0.0',
      averageOwnerRating: json['average_owner_rating'].toString() ?? '0.0',
      totalRevenue: json['total_revenue'].toString() ?? '0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_bookings': totalBookings,
      'bookings_with_ratings': bookingsWithRatings,
      'average_property_rating': averagePropertyRating,
      'average_user_rating': averageUserRating,
      'average_owner_rating': averageOwnerRating,
      'total_revenue': totalRevenue,
    };
  }
}

/// Model for date range
class DateRange {
  final String fromDate;
  final String toDate;

  DateRange({
    required this.fromDate,
    required this.toDate,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from_date': fromDate,
      'to_date': toDate,
    };
  }
}

/// Model for the complete bookings with ratings API response
class BookingsWithRatingsResponse {
  final DateRange dateRange;
  final List<BookingWithRatings> bookings;
  final int totalCount;
  final BookingStatistics statistics;

  BookingsWithRatingsResponse({
    required this.dateRange,
    required this.bookings,
    required this.totalCount,
    required this.statistics,
  });

  factory BookingsWithRatingsResponse.fromJson(Map<String, dynamic> json) {
    List<BookingWithRatings> bookingsList = [];
    if (json['bookings'] != null && json['bookings'] is List) {
      bookingsList = (json['bookings'] as List)
          .map((bookingJson) => BookingWithRatings.fromJson(bookingJson))
          .toList();
    }

    return BookingsWithRatingsResponse(
      dateRange: DateRange.fromJson(json['date_range'] ?? {}),
      bookings: bookingsList,
      totalCount: json['total_count'] ?? 0,
      statistics: BookingStatistics.fromJson(json['statistics'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_range': dateRange.toJson(),
      'bookings': bookings.map((b) => b.toJson()).toList(),
      'total_count': totalCount,
      'statistics': statistics.toJson(),
    };
  }
}
