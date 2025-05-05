import 'package:flutter/material.dart';
import 'personal_info_screen.dart';
import 'login_security_screen.dart';
import 'request_pending_screen.dart';
import 'my_properties_screen.dart';
import 'upload_property_screen.dart';
import 'booked_property_screen.dart';
import 'rate_pending_screen.dart';
import 'booking_confirmation_screen.dart';
import 'habits_screen.dart'; // 👈 Add this line

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage("assets/profile.jpg"),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Muhammad Yasir",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
            const Divider(height: 30),
            const Text(
              "Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildListTile(context, Icons.person, "Personal information",
                const PersonalInfoScreen()),
            buildListTile(context, Icons.accessibility_new, "Habits",
                const HabitsScreen()), // 👈 New tab
            buildListTile(context, Icons.security, "Login & security",
                const LoginSecurityScreen()),
            buildListTile(context, Icons.notifications, "Request pending",
                const RequestPendingScreen()),
            buildListTile(context, Icons.home, "My Properties",
                const MyPropertiesScreen()),
            buildListTile(context, Icons.upload, "Upload Property",
                const UploadPropertyScreen()),
            buildListTile(context, Icons.book, "Booked property",
                const BookedPropertyScreen()),
            buildListTile(
                context, Icons.star, "Rate pending", const RatePendingScreen()),
            buildListTile(context, Icons.check_circle, "Booking Confirmation",
                const BookingConfirmationScreen()),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                "Logout",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListTile(
      BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}
