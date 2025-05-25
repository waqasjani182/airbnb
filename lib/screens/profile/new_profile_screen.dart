import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class NewProfileScreen extends ConsumerWidget {
  const NewProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header with user info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user.profileImage != null
                        ? NetworkImage(user.profileImage!)
                        : null,
                    child: user.profileImage == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user.firstName} ${user.lastName}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),

            const Divider(),

            // Settings header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Settings items
            _buildSettingsItem(
              context,
              Icons.person_outline,
              'Personal information',
              () => Navigator.pushNamed(context, AppRoutes.personalInfo),
            ),

            _buildSettingsItem(
              context,
              Icons.accessibility_new,
              'Habits',
              () => Navigator.pushNamed(context, AppRoutes.habits),
            ),

            _buildSettingsItem(
              context,
              Icons.lock_outline,
              'Login & security',
              () => Navigator.pushNamed(context, AppRoutes.loginSecurity),
            ),

            _buildSettingsItem(
              context,
              Icons.notifications_none,
              'Request pending',
              () => Navigator.pushNamed(context, AppRoutes.requestPending),
            ),

            _buildSettingsItem(
              context,
              Icons.home_outlined,
              'My Properties',
              () => Navigator.pushNamed(context, AppRoutes.myProperties),
            ),

            _buildSettingsItem(
              context,
              Icons.add_box_outlined,
              'Upload Property',
              () => Navigator.pushNamed(context, AppRoutes.uploadProperty),
            ),

            _buildSettingsItem(
              context,
              Icons.book_outlined,
              'Booked property',
              () => Navigator.pushNamed(context, AppRoutes.bookedProperty),
            ),

            _buildSettingsItem(
              context,
              Icons.star_border,
              'Rate pending',
              () => Navigator.pushNamed(context, AppRoutes.ratePending),
            ),

            _buildSettingsItem(
              context,
              Icons.check_circle_outline,
              'Booking confirmation',
              () => Navigator.pushNamed(context, AppRoutes.bookingConfirmation),
            ),

            const Divider(),

            // Logout
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: GestureDetector(
                onTap: () => _showLogoutConfirmation(context, ref),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Show a confirmation dialog before logging out
  Future<void> _showLogoutConfirmation(
      BuildContext context, WidgetRef ref) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Check if context is still valid before showing loading dialog
      if (!context.mounted) return;

      // Show loading indicator
      _showLoadingDialog(context);

      try {
        // Perform logout
        await ref.read(authProvider.notifier).logout();

        // Dismiss loading dialog if it's still showing
        if (context.mounted) {
          Navigator.of(context).pop();

          // Explicitly navigate to login screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false, // Remove all previous routes
          );
        }
      } catch (e) {
        // Dismiss loading dialog if it's still showing
        if (context.mounted) {
          Navigator.of(context).pop();

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Show a loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Logging out...'),
            ],
          ),
        );
      },
    );
  }
}
