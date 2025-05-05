import 'package:flutter/foundation.dart';
import 'property_image.dart';
import 'property_amenity.dart';
import 'property_review.dart';

enum PropertyType {
  apartment,
  house,
  villa,
  cabin,
  hotel,
  other,
}

class Property {
  final int id;
  final int hostId;
  final String title;
  final String description;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final double latitude;
  final double longitude;
  final double pricePerNight;
  final int bedrooms;
  final int bathrooms;
  final int maxGuests;
  final String propertyType;
  final String createdAt;
  final String updatedAt;
  final String hostFirstName;
  final String hostLastName;
  final String? primaryImage;
  final double avgRating;
  final int reviewCount;
  final List<PropertyImage> images;
  final List<PropertyAmenity> amenities;
  final List<PropertyReview> reviews;
  final bool isAvailable;
  final bool isFavorite; // Whether the current user has favorited this property

  Property({
    required this.id,
    required this.hostId,
    required this.title,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    required this.pricePerNight,
    required this.bedrooms,
    required this.bathrooms,
    required this.maxGuests,
    required this.propertyType,
    required this.createdAt,
    required this.updatedAt,
    required this.hostFirstName,
    required this.hostLastName,
    this.primaryImage,
    this.avgRating = 0.0,
    this.reviewCount = 0,
    this.images = const [],
    this.amenities = const [],
    this.reviews = const [],
    this.isAvailable = true,
    this.isFavorite = false,
  });

  // Helper method to get a formatted location string
  String get location => '$city, $state, $country';

  // Helper method to get the property type as enum
  PropertyType get type {
    switch (propertyType.toLowerCase()) {
      case 'apartment':
        return PropertyType.apartment;
      case 'house':
        return PropertyType.house;
      case 'villa':
        return PropertyType.villa;
      case 'cabin':
        return PropertyType.cabin;
      case 'hotel':
        return PropertyType.hotel;
      default:
        return PropertyType.other;
    }
  }

  // Helper method to get image URLs as strings for backward compatibility
  List<String> get imageUrls {
    if (images.isEmpty && primaryImage != null) {
      return [primaryImage!];
    }
    return images.map((img) => img.imageUrl).toList();
  }

  // Helper method to get amenity names as strings for backward compatibility
  List<String> get amenityNames {
    return amenities.map((amenity) => amenity.name).toList();
  }

  Property copyWith({
    int? id,
    int? hostId,
    String? title,
    String? description,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    double? latitude,
    double? longitude,
    double? pricePerNight,
    int? bedrooms,
    int? bathrooms,
    int? maxGuests,
    String? propertyType,
    String? createdAt,
    String? updatedAt,
    String? hostFirstName,
    String? hostLastName,
    String? primaryImage,
    double? avgRating,
    int? reviewCount,
    List<PropertyImage>? images,
    List<PropertyAmenity>? amenities,
    List<PropertyReview>? reviews,
    bool? isAvailable,
    bool? isFavorite,
  }) {
    return Property(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      maxGuests: maxGuests ?? this.maxGuests,
      propertyType: propertyType ?? this.propertyType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hostFirstName: hostFirstName ?? this.hostFirstName,
      hostLastName: hostLastName ?? this.hostLastName,
      primaryImage: primaryImage ?? this.primaryImage,
      avgRating: avgRating ?? this.avgRating,
      reviewCount: reviewCount ?? this.reviewCount,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      reviews: reviews ?? this.reviews,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'host_id': hostId,
      'title': title,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'price_per_night': pricePerNight,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'max_guests': maxGuests,
      'property_type': propertyType,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'host_first_name': hostFirstName,
      'host_last_name': hostLastName,
      'primary_image': primaryImage,
      'avg_rating': avgRating,
      'review_count': reviewCount,
      'images': images.map((image) => image.toJson()).toList(),
      'amenities': amenities.map((amenity) => amenity.toJson()).toList(),
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'is_available': isAvailable,
      'is_favorite': isFavorite,
    };
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    // Handle images
    List<PropertyImage> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = (json['images'] as List)
          .map((imageJson) => PropertyImage.fromJson(imageJson))
          .toList();
    }

    // Handle amenities
    List<PropertyAmenity> amenitiesList = [];
    if (json['amenities'] != null && json['amenities'] is List) {
      amenitiesList = (json['amenities'] as List)
          .map((amenityJson) => PropertyAmenity.fromJson(amenityJson))
          .toList();
    }

    // Handle reviews
    List<PropertyReview> reviewsList = [];
    if (json['reviews'] != null && json['reviews'] is List) {
      reviewsList = (json['reviews'] as List)
          .map((reviewJson) => PropertyReview.fromJson(reviewJson))
          .toList();
    }

    return Property(
      id: json['id'],
      hostId: json['host_id'],
      title: json['title'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zip_code'],
      latitude: json['latitude'] is int
          ? (json['latitude'] as int).toDouble()
          : json['latitude'],
      longitude: json['longitude'] is int
          ? (json['longitude'] as int).toDouble()
          : json['longitude'],
      pricePerNight: json['price_per_night'] is int
          ? (json['price_per_night'] as int).toDouble()
          : json['price_per_night'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      maxGuests: json['max_guests'],
      propertyType: json['property_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      hostFirstName: json['host_first_name'],
      hostLastName: json['host_last_name'],
      primaryImage: json['primary_image'],
      avgRating: json['avg_rating'] is int
          ? (json['avg_rating'] as int).toDouble()
          : (json['avg_rating'] ?? 0.0),
      reviewCount: json['review_count'] ?? 0,
      images: imagesList,
      amenities: amenitiesList,
      reviews: reviewsList,
      isAvailable: json['is_available'] ?? true,
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Property &&
        other.id == id &&
        other.hostId == hostId &&
        other.title == title &&
        other.description == description &&
        other.address == address &&
        other.city == city &&
        other.state == state &&
        other.country == country &&
        other.zipCode == zipCode &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.pricePerNight == pricePerNight &&
        other.bedrooms == bedrooms &&
        other.bathrooms == bathrooms &&
        other.maxGuests == maxGuests &&
        other.propertyType == propertyType &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.hostFirstName == hostFirstName &&
        other.hostLastName == hostLastName &&
        other.primaryImage == primaryImage &&
        other.avgRating == avgRating &&
        other.reviewCount == reviewCount &&
        listEquals(other.images, images) &&
        listEquals(other.amenities, amenities) &&
        listEquals(other.reviews, reviews) &&
        other.isAvailable == isAvailable &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        hostId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        address.hashCode ^
        city.hashCode ^
        state.hashCode ^
        country.hashCode ^
        zipCode.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        pricePerNight.hashCode ^
        bedrooms.hashCode ^
        bathrooms.hashCode ^
        maxGuests.hashCode ^
        propertyType.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        hostFirstName.hashCode ^
        hostLastName.hashCode ^
        primaryImage.hashCode ^
        avgRating.hashCode ^
        reviewCount.hashCode ^
        images.hashCode ^
        amenities.hashCode ^
        reviews.hashCode ^
        isAvailable.hashCode ^
        isFavorite.hashCode;
  }
}
