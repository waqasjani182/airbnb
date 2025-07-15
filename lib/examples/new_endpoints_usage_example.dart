// Example usage of the new API endpoints
// This file demonstrates how to use the new city properties and bookings with ratings endpoints

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/city_properties_provider.dart';
import '../providers/bookings_with_ratings_provider.dart';
import '../models/city_properties_response.dart';
import '../models/bookings_with_ratings_response.dart';

/// Example 1: Using City Properties Provider
class CityPropertiesExample extends ConsumerWidget {
  const CityPropertiesExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the city properties state
    final cityPropertiesState = ref.watch(cityPropertiesProvider);
    final isLoading = ref.watch(cityPropertiesLoadingProvider);
    final properties = ref.watch(cityPropertiesListProvider);
    final errorMessage = ref.watch(cityPropertiesErrorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('City Properties Example')),
      body: Column(
        children: [
          // Search button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Search for properties in Mumbai
                ref.read(cityPropertiesProvider.notifier).getPropertiesByCity('Mumbai');
              },
              child: const Text('Search Properties in Mumbai'),
            ),
          ),

          // Display results
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text('Error: $errorMessage'))
                    : ListView.builder(
                        itemCount: properties.length,
                        itemBuilder: (context, index) {
                          final property = properties[index];
                          return ListTile(
                            title: Text(property.title),
                            subtitle: Text('Rs ${property.rentPerDay}/day'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                Text(property.totalRating.toStringAsFixed(1)),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// Example 2: Using Bookings with Ratings Provider
class BookingsAnalyticsExample extends ConsumerWidget {
  const BookingsAnalyticsExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the bookings state
    final isLoading = ref.watch(bookingsWithRatingsLoadingProvider);
    final bookings = ref.watch(bookingsWithRatingsListProvider);
    final statistics = ref.watch(bookingsStatisticsProvider);
    final errorMessage = ref.watch(bookingsWithRatingsErrorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookings Analytics Example')),
      body: Column(
        children: [
          // Search button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Get bookings for 2024
                ref.read(bookingsWithRatingsProvider.notifier).getBookingsWithRatingsByDateRange(
                  fromDate: '2024-01-01',
                  toDate: '2024-12-31',
                );
              },
              child: const Text('Get 2024 Bookings Analytics'),
            ),
          ),

          // Display statistics
          if (statistics != null)
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Text('Total Bookings: ${statistics.totalBookings}'),
                  Text('Total Revenue: Rs ${statistics.totalRevenue}'),
                  Text('Average Property Rating: ${statistics.averagePropertyRating}'),
                ],
              ),
            ),

          // Display bookings
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text('Error: $errorMessage'))
                    : ListView.builder(
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return ListTile(
                            title: Text(booking.propertyTitle),
                            subtitle: Text('${booking.guestName} - ${booking.status}'),
                            trailing: Text('Rs ${booking.totalAmount.toStringAsFixed(0)}'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// Example 3: Direct Service Usage (without providers)
class DirectServiceUsageExample {
  /// Example of using PropertyService directly
  static Future<void> exampleCityPropertiesUsage() async {
    try {
      // Import the service
      // import '../services/property_service.dart';
      
      // Create service instance
      // final propertyService = PropertyService();
      
      // Get properties by city
      // final response = await propertyService.getPropertiesByCity('Mumbai');
      
      // Access the data
      // print('City: ${response.city}');
      // print('Total properties: ${response.totalCount}');
      // print('Average city rating: ${response.averageCityRating}');
      
      // for (final property in response.properties) {
      //   print('Property: ${property.title}');
      //   print('Rating: ${property.totalRating}');
      //   print('Reviews: ${property.reviewCount}');
      //   print('Host: ${property.hostName}');
      //   print('Facilities: ${property.facilities.map((f) => f.facilityType).join(', ')}');
      //   print('---');
      // }
      
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Example of using BookingService directly
  static Future<void> exampleBookingsAnalyticsUsage() async {
    try {
      // Import the service
      // import '../services/booking_service.dart';
      
      // Create service instance
      // final bookingService = BookingService();
      
      // Get bookings with ratings by date range
      // final response = await bookingService.getBookingsWithRatingsByDateRange(
      //   fromDate: '2024-01-01',
      //   toDate: '2024-12-31',
      // );
      
      // Access the data
      // print('Date range: ${response.dateRange.fromDate} to ${response.dateRange.toDate}');
      // print('Total bookings: ${response.totalCount}');
      
      // final stats = response.statistics;
      // print('Statistics:');
      // print('- Total bookings: ${stats.totalBookings}');
      // print('- Bookings with ratings: ${stats.bookingsWithRatings}');
      // print('- Average property rating: ${stats.averagePropertyRating}');
      // print('- Average user rating: ${stats.averageUserRating}');
      // print('- Average owner rating: ${stats.averageOwnerRating}');
      // print('- Total revenue: Rs ${stats.totalRevenue}');
      
      // for (final booking in response.bookings) {
      //   print('Booking #${booking.bookingId}:');
      //   print('- Property: ${booking.propertyTitle}');
      //   print('- Guest: ${booking.guestName}');
      //   print('- Host: ${booking.hostName}');
      //   print('- Status: ${booking.status}');
      //   print('- Amount: Rs ${booking.totalAmount}');
      //   
      //   if (booking.propertyRating != null) {
      //     print('- Property rating: ${booking.propertyRating}');
      //   }
      //   if (booking.userRating != null) {
      //     print('- User rating: ${booking.userRating}');
      //   }
      //   if (booking.ownerRating != null) {
      //     print('- Owner rating: ${booking.ownerRating}');
      //   }
      //   print('---');
      // }
      
    } catch (e) {
      print('Error: $e');
    }
  }
}

/// Example 4: Error Handling
class ErrorHandlingExample extends ConsumerWidget {
  const ErrorHandlingExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Handling Example')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                // This will trigger an error for invalid city
                await ref.read(cityPropertiesProvider.notifier).getPropertiesByCity('');
              } catch (e) {
                // Error is handled by the provider and stored in state
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Test Empty City Error'),
          ),
          
          ElevatedButton(
            onPressed: () async {
              try {
                // This will trigger a date validation error
                await ref.read(bookingsWithRatingsProvider.notifier).getBookingsWithRatingsByDateRange(
                  fromDate: 'invalid-date',
                  toDate: '2024-12-31',
                );
              } catch (e) {
                // Error is handled by the provider and stored in state
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Test Invalid Date Error'),
          ),
          
          // Display current error states
          Consumer(
            builder: (context, ref, child) {
              final cityError = ref.watch(cityPropertiesErrorProvider);
              final bookingsError = ref.watch(bookingsWithRatingsErrorProvider);
              
              return Column(
                children: [
                  if (cityError != null)
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.red[100],
                      child: Text('City Properties Error: $cityError'),
                    ),
                  if (bookingsError != null)
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.red[100],
                      child: Text('Bookings Error: $bookingsError'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
