import 'property_review.dart';

/// Request model for creating guest reviews (property + host review)
class CreateGuestReviewRequest {
  final int bookingId;
  final int propertyId;
  final double? propertyRating;
  final String? propertyReview;
  final double? userRating; // Host rating
  final String? userReview; // Host review

  CreateGuestReviewRequest({
    required this.bookingId,
    required this.propertyId,
    this.propertyRating,
    this.propertyReview,
    this.userRating,
    this.userReview,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'property_id': propertyId,
      'property_rating': propertyRating,
      'property_review': propertyReview,
      'user_rating': userRating,
      'user_review': userReview,
    };
  }
}

/// Request model for creating host reviews (guest review)
class CreateHostReviewRequest {
  final int bookingId;
  final double ownerRating;
  final String ownerReview;

  CreateHostReviewRequest({
    required this.bookingId,
    required this.ownerRating,
    required this.ownerReview,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'owner_rating': ownerRating,
      'owner_review': ownerReview,
    };
  }
}

/// Response model for property reviews with pagination and statistics
class PropertyReviewsResponse {
  final List<PropertyReview> reviews;
  final int total;
  final double averageRating;

  PropertyReviewsResponse({
    required this.reviews,
    required this.total,
    required this.averageRating,
  });

  factory PropertyReviewsResponse.fromJson(Map<String, dynamic> json) {
    return PropertyReviewsResponse(
      reviews: (json['reviews'] as List? ?? [])
          .map((r) => PropertyReview.fromJson(r))
          .toList(),
      total: json['total'] ?? 0,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
    );
  }
}

/// Response model for review operations
class ReviewResponse {
  final String message;
  final PropertyReview review;

  ReviewResponse({
    required this.message,
    required this.review,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      message: json['message'] ?? '',
      review: PropertyReview.fromJson(json['review']),
    );
  }
}

/// Model for review statistics
class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // rating -> count

  ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    final distribution = <int, int>{};
    if (json['rating_distribution'] != null) {
      final dist = json['rating_distribution'] as Map<String, dynamic>;
      dist.forEach((key, value) {
        distribution[int.parse(key)] = value as int;
      });
    }

    return ReviewStats(
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      ratingDistribution: distribution,
    );
  }
}

/// Enum for review types
enum ReviewType {
  property,
  host,
  guest,
}

/// Model for review filters
class ReviewFilters {
  final ReviewType? type;
  final int? minRating;
  final int? maxRating;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;
  final int? offset;

  ReviewFilters({
    this.type,
    this.minRating,
    this.maxRating,
    this.startDate,
    this.endDate,
    this.limit,
    this.offset,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (type != null) {
      params['type'] = type!.name;
    }
    if (minRating != null) {
      params['min_rating'] = minRating;
    }
    if (maxRating != null) {
      params['max_rating'] = maxRating;
    }
    if (startDate != null) {
      params['start_date'] = startDate!.toIso8601String();
    }
    if (endDate != null) {
      params['end_date'] = endDate!.toIso8601String();
    }
    if (limit != null) {
      params['limit'] = limit;
    }
    if (offset != null) {
      params['offset'] = offset;
    }
    
    return params;
  }
}
