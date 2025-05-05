import 'package:flutter_test/flutter_test.dart';
import 'package:airbnb/models/property_amenity.dart';

void main() {
  group('PropertyAmenity', () {
    test('fromJson correctly parses API response without property_id', () {
      // Test data based on the actual API response format
      final json = {
        'id': 2,
        'name': 'Air Conditioning',
        'icon': 'ac',
        'created_at': '2025-05-03T16:22:22.807Z',
        // property_id is completely missing in the API response
      };

      // Create a PropertyAmenity from the JSON
      final amenity = PropertyAmenity.fromJson(json);

      // Verify the parsing is correct
      expect(amenity.id, 2);
      expect(amenity.name, 'Air Conditioning');
      expect(amenity.icon, 'ac');
      expect(amenity.createdAt, '2025-05-03T16:22:22.807Z');
      expect(amenity.propertyId, 0); // Should default to 0
    });

    test('fromJson correctly parses response with property_id', () {
      // Test data with property_id included
      final json = {
        'id': 1,
        'name': 'WiFi',
        'icon': 'wifi',
        'created_at': '2025-05-03T16:22:22.807Z',
        'property_id': 123, // property_id is included
      };

      // Create a PropertyAmenity from the JSON
      final amenity = PropertyAmenity.fromJson(json);

      // Verify the parsing is correct
      expect(amenity.id, 1);
      expect(amenity.name, 'WiFi');
      expect(amenity.icon, 'wifi');
      expect(amenity.createdAt, '2025-05-03T16:22:22.807Z');
      expect(amenity.propertyId, 123); // Should use the provided value
    });
  });
}
