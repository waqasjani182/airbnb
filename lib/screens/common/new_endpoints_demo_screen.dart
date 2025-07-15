import 'package:flutter/material.dart';
import '../search/city_properties_screen.dart';
import '../booking/bookings_with_ratings_screen.dart';
import '../../utils/constants.dart';

/// Demo screen to showcase the new API endpoints
class NewEndpointsDemoScreen extends StatelessWidget {
  const NewEndpointsDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New API Endpoints Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Search & Analytics Features',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'This demo showcases two new API endpoints that have been implemented in the Flutter app:',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 24),

            // Properties by City Card
            _buildFeatureCard(
              context: context,
              title: 'Properties by City with Ratings',
              description:
                  'Search for properties in a specific city with comprehensive rating information, review statistics, and facility details.',
              endpoint: 'GET /api/properties/city/:cityName',
              features: [
                'Case-insensitive city search',
                'Comprehensive rating statistics',
                'Host information included',
                'Property facilities included',
                'Only active properties',
                'Sorted by rating and reviews',
              ],
              buttonText: 'Try City Search',
              buttonColor: AppColors.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CityPropertiesScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Bookings with Ratings Card
            _buildFeatureCard(
              context: context,
              title: 'Bookings Analytics by Date Range',
              description:
                  'Retrieve bookings within a date range with rating information, guest/host details, and comprehensive statistics.',
              endpoint: 'GET /api/bookings/date-range',
              features: [
                'Date range validation',
                'Bidirectional rating system',
                'Revenue calculation',
                'Detailed statistics',
                'Guest and host information',
                'Property rating and reviews',
              ],
              buttonText: 'Try Analytics',
              buttonColor: AppColors.secondary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingsWithRatingsScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

            // API Documentation Note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        'API Documentation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For complete API documentation including request/response examples, error handling, and testing instructions, see:',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'lib/components/property/API_ENDPOINTS_GUIDE.md',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    required String endpoint,
    required List<String> features,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                endpoint,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Text(
              'Features:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
