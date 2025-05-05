enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

class Booking {
  final String id;
  final String propertyId;
  final String userId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestCount;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;
  final double? rating;
  final String? review;

  Booking({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.checkIn,
    required this.checkOut,
    required this.guestCount,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.rating,
    this.review,
  });

  Booking copyWith({
    String? id,
    String? propertyId,
    String? userId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guestCount,
    double? totalPrice,
    BookingStatus? status,
    DateTime? createdAt,
    double? rating,
    String? review,
  }) {
    return Booking(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      userId: userId ?? this.userId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guestCount: guestCount ?? this.guestCount,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'userId': userId,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'guestCount': guestCount,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'rating': rating,
      'review': review,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      userId: json['userId'] as String,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      guestCount: json['guestCount'] as int,
      totalPrice: json['totalPrice'] as double,
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      rating: json['rating'] as double?,
      review: json['review'] as String?,
    );
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
