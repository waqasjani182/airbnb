import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/property_provider2.dart';
import '../../components/property/property_image_gallery.dart';
import '../../components/property/user_property_info_section.dart';
import '../../components/property/user_property_management_section.dart';
// import '../../components/property/user_property_analytics_section.dart';
import '../../components/property/property_features_section.dart';
import '../../components/property/property_reviews_section.dart';
import '../../utils/constants.dart';

class UserPropertyDetailScreen extends ConsumerStatefulWidget {
  final String? propertyId;

  const UserPropertyDetailScreen({super.key, this.propertyId});

  @override
  ConsumerState<UserPropertyDetailScreen> createState() =>
      _UserPropertyDetailScreenState();
}

class _UserPropertyDetailScreenState
    extends ConsumerState<UserPropertyDetailScreen> {
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
    final errorMessage = propertyState.errorMessage;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Property Details'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Error Loading Property',
                  style: AppTextStyles.heading3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  errorMessage,
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.large),
                ElevatedButton(
                  onPressed: () {
                    if (widget.propertyId != null) {
                      ref
                          .read(propertyProvider2.notifier)
                          .fetchPropertyById(widget.propertyId!);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (property == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Property Details'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Property not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Property Image Gallery with management overlay
          PropertyImageGallery(property: property),

          // Property Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Information Section (User-specific)
                  UserPropertyInfoSection(property: property),

                  const Divider(height: 32),

                  // Property Management Section
                  UserPropertyManagementSection(property: property),

                  const Divider(height: 32),

                  // Property Analytics Section
                  // UserPropertyAnalyticsSection(property: property),

                  // const Divider(height: 32),

                  // Property Features Section
                  PropertyFeaturesSection(property: property),

                  const Divider(height: 32),

                  // Property Reviews Section
                  PropertyReviewsSection(property: property),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     // TODO: Navigate to edit property screen
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text('Edit property feature coming soon!'),
      //       ),
      //     );
      //   },
      //   backgroundColor: AppColors.primary,
      //   foregroundColor: Colors.white,
      //   icon: const Icon(Icons.edit),
      //   label: const Text('Edit Property'),
      // ),
    );
  }
}
