import 'package:flutter/material.dart';
import '../../models/property2.dart';
import '../../utils/constants.dart';

class UserPropertyManagementSection extends StatelessWidget {
  final Property2 property;

  const UserPropertyManagementSection({
    super.key,
    required this.property,
  });

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: backgroundColor?.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color:
                      (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.medium,
            horizontal: AppSpacing.small,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(
              color: (color ?? AppColors.primary).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color ?? AppColors.primary,
                size: 24,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Management',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppSpacing.medium),

        // Quick Actions - First Row
        Row(
          children: [
            Expanded(
              child: _buildQuickAction(
                label: 'Edit Details',
                icon: Icons.edit,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.editProperty,
                    arguments: property,
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: _buildQuickAction(
                label: 'Manage Photos',
                icon: Icons.photo_library,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.managePropertyImages,
                    arguments: property,
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: _buildQuickAction(
                label: 'Status Control',
                icon: Icons.settings,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.propertyStatusManagement,
                    arguments: property,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
