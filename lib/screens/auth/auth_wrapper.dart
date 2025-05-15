import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen2.dart';
import 'login_screen.dart';

/// A wrapper widget that handles authentication state changes
/// and redirects to the appropriate screen
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Show loading indicator while checking authentication status
    if (authState.status == AuthStatus.initial) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Redirect based on authentication status
    if (authState.isAuthenticated) {
      return const DashboardScreen2();
    } else {
      return const LoginScreen();
    }
  }
}
