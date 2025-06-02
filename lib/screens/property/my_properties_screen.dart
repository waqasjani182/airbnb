import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_property.dart';
import '../../providers/user_properties_provider.dart';
import '../../utils/constants.dart';
import '../../components/common/app_button.dart';

class MyPropertiesScreen extends ConsumerStatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  ConsumerState<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends ConsumerState<MyPropertiesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user properties when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userPropertiesProvider.notifier).fetchUserProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userPropertiesState = ref.watch(userPropertiesProvider);
    final properties = userPropertiesState.properties;
    final isLoading = userPropertiesState.isLoading;
    final errorMessage = userPropertiesState.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Properties'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.uploadProperty);
            },
            tooltip: 'Add New Property',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(userPropertiesProvider.notifier).fetchUserProperties();
        },
        child: _buildBody(context, properties, isLoading, errorMessage),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<UserProperty> properties,
    bool isLoading,
    String? errorMessage,
  ) {
    if (isLoading && properties.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return _buildErrorState(context, errorMessage);
    }

    if (properties.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildPropertiesList(context, properties);
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
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
              'Error Loading Properties',
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
            AppButton(
              text: 'Retry',
              onPressed: () {
                ref.read(userPropertiesProvider.notifier).fetchUserProperties();
              },
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home_outlined,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'No Properties Yet',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'You haven\'t listed any properties yet. Start by adding your first property!',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            AppButton(
              text: 'Add Your First Property',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.uploadProperty);
              },
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesList(
      BuildContext context, List<UserProperty> properties) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        return _buildPropertyCard(context, property);
      },
    );
  }

  Widget _buildPropertyCard(BuildContext context, UserProperty property) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: InkWell(
        onTap: () {
          _navigateToPropertyDetails(context, property);
        },
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            _buildPropertyImage(property),
            // Property Details
            Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Type
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: AppTextStyles.heading3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.small,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.small),
                        ),
                        child: Text(
                          property.propertyType,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.small),
                  // Address
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          property.address,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.small),
                  // Price and Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${property.rentPerDay.toStringAsFixed(0)}/night',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Row(
                        children: [
                          _buildStatChip(
                            Icons.people_outline,
                            '${property.guest} guests',
                          ),
                          const SizedBox(width: AppSpacing.small),
                          _buildStatChip(
                            Icons.book_outlined,
                            '${property.bookingCount} bookings',
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (property.rating != null) ...[
                    const SizedBox(height: AppSpacing.small),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          property.rating!.toStringAsFixed(1),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyImage(UserProperty property) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppBorderRadius.large),
        topRight: Radius.circular(AppBorderRadius.large),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: property.primaryImage.isNotEmpty
            ? Image.network(
                property.primaryImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImagePlaceholder();
                },
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.home_outlined,
          size: 48,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.textLight,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPropertyDetails(BuildContext context, UserProperty property) {
    Navigator.pushNamed(
      context,
      '${AppRoutes.userPropertyDetails}/${property.propertyId}',
    );
  }
}
