import 'package:flutter_test/flutter_test.dart';
import 'package:airbnb/models/property2.dart';
import 'package:airbnb/models/property_image2.dart';
import 'package:airbnb/models/facility.dart';
import 'package:airbnb/models/property_response.dart';

void main() {
  group('Property2', () {
    test('fromJson correctly parses API response', () {
      // Test data based on the actual API response format
      final json = {
        'property_id': 1,
        'user_id': 1,
        'property_type': 'House',
        'rent_per_day': 150,
        'address': '123 Beach Rd',
        'rating': 4.5,
        'city': 'Miami',
        'longitude': -80.191788,
        'latitude': 25.761681,
        'title': 'Beach House',
        'description': 'Beautiful house near the beach',
        'guest': 4,
        'host_name': 'John Doe',
        'images': [
          {
            'picture_id': 1,
            'property_id': 1,
            'image_url': 'images/property1_1.jpg'
          },
          {
            'picture_id': 2,
            'property_id': 1,
            'image_url': 'images/property1_2.jpg'
          }
        ],
        'facilities': [
          {
            'facility_id': 1,
            'facility_type': 'WiFi',
            'property_id': 1
          },
          {
            'facility_id': 2,
            'facility_type': 'Pool',
            'property_id': 1
          }
        ],
        'reviews': [],
        'avg_rating': 4.5,
        'review_count': 0
      };

      // Create a Property2 from the JSON
      final property = Property2.fromJson(json);

      // Verify the parsing is correct
      expect(property.propertyId, 1);
      expect(property.userId, 1);
      expect(property.propertyType, 'House');
      expect(property.rentPerDay, 150);
      expect(property.address, '123 Beach Rd');
      expect(property.rating, 4.5);
      expect(property.city, 'Miami');
      expect(property.longitude, -80.191788);
      expect(property.latitude, 25.761681);
      expect(property.title, 'Beach House');
      expect(property.description, 'Beautiful house near the beach');
      expect(property.guest, 4);
      expect(property.hostName, 'John Doe');
      
      // Check images
      expect(property.images.length, 2);
      expect(property.images[0].pictureId, 1);
      expect(property.images[0].propertyId, 1);
      expect(property.images[0].imageUrl, 'images/property1_1.jpg');
      
      // Check facilities
      expect(property.facilities.length, 2);
      expect(property.facilities[0].facilityId, 1);
      expect(property.facilities[0].facilityType, 'WiFi');
      expect(property.facilities[0].propertyId, 1);
      
      // Check reviews and ratings
      expect(property.reviews.length, 0);
      expect(property.avgRating, 4.5);
      expect(property.reviewCount, 0);
    });

    test('toJson correctly converts Property2 to JSON', () {
      // Create a Property2
      final property = Property2(
        propertyId: 2,
        userId: 2,
        propertyType: 'Apartment',
        rentPerDay: 100,
        address: '456 Downtown St',
        rating: 4.2,
        city: 'New York',
        longitude: -73.935242,
        latitude: 40.73061,
        title: 'City Apartment',
        description: 'Modern apartment in downtown',
        guest: 2,
        hostName: 'Jane Smith',
        images: [
          PropertyImage2(
            pictureId: 3,
            propertyId: 2,
            imageUrl: 'images/property2_1.jpg',
          ),
        ],
        facilities: [
          Facility(
            facilityId: 1,
            facilityType: 'WiFi',
            propertyId: 2,
          ),
          Facility(
            facilityId: 5,
            facilityType: 'Air Conditioning',
            propertyId: 2,
          ),
        ],
        avgRating: 4.2,
        reviewCount: 0,
      );

      // Convert to JSON
      final json = property.toJson();

      // Verify the conversion is correct
      expect(json['property_id'], 2);
      expect(json['user_id'], 2);
      expect(json['property_type'], 'Apartment');
      expect(json['rent_per_day'], 100);
      expect(json['address'], '456 Downtown St');
      expect(json['rating'], 4.2);
      expect(json['city'], 'New York');
      expect(json['longitude'], -73.935242);
      expect(json['latitude'], 40.73061);
      expect(json['title'], 'City Apartment');
      expect(json['description'], 'Modern apartment in downtown');
      expect(json['guest'], 2);
      expect(json['host_name'], 'Jane Smith');
      
      // Check images
      expect(json['images'].length, 1);
      expect(json['images'][0]['picture_id'], 3);
      expect(json['images'][0]['property_id'], 2);
      expect(json['images'][0]['image_url'], 'images/property2_1.jpg');
      
      // Check facilities
      expect(json['facilities'].length, 2);
      expect(json['facilities'][0]['facility_id'], 1);
      expect(json['facilities'][0]['facility_type'], 'WiFi');
      expect(json['facilities'][0]['property_id'], 2);
      
      // Check ratings
      expect(json['avg_rating'], 4.2);
      expect(json['review_count'], 0);
    });
  });

  group('PropertyResponse', () {
    test('fromJson correctly parses API response with pagination', () {
      // Test data based on the actual API response format
      final json = {
        'properties': [
          {
            'property_id': 1,
            'user_id': 1,
            'property_type': 'House',
            'rent_per_day': 150,
            'address': '123 Beach Rd',
            'rating': 4.5,
            'city': 'Miami',
            'longitude': -80.191788,
            'latitude': 25.761681,
            'title': 'Beach House',
            'description': 'Beautiful house near the beach',
            'guest': 4,
            'host_name': 'John Doe',
            'images': [],
            'facilities': [],
            'reviews': [],
            'avg_rating': 4.5,
            'review_count': 0
          }
        ],
        'pagination': {
          'total': 3,
          'page': 1,
          'limit': 10,
          'pages': 1
        }
      };

      // Create a PropertyResponse from the JSON
      final response = PropertyResponse.fromJson(json);

      // Verify the parsing is correct
      expect(response.properties.length, 1);
      expect(response.properties[0].propertyId, 1);
      expect(response.properties[0].title, 'Beach House');
      
      // Check pagination
      expect(response.total, 3);
      expect(response.page, 1);
      expect(response.limit, 10);
      expect(response.pages, 1);
    });
  });
}
