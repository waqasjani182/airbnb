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
    };
  }

  factory PropertyReview.fromJson(Map<String, dynamic> json) {
    return PropertyReview(
      id: json['id'],
      propertyId: json['property_id'],
      userId: json['user_id'],
      bookingId: json['booking_id'],
      rating: (json['rating'] is int) 
          ? (json['rating'] as int).toDouble() 
          : json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      userFirstName: json['user_first_name'],
      userLastName: json['user_last_name'],
      userProfileImage: json['user_profile_image'],
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
        other.userProfileImage == userProfileImage;
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
        userProfileImage.hashCode;
  }
}
