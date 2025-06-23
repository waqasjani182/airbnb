import '../models/property.dart';
import '../models/property2.dart';
import '../models/property_image.dart';
import '../models/property_image2.dart';
import '../models/property_amenity.dart';
import '../models/facility.dart';

/// Utility class to convert between Property and Property2 models
class PropertyConverter {
  /// Convert a Property2 to a Property
  static Property toProperty(Property2 property2) {
    // Convert PropertyImage2 to PropertyImage
    List<PropertyImage> images = property2.images.map((image2) {
      return PropertyImage(
        id: image2.pictureId,
        propertyId: image2.propertyId,
        imageUrl: image2.imageUrl,
        isPrimary:
            property2.images.indexOf(image2) == 0, // First image is primary
        createdAt: DateTime.now().toIso8601String(),
      );
    }).toList();

    // Convert Facility to PropertyAmenity
    List<PropertyAmenity> amenities = property2.facilities.map((facility) {
      return PropertyAmenity(
        id: facility.facilityId,
        name: facility.facilityType,
        icon:
            'default_icon', // Default icon as it's not provided in the new API
        createdAt: DateTime.now().toIso8601String(),
        propertyId: facility.propertyId ??
            property2
                .propertyId, // Use property ID if facility's property ID is null
      );
    }).toList();

    // Extract first and last name from host_name
    List<String> nameParts = property2.hostName?.split(' ') ?? [];
    String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    String lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return Property(
      id: property2.propertyId,
      hostId: property2.userId,
      title: property2.title,
      description: property2.description,
      address: property2.address,
      city: property2.city,
      state: '', // Not provided in the new API
      country: '', // Not provided in the new API
      zipCode: '', // Not provided in the new API
      latitude: property2.latitude,
      longitude: property2.longitude,
      pricePerNight: property2.rentPerDay,
      bedrooms: 0, // Not provided in the new API
      bathrooms: 0, // Not provided in the new API
      maxGuests: property2.guest,
      propertyType: property2.propertyType,
      createdAt:
          DateTime.now().toIso8601String(), // Not provided in the new API
      updatedAt:
          DateTime.now().toIso8601String(), // Not provided in the new API
      hostFirstName: firstName,
      hostLastName: lastName,
      primaryImage: property2.primaryImage,
      avgRating: property2.avgRating,
      reviewCount: property2.reviewCount,
      images: images,
      amenities: amenities,
      reviews: property2.reviews,
      isAvailable: true, // Default value as it's not provided in the new API
      isFavorite: false, // Default value as it's not provided in the new API
    );
  }

  /// Convert a Property to a Property2
  static Property2 toProperty2(Property property) {
    // Convert PropertyImage to PropertyImage2
    List<PropertyImage2> images = property.images.map((image) {
      return PropertyImage2(
        pictureId: image.id,
        propertyId: image.propertyId,
        imageUrl: image.imageUrl,
      );
    }).toList();

    // Convert PropertyAmenity to Facility
    List<Facility> facilities = property.amenities.map((amenity) {
      return Facility(
        facilityId: amenity.id,
        facilityType: amenity.name,
        propertyId: amenity.propertyId,
      );
    }).toList();

    // Combine first and last name for host_name
    String hostName =
        '${property.hostFirstName} ${property.hostLastName}'.trim();

    return Property2(
      propertyId: property.id,
      userId: property.hostId,
      propertyType: property.propertyType,
      rentPerDay: property.pricePerNight,
      address: property.address,
      rating: property.avgRating,
      city: property.city,
      longitude: property.longitude,
      latitude: property.latitude,
      title: property.title,
      description: property.description,
      guest: property.maxGuests,
      hostName: hostName,
      images: images,
      facilities: facilities,
      reviews: property.reviews,
      avgRating: property.avgRating,
      reviewCount: property.reviewCount,
    );
  }

  /// Convert a list of Property2 to a list of Property
  static List<Property> toProperties(List<Property2> properties2) {
    return properties2.map((property2) => toProperty(property2)).toList();
  }

  /// Convert a list of Property to a list of Property2
  static List<Property2> toProperties2(List<Property> properties) {
    return properties.map((property) => toProperty2(property)).toList();
  }
}
