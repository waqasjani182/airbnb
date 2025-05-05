import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A service that handles navigation throughout the app.
/// This allows navigation to be triggered from providers without needing a BuildContext.
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to a named route
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  /// Replace the current route with a new one
  Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Pop the current route
  void goBack() {
    return navigatorKey.currentState!.pop();
  }

  /// Pop until a specific route
  void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }
}

/// Provider for the navigation service
final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});
