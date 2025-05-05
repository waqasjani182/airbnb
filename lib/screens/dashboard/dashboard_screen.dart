import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/property/property_card.dart';
import '../../providers/property_provider.dart';
import '../../utils/constants.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.apartment, 'label': 'Apartments', 'type': 'apartment'},
    {'icon': Icons.house, 'label': 'Houses', 'type': 'house'},
    {'icon': Icons.villa, 'label': 'Villas', 'type': 'villa'},
    {'icon': Icons.cabin, 'label': 'Cabins', 'type': 'cabin'},
    {'icon': Icons.hotel, 'label': 'Hotels', 'type': 'hotel'},
    {'icon': Icons.beach_access, 'label': 'Beach', 'type': null},
    {'icon': Icons.landscape, 'label': 'Mountains', 'type': null},
    {'icon': Icons.pool, 'label': 'Pools', 'type': null},
  ];

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Fetch properties when the dashboard loads
    Future.microtask(
        () => ref.read(propertyProvider.notifier).fetchProperties());
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyProvider);

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
              ref.read(propertyProvider.notifier).fetchProperties();
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PropertyCard(
                              property: property,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '${AppRoutes.propertyDetails}/${property.id}',
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
            ref.read(propertyProvider.notifier).fetchProperties();
          } else {
            _selectedCategory = label;
            // Filter properties by type if available
            if (type != null) {
              ref.read(propertyProvider.notifier).searchProperties(
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
