import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/property/property_card2.dart';
import '../../providers/property_provider2.dart';
import '../../utils/constants.dart';
import '../../utils/property_converter.dart';

class DashboardScreen2 extends ConsumerStatefulWidget {
  const DashboardScreen2({super.key});

  @override
  ConsumerState<DashboardScreen2> createState() => _DashboardScreen2State();
}

class _DashboardScreen2State extends ConsumerState<DashboardScreen2> {
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.apartment, 'label': 'Apartments', 'type': 'Apartment'},
    {'icon': Icons.house, 'label': 'Houses', 'type': 'House'},
    {'icon': Icons.room_service, 'label': 'Rooms', 'type': 'Room'},
  ];

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Fetch properties when the dashboard loads
    Future.microtask(
        () => ref.read(propertyProvider2.notifier).fetchProperties());
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyProvider2);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.uploadProperty);
        },
        backgroundColor: AppColors.primary,
        tooltip: 'Upload New Property',
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: const AssetImage(AppAssets.logo),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.search),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(AppBorderRadius.large),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Where to? Anywhere. Any Time.",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              ref.read(propertyProvider2.notifier).fetchProperties();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryItem(
                  _categories[index]['icon'],
                  _categories[index]['label'],
                  type: _categories[index]['type'],
                );
              },
            ),
          ),

          // Quick access to new features
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.cityProperties);
                    },
                    icon: const Icon(Icons.location_city, size: 16),
                    label: const Text('City Search'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.bookingsAnalytics);
                    },
                    icon: const Icon(Icons.analytics, size: 16),
                    label: const Text('Analytics'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.newEndpointsDemo);
                    },
                    icon: const Icon(Icons.new_releases, size: 16),
                    label: const Text('Demo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Properties
          Expanded(
            child: propertyState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : propertyState.properties.isEmpty
                    ? const Center(child: Text('No properties found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: propertyState.properties.length,
                        itemBuilder: (context, index) {
                          final property = propertyState.properties[index];
                          // Convert Property2 to Property for backward compatibility
                          // final oldProperty = PropertyConverter.toProperty(property);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PropertyCard2(
                              property: property,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '${AppRoutes.propertyDetails}/${property.propertyId}',
                                );
                              },
                              onFavoriteToggle: () {
                                // TODO: Implement favorite toggle
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, {String? type}) {
    final isSelected = _selectedCategory == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedCategory == label) {
            // If already selected, clear the filter
            _selectedCategory = null;
            ref.read(propertyProvider2.notifier).fetchProperties();
          } else {
            _selectedCategory = label;
            // Filter properties by type if available
            if (type != null) {
              ref.read(propertyProvider2.notifier).searchProperties(
                    '',
                    propertyType: type,
                  );
            }
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(50)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(AppBorderRadius.circular),
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Icon(icon,
                  color: isSelected ? AppColors.primary : Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
