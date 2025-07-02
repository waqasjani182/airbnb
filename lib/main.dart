import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard/dashboard_screen2.dart';
import 'screens/profile/new_profile_screen.dart';
import 'screens/profile/personal_info_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/property/property_detail_screen.dart';
import 'screens/property/upload_property_screen.dart';
import 'screens/property/my_properties_screen.dart';
import 'screens/property/user_property_detail_screen.dart';
import 'screens/booking/user_bookings_screen.dart';
import 'screens/booking/host_bookings_screen.dart';
import 'screens/booking/booking_details_screen.dart';
import 'screens/booking/request_pending_screen.dart';
import 'screens/booking/host_booking_confirmation_screen.dart';
import 'screens/common/coming_soon_screen.dart';
import 'screens/common/not_found_screen.dart';
import 'screens/profile/user_reviews_screen.dart';
import 'services/navigation_service.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AppConfig
  AppConfig().initialize(environment: Environment.development);

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override the sharedPreferencesProvider with the actual instance
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the navigation service
    final navigationService = ref.watch(navigationServiceProvider);

    return MaterialApp(
      title: 'Air Bed And Breakfast',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigationService.navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          ThemeMode.light, // You can make this dynamic based on user preference
      home: const AuthWrapper(), // Use AuthWrapper as the home widget
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),
        AppRoutes.dashboard: (context) =>
            const DashboardScreen2(), // Using the new dashboard screen
        AppRoutes.profile: (context) => const NewProfileScreen(),
        AppRoutes.search: (context) => const SearchScreen(),
        AppRoutes.propertyDetails: (context) => const PropertyDetailScreen(),
        AppRoutes.uploadProperty: (context) => const UploadPropertyScreen(),
        AppRoutes.myProperties: (context) => const MyPropertiesScreen(),
        AppRoutes.userBookings: (context) => const UserBookingsScreen(),
        AppRoutes.hostBookings: (context) => const HostBookingsScreen(),
        AppRoutes.requestPendingManagement: (context) =>
            const RequestPendingScreen(),
        AppRoutes.hostBookingConfirmation: (context) =>
            const HostBookingConfirmationScreen(),
        AppRoutes.personalInfo: (context) => const PersonalInfoScreen(),
        AppRoutes.userReviews: (context) => const UserReviewsScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes here
        if (settings.name?.startsWith('${AppRoutes.propertyDetails}/') ??
            false) {
          final propertyId = settings.name!.split('/').last;
          // Use PropertyDetailScreen for the property details screen
          return MaterialPageRoute(
            builder: (context) => PropertyDetailScreen(propertyId: propertyId),
          );
        }

        // Handle user property details route
        if (settings.name?.startsWith('${AppRoutes.userPropertyDetails}/') ??
            false) {
          final propertyId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) =>
                UserPropertyDetailScreen(propertyId: propertyId),
          );
        }

        // Handle booking details route
        if (settings.name?.startsWith('${AppRoutes.bookingDetails}/') ??
            false) {
          final bookingId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => BookingDetailsScreen(bookingId: bookingId),
          );
        }

        // Check if the route is defined in our routes map
        if (settings.name != null) {
          // Define which routes are implemented and which are coming soon
          final implementedRoutes = {
            AppRoutes.login,
            AppRoutes.signup,
            AppRoutes.dashboard,
            AppRoutes.profile,
            AppRoutes.search,
            AppRoutes.propertyDetails,
            AppRoutes.uploadProperty,
            AppRoutes.myProperties,
            AppRoutes.userBookings,
            AppRoutes.hostBookings,
            AppRoutes.bookingDetails,
            AppRoutes.requestPendingManagement,
            AppRoutes.hostBookingConfirmation,
            AppRoutes.personalInfo,
          };

          // If the route is in AppRoutes but not in implementedRoutes, show Coming Soon
          if (AppRoutes.values.contains(settings.name) &&
              !implementedRoutes.contains(settings.name)) {
            return MaterialPageRoute(
              builder: (context) => ComingSoonScreen(
                title: 'Coming Soon',
                message:
                    'The ${settings.name?.substring(1)} feature is under development and will be available soon.',
              ),
            );
          }
        }

        // If we reach here, the route doesn't exist, show 404
        return MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
        );
      },
    );
  }
}
