import 'package:flutter/material.dart';
import '../../models/property2.dart';
import '../../utils/constants.dart';

class UserPropertyAnalyticsSection extends StatelessWidget {
  final Property2 property;

  const UserPropertyAnalyticsSection({
    super.key,
    required this.property,
  });

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    Color? color,
    String? trend,
    bool? isPositiveTrend,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(
          color: (color ?? AppColors.primary).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color ?? AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: color ?? AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ),
              if (trend != null) ...[
                Icon(
                  isPositiveTrend == true
                      ? Icons.trending_up
                      : isPositiveTrend == false
                          ? Icons.trending_down
                          : Icons.trending_flat,
                  size: 16,
                  color: isPositiveTrend == true
                      ? AppColors.success
                      : isPositiveTrend == false
                          ? AppColors.error
                          : AppColors.textLight,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  trend,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isPositiveTrend == true
                        ? AppColors.success
                        : isPositiveTrend == false
                            ? AppColors.error
                            : AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicator({
    required String label,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall,
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mock data - in real app, this would come from API
    final totalBookings = property.reviewCount; // Using review count as proxy
    final totalRevenue = (property.rentPerDay * totalBookings * 0.8).toInt();
    final occupancyRate =
        totalBookings > 0 ? (totalBookings / 30 * 100).clamp(0.0, 100.0) : 0.0;
    final responseRate = 95.0; // Mock data
    final guestSatisfaction =
        property.avgRating > 0 ? (property.avgRating / 5 * 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Analytics',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppSpacing.medium),

        // Key Metrics Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.medium,
          mainAxisSpacing: AppSpacing.medium,
          childAspectRatio: 1.1,
          children: [
            _buildMetricCard(
              title: 'Total Bookings',
              value: '$totalBookings',
              subtitle: 'All time',
              icon: Icons.book,
              color: AppColors.primary,
              trend: '+12%',
              isPositiveTrend: true,
            ),
            _buildMetricCard(
              title: 'Total Revenue',
              value: '\$${totalRevenue.toString()}',
              subtitle: 'All time',
              icon: Icons.attach_money,
              color: AppColors.success,
              trend: '+8%',
              isPositiveTrend: true,
            ),
            _buildMetricCard(
              title: 'Avg. Rating',
              value: property.avgRating > 0
                  ? property.avgRating.toStringAsFixed(1)
                  : 'N/A',
              subtitle: '${property.reviewCount} reviews',
              icon: Icons.star,
              color: AppColors.accent,
              trend: property.avgRating > 4.0 ? '+0.2' : null,
              isPositiveTrend: property.avgRating > 4.0,
            ),
            _buildMetricCard(
              title: 'Views',
              value: (totalBookings * 15).toString(), // Mock calculation
              subtitle: 'Last 30 days',
              icon: Icons.visibility,
              color: AppColors.secondary,
              trend: '+25%',
              isPositiveTrend: true,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.large),

        // Performance Indicators
        Container(
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance Indicators',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              _buildPerformanceIndicator(
                label: 'Occupancy Rate',
                percentage: occupancyRate,
                color: occupancyRate > 70
                    ? AppColors.success
                    : occupancyRate > 40
                        ? AppColors.accent
                        : AppColors.error,
              ),
              const SizedBox(height: AppSpacing.medium),
              _buildPerformanceIndicator(
                label: 'Response Rate',
                percentage: responseRate,
                color: responseRate > 90
                    ? AppColors.success
                    : responseRate > 70
                        ? AppColors.accent
                        : AppColors.error,
              ),
              const SizedBox(height: AppSpacing.medium),
              _buildPerformanceIndicator(
                label: 'Guest Satisfaction',
                percentage: guestSatisfaction,
                color: guestSatisfaction > 80
                    ? AppColors.success
                    : guestSatisfaction > 60
                        ? AppColors.accent
                        : AppColors.error,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.large),

        // Quick Insights
        Container(
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Text(
                    'Quick Insights',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              if (property.avgRating > 0) ...[
                _buildInsightItem(
                  'Your property has a ${property.avgRating.toStringAsFixed(1)}-star rating',
                  property.avgRating >= 4.5
                      ? 'Excellent!'
                      : property.avgRating >= 4.0
                          ? 'Good performance'
                          : 'Room for improvement',
                  property.avgRating >= 4.0 ? Icons.thumb_up : Icons.info,
                ),
              ],
              if (totalBookings > 0) ...[
                const SizedBox(height: AppSpacing.small),
                _buildInsightItem(
                  'You have $totalBookings total bookings',
                  totalBookings > 10 ? 'Great traction!' : 'Building momentum',
                  totalBookings > 10 ? Icons.trending_up : Icons.info,
                ),
              ],
              const SizedBox(height: AppSpacing.small),
              _buildInsightItem(
                'Property pricing is competitive',
                'Your \$${property.rentPerDay.toStringAsFixed(0)}/night rate is well-positioned',
                Icons.attach_money,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(String title, String subtitle, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 16,
        ),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
