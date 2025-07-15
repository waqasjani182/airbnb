import 'facility.dart';

/// Model for property data returned by the city properties API
class CityProperty {
  final int propertyId;
  final int userId;
  final String propertyType;
  final double rentPerDay;
  final String address;
  final double rating;
  final String city;
  final double longitude;
  final double latitude;
  final String title;
  final String description;
  final int guest;
  final String status;
  final bool isActive;
  final String hostName;
  final String? hostProfileImage;
  final String? propertyImage;
  final double totalRating;
  final int reviewCount;
  final double avgUserRating;
  final double avgOwnerRating;
  final List<String> images;
  final List<Facility> facilities;

  CityProperty({
    required this.propertyId,
    required this.userId,
    required this.propertyType,
    required this.rentPerDay,
    required this.address,
    required this.rating,
    required this.city,
    required this.longitude,
    required this.latitude,
    required this.title,
    required this.description,
    required this.guest,
    required this.status,
    required this.isActive,
    required this.hostName,
    this.hostProfileImage,
    this.propertyImage,
    required this.totalRating,
    required this.reviewCount,
    required this.avgUserRating,
    required this.avgOwnerRating,
    required this.images,
    required this.facilities,
  });

  factory CityProperty.fromJson(Map<String, dynamic> json) {
    // Parse images array
    List<String> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = (json['images'] as List).cast<String>();
    }

    // Parse facilities array
    List<Facility> facilitiesList = [];
    if (json['facilities'] != null && json['facilities'] is List) {
      facilitiesList = (json['facilities'] as List)
          .map((facilityJson) => Facility.fromJson(facilityJson))
          .toList();
    }

    // Helper function to parse double values
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Helper function to parse int values
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return CityProperty(
      propertyId: parseInt(json['property_id']),
      userId: parseInt(json['user_id']),
      propertyType: json['property_type'] ?? '',
      rentPerDay: parseDouble(json['rent_per_day']),
      address: json['address'] ?? '',
      rating: parseDouble(json['rating']),
      city: json['city'] ?? '',
      longitude: parseDouble(json['longitude']),
      latitude: parseDouble(json['latitude']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      guest: parseInt(json['guest']),
      status: json['status'] ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      hostName: json['host_name'] ?? '',
      hostProfileImage: json['host_profile_image'],
      propertyImage: json['property_image'],
      totalRating: parseDouble(json['total_rating']),
      reviewCount: parseInt(json['review_count']),
      avgUserRating: parseDouble(json['avg_user_rating']),
      avgOwnerRating: parseDouble(json['avg_owner_rating']),
      images: imagesList,
      facilities: facilitiesList,
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
      'status': status,
      'is_active': isActive,
      'host_name': hostName,
      'host_profile_image': hostProfileImage,
      'property_image': propertyImage,
      'total_rating': totalRating,
      'review_count': reviewCount,
      'avg_user_rating': avgUserRating,
      'avg_owner_rating': avgOwnerRating,
      'images': images,
      'facilities': facilities.map((f) => f.toJson()).toList(),
    };
  }
}

/// Model for the complete city properties API response
class CityPropertiesResponse {
  final String city;
  final List<CityProperty> properties;
  final int totalCount;
  final String averageCityRating;

  CityPropertiesResponse({
    required this.city,
    required this.properties,
    required this.totalCount,
    required this.averageCityRating,
  });

  factory CityPropertiesResponse.fromJson(Map<String, dynamic> json) {
    List<CityProperty> propertiesList = [];
    if (json['properties'] != null && json['properties'] is List) {
      propertiesList = (json['properties'] as List)
          .map((propertyJson) => CityProperty.fromJson(propertyJson))
          .toList();
    }

    return CityPropertiesResponse(
      city: json['city'] ?? '',
      properties: propertiesList,
      totalCount: json['total_count'] ?? 0,
      averageCityRating: json['average_city_rating'] ?? '0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'properties': properties.map((p) => p.toJson()).toList(),
      'total_count': totalCount,
      'average_city_rating': averageCityRating,
    };
  }
}
