import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/constants.dart';

class LocationPickerMap extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final Function(double latitude, double longitude, String address, String city)
      onLocationSelected;
  final bool showSearchBar;

  const LocationPickerMap({
    super.key,
    this.initialLatitude = 0.0,
    this.initialLongitude = 0.0,
    required this.onLocationSelected,
    this.showSearchBar = true,
  });

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  late MapController _mapController;
  late LatLng _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  String _selectedAddress = '';
  String _selectedCity = '';
  bool _isSearching = false;
  String? _searchError;
  List<Placemark>? _searchResults;
  bool _isMapLoaded = false;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Initialize with provided coordinates or default to a central location
    _selectedLocation = LatLng(
      widget.initialLatitude != 0.0 ? widget.initialLatitude : 37.7749,
      widget.initialLongitude != 0.0 ? widget.initialLongitude : -122.4194,
    );

    // If initial coordinates are provided, get the address
    if (widget.initialLatitude != 0.0 && widget.initialLongitude != 0.0) {
      _getAddressFromLatLng(_selectedLocation);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Get address from latitude and longitude (internal use only)
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final address = _formatAddress(place);
        final city = place.locality ?? '';

        setState(() {
          _selectedAddress = address;
          _selectedCity = city;
        });

        // Don't automatically notify parent - only update internal state
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        _selectedAddress = 'Address not found';
        _selectedCity = '';
      });
    }
  }

  // Get address and notify parent (for user selections)
  Future<void> _getAddressAndNotify(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final address = _formatAddress(place);
        final city = place.locality ?? '';

        setState(() {
          _selectedAddress = address;
          _selectedCity = city;
        });

        // Notify parent widget about the user's selection
        widget.onLocationSelected(
          position.latitude,
          position.longitude,
          address,
          city,
        );
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        _selectedAddress = 'Address not found';
        _selectedCity = '';
      });
    }
  }

  // Format address from placemark
  String _formatAddress(Placemark place) {
    List<String> addressParts = [
      place.street ?? '',
      place.subLocality ?? '',
      place.locality ?? '',
      place.postalCode ?? '',
      place.country ?? '',
    ];

    // Filter out empty parts
    addressParts = addressParts.where((part) => part.isNotEmpty).toList();

    return addressParts.join(', ');
  }

  // Search for location by address
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
      _searchResults = null;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newPosition = LatLng(location.latitude, location.longitude);

        // Move map to the new location
        _mapController.move(newPosition, 15.0);

        // Update selected location
        setState(() {
          _selectedLocation = newPosition;
        });

        // Get address details for the new location
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          final address = _formatAddress(place);
          final city = place.locality ?? '';

          setState(() {
            _selectedAddress = address;
            _selectedCity = city;
            _searchResults = placemarks;
            _isSearching = false;
          });

          // Don't automatically select - let user choose from search results
        } else {
          setState(() {
            _searchResults = null;
            _isSearching = false;
          });
        }
      } else {
        setState(() {
          _searchError = 'No results found';
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('Error searching location: $e');
      setState(() {
        _searchError = 'Error searching location';
        _isSearching = false;
      });
    }
  }

  // Select a search result
  void _selectSearchResult(Placemark place) {
    final address = _formatAddress(place);
    final city = place.locality ?? '';

    setState(() {
      _selectedAddress = address;
      _selectedCity = city;
      _searchResults = null;
    });

    // Notify parent widget about the selected location
    widget.onLocationSelected(
      _selectedLocation.latitude,
      _selectedLocation.longitude,
      address,
      city,
    );
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      // Move map to current location
      _mapController.move(currentLocation, 15.0);

      // Update selected location
      setState(() {
        _selectedLocation = currentLocation;
      });

      // Get address for current location and notify parent
      await _getAddressAndNotify(currentLocation);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting current location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        if (widget.showSearchBar) ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for a location',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _isSearching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchResults = null;
                                      _searchError = null;
                                    });
                                  },
                                ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.medium),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: _searchLocation,
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSearching
                          ? null
                          : () => _searchLocation(_searchController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Search'),
                    ),
                  ],
                ),

                // Search results
                if (_searchResults != null && _searchResults!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.medium),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchResults!.length > 5
                          ? 5
                          : _searchResults!.length,
                      itemBuilder: (context, index) {
                        final place = _searchResults![index];
                        return ListTile(
                          title: Text(place.street ?? 'Unknown'),
                          subtitle: Text(_formatAddress(place)),
                          onTap: () => _selectSearchResult(place),
                        );
                      },
                    ),
                  ),

                // Search error
                if (_searchError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _searchError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ],

        // Map
        Container(
          height: 200, // Reduced height to fit better
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 13.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLocation = point;
                      });
                      _getAddressAndNotify(point);
                    },
                    onMapReady: () {
                      setState(() {
                        _isMapLoaded = true;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.airbnb',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Loading indicator
                if (!_isMapLoaded)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),

                // Map controls
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(
                            _selectedLocation,
                            currentZoom + 1,
                          );
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(
                            _selectedLocation,
                            currentZoom - 1,
                          );
                        },
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'current_location',
                        onPressed:
                            _isGettingLocation ? null : _getCurrentLocation,
                        backgroundColor: _isGettingLocation
                            ? Colors.grey
                            : AppColors.primary,
                        child: _isGettingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.my_location,
                                color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
