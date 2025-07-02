import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/property2.dart';
import '../../models/booking.dart';
import '../../models/availability.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../common/app_button.dart';

class PropertyBookingSection extends ConsumerStatefulWidget {
  final Property2 property;

  const PropertyBookingSection({
    super.key,
    required this.property,
  });

  @override
  ConsumerState<PropertyBookingSection> createState() =>
      _PropertyBookingSectionState();
}

class _PropertyBookingSectionState
    extends ConsumerState<PropertyBookingSection> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guestCount = 1;
  final int _maxGuests = 10;
  bool _isBooking = false;
  bool _isCheckingAvailability = false;
  PropertyAvailability? _availabilityData;
  String? _availabilityError;

  Future<void> _selectCheckInDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
        // If check-out date is before check-in date, reset it
        if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
          _checkOutDate = null;
        }
        // Clear previous availability data
        _availabilityData = null;
        _availabilityError = null;
      });

      // Check availability if both dates are selected
      if (_checkOutDate != null) {
        _checkAvailability();
      }
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate ??
          (_checkInDate?.add(const Duration(days: 1)) ??
              DateTime.now().add(const Duration(days: 2))),
      firstDate: _checkInDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkOutDate) {
      setState(() {
        _checkOutDate = picked;
        // Clear previous availability data
        _availabilityData = null;
        _availabilityError = null;
      });

      // Check availability if both dates are selected
      if (_checkInDate != null) {
        _checkAvailability();
      }
    }
  }

  int _calculateNights() {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  double _calculateTotalPrice() {
    final nights = _calculateNights();
    // Use availability data price if available, otherwise use property price
    if (_availabilityData != null) {
      return _availabilityData!.totalAmount;
    }
    return widget.property.rentPerDay * nights;
  }

  // Check availability with the API
  Future<void> _checkAvailability() async {
    if (_checkInDate == null || _checkOutDate == null) return;

    setState(() {
      _isCheckingAvailability = true;
      _availabilityError = null;
    });

    try {
      final availability =
          await ref.read(bookingProvider.notifier).checkPropertyAvailability(
                propertyId: widget.property.propertyId.toString(),
                startDate: _checkInDate!,
                endDate: _checkOutDate!,
                guests: _guestCount,
              );

      if (mounted) {
        setState(() {
          _availabilityData = availability;
          _isCheckingAvailability = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availabilityError = e.toString();
          _isCheckingAvailability = false;
        });
      }
    }
  }

  // Update guest count and check availability
  void _updateGuestCount(int newCount) {
    setState(() {
      _guestCount = newCount;
      // Clear previous availability data
      _availabilityData = null;
      _availabilityError = null;
    });

    // Check availability if dates are selected
    if (_checkInDate != null && _checkOutDate != null) {
      _checkAvailability();
    }
  }

  // Check if booking is possible
  bool _canBook() {
    if (_checkInDate == null || _checkOutDate == null) return false;
    if (_isCheckingAvailability || _isBooking) return false;
    if (_availabilityData == null) return false;
    return _availabilityData!.available;
  }

  Future<void> _bookProperty() async {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select check-in and check-out dates')),
      );
      return;
    }

    // Check availability first
    if (_availabilityData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please wait while we check availability')),
      );
      return;
    }

    if (!_availabilityData!.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property is not available for selected dates'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if user is authenticated
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to make a booking')),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      // Create booking object
      final booking = Booking(
        propertyId: widget.property.propertyId,
        userId: 0, // Will be set by the server
        status: 'Pending',
        bookingDate: DateTime.now(),
        startDate: _checkInDate!,
        endDate: _checkOutDate!,
        totalAmount: _calculateTotalPrice(),
        guests: _guestCount,
        numberOfDays: _calculateNights(),
      );

      // Call the booking provider to create the booking
      await ref.read(bookingProvider.notifier).createBooking(booking);

      // If we reach here, the booking was successful
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate back or to bookings page
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message
      print('[BOOKING SECTION] Error creating booking: $e'); // Debug log

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create booking: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nights = _calculateNights();
    final totalPrice = _calculateTotalPrice();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                onTap: () => _selectCheckInDate(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
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
                      Text(
                        _checkInDate == null
                            ? 'Select date'
                            : DateFormat('MMM d, yyyy').format(_checkInDate!),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectCheckOutDate(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
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
                      Text(
                        _checkOutDate == null
                            ? 'Select date'
                            : DateFormat('MMM d, yyyy').format(_checkOutDate!),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Guests',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _guestCount > 1
                        ? () => _updateGuestCount(_guestCount - 1)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    '$_guestCount',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _guestCount < _maxGuests
                        ? () => _updateGuestCount(_guestCount + 1)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Availability Status
        if (_checkInDate != null && _checkOutDate != null) ...[
          _buildAvailabilityStatus(),
          const SizedBox(height: 16),
        ],

        // Price breakdown
        if (nights > 0) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _availabilityData != null
                          ? 'RS ${_availabilityData!.pricePerDay.toStringAsFixed(0)} x $nights ${nights == 1 ? 'night' : 'nights'}'
                          : 'RS ${widget.property.rentPerDay.toStringAsFixed(0)} x $nights ${nights == 1 ? 'night' : 'nights'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'RS ${totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'RS ${totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Book button
        if (_canBook())
          AppButton(
            text: 'Book Now',
            onPressed: () => _bookProperty(),
            isLoading: _isBooking,
            isFullWidth: true,
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _isCheckingAvailability
                  ? 'Checking availability...'
                  : (_availabilityData?.available == false
                      ? 'Not Available'
                      : 'Select dates to continue'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvailabilityStatus() {
    if (_isCheckingAvailability) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Checking availability...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_availabilityError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error checking availability: $_availabilityError',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_availabilityData != null) {
      final isAvailable = _availabilityData!.available;
      final hasConflicts = _availabilityData!.conflictingBookings.isNotEmpty;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAvailable ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isAvailable ? Colors.green[200]! : Colors.red[200]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isAvailable ? Icons.check_circle : Icons.cancel,
                  color: isAvailable ? Colors.green[700] : Colors.red[700],
                  size: 16,
                ),
                const SizedBox(width: 12),
                Text(
                  isAvailable ? 'Available' : 'Not Available',
                  style: TextStyle(
                    fontSize: 14,
                    color: isAvailable ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (!isAvailable && hasConflicts) ...[
              const SizedBox(height: 8),
              Text(
                'Property has ${_availabilityData!.conflictingBookings.length} conflicting booking(s) for these dates.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                ),
              ),
            ],
            if (isAvailable) ...[
              const SizedBox(height: 8),
              Text(
                'Max guests: ${_availabilityData!.maxGuests}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
