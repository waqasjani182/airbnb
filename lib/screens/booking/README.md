# Booking Screens

This directory contains the Flutter screens for managing bookings in the Airbnb clone app.

## Overview

The booking system provides different views for guests and hosts:

### Guest Perspective (User Bookings)
- View all bookings made as a guest
- Filter bookings by status (All, Pending, Confirmed, Completed)
- Cancel pending or confirmed bookings
- View detailed booking information

### Host Perspective (Property Bookings)
- View all bookings for owned properties
- Manage booking requests (confirm/cancel pending bookings)
- Mark confirmed bookings as completed
- View guest information and booking details

## Screens

### 1. UserBookingsScreen (`user_bookings_screen.dart`)
**Route**: `/user_bookings`
**Purpose**: Display all bookings made by the current user as a guest

**Features**:
- Tabbed interface with status filters
- Pull-to-refresh functionality
- Cancel booking capability
- Navigation to booking details

**API Endpoint**: `GET /api/bookings/user`

### 2. HostBookingsScreen (`host_bookings_screen.dart`)
**Route**: `/host_bookings`
**Purpose**: Display all bookings for properties owned by the current user

**Features**:
- Tabbed interface with status filters
- Booking management actions (confirm, cancel, complete)
- Guest information display
- Navigation to booking details

**API Endpoint**: `GET /api/bookings/host`

### 3. BookingDetailsScreen (`booking_details_screen.dart`)
**Route**: `/booking_details/:id`
**Purpose**: Display detailed information about a specific booking

**Features**:
- Complete booking information
- Property details with image
- Guest/Host information (context-dependent)
- Payment information
- Status management actions
- Role-based action buttons

**API Endpoint**: `GET /api/bookings/:id`

### 4. RequestPendingScreen (`request_pending_screen.dart`)
**Route**: `/request_pending_management`
**Purpose**: Host-only screen for managing incoming booking requests

**Features**:
- Shows only pending booking requests
- Quick confirm/reject actions
- Guest information display
- Urgent request indicators
- Confirmation dialogs for actions
- Navigation to detailed booking view

**API Endpoint**: `GET /api/bookings/host` (filtered for pending status)

### 5. HostBookingConfirmationScreen (`host_booking_confirmation_screen.dart`)
**Route**: `/host_booking_confirmation`
**Purpose**: Host-only screen for managing confirmed, completed, and cancelled bookings

**Features**:
- Tabbed interface (Confirmed, Completed, Cancelled)
- Mark confirmed bookings as completed
- Cancel confirmed bookings
- View booking details
- Status-specific UI indicators
- Comprehensive booking management

**API Endpoint**: `GET /api/bookings/host` (filtered by status)

## Components

### BookingCard (`components/booking_card.dart`)
Reusable card component for displaying booking information in lists.

**Props**:
- `booking`: Booking model instance
- `isHostView`: Boolean to determine if showing host or guest perspective
- `onTap`: Callback for card tap (usually navigation to details)
- `onStatusUpdate`: Callback for status update actions

### BookingStatusBadge (`components/booking_status_badge.dart`)
Visual indicator for booking status with appropriate colors and icons.

**Props**:
- `status`: String status value
- `isCompact`: Boolean for compact display mode

**Status Types**:
- **Pending**: Orange badge with schedule icon
- **Confirmed**: Green badge with check circle icon
- **Cancelled**: Red badge with cancel icon
- **Completed**: Blue badge with done all icon

### BookingRequestCard (`components/booking_request_card.dart`)
Specialized card component for displaying pending booking requests with quick actions.

**Props**:
- `booking`: Booking model instance
- `onConfirm`: Callback for confirming the request
- `onReject`: Callback for rejecting the request
- `onViewDetails`: Callback for viewing full details

**Features**:
- Urgent request indicator
- Guest information display
- Quick action buttons (Confirm/Reject)
- Property image and details
- Booking dates and amount

### ConfirmedBookingCard (`components/confirmed_booking_card.dart`)
Specialized card component for displaying confirmed, completed, and cancelled bookings.

**Props**:
- `booking`: Booking model instance
- `onMarkComplete`: Callback for marking booking as complete
- `onCancel`: Callback for cancelling confirmed booking
- `onViewDetails`: Callback for viewing full details

**Features**:
- Status-specific styling and colors
- Action buttons based on booking status
- Property image and guest information
- Booking dates and payment details
- Status indicators and icons

## Navigation

### From Profile Screen
- **My Bookings**: Available to all users
- **Property Bookings**: Available only to hosts (users with `isHost: true`)
- **Booking Requests**: Available only to hosts, shows notification badge with pending count
- **Booking Management**: Available only to hosts, replaces "Booking confirmation" for hosts

### Programmatic Navigation
```dart
// Navigate to user bookings
Navigator.pushNamed(context, AppRoutes.userBookings);

// Navigate to host bookings
Navigator.pushNamed(context, AppRoutes.hostBookings);

// Navigate to booking requests (hosts only)
Navigator.pushNamed(context, AppRoutes.requestPendingManagement);

// Navigate to booking management (hosts only)
Navigator.pushNamed(context, AppRoutes.hostBookingConfirmation);

// Navigate to booking details
Navigator.pushNamed(context, '${AppRoutes.bookingDetails}/$bookingId');
```

## Status Management

### Booking Status Flow
1. **Pending** → Initial status when booking is created
2. **Confirmed** → Host approves the booking
3. **Completed** → Stay is finished (host action)
4. **Cancelled** → Booking cancelled by guest or host

### Permission Matrix
| Action | Guest | Host | Status Requirements |
|--------|-------|------|-------------------|
| Cancel | ✅ | ✅ | Pending, Confirmed |
| Confirm | ❌ | ✅ | Pending |
| Complete | ❌ | ✅ | Confirmed |

## API Integration

### Service Layer
The `BookingService` class handles all API communications:

```dart
// Get user bookings (guest perspective)
Future<List<Booking>> getUserBookings(String token)

// Get host bookings (property owner perspective)
Future<List<Booking>> getHostBookings(String token)

// Get specific booking details
Future<Booking> getBookingById(String id, String token)

// Update booking status
Future<Booking> updateBookingStatus(String id, BookingStatus status, String token)
```

### Provider Layer
The `BookingProvider` manages state and business logic:

```dart
// Fetch methods
Future<void> fetchUserBookings()
Future<void> fetchHostBookings()
Future<void> fetchBookingById(String id)

// Action methods
Future<void> updateBookingStatus(String id, BookingStatus status)
```

## Error Handling

All screens include comprehensive error handling:
- Network errors with retry functionality
- Empty states with appropriate messaging
- Loading states with progress indicators
- User-friendly error messages

## Dependencies

- `flutter_riverpod`: State management
- `intl`: Date formatting
- Custom models: `Booking`, `BookingStatus`
- Custom providers: `BookingProvider`, `AuthProvider`
- Custom services: `BookingService`

## Usage Example

```dart
// In a widget that needs to show user bookings
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, AppRoutes.userBookings);
  },
  child: Text('View My Bookings'),
)

// For hosts to view property bookings
if (user.isHost) {
  ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(context, AppRoutes.hostBookings);
    },
    child: Text('Manage Property Bookings'),
  )
}
```
