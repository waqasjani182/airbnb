import 'package:flutter_test/flutter_test.dart';
import 'package:airbnb/models/amenity.dart';

void main() {
  group('Amenity', () {
    test('fromJson correctly parses API response', () {
      // Test data based on the actual API response format
      final json = {
        'id': 2,
        'name': 'Air Conditioning',
        'icon': 'ac',
        'created_at': '2025-05-03T16:22:22.807Z',
      };

      // Create an Amenity from the JSON
      final amenity = Amenity.fromJson(json);

      // Verify the parsing is correct
      expect(amenity.id, 2);
      expect(amenity.name, 'Air Conditioning');
      expect(amenity.icon, 'ac');
      expect(amenity.createdAt, '2025-05-03T16:22:22.807Z');
    });

    test('toJson correctly converts Amenity to JSON', () {
      // Create an Amenity
      final amenity = Amenity(
        id: 7,
        name: 'Dryer',
        icon: 'dryer',
        createdAt: '2025-05-03T16:22:22.807Z',
      );

      // Convert to JSON
      final json = amenity.toJson();

      // Verify the conversion is correct
      expect(json['id'], 7);
      expect(json['name'], 'Dryer');
      expect(json['icon'], 'dryer');
      expect(json['created_at'], '2025-05-03T16:22:22.807Z');
    });

    test('copyWith correctly creates a new instance with updated values', () {
      // Create an Amenity
      final amenity = Amenity(
        id: 8,
        name: 'Free Parking',
        icon: 'parking',
        createdAt: '2025-05-03T16:22:22.807Z',
      );

      // Create a copy with updated values
      final updatedAmenity = amenity.copyWith(
        name: 'Paid Parking',
        icon: 'paid-parking',
      );

      // Verify the original is unchanged
      expect(amenity.id, 8);
      expect(amenity.name, 'Free Parking');
      expect(amenity.icon, 'parking');
      expect(amenity.createdAt, '2025-05-03T16:22:22.807Z');

      // Verify the copy has the updated values
      expect(updatedAmenity.id, 8); // Unchanged
      expect(updatedAmenity.name, 'Paid Parking'); // Updated
      expect(updatedAmenity.icon, 'paid-parking'); // Updated
      expect(updatedAmenity.createdAt, '2025-05-03T16:22:22.807Z'); // Unchanged
    });

    test('equality works correctly', () {
      final amenity1 = Amenity(
        id: 11,
        name: 'Gym',
        icon: 'gym',
        createdAt: '2025-05-03T16:22:22.807Z',
      );

      final amenity2 = Amenity(
        id: 11,
        name: 'Gym',
        icon: 'gym',
        createdAt: '2025-05-03T16:22:22.807Z',
      );

      final amenity3 = Amenity(
        id: 10,
        name: 'Hot Tub',
        icon: 'hot-tub',
        createdAt: '2025-05-03T16:22:22.807Z',
      );

      // Same values should be equal
      expect(amenity1, amenity2);
      expect(amenity1.hashCode, amenity2.hashCode);

      // Different values should not be equal
      expect(amenity1, isNot(amenity3));
      expect(amenity1.hashCode, isNot(amenity3.hashCode));
    });
  });
}
