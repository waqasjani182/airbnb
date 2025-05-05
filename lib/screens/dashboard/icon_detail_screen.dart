import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../components/common/app_button.dart';
import '../../models/property.dart';
import '../../providers/property_provider.dart';
import '../../utils/constants.dart';

class IconDetailScreen extends ConsumerStatefulWidget {
  final String? propertyId;

  const IconDetailScreen({Key? key, this.propertyId}) : super(key: key);

  @override
  ConsumerState<IconDetailScreen> createState() => _IconDetailScreenState();
}

class _IconDetailScreenState extends ConsumerState<IconDetailScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestCount = 1;
  final int _maxGuests = 10;

  @override
  void initState() {
    super.initState();
    if (widget.propertyId != null) {
      Future.microtask(() => ref
          .read(propertyProvider.notifier)
          .fetchPropertyById(widget.propertyId!));
    }
  }

  void _selectCheckInDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && pickedDate != _checkInDate) {
      setState(() {
        _checkInDate = pickedDate;
        // If check-out date is before check-in date, reset it
        if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
          _checkOutDate = null;
        }
      });
    }
  }

  void _selectCheckOutDate() async {
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select check-in date first')),
      );
      return;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _checkOutDate ?? _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: _checkInDate!.add(const Duration(days: 30)),
    );

    if (pickedDate != null && pickedDate != _checkOutDate) {
      setState(() {
        _checkOutDate = pickedDate;
      });
    }
  }

  void _incrementGuestCount() {
    if (_guestCount < _maxGuests) {
      setState(() {
        _guestCount++;
      });
    }
  }

  void _decrementGuestCount() {
    if (_guestCount > 1) {
      setState(() {
        _guestCount--;
      });
    }
  }

  int _calculateNights() {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  double _calculateTotalPrice(Property property) {
    final nights = _calculateNights();
    return property.pricePerNight * nights;
  }

  void _bookProperty(Property property) {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select check-in and check-out dates')),
      );
      return;
    }

    // Navigate to booking confirmation screen with booking details
    Navigator.pushNamed(
      context,
      AppRoutes.bookingConfirmation,
      arguments: {
        'property': property,
        'checkIn': _checkInDate,
        'checkOut': _checkOutDate,
        'guestCount': _guestCount,
        'totalPrice': _calculateTotalPrice(property),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyProvider);
    final property = propertyState.selectedProperty;
    final isLoading = propertyState.isLoading;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (property == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property Details')),
        body: const Center(child: Text('Property not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with property image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: property.images.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        property.images[index].imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Gradient overlay for better text visibility
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Property details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${property.avgRating} (${property.reviewCount})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                        property.location,
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
                      _buildFeature(Icons.king_bed,
                          '${property.bedrooms} ${property.bedrooms > 1 ? 'beds' : 'bed'}'),
                      _buildFeature(Icons.bathtub,
                          '${property.bathrooms} ${property.bathrooms > 1 ? 'baths' : 'bath'}'),
                      _buildFeature(Icons.person,
                          '${property.maxGuests} ${property.maxGuests > 1 ? 'guests' : 'guest'}'),
                      _buildFeature(
                          Icons.home, property.type.toString().split('.').last),
                    ],
                  ),

                  const Divider(height: 32),

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

                  const Divider(height: 32),

                  // Amenities
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: property.amenities.map((amenity) {
                      return Chip(
                        label: Text(amenity.name),
                        backgroundColor: Colors.grey[100],
                      );
                    }).toList(),
                  ),

                  const Divider(height: 32),

                  // Booking section
                  const Text(
                    'Book this property',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date selection
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectCheckInDate,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.circular(AppBorderRadius.medium),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Check-in',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _checkInDate != null
                                      ? DateFormat('MMM dd, yyyy')
                                          .format(_checkInDate!)
                                      : 'Select date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: _checkInDate != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectCheckOutDate,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.circular(AppBorderRadius.medium),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Check-out',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _checkOutDate != null
                                      ? DateFormat('MMM dd, yyyy')
                                          .format(_checkOutDate!)
                                      : 'Select date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: _checkOutDate != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
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

                  // Guest count
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.medium),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Guests',
                          style: TextStyle(fontSize: 16),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: _decrementGuestCount,
                              color: _guestCount > 1
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                            Text(
                              '$_guestCount',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: _incrementGuestCount,
                              color: _guestCount < _maxGuests
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Price and booking button
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${property.pricePerNight.toStringAsFixed(0)} / night',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_calculateNights() > 0)
                              Text(
                                'Total: \$${_calculateTotalPrice(property).toStringAsFixed(0)} for ${_calculateNights()} nights',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textLight,
                                ),
                              ),
                          ],
                        ),
                      ),
                      AppButton(
                        text: 'Book Now',
                        onPressed: () => _bookProperty(property),
                        type: ButtonType.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.primary,
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
