import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/common/app_button.dart';
import '../../models/property2.dart';
import '../../providers/property_provider2.dart';
import '../../utils/constants.dart';

class PropertyImageManagementScreen extends ConsumerStatefulWidget {
  final Property2 property;

  const PropertyImageManagementScreen({
    super.key,
    required this.property,
  });

  @override
  ConsumerState<PropertyImageManagementScreen> createState() =>
      _PropertyImageManagementScreenState();
}

class _PropertyImageManagementScreenState
    extends ConsumerState<PropertyImageManagementScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  List<File> _newImages = [];
  bool _isLoading = false;

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _newImages.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickSingleImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _newImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _uploadSingleImage(File imageFile,
      {bool isPrimary = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final imageUrl =
          await ref.read(propertyProvider2.notifier).uploadSingleImage(
                imageFile: imageFile,
                propertyId: widget.property.propertyId,
                isPrimary: isPrimary,
              );

      if (imageUrl != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Remove the uploaded image from new images list
        setState(() {
          _newImages.remove(imageFile);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
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

  Future<void> _uploadMultipleImages() async {
    if (_newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No images to upload'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final imageUrls =
          await ref.read(propertyProvider2.notifier).uploadMultipleImages(
                imageFiles: _newImages,
                propertyId: widget.property.propertyId,
                setPrimary: widget.property.images
                    .isEmpty, // Set as primary if no existing images
              );

      if (imageUrls.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${imageUrls.length} images uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear the new images list
        setState(() {
          _newImages.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload images: $e'),
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
        title: const Text('Manage Property Images'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Info
                  _buildPropertyInfo(),
                  const SizedBox(height: 24),

                  // Current Images Section
                  _buildCurrentImagesSection(),
                  const SizedBox(height: 24),

                  // Add Images Section
                  _buildAddImagesSection(),
                  const SizedBox(height: 24),

                  // New Images Section
                  if (_newImages.isNotEmpty) ...[
                    _buildNewImagesSection(),
                    const SizedBox(height: 24),
                  ],

                  // Upload Actions
                  _buildUploadActions(),
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
                  '${widget.property.images.length} images',
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

  Widget _buildCurrentImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Images',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 16),
        if (widget.property.images.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No images uploaded yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: widget.property.images.length,
            itemBuilder: (context, index) {
              final image = widget.property.images[index];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    child: Image.network(
                      image.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.small),
                        ),
                        child: const Text(
                          'Primary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildAddImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add New Images',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Pick Single Image',
                onPressed: _pickSingleImage,
                type: ButtonType.outline,
                icon: Icons.photo,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppButton(
                text: 'Pick Multiple Images',
                onPressed: _pickImages,
                type: ButtonType.outline,
                icon: Icons.photo_library,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'New Images to Upload',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _newImages.length,
          itemBuilder: (context, index) {
            final imageFile = _newImages[index];
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  child: Image.file(
                    imageFile,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Remove button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeNewImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                // Upload single button
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () => _uploadSingleImage(
                      imageFile,
                      isPrimary: widget.property.images.isEmpty && index == 0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.circular(AppBorderRadius.small),
                      ),
                      child: const Icon(
                        Icons.upload,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildUploadActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 16),
        if (_newImages.isNotEmpty) ...[
          AppButton(
            text: 'Upload All Images (${_newImages.length})',
            onPressed: _uploadMultipleImages,
            isFullWidth: true,
            icon: Icons.cloud_upload,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 12),
          Text(
            'This will upload all ${_newImages.length} images using the dedicated multiple upload endpoint.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Add some images to see upload options',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            'Image Management Guidelines:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Maximum 10MB per image\n'
            '• Supported formats: JPG, PNG, GIF\n'
            '• Upload images individually or in batches\n'
            '• First image is automatically set as primary\n'
            '• Use dedicated endpoints for better performance\n'
            '• Images are added to existing ones (no replacement)',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
