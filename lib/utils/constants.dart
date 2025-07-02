import 'package:flutter/material.dart';

// API Constants
// The base URL is now managed in AppConfig
// This is just a fallback value
const String kBaseUrl = 'http://10.0.2.2:3004'; // Echo API URL for Airbnb clone

// Logging Constants
const bool kEnableApiLogging =
    true; // Set to true to enable API request/response logging

// Color Constants
class AppColors {
  static const Color primary = Color(0xFFFF5A5F);
  static const Color secondary = Color(0xFF00A699);
  static const Color accent = Color(0xFFFFB400);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F8F8);
  static const Color error = Color(0xFFFF0000);
  static const Color success = Color(0xFF4CAF50);
  static const Color text = Color(0xFF484848);
  static const Color textLight = Color(0xFF767676);
}

// Text Styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    color: AppColors.textLight,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

// Padding and Margin Constants
class AppSpacing {
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Border Radius Constants
class AppBorderRadius {
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;
  static const double xl = 16.0;
  static const double circular = 100.0;
}

// Animation Duration Constants
class AppDurations {
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 500);
}

// Route Names
class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String search = '/search';
  static const String searchResults = '/search_results';
  static const String propertyDetails = '/property_details';
  static const String bookingConfirmation = '/booking_confirmation';
  static const String myProperties = '/my_properties';
  static const String userPropertyDetails = '/user_property_details';
  static const String uploadProperty = '/upload_property';
  static const String bookedProperty = '/booked_property';
  static const String requestPending = '/request_pending';
  static const String ratePending = '/rate_pending';
  static const String userBookings = '/user_bookings';
  static const String hostBookings = '/host_bookings';
  static const String bookingDetails = '/booking_details';
  static const String requestPendingManagement = '/request_pending_management';
  static const String hostBookingConfirmation = '/host_booking_confirmation';
  static const String personalInfo = '/personal_info';
  static const String loginSecurity = '/login_security';
  static const String habits = '/habits';
  static const String propertyReviews = '/property_reviews';
  static const String userReviews = '/user_reviews';
  static const String hostReviews = '/host_reviews';

  // List of all routes for easy access
  static final List<String> values = [
    login,
    signup,
    dashboard,
    profile,
    search,
    searchResults,
    propertyDetails,
    bookingConfirmation,
    myProperties,
    userPropertyDetails,
    uploadProperty,
    bookedProperty,
    requestPending,
    ratePending,
    userBookings,
    hostBookings,
    bookingDetails,
    requestPendingManagement,
    hostBookingConfirmation,
    personalInfo,
    loginSecurity,
    habits,
    propertyReviews,
    userReviews,
    hostReviews,
  ];
}

// Asset Paths
class AppAssets {
  static const String logo = 'assets/images/logo.jpg';
  static const String background = 'assets/images/background.jpg';
  static const String placeholder = 'assets/images/placeholder.png';
}

// Shared Preferences Keys
class AppPreferences {
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String username = 'username';
  static const String email = 'email';
  static const String isDarkMode = 'is_dark_mode';
}
