class UserProperty {
  final int propertyId;
  final int userId;
  final String propertyType;
  final double rentPerDay;
  final String address;
  final double? rating;
  final String city;
  final double longitude;
  final double latitude;
  final String title;
  final String description;
  final int guest;
  final String primaryImage;
  final int bookingCount;

  UserProperty({
    required this.propertyId,
    required this.userId,
    required this.propertyType,
    required this.rentPerDay,
    required this.address,
    this.rating,
    required this.city,
    required this.longitude,
    required this.latitude,
    required this.title,
    required this.description,
    required this.guest,
    required this.primaryImage,
    required this.bookingCount,
  });

  UserProperty copyWith({
    int? propertyId,
    int? userId,
    String? propertyType,
    double? rentPerDay,
    String? address,
    double? rating,
    String? city,
    double? longitude,
    double? latitude,
    String? title,
    String? description,
    int? guest,
    String? primaryImage,
    int? bookingCount,
  }) {
    return UserProperty(
      propertyId: propertyId ?? this.propertyId,
      userId: userId ?? this.userId,
      propertyType: propertyType ?? this.propertyType,
      rentPerDay: rentPerDay ?? this.rentPerDay,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      city: city ?? this.city,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      title: title ?? this.title,
      description: description ?? this.description,
      guest: guest ?? this.guest,
      primaryImage: primaryImage ?? this.primaryImage,
      bookingCount: bookingCount ?? this.bookingCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'user_id': userId,
      'property_type': propertyType,
      'rent_per_day': rentPerDay,
      'address': address,
      'rating': rating,
      'city': city,
      'longitude': longitude,
      'latitude': latitude,
      'title': title,
      'description': description,
      'guest': guest,
      'primary_image': primaryImage,
      'booking_count': bookingCount,
    };
  }

  factory UserProperty.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse int values
    int parseIntValue(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    // Helper function to safely parse double values
    double parseDoubleValue(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return UserProperty(
      propertyId: parseIntValue(json['property_id']),
      userId: parseIntValue(json['user_id']),
      propertyType: json['property_type'] ?? '',
      rentPerDay: parseDoubleValue(json['rent_per_day']),
      address: json['address'] ?? '',
      rating: json['rating'] != null ? parseDoubleValue(json['rating']) : null,
      city: json['city'] ?? '',
      longitude: parseDoubleValue(json['longitude']),
      latitude: parseDoubleValue(json['latitude']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      guest: parseIntValue(json['guest']),
      primaryImage: json['primary_image'] ?? '',
      bookingCount: parseIntValue(json['booking_count']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProperty &&
        other.propertyId == propertyId &&
        other.userId == userId &&
        other.propertyType == propertyType &&
        other.rentPerDay == rentPerDay &&
        other.address == address &&
        other.rating == rating &&
        other.city == city &&
        other.longitude == longitude &&
        other.latitude == latitude &&
        other.title == title &&
        other.description == description &&
        other.guest == guest &&
        other.primaryImage == primaryImage &&
        other.bookingCount == bookingCount;
  }

  @override
  int get hashCode {
    return propertyId.hashCode ^
        userId.hashCode ^
        propertyType.hashCode ^
        rentPerDay.hashCode ^
        address.hashCode ^
        rating.hashCode ^
        city.hashCode ^
        longitude.hashCode ^
        latitude.hashCode ^
        title.hashCode ^
        description.hashCode ^
        guest.hashCode ^
        primaryImage.hashCode ^
        bookingCount.hashCode;
  }
}

class UserPropertiesResponse {
  final List<UserProperty> properties;

  UserPropertiesResponse({
    required this.properties,
  });

  factory UserPropertiesResponse.fromJson(Map<String, dynamic> json) {
    final propertiesList = json['properties'] as List<dynamic>? ?? [];
    final properties = propertiesList
        .map((propertyJson) =>
            UserProperty.fromJson(propertyJson as Map<String, dynamic>))
        .toList();

    return UserPropertiesResponse(
      properties: properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'properties': properties.map((property) => property.toJson()).toList(),
    };
  }
}
