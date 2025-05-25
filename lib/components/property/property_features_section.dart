import 'package:flutter/material.dart';
import '../../models/property2.dart';
import '../../utils/constants.dart';

class PropertyFeaturesSection extends StatelessWidget {
  final Property2 property;

  const PropertyFeaturesSection({
    super.key,
    required this.property,
  });

  IconData _getFacilityIcon(String facilityType) {
    switch (facilityType.toLowerCase()) {
      case 'wifi':
      case 'wi-fi':
        return Icons.wifi;
      case 'pool':
      case 'swimming pool':
        return Icons.pool;
      case 'parking':
        return Icons.local_parking;
      case 'gym':
      case 'fitness':
        return Icons.fitness_center;
      case 'kitchen':
        return Icons.kitchen;
      case 'air conditioning':
      case 'ac':
        return Icons.ac_unit;
      case 'heating':
        return Icons.local_fire_department;
      case 'tv':
      case 'television':
        return Icons.tv;
      case 'balcony':
        return Icons.balcony;
      case 'garden':
        return Icons.grass;
      case 'laundry':
        return Icons.local_laundry_service;
      case 'elevator':
        return Icons.elevator;
      case 'security':
        return Icons.security;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (property.facilities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Facilities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: property.facilities.map((facility) {
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFacilityIcon(facility.facilityType),
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    facility.facilityType,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
