import 'package:flutter_test/flutter_test.dart';
import 'package:airbnb/models/amenity.dart';
import 'package:airbnb/models/property_amenity.dart';
import 'package:airbnb/utils/amenity_converter.dart';

void main() {
  group('AmenityConverter', () {
    test('toPropertyAmenity correctly converts Amenity to PropertyAmenity', () {
      // Create an Amenity
      final amenity = Amenity(
        id: 1,
        name: 'WiFi',
        icon: 'wifi',
        createdAt: '2023-01-01T00:00:00.000Z',
      );

      // Convert to PropertyAmenity
      final propertyAmenity = AmenityConverter.toPropertyAmenity(amenity);

      // Verify the conversion is correct
      expect(propertyAmenity.id, 1);
      expect(propertyAmenity.name, 'WiFi');
      expect(propertyAmenity.icon, 'wifi');
      expect(propertyAmenity.createdAt, '2023-01-01T00:00:00.000Z');
      expect(propertyAmenity.propertyId, 0); // Default value
    });

    test('toPropertyAmenity correctly sets propertyId', () {
      // Create an Amenity
      final amenity = Amenity(
        id: 1,
        name: 'WiFi',
        icon: 'wifi',
        createdAt: '2023-01-01T00:00:00.000Z',
      );

      // Convert to PropertyAmenity with a specific propertyId
      final propertyAmenity = AmenityConverter.toPropertyAmenity(amenity, propertyId: 123);

      // Verify the propertyId is set correctly
      expect(propertyAmenity.propertyId, 123);
    });

    test('toAmenity correctly converts PropertyAmenity to Amenity', () {
      // Create a PropertyAmenity
      final propertyAmenity = PropertyAmenity(
        id: 2,
        name: 'Pool',
        icon: 'pool',
        createdAt: '2023-01-01T00:00:00.000Z',
        propertyId: 123,
      );

      // Convert to Amenity
      final amenity = AmenityConverter.toAmenity(propertyAmenity);

      // Verify the conversion is correct
      expect(amenity.id, 2);
      expect(amenity.name, 'Pool');
      expect(amenity.icon, 'pool');
      expect(amenity.createdAt, '2023-01-01T00:00:00.000Z');
      // Note: propertyId is not included in the Amenity model
    });

    test('toPropertyAmenities correctly converts a list of Amenities', () {
      // Create a list of Amenities
      final amenities = [
        Amenity(
          id: 1,
          name: 'WiFi',
          icon: 'wifi',
          createdAt: '2023-01-01T00:00:00.000Z',
        ),
        Amenity(
          id: 2,
          name: 'Pool',
          icon: 'pool',
          createdAt: '2023-01-01T00:00:00.000Z',
        ),
      ];

      // Convert to a list of PropertyAmenities
      final propertyAmenities = AmenityConverter.toPropertyAmenities(amenities, propertyId: 123);

      // Verify the conversion is correct
      expect(propertyAmenities.length, 2);
      expect(propertyAmenities[0].id, 1);
      expect(propertyAmenities[0].name, 'WiFi');
      expect(propertyAmenities[0].propertyId, 123);
      expect(propertyAmenities[1].id, 2);
      expect(propertyAmenities[1].name, 'Pool');
      expect(propertyAmenities[1].propertyId, 123);
    });

    test('toAmenities correctly converts a list of PropertyAmenities', () {
      // Create a list of PropertyAmenities
      final propertyAmenities = [
        PropertyAmenity(
          id: 1,
          name: 'WiFi',
          icon: 'wifi',
          createdAt: '2023-01-01T00:00:00.000Z',
          propertyId: 123,
        ),
        PropertyAmenity(
          id: 2,
          name: 'Pool',
          icon: 'pool',
          createdAt: '2023-01-01T00:00:00.000Z',
          propertyId: 123,
        ),
      ];

      // Convert to a list of Amenities
      final amenities = AmenityConverter.toAmenities(propertyAmenities);

      // Verify the conversion is correct
      expect(amenities.length, 2);
      expect(amenities[0].id, 1);
      expect(amenities[0].name, 'WiFi');
      expect(amenities[1].id, 2);
      expect(amenities[1].name, 'Pool');
    });
  });
}
