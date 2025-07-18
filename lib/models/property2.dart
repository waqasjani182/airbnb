import 'package:flutter/foundation.dart';
import 'property_image2.dart';
import 'facility.dart';
import 'property_review.dart';

class Property2 {
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
  final String? hostName;
  final List<PropertyImage2> images;
  final List<Facility> facilities;
  final List<PropertyReview> reviews;
  final double avgRating;
  final int reviewCount;
  final int? totalBedrooms;
  final int? totalRooms;
  final int? totalBeds;

  Property2({
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
    this.hostName,
    this.images = const [],
    this.facilities = const [],
    this.reviews = const [],
    this.avgRating = 0.0,
    this.reviewCount = 0,
    this.totalBedrooms,
    this.totalRooms,
    this.totalBeds,
  });

  // Helper method to get image URLs as strings
  List<String> get imageUrls {
    return images.map((img) => img.imageUrl).toList();
  }

  // Helper method to get facility types as strings
  List<String> get facilityTypes {
    return facilities.map((facility) => facility.facilityType).toList();
  }

  // Helper method to get the primary image URL (first image or null)
  String? get primaryImage {
    return images.isNotEmpty ? images.first.imageUrl : null;
  }

  Property2 copyWith({
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
    String? hostName,
    List<PropertyImage2>? images,
    List<Facility>? facilities,
    List<PropertyReview>? reviews,
    double? avgRating,
    int? reviewCount,
    int? totalBedrooms,
    int? totalRooms,
    int? totalBeds,
  }) {
    return Property2(
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
      hostName: hostName ?? this.hostName,
      images: images ?? this.images,
      facilities: facilities ?? this.facilities,
      reviews: reviews ?? this.reviews,
      avgRating: avgRating ?? this.avgRating,
      reviewCount: reviewCount ?? this.reviewCount,
      totalBedrooms: totalBedrooms ?? this.totalBedrooms,
      totalRooms: totalRooms ?? this.totalRooms,
      totalBeds: totalBeds ?? this.totalBeds,
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
      'host_name': hostName,
      'images': images.map((image) => image.toJson()).toList(),
      'facilities': facilities.map((facility) => facility.toJson()).toList(),
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'avg_rating': avgRating,
      'review_count': reviewCount,
      if (totalBedrooms != null) 'total_bedrooms': totalBedrooms,
      if (totalRooms != null) 'total_rooms': totalRooms,
      if (totalBeds != null) 'total_beds': totalBeds,
    };
  }

  factory Property2.fromJson(Map<String, dynamic> json) {
    print('Property2.fromJson - Input JSON: $json');

    // Check if the response has a 'property' wrapper
    Map<String, dynamic> propertyData = json;
    if (json.containsKey('property') &&
        json['property'] is Map<String, dynamic>) {
      propertyData = json['property'] as Map<String, dynamic>;
      print('Property2.fromJson - Using wrapped property data');
    } else {
      print('Property2.fromJson - Using direct property data');
    }

    // Handle images
    List<PropertyImage2> imagesList = [];
    if (propertyData['images'] != null && propertyData['images'] is List) {
      imagesList = (propertyData['images'] as List)
          .map((imageJson) => PropertyImage2.fromJson(imageJson))
          .toList();
    }

    // Handle facilities
    List<Facility> facilitiesList = [];
    if (propertyData['facilities'] != null &&
        propertyData['facilities'] is List) {
      facilitiesList = (propertyData['facilities'] as List)
          .map((facilityJson) => Facility.fromJson(facilityJson))
          .toList();
    }

    // Handle reviews
    List<PropertyReview> reviewsList = [];
    if (propertyData['reviews'] != null && propertyData['reviews'] is List) {
      reviewsList = (propertyData['reviews'] as List)
          .map((reviewJson) => PropertyReview.fromJson(reviewJson))
          .toList();
    }

    // Parse numeric values safely
    double? parseNullableDoubleValue(dynamic value) {
      if (value == null) return null;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString());
    }

    double parseDoubleValue(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int parseIntValue(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    final property = Property2(
      propertyId: parseIntValue(propertyData['property_id']),
      userId: parseIntValue(propertyData['user_id']),
      propertyType: propertyData['property_type'] ?? '',
      rentPerDay: parseDoubleValue(propertyData['rent_per_day']),
      address: propertyData['address'] ?? '',
      rating: parseNullableDoubleValue(propertyData['rating']),
      city: propertyData['city'] ?? '',
      longitude: parseDoubleValue(propertyData['longitude']),
      latitude: parseDoubleValue(propertyData['latitude']),
      title: propertyData['title'] ?? '',
      description: propertyData['description'] ?? '',
      guest: parseIntValue(propertyData['guest']),
      hostName: propertyData['host_name'],
      images: imagesList,
      facilities: facilitiesList,
      reviews: reviewsList,
      avgRating: parseDoubleValue(propertyData['avg_rating']),
      reviewCount: parseIntValue(propertyData['review_count']),
      totalBedrooms: propertyData.containsKey('total_bedrooms')
          ? parseIntValue(propertyData['total_bedrooms'])
          : null,
      totalRooms: propertyData.containsKey('total_rooms')
          ? parseIntValue(propertyData['total_rooms'])
          : null,
      totalBeds: propertyData.containsKey('total_beds')
          ? parseIntValue(propertyData['total_beds'])
          : null,
    );

    print(
        'Property2.fromJson - Successfully created property: ${property.title} (ID: ${property.propertyId})');
    return property;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Property2 &&
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
        other.hostName == hostName &&
        listEquals(other.images, images) &&
        listEquals(other.facilities, facilities) &&
        listEquals(other.reviews, reviews) &&
        other.avgRating == avgRating &&
        other.reviewCount == reviewCount &&
        other.totalBedrooms == totalBedrooms &&
        other.totalRooms == totalRooms &&
        other.totalBeds == totalBeds;
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
        hostName.hashCode ^
        images.hashCode ^
        facilities.hashCode ^
        reviews.hashCode ^
        avgRating.hashCode ^
        reviewCount.hashCode ^
        totalBedrooms.hashCode ^
        totalRooms.hashCode ^
        totalBeds.hashCode;
  }
}
