import 'package:flutter_test/flutter_test.dart';
import 'package:airbnb/models/amenity.dart';
import 'package:airbnb/providers/amenity_provider.dart';

void main() {
  group('AmenityState', () {
    test('initial state is correct', () {
      final state = AmenityState();
      expect(state.status, AmenityStatus.initial);
      expect(state.amenities, isEmpty);
      expect(state.selectedAmenity, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, isFalse);
    });

    test('copyWith correctly updates state', () {
      final initialState = AmenityState();
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
      final selectedAmenity = Amenity(
        id: 1,
        name: 'WiFi',
        icon: 'wifi',
        createdAt: '2023-01-01T00:00:00.000Z',
      );

      final updatedState = initialState.copyWith(
        status: AmenityStatus.success,
        amenities: amenities,
        selectedAmenity: selectedAmenity,
        errorMessage: 'Test error',
        isLoading: true,
      );

      expect(updatedState.status, AmenityStatus.success);
      expect(updatedState.amenities, amenities);
      expect(updatedState.selectedAmenity, selectedAmenity);
      expect(updatedState.errorMessage, 'Test error');
      expect(updatedState.isLoading, true);
    });
  });
}
