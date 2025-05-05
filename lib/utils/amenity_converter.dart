import '../models/amenity.dart';
import '../models/property_amenity.dart';

/// Utility class to convert between Amenity and PropertyAmenity models
class AmenityConverter {
  /// Convert an Amenity to a PropertyAmenity
  static PropertyAmenity toPropertyAmenity(Amenity amenity, {int propertyId = 0}) {
    return PropertyAmenity(
      id: amenity.id,
      name: amenity.name,
      icon: amenity.icon,
      createdAt: amenity.createdAt,
      propertyId: propertyId,
    );
  }

  /// Convert a PropertyAmenity to an Amenity
  static Amenity toAmenity(PropertyAmenity propertyAmenity) {
    return Amenity(
      id: propertyAmenity.id,
      name: propertyAmenity.name,
      icon: propertyAmenity.icon,
      createdAt: propertyAmenity.createdAt,
    );
  }

  /// Convert a list of Amenities to a list of PropertyAmenities
  static List<PropertyAmenity> toPropertyAmenities(List<Amenity> amenities, {int propertyId = 0}) {
    return amenities.map((amenity) => toPropertyAmenity(amenity, propertyId: propertyId)).toList();
  }

  /// Convert a list of PropertyAmenities to a list of Amenities
  static List<Amenity> toAmenities(List<PropertyAmenity> propertyAmenities) {
    return propertyAmenities.map((propertyAmenity) => toAmenity(propertyAmenity)).toList();
  }
}
