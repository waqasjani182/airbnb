import 'booking.dart';

class PropertyAvailability {
  final int propertyId;
  final bool available;
  final String checkInDate;
  final String checkOutDate;
  final int numberOfDays;
  final int guests;
  final int maxGuests;
  final double pricePerDay;
  final double totalAmount;
  final List<Booking> conflictingBookings;
  final List<Booking> upcomingBookings;
  final PropertyDetails? propertyDetails;

  PropertyAvailability({
    required this.propertyId,
    required this.available,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfDays,
    required this.guests,
    required this.maxGuests,
    required this.pricePerDay,
    required this.totalAmount,
    required this.conflictingBookings,
    required this.upcomingBookings,
    this.propertyDetails,
  });

  factory PropertyAvailability.fromJson(Map<String, dynamic> json) {
    return PropertyAvailability(
      propertyId: json['property_id'] ?? 0,
      available: json['available'] ?? false,
      checkInDate: json['check_in_date'] ?? '',
      checkOutDate: json['check_out_date'] ?? '',
      numberOfDays: json['number_of_days'] ?? 0,
      guests: json['guests'] ?? 0,
      maxGuests: json['max_guests'] ?? 0,
      pricePerDay: (json['price_per_day'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      conflictingBookings:
          (json['conflicting_bookings'] as List<dynamic>? ?? [])
              .map((booking) => Booking.fromJson(booking))
              .toList(),
      upcomingBookings: (json['upcoming_bookings'] as List<dynamic>? ?? [])
          .map((booking) => Booking.fromJson(booking))
          .toList(),
      propertyDetails: json['property_details'] != null
          ? PropertyDetails.fromJson(json['property_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'available': available,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'number_of_days': numberOfDays,
      'guests': guests,
      'max_guests': maxGuests,
      'price_per_day': pricePerDay,
      'total_amount': totalAmount,
      'conflicting_bookings':
          conflictingBookings.map((b) => b.toJson()).toList(),
      'upcoming_bookings': upcomingBookings.map((b) => b.toJson()).toList(),
      'property_details': propertyDetails?.toJson(),
    };
  }
}

class PropertyDetails {
  final String title;
  final String city;
  final String propertyType;

  PropertyDetails({
    required this.title,
    required this.city,
    required this.propertyType,
  });

  factory PropertyDetails.fromJson(Map<String, dynamic> json) {
    return PropertyDetails(
      title: json['title'] ?? '',
      city: json['city'] ?? '',
      propertyType: json['property_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'city': city,
      'property_type': propertyType,
    };
  }
}

// Import the Booking model
