import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/property_review.dart';
import '../../models/review_models.dart';
import '../../providers/review_provider.dart';
import '../../utils/constants.dart';
import 'star_rating.dart';

class ReviewForm extends ConsumerStatefulWidget {
  final PropertyReview? existingReview;
  final int bookingId;
  final int propertyId;
  final String propertyTitle;
  final Function(PropertyReview)? onSuccess;
  final VoidCallback? onCancel;
  final bool isHostReview;

  const ReviewForm({
    super.key,
    this.existingReview,
    required this.bookingId,
    required this.propertyId,
    required this.propertyTitle,
    this.onSuccess,
    this.onCancel,
    this.isHostReview = false,
  });

  @override
  ConsumerState<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends ConsumerState<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _propertyReviewController = TextEditingController();
  final _hostReviewController = TextEditingController();
  final _guestReviewController = TextEditingController();

  double _propertyRating = 5.0;
  double _hostRating = 5.0;
  double _guestRating = 5.0;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.existingReview != null) {
      final review = widget.existingReview!;

      if (review.propertyRating != null) {
        _propertyRating = review.propertyRating!;
        _propertyReviewController.text = review.propertyReview ?? '';
      }

      if (review.userRating != null) {
        _hostRating = review.userRating!;
        _hostReviewController.text = review.userReview ?? '';
      }

      if (review.ownerRating != null) {
        _guestRating = review.ownerRating!;
        _guestReviewController.text = review.ownerReview ?? '';
      }
    }
  }

  @override
  void dispose() {
    _propertyReviewController.dispose();
    _hostReviewController.dispose();
    _guestReviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.isHostReview) {
        await _submitHostReview();
      } else {
        await _submitGuestReview();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitGuestReview() async {
    final guestReviewsNotifier = ref.read(guestReviewsProvider.notifier);

    if (widget.existingReview != null) {
      // Update existing review
      final updates = <String, dynamic>{};

      if (_propertyReviewController.text.trim().isNotEmpty) {
        updates['property_rating'] = _propertyRating;
        updates['property_review'] = _propertyReviewController.text.trim();
      }

      if (_hostReviewController.text.trim().isNotEmpty) {
        updates['user_rating'] = _hostRating;
        updates['user_review'] = _hostReviewController.text.trim();
      }

      await guestReviewsNotifier.updateReview(widget.bookingId, updates);
    } else {
      // Create new review
      final request = CreateGuestReviewRequest(
        bookingId: widget.bookingId,
        propertyId: widget.propertyId,
        propertyRating: _propertyReviewController.text.trim().isNotEmpty
            ? _propertyRating
            : null,
        propertyReview: _propertyReviewController.text.trim().isNotEmpty
            ? _propertyReviewController.text.trim()
            : null,
        userRating:
            _hostReviewController.text.trim().isNotEmpty ? _hostRating : null,
        userReview: _hostReviewController.text.trim().isNotEmpty
            ? _hostReviewController.text.trim()
            : null,
      );

      await guestReviewsNotifier.createReview(request);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingReview != null
              ? 'Review updated successfully!'
              : 'Review submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      widget.onSuccess?.call(widget.existingReview!);
    }
  }

  Future<void> _submitHostReview() async {
    final hostReviewsNotifier = ref.read(hostReviewsProvider.notifier);

    final request = CreateHostReviewRequest(
      bookingId: widget.bookingId,
      ownerRating: _guestRating,
      ownerReview: _guestReviewController.text.trim(),
    );

    await hostReviewsNotifier.createHostReview(request);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guest review submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      widget.onSuccess?.call(widget.existingReview!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.medium),
              if (_errorMessage != null) ...[
                _buildErrorMessage(),
                const SizedBox(height: AppSpacing.medium),
              ],
              if (widget.isHostReview)
                _buildGuestReviewSection()
              else ...[
                _buildPropertyReviewSection(),
                const SizedBox(height: AppSpacing.large),
                _buildHostReviewSection(),
              ],
              const SizedBox(height: AppSpacing.large),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingReview != null
                    ? 'Edit Your Review'
                    : widget.isHostReview
                        ? 'Review Guest'
                        : 'Write a Review',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.propertyTitle,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        if (widget.onCancel != null)
          IconButton(
            onPressed: widget.onCancel,
            icon: const Icon(Icons.close),
          ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Property Rating', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.small),
        InteractiveStarRating(
          initialRating: _propertyRating,
          onRatingChanged: (rating) {
            setState(() {
              _propertyRating = rating;
            });
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Rate your overall experience with this property',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.medium),
        const Text('Property Review', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.small),
        TextFormField(
          controller: _propertyReviewController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Share your experience with this property...',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please write a review';
            }
            if (value.trim().length < 10) {
              return 'Review must be at least 10 characters long';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildHostReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Host Rating (Optional)', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.small),
        InteractiveStarRating(
          initialRating: _hostRating,
          onRatingChanged: (rating) {
            setState(() {
              _hostRating = rating;
            });
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Rate your experience with the host',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.medium),
        const Text('Host Review (Optional)', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.small),
        TextFormField(
          controller: _hostReviewController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Share your experience with the host...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Guest Rating', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.small),
        InteractiveStarRating(
          initialRating: _guestRating,
          onRatingChanged: (rating) {
            setState(() {
              _guestRating = rating;
            });
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Rate your experience with this guest',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.medium),
        const Text('Guest Review', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.small),
        TextFormField(
          controller: _guestReviewController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Share your experience with this guest...',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please write a review';
            }
            if (value.trim().length < 10) {
              return 'Review must be at least 10 characters long';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.onCancel != null) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : widget.onCancel,
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(widget.existingReview != null
                    ? 'Update Review'
                    : 'Submit Review'),
          ),
        ),
      ],
    );
  }
}
