import '../models/property_review.dart';
import '../models/review_models.dart';
import 'api_client.dart';

class ReviewService {
  final ApiClient _apiClient;

  ReviewService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get all reviews for a property (public endpoint)
  Future<PropertyReviewsResponse> getPropertyReviews(int propertyId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/reviews/property/$propertyId',
      fromJson: (json) => json,
    );

    if (response.success && response.data != null) {
      return PropertyReviewsResponse.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to load property reviews');
    }
  }

  /// Get all reviews written by current user as guest
  Future<List<PropertyReview>> getGuestReviews() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/reviews/guest',
      requiresAuth: true,
      fromJson: (json) => json,
    );

    if (response.success && response.data != null) {
      final reviews = response.data!['reviews'] as List? ?? [];
      return reviews.map((r) => PropertyReview.fromJson(r)).toList();
    } else {
      throw Exception(response.error ?? 'Failed to load guest reviews');
    }
  }

  /// Get all reviews received by current user as host
  Future<List<PropertyReview>> getHostReviews() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/reviews/host',
      requiresAuth: true,
      fromJson: (json) => json,
    );

    if (response.success && response.data != null) {
      final reviews = response.data!['reviews'] as List? ?? [];
      return reviews.map((r) => PropertyReview.fromJson(r)).toList();
    } else {
      throw Exception(response.error ?? 'Failed to load host reviews');
    }
  }

  /// Create a new guest review (property + host review)
  Future<ReviewResponse> createGuestReview(CreateGuestReviewRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/reviews',
      requiresAuth: true,
      body: request.toJson(),
      fromJson: (json) => json,
    );

    if (response.success && response.data != null) {
      return ReviewResponse.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to create review');
    }
  }

  /// Create a new host review (guest review)
  Future<ReviewResponse> createHostReview(CreateHostReviewRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/reviews/host',
      requiresAuth: true,
      body: request.toJson(),
      fromJson: (json) => json,
    );

    if (response.success && response.data != null) {
      return ReviewResponse.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to create host review');
    }
  }

  /// Update a guest review
  Future<ReviewResponse> updateGuestReview(
    int bookingId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/reviews/$bookingId',
      requiresAuth: true,
      body: updates,
      fromJson: (json) => json,
    );

    if (response.success && response.data != null) {
      return ReviewResponse.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to update review');
    }
  }

  /// Update a host review
  Future<ReviewResponse> updateHostReview(
    int bookingId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '/api/reviews/host/$bookingId',
      requiresAuth: true,
      body: updates,
      fromJson: (json) => json,
    );

    if (response.success && response.data != null) {
      return ReviewResponse.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to update host review');
    }
  }

  /// Delete a review
  Future<void> deleteReview(int bookingId) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      '/api/reviews/$bookingId',
      requiresAuth: true,
      fromJson: (json) => json,
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Failed to delete review');
    }
  }

  /// Get review statistics for a property
  Future<ReviewStats> getReviewStats(int propertyId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/reviews/property/$propertyId/stats',
      fromJson: (json) => json,
    );

    if (response.success && response.data != null) {
      return ReviewStats.fromJson(response.data!);
    } else {
      throw Exception(response.error ?? 'Failed to load review statistics');
    }
  }
}
