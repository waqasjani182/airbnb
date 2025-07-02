import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property_review.dart';
import '../models/review_models.dart';
import '../services/review_service.dart';
import 'api_provider.dart';

// Review service provider
final reviewServiceProvider = Provider<ReviewService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReviewService(apiClient: apiClient);
});

// Review state classes
class ReviewState {
  final List<PropertyReview> reviews;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  ReviewState({
    this.reviews = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 0,
  });

  ReviewState copyWith({
    List<PropertyReview>? reviews,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PropertyReviewsState {
  final PropertyReviewsResponse? reviewsResponse;
  final bool isLoading;
  final String? errorMessage;

  PropertyReviewsState({
    this.reviewsResponse,
    this.isLoading = false,
    this.errorMessage,
  });

  PropertyReviewsState copyWith({
    PropertyReviewsResponse? reviewsResponse,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PropertyReviewsState(
      reviewsResponse: reviewsResponse ?? this.reviewsResponse,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Property reviews provider
class PropertyReviewsNotifier extends StateNotifier<PropertyReviewsState> {
  final ReviewService _reviewService;

  PropertyReviewsNotifier(this._reviewService) : super(PropertyReviewsState());

  Future<void> loadPropertyReviews(int propertyId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final reviewsResponse = await _reviewService.getPropertyReviews(propertyId);
      state = state.copyWith(
        reviewsResponse: reviewsResponse,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearReviews() {
    state = PropertyReviewsState();
  }
}

final propertyReviewsProvider =
    StateNotifierProvider<PropertyReviewsNotifier, PropertyReviewsState>((ref) {
  final reviewService = ref.watch(reviewServiceProvider);
  return PropertyReviewsNotifier(reviewService);
});

// Guest reviews provider
class GuestReviewsNotifier extends StateNotifier<ReviewState> {
  final ReviewService _reviewService;

  GuestReviewsNotifier(this._reviewService) : super(ReviewState());

  Future<void> loadGuestReviews() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final reviews = await _reviewService.getGuestReviews();
      state = state.copyWith(
        reviews: reviews,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> createReview(CreateGuestReviewRequest request) async {
    try {
      final response = await _reviewService.createGuestReview(request);
      // Add the new review to the list
      final updatedReviews = [response.review, ...state.reviews];
      state = state.copyWith(reviews: updatedReviews);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> updateReview(int bookingId, Map<String, dynamic> updates) async {
    try {
      final response = await _reviewService.updateGuestReview(bookingId, updates);
      // Update the review in the list
      final updatedReviews = state.reviews.map((review) {
        return review.bookingId == bookingId ? response.review : review;
      }).toList();
      state = state.copyWith(reviews: updatedReviews);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> deleteReview(int bookingId) async {
    try {
      await _reviewService.deleteReview(bookingId);
      // Remove the review from the list
      final updatedReviews = state.reviews
          .where((review) => review.bookingId != bookingId)
          .toList();
      state = state.copyWith(reviews: updatedReviews);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  void clearReviews() {
    state = ReviewState();
  }
}

final guestReviewsProvider =
    StateNotifierProvider<GuestReviewsNotifier, ReviewState>((ref) {
  final reviewService = ref.watch(reviewServiceProvider);
  return GuestReviewsNotifier(reviewService);
});

// Host reviews provider
class HostReviewsNotifier extends StateNotifier<ReviewState> {
  final ReviewService _reviewService;

  HostReviewsNotifier(this._reviewService) : super(ReviewState());

  Future<void> loadHostReviews() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final reviews = await _reviewService.getHostReviews();
      state = state.copyWith(
        reviews: reviews,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> createHostReview(CreateHostReviewRequest request) async {
    try {
      final response = await _reviewService.createHostReview(request);
      // Add the new review to the list
      final updatedReviews = [response.review, ...state.reviews];
      state = state.copyWith(reviews: updatedReviews);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  void clearReviews() {
    state = ReviewState();
  }
}

final hostReviewsProvider =
    StateNotifierProvider<HostReviewsNotifier, ReviewState>((ref) {
  final reviewService = ref.watch(reviewServiceProvider);
  return HostReviewsNotifier(reviewService);
});

// Review stats provider
final reviewStatsProvider = FutureProvider.family<ReviewStats, int>((ref, propertyId) async {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.getReviewStats(propertyId);
});
