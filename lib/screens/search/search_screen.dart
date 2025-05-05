import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/common/app_button.dart';
import '../../components/property/property_card.dart';
import '../../providers/property_provider.dart';
import '../../utils/constants.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  String? _selectedPropertyType;
  int _page = 1;
  // int _limit = 10;
  bool _isFilterVisible = false;
  bool _isSearching = false;

  final List<String> _propertyTypes = [
    'Apartment',
    'House',
    'Villa',
    'Cabin',
    'Hotel',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _bedroomsController.dispose();
    super.dispose();
  }

  void _toggleFilterVisibility() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });
  }

  Future<void> _search() async {
    setState(() {
      _isSearching = true;
    });

    try {
      await ref.read(propertyProvider.notifier).searchProperties(
            _searchController.text,
            location: _locationController.text.isNotEmpty
                ? _locationController.text
                : null,
            city: _cityController.text.isNotEmpty ? _cityController.text : null,
            minPrice: _minPriceController.text.isNotEmpty
                ? double.parse(_minPriceController.text)
                : null,
            maxPrice: _maxPriceController.text.isNotEmpty
                ? double.parse(_maxPriceController.text)
                : null,
            bedrooms: _bedroomsController.text.isNotEmpty
                ? int.parse(_bedroomsController.text)
                : null,
            propertyType: _selectedPropertyType,
            page: _page,
            // limit: _limit,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _locationController.clear();
      _cityController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _bedroomsController.clear();
      _selectedPropertyType = null;
      _page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          IconButton(
            icon: Icon(
              _isFilterVisible ? Icons.filter_list_off : Icons.filter_list,
              color: AppColors.primary,
            ),
            onPressed: _toggleFilterVisibility,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search properties...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppBorderRadius.medium),
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  text: 'Search',
                  onPressed: _search,
                  isLoading: _isSearching,
                ),
              ],
            ),
          ),

          // Filters
          AnimatedContainer(
            duration: AppDurations.medium,
            height: _isFilterVisible ? 350 : 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location filter
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Location',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.medium),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // City filter
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'City',
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.medium),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price range
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minPriceController,
                            decoration: InputDecoration(
                              hintText: 'Min Price',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppBorderRadius.medium),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _maxPriceController,
                            decoration: InputDecoration(
                              hintText: 'Max Price',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppBorderRadius.medium),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Bedrooms and Property Type
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _bedroomsController,
                            decoration: InputDecoration(
                              hintText: 'Bedrooms',
                              prefixIcon: const Icon(Icons.bed),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppBorderRadius.medium),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedPropertyType,
                            decoration: InputDecoration(
                              hintText: 'Property Type',
                              prefixIcon: const Icon(Icons.house),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppBorderRadius.medium),
                              ),
                            ),
                            items: _propertyTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPropertyType = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Filter actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear'),
                        ),
                        const SizedBox(width: 8),
                        AppButton(
                          text: 'Apply',
                          onPressed: _search,
                          isLoading: _isSearching,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Results
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
}
