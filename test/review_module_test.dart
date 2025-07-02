import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/models/review_models.dart';
import '../lib/models/property_review.dart';
import '../lib/components/common/star_rating.dart';
import '../lib/components/common/review_card.dart';

void main() {
  group('Review Module Tests', () {
    
    group('Review Models', () {
      test('CreateGuestReviewRequest should serialize correctly', () {
        final request = CreateGuestReviewRequest(
          bookingId: 1,
          propertyId: 2,
          propertyRating: 4.5,
          propertyReview: 'Great property!',
          userRating: 5.0,
          userReview: 'Excellent host!',
        );

        final json = request.toJson();

        expect(json['booking_id'], 1);
        expect(json['property_id'], 2);
        expect(json['property_rating'], 4.5);
        expect(json['property_review'], 'Great property!');
        expect(json['user_rating'], 5.0);
        expect(json['user_review'], 'Excellent host!');
      });

      test('CreateHostReviewRequest should serialize correctly', () {
        final request = CreateHostReviewRequest(
          bookingId: 1,
          ownerRating: 4.0,
          ownerReview: 'Good guest!',
        );

        final json = request.toJson();

        expect(json['booking_id'], 1);
        expect(json['owner_rating'], 4.0);
        expect(json['owner_review'], 'Good guest!');
      });

      test('PropertyReviewsResponse should deserialize correctly', () {
        final json = {
          'reviews': [
            {
              'id': 1,
              'booking_id': 1,
              'user_ID': 1,
              'property_id': 1,
              'rating': 4.5,
              'comment': 'Great!',
              'created_at': '2023-01-01T00:00:00Z',
              'updated_at': '2023-01-01T00:00:00Z',
              'user_first_name': 'John',
              'user_last_name': 'Doe',
              'property_rating': 4.5,
              'property_review': 'Great property!',
            }
          ],
          'total': 1,
          'average_rating': 4.5,
        };

        final response = PropertyReviewsResponse.fromJson(json);

        expect(response.reviews.length, 1);
        expect(response.total, 1);
        expect(response.averageRating, 4.5);
        expect(response.reviews.first.propertyRating, 4.5);
        expect(response.reviews.first.propertyReview, 'Great property!');
      });

      test('PropertyReview should handle enhanced fields', () {
        final json = {
          'id': 1,
          'booking_id': 1,
          'user_ID': 1,
          'property_id': 1,
          'rating': 4.5,
          'comment': 'Great!',
          'created_at': '2023-01-01T00:00:00Z',
          'updated_at': '2023-01-01T00:00:00Z',
          'user_first_name': 'John',
          'user_last_name': 'Doe',
          'property_rating': 4.5,
          'property_review': 'Great property!',
          'user_rating': 5.0,
          'user_review': 'Excellent host!',
          'property_title': 'Beautiful Apartment',
          'property_city': 'New York',
          'property_image': 'https://example.com/image.jpg',
        };

        final review = PropertyReview.fromJson(json);

        expect(review.propertyRating, 4.5);
        expect(review.propertyReview, 'Great property!');
        expect(review.userRating, 5.0);
        expect(review.userReview, 'Excellent host!');
        expect(review.propertyTitle, 'Beautiful Apartment');
        expect(review.propertyCity, 'New York');
        expect(review.propertyImage, 'https://example.com/image.jpg');
      });
    });

    group('Star Rating Widget', () {
      testWidgets('StarRating should display correct number of stars', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StarRating(rating: 3.5),
            ),
          ),
        );

        // Should have 5 star icons
        expect(find.byIcon(Icons.star), findsNWidgets(3));
        expect(find.byIcon(Icons.star_half), findsOneWidget);
        expect(find.byIcon(Icons.star_border), findsOneWidget);
      });

      testWidgets('StarRating should show rating text when enabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StarRating(
                rating: 4.2,
                showRatingText: true,
              ),
            ),
          ),
        );

        expect(find.text('4.2'), findsOneWidget);
      });

      testWidgets('InteractiveStarRating should respond to taps', (WidgetTester tester) async {
        double? selectedRating;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InteractiveStarRating(
                initialRating: 3.0,
                onRatingChanged: (rating) {
                  selectedRating = rating;
                },
              ),
            ),
          ),
        );

        // Tap on the 5th star
        await tester.tap(find.byIcon(Icons.star_border).last);
        await tester.pump();

        expect(selectedRating, 5.0);
      });
    });

    group('Review Card Widget', () {
      testWidgets('ReviewCard should display review information', (WidgetTester tester) async {
        final review = PropertyReview(
          id: 1,
          bookingId: 1,
          userId: 1,
          propertyId: 1,
          rating: 4.5,
          comment: 'Great stay!',
          createdAt: '2023-01-01T00:00:00Z',
          updatedAt: '2023-01-01T00:00:00Z',
          userFirstName: 'John',
          userLastName: 'Doe',
          propertyRating: 4.5,
          propertyReview: 'Amazing property with great amenities!',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReviewCard(review: review),
            ),
          ),
        );

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Amazing property with great amenities!'), findsOneWidget);
        expect(find.byType(StarRating), findsWidgets);
      });

      testWidgets('ReviewCard should show property info when enabled', (WidgetTester tester) async {
        final review = PropertyReview(
          id: 1,
          bookingId: 1,
          userId: 1,
          propertyId: 1,
          rating: 4.5,
          comment: 'Great stay!',
          createdAt: '2023-01-01T00:00:00Z',
          updatedAt: '2023-01-01T00:00:00Z',
          userFirstName: 'John',
          userLastName: 'Doe',
          propertyRating: 4.5,
          propertyReview: 'Amazing property!',
          propertyTitle: 'Beautiful Apartment',
          propertyCity: 'New York',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReviewCard(
                review: review,
                showPropertyInfo: true,
              ),
            ),
          ),
        );

        expect(find.text('Beautiful Apartment'), findsOneWidget);
        expect(find.text('New York'), findsOneWidget);
      });
    });

    group('Review Filters', () {
      test('ReviewFilters should generate correct query params', () {
        final filters = ReviewFilters(
          type: ReviewType.property,
          minRating: 3,
          maxRating: 5,
          limit: 10,
          offset: 0,
        );

        final params = filters.toQueryParams();

        expect(params['type'], 'property');
        expect(params['min_rating'], 3);
        expect(params['max_rating'], 5);
        expect(params['limit'], 10);
        expect(params['offset'], 0);
      });

      test('ReviewFilters should handle null values', () {
        final filters = ReviewFilters();
        final params = filters.toQueryParams();

        expect(params.isEmpty, true);
      });
    });

    group('Review Stats', () {
      test('ReviewStats should deserialize correctly', () {
        final json = {
          'average_rating': 4.2,
          'total_reviews': 150,
          'rating_distribution': {
            '1': 5,
            '2': 10,
            '3': 20,
            '4': 50,
            '5': 65,
          },
        };

        final stats = ReviewStats.fromJson(json);

        expect(stats.averageRating, 4.2);
        expect(stats.totalReviews, 150);
        expect(stats.ratingDistribution[1], 5);
        expect(stats.ratingDistribution[5], 65);
      });
    });
  });
}
