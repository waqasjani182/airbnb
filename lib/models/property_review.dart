class PropertyReview {
  final int id;
  final int propertyId;
  final int userId;
  final int bookingId;
  final double rating;
  final String comment;
  final String createdAt;
  final String updatedAt;
  final String userFirstName;
  final String userLastName;
  final String? userProfileImage;

  // New fields from the updated API response
  final double? userRating;
  final String? userReview;
  final double? ownerRating;
  final String? ownerReview;
  final double? propertyRating;
  final String? propertyReview;
  final String? name;

  PropertyReview({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.userFirstName,
    required this.userLastName,
    this.userProfileImage,
    this.userRating,
    this.userReview,
    this.ownerRating,
    this.ownerReview,
    this.propertyRating,
    this.propertyReview,
    this.name,
  });

  PropertyReview copyWith({
    int? id,
    int? propertyId,
    int? userId,
    int? bookingId,
    double? rating,
    String? comment,
    String? createdAt,
    String? updatedAt,
    String? userFirstName,
    String? userLastName,
    String? userProfileImage,
    double? userRating,
    String? userReview,
    double? ownerRating,
    String? ownerReview,
    double? propertyRating,
    String? propertyReview,
    String? name,
  }) {
    return PropertyReview(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      userId: userId ?? this.userId,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userFirstName: userFirstName ?? this.userFirstName,
      userLastName: userLastName ?? this.userLastName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      userRating: userRating ?? this.userRating,
      userReview: userReview ?? this.userReview,
      ownerRating: ownerRating ?? this.ownerRating,
      ownerReview: ownerReview ?? this.ownerReview,
      propertyRating: propertyRating ?? this.propertyRating,
      propertyReview: propertyReview ?? this.propertyReview,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'user_id': userId,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_first_name': userFirstName,
      'user_last_name': userLastName,
      'user_profile_image': userProfileImage,
      'user_rating': userRating,
      'user_review': userReview,
      'owner_rating': ownerRating,
      'owner_review': ownerReview,
      'property_rating': propertyRating,
      'property_review': propertyReview,
      'name': name,
    };
  }

  factory PropertyReview.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse double values
    double? parseDoubleValue(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return PropertyReview(
      id: json['id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      userId: json['user_ID'] ??
          json['user_id'] ??
          0, // Handle both user_ID and user_id
      bookingId: json['booking_id'] ?? 0,
      rating: parseDoubleValue(json['rating']) ?? 0.0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      userFirstName: json['user_first_name'] ?? '',
      userLastName: json['user_last_name'] ?? '',
      userProfileImage: json['user_profile_image'],
      userRating: parseDoubleValue(json['user_rating']),
      userReview: json['user_review'],
      ownerRating: parseDoubleValue(json['owner_rating']),
      ownerReview: json['owner_review'],
      propertyRating: parseDoubleValue(json['property_rating']),
      propertyReview: json['property_review'],
      name: json['name'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PropertyReview &&
        other.id == id &&
        other.propertyId == propertyId &&
        other.userId == userId &&
        other.bookingId == bookingId &&
        other.rating == rating &&
        other.comment == comment &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.userFirstName == userFirstName &&
        other.userLastName == userLastName &&
        other.userProfileImage == userProfileImage &&
        other.userRating == userRating &&
        other.userReview == userReview &&
        other.ownerRating == ownerRating &&
        other.ownerReview == ownerReview &&
        other.propertyRating == propertyRating &&
        other.propertyReview == propertyReview &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        propertyId.hashCode ^
        userId.hashCode ^
        bookingId.hashCode ^
        rating.hashCode ^
        comment.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        userFirstName.hashCode ^
        userLastName.hashCode ^
        userProfileImage.hashCode ^
        userRating.hashCode ^
        userReview.hashCode ^
        ownerRating.hashCode ^
        ownerReview.hashCode ^
        propertyRating.hashCode ^
        propertyReview.hashCode ^
        name.hashCode;
  }
}
