import 'package:flutter/material.dart';

class SearchResultsScreen extends StatelessWidget {
  final String city;
  final Map<String, bool> propertyTypes;
  final RangeValues priceRange;
  final RangeValues ratingRange;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int adults;
  final int children;
  final Map<String, bool> services;

  const SearchResultsScreen({
    super.key,
    required this.city,
    required this.propertyTypes,
    required this.priceRange,
    required this.ratingRange,
    required this.dateFrom,
    required this.dateTo,
    required this.adults,
    required this.children,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Results"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("City: $city"),
            Text("Property Types: ${propertyTypes.entries.where((e) => e.value).map((e) => e.key).join(', ')}"),
            Text("Price Range: ${priceRange.start.toInt()} - ${priceRange.end.toInt()}"),
            Text("Rating Range: ${ratingRange.start} - ${ratingRange.end}"),
            Text("Date From: ${dateFrom != null ? "${dateFrom!.day}/${dateFrom!.month}/${dateFrom!.year}" : "Not selected"}"),
            Text("Date To: ${dateTo != null ? "${dateTo!.day}/${dateTo!.month}/${dateTo!.year}" : "Not selected"}"),
            Text("Guests: $adults Adults, $children Children"),
            Text("Services: ${services.entries.where((e) => e.value).map((e) => e.key).join(', ')}"),
          ],
        ),
      ),
    );
  }
}
