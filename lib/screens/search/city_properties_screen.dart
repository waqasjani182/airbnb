import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/city_properties_provider.dart';
import '../../models/city_properties_response.dart';
import '../../utils/constants.dart';

class CityPropertiesScreen extends ConsumerStatefulWidget {
  final String? initialCity;

  const CityPropertiesScreen({
    Key? key,
    this.initialCity,
  }) : super(key: key);

  @override
  ConsumerState<CityPropertiesScreen> createState() =>
      _CityPropertiesScreenState();
}

class _CityPropertiesScreenState extends ConsumerState<CityPropertiesScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCity != null) {
      _cityController.text = widget.initialCity!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchProperties();
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _searchProperties() {
    final city = _cityController.text.trim();
    if (city.isNotEmpty) {
      ref.read(cityPropertiesProvider.notifier).getPropertiesByCity(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(cityPropertiesLoadingProvider);
    final errorMessage = ref.watch(cityPropertiesErrorProvider);
    final properties = ref.watch(cityPropertiesListProvider);
    final currentCity = ref.watch(currentCityProvider);
    final averageRating = ref.watch(averageCityRatingProvider);
    final totalCount = ref.watch(cityPropertiesCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties by City'),
      ),
      body: Column(
        children: [
          // Search section
          Container(
            padding: const EdgeInsets.all(AppSpacing.medium),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Enter City Name',
                    hintText: 'e.g., Mumbai, Delhi, Bangalore',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.medium),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchProperties,
                    ),
                  ),
                  onSubmitted: (_) => _searchProperties(),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _searchProperties,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.medium),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Search Properties'),
                  ),
                ),
              ],
            ),
          ),

          // Results section
          Expanded(
            child: _buildResultsSection(
              isLoading: isLoading,
              errorMessage: errorMessage,
              properties: properties,
              currentCity: currentCity,
              averageRating: averageRating,
              totalCount: totalCount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection({
    required bool isLoading,
    required String? errorMessage,
    required List<CityProperty> properties,
    required String? currentCity,
    required String? averageRating,
    required int totalCount,
  }) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading properties...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(cityPropertiesProvider.notifier).clearData();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (currentCity == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Search for Properties',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a city name to find properties with ratings',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Properties Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'No properties found in $currentCity',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // City summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.medium),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentCity!,
                style: AppTextStyles.heading3.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('$totalCount properties'),
                  if (averageRating != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.star, color: Colors.amber[600], size: 16),
                    const SizedBox(width: 4),
                    Text('Avg: $averageRating'),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Properties list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.medium),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return _buildPropertyCard(property);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(CityProperty property) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Theme.of(context).colorScheme.surface,
                    child: property.propertyImage != null
                        ? Image.network(
                            property.propertyImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.home,
                                size: 40,
                                color: Colors.grey[600],
                              );
                            },
                          )
                        : Icon(
                            Icons.home,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Property details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        property.address,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        property.propertyType,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Price and ratings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rs ${property.rentPerDay.toStringAsFixed(0)}/day',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                        '${property.totalRating.toStringAsFixed(1)} (${property.reviewCount})'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Host info and guest capacity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Host: ${property.hostName}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  '${property.guest} guests',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),

            // Facilities (if any)
            if (property.facilities.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: property.facilities.take(3).map((facility) {
                  return Chip(
                    label: Text(
                      facility.facilityType,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
