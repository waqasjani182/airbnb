import 'package:flutter/material.dart';
import '../../models/property2.dart';
import '../../utils/constants.dart';

class PropertyInfoSection extends StatelessWidget {
  final Property2 property;

  const PropertyInfoSection({
    super.key,
    required this.property,
  });

  Widget _buildFeature(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property title and price
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                property.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${property.rentPerDay.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '/ night',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Location
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: AppColors.textLight,
            ),
            const SizedBox(width: 4),
            Text(
              '${property.city}, ${property.address}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Property features
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFeature(Icons.person,
                '${property.guest} ${property.guest > 1 ? 'guests' : 'guest'}'),
            _buildFeature(Icons.category, property.propertyType),
            if (property.totalBedrooms != null)
              _buildFeature(Icons.king_bed,
                  '${property.totalBedrooms} ${property.totalBedrooms! > 1 ? 'bedrooms' : 'bedroom'}'),
            if (property.totalRooms != null)
              _buildFeature(Icons.room,
                  '${property.totalRooms} ${property.totalRooms! > 1 ? 'rooms' : 'room'}'),
            if (property.totalBeds != null)
              _buildFeature(Icons.bed,
                  '${property.totalBeds} ${property.totalBeds! > 1 ? 'beds' : 'bed'}'),
          ],
        ),

        const SizedBox(height: 16),

        // Host and Rating Information
        Row(
          children: [
            const Icon(
              Icons.person_outline,
              size: 20,
              color: AppColors.textLight,
            ),
            const SizedBox(width: 8),
            Text(
              'Hosted by ${property.hostName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (property.avgRating > 0) ...[
              const Icon(
                Icons.star,
                size: 20,
                color: Colors.amber,
              ),
              const SizedBox(width: 4),
              Text(
                '${property.avgRating.toStringAsFixed(1)} (${property.reviewCount} ${property.reviewCount == 1 ? 'review' : 'reviews'})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 16),

        // Description
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          property.description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
