# Flutter Booking Creation Guide

## Overview
This document provides comprehensive instructions for implementing booking creation functionality in Flutter, including automatic total amount calculation, date validation, and integration with the updated booking API.

## API Changes Summary

### Updated Booking Creation Endpoint
- **URL**: `POST /api/bookings`
- **Authentication**: Required (Bearer token)
- **Content-Type**: `application/json`

### New Booking Schema
The booking table now includes additional fields for better functionality:

```sql
CREATE TABLE Booking (
    booking_id INT PRIMARY KEY,
    user_ID INT,
    property_id INT,
    status VARCHAR(50),
    booking_date DATE,
    start_date DATE,
    end_date DATE,
    total_amount DECIMAL(10, 2),  -- NEW FIELD
    guests INT,                   -- NEW FIELD
    FOREIGN KEY (user_ID) REFERENCES Users(user_ID),
    FOREIGN KEY (property_id) REFERENCES Properties(property_id)
);
```

### Required Fields for Booking Creation

```json
{
  "property_id": "integer (required)",
  "start_date": "string (required, format: YYYY-MM-DD)",
  "end_date": "string (required, format: YYYY-MM-DD)",
  "guests": "integer (optional, defaults to property max guests)"
}
```

### API Response Structure

```json
{
  "message": "Booking created successfully",
  "booking": {
    "booking_id": 1,
    "property_id": 1,
    "user_ID": 3,
    "status": "Pending",
    "booking_date": "2024-01-15",
    "start_date": "2024-02-01",
    "end_date": "2024-02-05",
    "total_amount": 600.00,
    "guests": 2,
    "number_of_days": 4,
    "title": "Beautiful Beach House",
    "city": "Miami",
    "rent_per_day": 150.00,
    "address": "123 Beach Road",
    "property_type": "House",
    "host_name": "John Doe",
    "property_image": "http://localhost:3004/uploads/property1.jpg"
  }
}
```

## Flutter Implementation

### 1. Update Booking Model

Create or update your booking model to include the new fields:

```dart
// models/booking.dart
class Booking {
  final int? bookingId;
  final int propertyId;
  final int userId;
  final String status;
  final DateTime bookingDate;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final int guests;
  final int numberOfDays;

  // Property details
  final String? title;
  final String? city;
  final double? rentPerDay;
  final String? address;
  final String? propertyType;
  final String? hostName;
  final String? propertyImage;

  Booking({
    this.bookingId,
    required this.propertyId,
    required this.userId,
    required this.status,
    required this.bookingDate,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.guests,
    required this.numberOfDays,
    this.title,
    this.city,
    this.rentPerDay,
    this.address,
    this.propertyType,
    this.hostName,
    this.propertyImage,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['booking_id'],
      propertyId: json['property_id'],
      userId: json['user_ID'],
      status: json['status'],
      bookingDate: DateTime.parse(json['booking_date']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalAmount: double.parse(json['total_amount'].toString()),
      guests: json['guests'],
      numberOfDays: json['number_of_days'] ?? 0,
      title: json['title'],
      city: json['city'],
      rentPerDay: json['rent_per_day'] != null
          ? double.parse(json['rent_per_day'].toString()) : null,
      address: json['address'],
      propertyType: json['property_type'],
      hostName: json['host_name'],
      propertyImage: json['property_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'guests': guests,
    };
  }
}
```

### 2. Create Booking Service

```dart
// services/booking_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingService {
  static const String baseUrl = 'http://your-api-url:3004/api';

  static Future<Map<String, dynamic>> createBooking({
    required int propertyId,
    required DateTime startDate,
    required DateTime endDate,
    required int guests,
    required String authToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/bookings');

      final bookingData = {
        'property_id': propertyId,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'guests': guests,
      };

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(bookingData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create booking');
      }
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  static Future<List<Booking>> getUserBookings(String authToken) async {
    try {
      final uri = Uri.parse('$baseUrl/bookings/user');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> bookingsJson = data['bookings'];
        return bookingsJson.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch bookings');
      }
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  static Future<Map<String, dynamic>> updateBookingStatus({
    required int bookingId,
    required String status,
    required String authToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/bookings/$bookingId/status');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update booking');
      }
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }
}
```

### 3. Create Booking Form Widget

```dart
// widgets/booking_form.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingForm extends StatefulWidget {
  final Map<String, dynamic> property;
  final Function(Booking) onBookingCreated;

  const BookingForm({
    Key? key,
    required this.property,
    required this.onBookingCreated,
  }) : super(key: key);

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _guests = 1;
  bool _isLoading = false;
  double _totalAmount = 0.0;
  int _numberOfDays = 0;

  @override
  void initState() {
    super.initState();
    _guests = widget.property['guest'] ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book This Property',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 16),

            // Property Info Summary
            _buildPropertySummary(),
            SizedBox(height: 16),

            // Date Selection
            _buildDateSelection(),
            SizedBox(height: 16),

            // Guest Selection
            _buildGuestSelection(),
            SizedBox(height: 16),

            // Booking Summary
            if (_startDate != null && _endDate != null)
              _buildBookingSummary(),
            SizedBox(height: 16),

            // Book Button
            _buildBookButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertySummary() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (widget.property['property_image'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.property['property_image'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: Icon(Icons.home, color: Colors.grey[600]),
                  );
                },
              ),
            ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property['title'] ?? 'Property',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.property['city'] ?? '',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  '\$${widget.property['rent_per_day']}/night',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Dates',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Check-in',
                date: _startDate,
                onTap: () => _selectStartDate(),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'Check-out',
                date: _endDate,
                onTap: () => _selectEndDate(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              date != null
                  ? DateFormat('MMM dd, yyyy').format(date)
                  : 'Select date',
              style: TextStyle(
                fontSize: 16,
                color: date != null ? Colors.black : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guests',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Number of guests'),
              Row(
                children: [
                  IconButton(
                    onPressed: _guests > 1 ? () => _updateGuests(_guests - 1) : null,
                    icon: Icon(Icons.remove),
                    iconSize: 20,
                  ),
                  Text(
                    '$_guests',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _guests < (widget.property['guest'] ?? 1)
                        ? () => _updateGuests(_guests + 1) : null,
                    icon: Icon(Icons.add),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(
          'Max guests: ${widget.property['guest'] ?? 1}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 12),
          _buildSummaryRow(
            'Check-in',
            DateFormat('MMM dd, yyyy').format(_startDate!),
          ),
          _buildSummaryRow(
            'Check-out',
            DateFormat('MMM dd, yyyy').format(_endDate!),
          ),
          _buildSummaryRow('Guests', '$_guests'),
          _buildSummaryRow('Number of nights', '$_numberOfDays'),
          Divider(),
          _buildSummaryRow(
            'Rate per night',
            '\$${widget.property['rent_per_day']}',
          ),
          _buildSummaryRow(
            'Total Amount',
            '\$${_totalAmount.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.blue[800] : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    final bool canBook = _startDate != null &&
                        _endDate != null &&
                        _numberOfDays > 0 &&
                        !_isLoading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canBook ? _createBooking : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Book Now - \$${_totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Reset end date if it's before or same as start date
        if (_endDate != null && _endDate!.isBefore(picked.add(Duration(days: 1)))) {
          _endDate = null;
        }
        _calculateTotal();
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select check-in date first')),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate!.add(Duration(days: 1)),
      firstDate: _startDate!.add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        _calculateTotal();
      });
    }
  }

  void _updateGuests(int newGuests) {
    setState(() {
      _guests = newGuests;
    });
  }

  void _calculateTotal() {
    if (_startDate != null && _endDate != null) {
      final difference = _endDate!.difference(_startDate!);
      _numberOfDays = difference.inDays;
      _totalAmount = _numberOfDays * (widget.property['rent_per_day'] ?? 0.0);
    } else {
      _numberOfDays = 0;
      _totalAmount = 0.0;
    }
  }

  Future<void> _createBooking() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both check-in and check-out dates')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authToken = await _getAuthToken(); // Implement this method

      final result = await BookingService.createBooking(
        propertyId: widget.property['property_id'],
        startDate: _startDate!,
        endDate: _endDate!,
        guests: _guests,
        authToken: authToken,
      );

      final booking = Booking.fromJson(result['booking']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onBookingCreated(booking);
      Navigator.pop(context, booking);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getAuthToken() async {
    // Implement your authentication token retrieval logic here
    // This could be from SharedPreferences, secure storage, etc.
    throw UnimplementedError('Implement authentication token retrieval');
  }
}
```

### 4. Usage Example

Here's how to use the booking form in your property details page:

```dart
// pages/property_details_page.dart
class PropertyDetailsPage extends StatelessWidget {
  final Map<String, dynamic> property;

  const PropertyDetailsPage({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(property['title'] ?? 'Property Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Property images, description, etc.
            _buildPropertyDetails(),

            // Booking form
            BookingForm(
              property: property,
              onBookingCreated: (booking) {
                // Handle successful booking creation
                Navigator.pushNamed(
                  context,
                  '/booking-confirmation',
                  arguments: booking,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDetails() {
    // Implement your property details UI here
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            property['title'] ?? '',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            property['description'] ?? '',
            style: TextStyle(fontSize: 16),
          ),
          // Add more property details as needed
        ],
      ),
    );
  }
}
```

### 5. Error Handling and Validation

The booking system includes comprehensive validation:

#### Client-Side Validation
- **Date Validation**: Ensures start date is not in the past and end date is after start date
- **Guest Validation**: Prevents exceeding property's maximum guest capacity
- **Booking Duration**: Limits bookings to maximum 365 days
- **Required Fields**: Validates all mandatory fields before submission

#### Server-Side Validation
The API returns specific error messages for validation failures:

```json
// Example error responses:
{
  "message": "Start date cannot be in the past"
}
{
  "message": "End date must be after start date"
}
{
  "message": "Property can accommodate maximum 4 guests"
}
{
  "message": "Property is not available for the selected dates"
}
{
  "message": "You cannot book your own property"
}
```

### 6. Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
```

### 7. Database Migration

If you're updating an existing database, run this SQL to add the missing columns:

```sql
-- Add new columns to existing Booking table
ALTER TABLE Booking ADD COLUMN total_amount DECIMAL(10, 2);
ALTER TABLE Booking ADD COLUMN guests INT;

-- Update existing bookings with calculated values (example)
UPDATE Booking
SET total_amount = (
  SELECT DATEDIFF(day, b.start_date, b.end_date) * p.rent_per_day
  FROM Booking b
  JOIN Properties p ON b.property_id = p.property_id
  WHERE b.booking_id = Booking.booking_id
),
guests = (
  SELECT p.guest
  FROM Properties p
  WHERE p.property_id = Booking.property_id
)
WHERE total_amount IS NULL;
```

### 8. Testing the Implementation

#### Test Cases to Verify:

1. **Date Selection**:
   - Try selecting past dates (should be prevented)
   - Try selecting end date before start date (should be prevented)
   - Verify total calculation updates when dates change

2. **Guest Selection**:
   - Try exceeding maximum guest capacity (should be prevented)
   - Verify guest count affects booking but not total amount

3. **Total Amount Calculation**:
   - Verify correct calculation: (end_date - start_date) × rent_per_day
   - Test with different date ranges
   - Verify real-time updates as dates change

4. **API Integration**:
   - Test successful booking creation
   - Test error handling for unavailable dates
   - Test validation error responses

5. **Availability Check**:
   - Try booking dates that overlap with existing bookings
   - Verify cancelled bookings don't block availability

### 9. Key Features

#### Automatic Total Calculation
- **Real-time Updates**: Total amount updates automatically when dates change
- **Accurate Calculation**: Uses exact number of days between check-in and check-out
- **Server Validation**: Server recalculates and validates the total amount

#### Date Validation
- **Past Date Prevention**: Cannot select past dates for check-in
- **Logical Date Order**: Check-out must be after check-in
- **Availability Check**: Prevents booking unavailable dates

#### Guest Management
- **Capacity Limits**: Enforces property's maximum guest capacity
- **Flexible Selection**: Easy increment/decrement guest count
- **Clear Feedback**: Shows maximum capacity to users

#### User Experience
- **Visual Feedback**: Clear booking summary with all details
- **Loading States**: Shows progress during booking creation
- **Error Handling**: User-friendly error messages
- **Responsive Design**: Works on different screen sizes

### 10. Migration Checklist

- [ ] Update database schema with new columns
- [ ] Update Booking model with new fields
- [ ] Implement BookingService with new API endpoints
- [ ] Create BookingForm widget with date selection
- [ ] Add guest selection functionality
- [ ] Implement total amount calculation
- [ ] Add comprehensive validation
- [ ] Test booking creation flow
- [ ] Test error handling scenarios
- [ ] Update existing booking displays to show new fields

### 11. Additional Considerations

#### Performance Optimizations:
- Cache property details to avoid repeated API calls
- Implement debounced date selection for better UX
- Add offline support for viewing existing bookings

#### Security:
- Validate all inputs on both client and server
- Implement proper authentication token handling
- Add rate limiting for booking creation

#### User Experience Enhancements:
- Add calendar view for date selection
- Show property availability calendar
- Implement booking confirmation emails
- Add booking modification/cancellation features

This implementation provides a complete, robust booking creation system with automatic total amount calculation, comprehensive validation, and excellent user experience.
```