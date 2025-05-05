import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airbnb/models/amenity.dart';
import 'package:airbnb/providers/amenity_provider.dart';
import 'package:airbnb/services/amenity_service.dart';

// Import the when function from mockito
export 'package:mockito/mockito.dart' show when;

@GenerateMocks([AmenityService])
import 'amenity_provider_test.mocks.dart';

void main() {
  late MockAmenityService mockAmenityService;
  late AmenityNotifier amenityNotifier;
  late ProviderContainer container;

  setUp(() {
    mockAmenityService = MockAmenityService();
    amenityNotifier = AmenityNotifier(mockAmenityService, 'test-token');

    container = ProviderContainer(
      overrides: [
        amenityProvider.overrideWith((ref) => amenityNotifier),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AmenityNotifier', () {
    test('initial state is correct', () {
      expect(amenityNotifier.state.status, AmenityStatus.initial);
      expect(amenityNotifier.state.amenities, isEmpty);
      expect(amenityNotifier.state.selectedAmenity, isNull);
      expect(amenityNotifier.state.errorMessage, isNull);
      expect(amenityNotifier.state.isLoading, isFalse);
    });

    test('fetchAmenities updates state correctly on success', () async {
      // Arrange
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

      when(mockAmenityService.getAllAmenities('test-token'))
          .thenAnswer((_) async => amenities);

      // Act
      await amenityNotifier.fetchAmenities();

      // Assert
      expect(amenityNotifier.state.status, AmenityStatus.success);
      expect(amenityNotifier.state.amenities, amenities);
      expect(amenityNotifier.state.isLoading, isFalse);
    });

    test('fetchAmenities updates state correctly on error', () async {
      // Arrange
      when(mockAmenityService.getAllAmenities('test-token'))
          .thenThrow(Exception('Failed to load amenities'));

      // Act
      await amenityNotifier.fetchAmenities();

      // Assert
      expect(amenityNotifier.state.status, AmenityStatus.error);
      expect(amenityNotifier.state.errorMessage,
          contains('Failed to load amenities'));
      expect(amenityNotifier.state.isLoading, isFalse);
    });

    test('fetchAmenityById updates state correctly on success', () async {
      // Arrange
      final amenity = PropertyAmenity(
        id: 1,
        name: 'WiFi',
        icon: 'wifi',
        createdAt: '2023-01-01T00:00:00.000Z',
        propertyId: 0,
      );

      when(mockAmenityService.getAmenityById('1', 'test-token'))
          .thenAnswer((_) async => amenity);

      // Act
      await amenityNotifier.fetchAmenityById('1');

      // Assert
      expect(amenityNotifier.state.selectedAmenity, amenity);
      expect(amenityNotifier.state.isLoading, isFalse);
    });

    test('fetchAmenityById updates state correctly on error', () async {
      // Arrange
      when(mockAmenityService.getAmenityById('1', 'test-token'))
          .thenThrow(Exception('Failed to load amenity'));

      // Act
      await amenityNotifier.fetchAmenityById('1');

      // Assert
      expect(amenityNotifier.state.errorMessage,
          contains('Failed to load amenity'));
      expect(amenityNotifier.state.isLoading, isFalse);
    });
  });
}
