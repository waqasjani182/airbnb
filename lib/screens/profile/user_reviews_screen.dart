import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/common/review_card.dart';
import '../../components/common/review_form.dart';
import '../../models/property_review.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../utils/constants.dart';

class UserReviewsScreen extends ConsumerStatefulWidget {
  const UserReviewsScreen({super.key});

  @override
  ConsumerState<UserReviewsScreen> createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends ConsumerState<UserReviewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PropertyReview? _editingReview;
  bool _showEditForm = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load reviews when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(guestReviewsProvider.notifier).loadGuestReviews();
      ref.read(hostReviewsProvider.notifier).loadHostReviews();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Reviews I\'ve Written'),
            Tab(text: 'Reviews I\'ve Received'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGuestReviewsTab(),
          _buildHostReviewsTab(),
        ],
      ),
    );
  }

  Widget _buildGuestReviewsTab() {
    final guestReviewsState = ref.watch(guestReviewsProvider);
    final authState = ref.watch(authProvider);

    return _buildReviewsList(
      state: guestReviewsState,
      onRefresh: () async {
        ref.read(guestReviewsProvider.notifier).loadGuestReviews();
      },
      showPropertyInfo: true,
      currentUserId: authState.user?.id,
      onEdit: _handleEditReview,
      onDelete: _handleDeleteReview,
      emptyMessage: 'You haven\'t written any reviews yet.',
      emptySubMessage: 'Reviews you write for properties and hosts will appear here.',
    );
  }

  Widget _buildHostReviewsTab() {
    final hostReviewsState = ref.watch(hostReviewsProvider);

    return _buildReviewsList(
      state: hostReviewsState,
      onRefresh: () async {
        ref.read(hostReviewsProvider.notifier).loadHostReviews();
      },
      showPropertyInfo: true,
      showActions: false, // Host reviews received are not editable
      emptyMessage: 'You haven\'t received any reviews yet.',
      emptySubMessage: 'Reviews from your guests will appear here.',
    );
  }

  Widget _buildReviewsList({
    required ReviewState state,
    required Future<void> Function() onRefresh,
    bool showPropertyInfo = false,
    int? currentUserId,
    Function(PropertyReview)? onEdit,
    Function(PropertyReview)? onDelete,
    bool showActions = true,
    required String emptyMessage,
    required String emptySubMessage,
  }) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!, onRefresh);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          // Edit Form (if editing)
          if (_showEditForm && _editingReview != null) ...[
            ReviewForm(
              existingReview: _editingReview,
              bookingId: _editingReview!.bookingId,
              propertyId: _editingReview!.propertyId,
              propertyTitle: _editingReview!.propertyTitle ?? 'Property',
              onSuccess: _handleReviewUpdate,
              onCancel: _handleCancelEdit,
            ),
            const SizedBox(height: AppSpacing.large),
          ],

          // Reviews List
          if (state.reviews.isEmpty)
            _buildEmptyState(emptyMessage, emptySubMessage)
          else
            ...state.reviews.map((review) => ReviewCard(
                  review: review,
                  showPropertyInfo: showPropertyInfo,
                  currentUserId: currentUserId,
                  showActions: showActions,
                  onEdit: onEdit != null ? () => onEdit(review) : null,
                  onDelete: onDelete != null ? () => onDelete(review) : null,
                )),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, Future<void> Function() onRetry) {
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
              onPressed: () => onRetry(),
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

  Widget _buildEmptyState(String message, String subMessage) {
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
              message,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              subMessage,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleEditReview(PropertyReview review) {
    setState(() {
      _editingReview = review;
      _showEditForm = true;
    });
  }

  void _handleDeleteReview(PropertyReview review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text(
          'Are you sure you want to delete this review? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteReview(review.bookingId);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReview(int bookingId) async {
    try {
      await ref.read(guestReviewsProvider.notifier).deleteReview(bookingId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete review: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleReviewUpdate(PropertyReview updatedReview) {
    setState(() {
      _editingReview = null;
      _showEditForm = false;
    });
  }

  void _handleCancelEdit() {
    setState(() {
      _editingReview = null;
      _showEditForm = false;
    });
  }
}
