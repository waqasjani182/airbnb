import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final bool interactive;
  final double size;
  final Function(double)? onRatingChanged;
  final Color activeColor;
  final Color inactiveColor;
  final MainAxisSize mainAxisSize;
  final bool showRatingText;
  final TextStyle? ratingTextStyle;

  const StarRating({
    super.key,
    required this.rating,
    this.interactive = false,
    this.size = 24.0,
    this.onRatingChanged,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.mainAxisSize = MainAxisSize.min,
    this.showRatingText = false,
    this.ratingTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: mainAxisSize,
      children: [
        ...List.generate(5, (index) {
          return GestureDetector(
            onTap: interactive ? () => onRatingChanged?.call(index + 1.0) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Icon(
                _getStarIcon(index),
                color: _getStarColor(index),
                size: size,
              ),
            ),
          );
        }),
        if (showRatingText) ...[
          const SizedBox(width: AppSpacing.small),
          Text(
            rating.toStringAsFixed(1),
            style: ratingTextStyle ??
                TextStyle(
                  fontSize: size * 0.6,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ],
    );
  }

  IconData _getStarIcon(int index) {
    if (index < rating.floor()) {
      return Icons.star;
    } else if (index < rating && rating - index >= 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }

  Color _getStarColor(int index) {
    if (index < rating) {
      return activeColor;
    } else {
      return inactiveColor;
    }
  }
}

class InteractiveStarRating extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool allowHalfRating;

  const InteractiveStarRating({
    super.key,
    required this.initialRating,
    required this.onRatingChanged,
    this.size = 32.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.allowHalfRating = false,
  });

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1.0;
            });
            widget.onRatingChanged(_currentRating);
          },
          onTapDown: widget.allowHalfRating
              ? (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  final starWidth = widget.size + 2.0; // Including padding
                  final starIndex = (localPosition.dx / starWidth).floor();
                  final withinStar = (localPosition.dx % starWidth) / starWidth;
                  
                  double newRating;
                  if (withinStar < 0.5) {
                    newRating = starIndex + 0.5;
                  } else {
                    newRating = starIndex + 1.0;
                  }
                  
                  if (newRating >= 0.5 && newRating <= 5.0) {
                    setState(() {
                      _currentRating = newRating;
                    });
                    widget.onRatingChanged(_currentRating);
                  }
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: Icon(
              _getStarIcon(index),
              color: _getStarColor(index),
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }

  IconData _getStarIcon(int index) {
    if (index < _currentRating.floor()) {
      return Icons.star;
    } else if (index < _currentRating && _currentRating - index >= 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }

  Color _getStarColor(int index) {
    if (index < _currentRating) {
      return widget.activeColor;
    } else {
      return widget.inactiveColor;
    }
  }
}

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double starSize;
  final TextStyle? textStyle;
  final bool showReviewCount;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.reviewCount,
    this.starSize = 16.0,
    this.textStyle,
    this.showReviewCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StarRating(
          rating: rating,
          size: starSize,
          showRatingText: true,
          ratingTextStyle: textStyle,
        ),
        if (showReviewCount && reviewCount != null) ...[
          const SizedBox(width: AppSpacing.small),
          Text(
            '($reviewCount)',
            style: textStyle ??
                TextStyle(
                  fontSize: starSize * 0.75,
                  color: AppColors.textLight,
                ),
          ),
        ],
      ],
    );
  }
}
