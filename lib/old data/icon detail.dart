import 'package:flutter/material.dart';

class IconDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String propertyName = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(propertyName),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("assets/property.jpg", fit: BoxFit.cover), // Add image in assets
            SizedBox(height: 10),
            Text(propertyName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("A luxurious property with all modern amenities."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Book Now"),
            ),
          ],
        ),
      ),
    );
  }
}
