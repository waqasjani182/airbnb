import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/common/app_button.dart';
import '../../components/property/property_card2.dart';
import '../../components/map/location_picker_map.dart';
import '../../providers/property_provider2.dart';
import '../../utils/constants.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _minRatingController = TextEditingController();
  final TextEditingController _maxRatingController = TextEditingController();
  String? _selectedPropertyType;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _page = 1;
  // int _limit = 10;
  bool _isFilterVisible = false;
  bool _isSearching = false;
  bool _isMapVisible = false;

  final List<String> _propertyTypes = [
    'Apartment',
    'House',
    'Rooms',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _cityController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _bedroomsController.dispose();
    _minRatingController.dispose();
    _maxRatingController.dispose();
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
      await ref.read(propertyProvider2.notifier).searchProperties(
            _searchController.text,
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
            minRating: _minRatingController.text.isNotEmpty
                ? double.parse(_minRatingController.text)
                : null,
            maxRating: _maxRatingController.text.isNotEmpty
                ? double.parse(_maxRatingController.text)
                : null,
            checkInDate: _checkInDate,
            checkOutDate: _checkOutDate,
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
      _cityController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _bedroomsController.clear();
      _minRatingController.clear();
      _maxRatingController.clear();
      _selectedPropertyType = null;
      _checkInDate = null;
      _checkOutDate = null;
      _page = 1;
    });
  }

  // Toggle map visibility
  void _toggleMapVisibility() {
    setState(() {
      _isMapVisible = !_isMapVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyProvider2);

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
            child: Column(
              children: [
                Row(
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
                const SizedBox(height: 12),
                // Map search button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _toggleMapVisibility,
                    icon: Icon(_isMapVisible ? Icons.map_outlined : Icons.map),
                    label: Text(_isMapVisible
                        ? 'Hide Map'
                        : 'Show Map for Location Search'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppBorderRadius.medium),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filters
          AnimatedContainer(
            duration: AppDurations.medium,
            height: _isFilterVisible ? 500 : 0,
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

                    // City filter with map button
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'City',
                        prefixIcon: const Icon(Icons.location_city),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.map,
                            color: AppColors.primary,
                          ),
                          onPressed: _toggleMapVisibility,
                          tooltip: 'Toggle map visibility',
                        ),
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

                    // Bedrooms
                    TextField(
                      controller: _bedroomsController,
                      decoration: InputDecoration(
                        hintText: 'Bedrooms',
                        prefixIcon: const Icon(Icons.bed),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.medium),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),

                    // Property Type
                    DropdownButtonFormField<String>(
                      value: _selectedPropertyType,
                      decoration: InputDecoration(
                        hintText: 'Property Type',
                        prefixIcon: const Icon(Icons.house),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.medium),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      isExpanded: true,
                      items: _propertyTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPropertyType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // Rating range
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minRatingController,
                            decoration: InputDecoration(
                              hintText: 'Min Rating (1-5)',
                              prefixIcon: const Icon(Icons.star_border),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppBorderRadius.medium),
                              ),
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _maxRatingController,
                            decoration: InputDecoration(
                              hintText: 'Max Rating (1-5)',
                              prefixIcon: const Icon(Icons.star),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppBorderRadius.medium),
                              ),
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Date range
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _checkInDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  _checkInDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(
                                    AppBorderRadius.medium),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _checkInDate != null
                                          ? '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}'
                                          : 'Check-in Date',
                                      style: TextStyle(
                                        color: _checkInDate != null
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _checkOutDate ??
                                    (_checkInDate
                                            ?.add(const Duration(days: 1)) ??
                                        DateTime.now()
                                            .add(const Duration(days: 1))),
                                firstDate: _checkInDate
                                        ?.add(const Duration(days: 1)) ??
                                    DateTime.now().add(const Duration(days: 1)),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  _checkOutDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(
                                    AppBorderRadius.medium),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _checkOutDate != null
                                          ? '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}'
                                          : 'Check-out Date',
                                      style: TextStyle(
                                        color: _checkOutDate != null
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

          // Map section
          if (_isMapVisible)
            Container(
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                child: LocationPickerMap(
                  initialLatitude: 37.7749, // Default to San Francisco
                  initialLongitude: -122.4194,
                  showSearchBar: true,
                  onLocationSelected: (latitude, longitude, address, city) {
                    // Update the city field with selected city
                    setState(() {
                      _cityController.text = city;
                      _isMapVisible = false; // Hide map after selection
                    });
                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('City selected: $city'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
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
}
