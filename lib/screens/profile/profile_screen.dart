import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/common/app_button.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user.profileImage != null
                        ? NetworkImage(user.profileImage!)
                        : null,
                    child: user.profileImage == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Account settings
            const Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context,
              Icons.person,
              'Personal Information',
              () => Navigator.pushNamed(context, AppRoutes.personalInfo),
            ),
            _buildSettingsItem(
              context,
              Icons.lock,
              'Login & Security',
              () => Navigator.pushNamed(context, AppRoutes.loginSecurity),
            ),
            _buildSettingsItem(
              context,
              Icons.favorite,
              'Preferences',
              () => Navigator.pushNamed(context, AppRoutes.habits),
            ),

            const SizedBox(height: 24),

            // Hosting
            const Text(
              'Hosting',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context,
              Icons.home,
              'My Properties',
              () => Navigator.pushNamed(context, AppRoutes.myProperties),
            ),
            _buildSettingsItem(
              context,
              Icons.add_home,
              'List a New Property',
              () => Navigator.pushNamed(context, AppRoutes.uploadProperty),
            ),
            _buildSettingsItem(
              context,
              Icons.book,
              'Booking Requests',
              () => Navigator.pushNamed(context, AppRoutes.requestPending),
            ),

            const SizedBox(height: 24),

            // Trips
            const Text(
              'Trips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context,
              Icons.hotel,
              'Booked Properties',
              () => Navigator.pushNamed(context, AppRoutes.bookedProperty),
            ),
            _buildSettingsItem(
              context,
              Icons.star,
              'Reviews to Write',
              () => Navigator.pushNamed(context, AppRoutes.ratePending),
            ),

            const SizedBox(height: 32),

            // Logout button
            Center(
              child: AppButton(
                text: 'Logout',
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  // No need to navigate, the main.dart will handle navigation based on auth state
                },
                type: ButtonType.outline,
                isFullWidth: true,
              ),
            ),

            const SizedBox(height: 16),

            // App version
            const Center(
              child: Text(
                'App Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
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
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
