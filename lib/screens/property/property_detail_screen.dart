import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/property_provider2.dart';
import '../../components/property/property_image_gallery.dart';
import '../../components/property/property_info_section.dart';
import '../../components/property/property_features_section.dart';
import '../../components/property/property_reviews_section.dart';
import '../../components/property/property_booking_section.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String? propertyId;

  const PropertyDetailScreen({super.key, this.propertyId});

  @override
  ConsumerState<PropertyDetailScreen> createState() =>
      _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.propertyId != null) {
      Future.microtask(() => ref
          .read(propertyProvider2.notifier)
          .fetchPropertyById(widget.propertyId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyProvider2);
    final property = propertyState.selectedProperty;
    final isLoading = propertyState.isLoading;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (property == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property Details')),
        body: const Center(child: Text('Property not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Property Image Gallery
          PropertyImageGallery(property: property),

          // Property Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Information Section
                  PropertyInfoSection(property: property),

                  const Divider(height: 32),

                  // Property Features Section
                  PropertyFeaturesSection(property: property),

                  const Divider(height: 32),

                  // Property Reviews Section
                  PropertyReviewsSection(property: property),

                  const Divider(height: 32),

                  // Property Booking Section
                  PropertyBookingSection(property: property),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
