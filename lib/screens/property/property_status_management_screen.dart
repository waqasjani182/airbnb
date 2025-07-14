import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/common/app_text_field.dart';
import '../../models/property2.dart';
import '../../models/property_status.dart' as status_models;
import '../../providers/property_provider2.dart';
import '../../utils/constants.dart';

class PropertyStatusManagementScreen extends ConsumerStatefulWidget {
  final Property2 property;

  const PropertyStatusManagementScreen({
    super.key,
    required this.property,
  });

  @override
  ConsumerState<PropertyStatusManagementScreen> createState() =>
      _PropertyStatusManagementScreenState();
}

class _PropertyStatusManagementScreenState
    extends ConsumerState<PropertyStatusManagementScreen> {
  final _maintenanceReasonController = TextEditingController();
  status_models.PropertyStatus? _currentStatus;
  bool _isLoading = false;
  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    _loadPropertyStatus();
  }

  @override
  void dispose() {
    _maintenanceReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadPropertyStatus() async {
    setState(() {
      _isLoadingStatus = true;
    });

    try {
      final status =
          await ref.read(propertyProvider2.notifier).getPropertyStatus(
                widget.property.propertyId,
              );

      setState(() {
        _currentStatus = status;
        if (status.maintenanceReason != null) {
          _maintenanceReasonController.text = status.maintenanceReason!;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load property status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStatus = false;
        });
      }
    }
  }

  Future<void> _setMaintenance() async {
    if (_maintenanceReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a maintenance reason'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await ref.read(propertyProvider2.notifier).setPropertyMaintenance(
                propertyId: widget.property.propertyId,
                maintenanceReason: _maintenanceReasonController.text.trim(),
              );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        // Reload status
        await _loadPropertyStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set maintenance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _activateProperty() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await ref.read(propertyProvider2.notifier).activateProperty(
                widget.property.propertyId,
              );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        // Reload status
        await _loadPropertyStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to activate property: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePropertyStatus(bool isActive) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await ref.read(propertyProvider2.notifier).togglePropertyStatus(
                propertyId: widget.property.propertyId,
                isActive: isActive,
              );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        // Reload status
        await _loadPropertyStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle property status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Status Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingStatus
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Info
                  _buildPropertyInfo(),
                  const SizedBox(height: 24),

                  // Current Status Section
                  _buildCurrentStatusSection(),
                  const SizedBox(height: 24),

                  // Status Controls Section
                  _buildStatusControlsSection(),
                  const SizedBox(height: 24),

                  // Maintenance Section
                  if (_currentStatus?.isInMaintenance == true) ...[
                    _buildMaintenanceSection(),
                    const SizedBox(height: 24),
                  ],

                  // Maintenance Controls
                  _buildMaintenanceControls(),
                  const SizedBox(height: 24),

                  // Guidelines
                  _buildGuidelines(),
                ],
              ),
            ),
    );
  }

  Widget _buildPropertyInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: Row(
        children: [
          if (widget.property.images.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
              child: Image.network(
                widget.property.images.first.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  );
                },
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: const Icon(Icons.home),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.property.address,
                  style: const TextStyle(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusSection() {
    if (_currentStatus == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getStatusColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(color: _getStatusColor()),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _currentStatus!.statusDisplayText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _currentStatus!.statusDescription,
                style: const TextStyle(
                  color: AppColors.text,
                ),
              ),
              if (_currentStatus!.isInMaintenance &&
                  _currentStatus!.maintenanceReason != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Reason: ${_currentStatus!.maintenanceReason}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusControlsSection() {
    if (_currentStatus == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Controls',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 16),

        // Enable/Disable Toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Property Visibility',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentStatus!.isActive
                          ? 'Property is visible to guests'
                          : 'Property is hidden from guests',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _currentStatus!.isActive,
                onChanged:
                    _isLoading ? null : (value) => _togglePropertyStatus(value),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Maintenance Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(color: Colors.orange),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.build, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Under Maintenance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'This property is currently under maintenance and not accepting bookings.',
                style: TextStyle(color: AppColors.text),
              ),
              if (_currentStatus!.maintenanceReason != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Reason: ${_currentStatus!.maintenanceReason}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _activateProperty(),
                icon: const Icon(Icons.check_circle),
                label: const Text('Activate Property'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Maintenance Controls',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _maintenanceReasonController,
          label: 'Maintenance Reason',
          maxLines: 3,
          hint:
              'Enter the reason for putting this property under maintenance...',
        ),
        const SizedBox(height: 16),
        if (_currentStatus?.isInMaintenance != true)
          OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _setMaintenance(),
            icon: const Icon(Icons.build),
            label: const Text('Set to Maintenance'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGuidelines() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Status Guidelines:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Active: Property is visible and accepting bookings\n'
            '• Disabled: Property is hidden from search results\n'
            '• Maintenance: Property is temporarily unavailable\n'
            '• Use maintenance mode for repairs or renovations\n'
            '• Disabled properties can still be viewed by direct link\n'
            '• Maintenance properties cannot accept new bookings',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_currentStatus == null) return Colors.grey;

    if (_currentStatus!.isInMaintenance) {
      return Colors.orange;
    } else if (!_currentStatus!.isActive) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  IconData _getStatusIcon() {
    if (_currentStatus == null) return Icons.help;

    if (_currentStatus!.isInMaintenance) {
      return Icons.build;
    } else if (!_currentStatus!.isActive) {
      return Icons.visibility_off;
    } else {
      return Icons.check_circle;
    }
  }
}
