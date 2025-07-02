import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/common/review_card.dart';
import '../../components/common/star_rating.dart';
import '../../models/review_models.dart';
import '../../providers/review_provider.dart';
import '../../utils/constants.dart';

class PropertyReviewsScreen extends ConsumerStatefulWidget {
  final int propertyId;
  final String? propertyTitle;

  const PropertyReviewsScreen({
    super.key,
    required this.propertyId,
    this.propertyTitle,
  });

  @override
  ConsumerState<PropertyReviewsScreen> createState() =>
      _PropertyReviewsScreenState();
}

class _PropertyReviewsScreenState extends ConsumerState<PropertyReviewsScreen> {
  @override
  void initState() {
    super.initState();
    // Load reviews when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(propertyReviewsProvider.notifier)
          .loadPropertyReviews(widget.propertyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(propertyReviewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(reviewsState),
    );
  }

  Widget _buildBody(PropertyReviewsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!);
    }

    if (state.reviewsResponse == null) {
      return _buildEmptyState();
    }

    return _buildReviewsList(state.reviewsResponse!);
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Unable to load reviews',
              style: AppTextStyles.heading2.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              errorMessage,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.medium),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(propertyReviewsProvider.notifier)
                    .loadPropertyReviews(widget.propertyId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'No reviews yet',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Be the first to share your experience!',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList(PropertyReviewsResponse reviewsResponse) {
    final reviews = reviewsResponse.reviews;
    final averageRating = reviewsResponse.averageRating;
    final totalReviews = reviewsResponse.total;

    return RefreshIndicator(
      onRefresh: () async {
        ref
            .read(propertyReviewsProvider.notifier)
            .loadPropertyReviews(widget.propertyId);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          // Header with statistics
          _buildReviewsHeader(averageRating, totalReviews),

          const SizedBox(height: AppSpacing.large),

          // Reviews list
          if (reviews.isEmpty)
            _buildEmptyReviewsList()
          else
            ...reviews.map((review) => ReviewCard(
                  review: review,
                  showPropertyInfo: false,
                  showActions: false,
                )),
        ],
      ),
    );
  }

  Widget _buildReviewsHeader(double averageRating, int totalReviews) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviews',
                      style: AppTextStyles.heading2,
                    ),
                    if (totalReviews > 0) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (averageRating > 0) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    StarRating(
                      rating: averageRating,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ],
          ),

          // Rating distribution could be added here in the future
          // if the API provides this data
        ],
      ),
    );
  }

  Widget _buildEmptyReviewsList() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'No reviews available',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'This property hasn\'t received any reviews yet.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
