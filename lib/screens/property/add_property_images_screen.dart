import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/common/app_button.dart';
import '../../models/property.dart';
import '../../models/property_image.dart';
import '../../providers/property_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/api_provider.dart';
import '../../utils/constants.dart';

class AddPropertyImagesScreen extends ConsumerStatefulWidget {
  final Property property;

  const AddPropertyImagesScreen({
    super.key,
    required this.property,
  });

  @override
  ConsumerState<AddPropertyImagesScreen> createState() =>
      _AddPropertyImagesScreenState();
}

class _AddPropertyImagesScreenState
    extends ConsumerState<AddPropertyImagesScreen> {
  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        if (mounted) {
          setState(() {
            _selectedImages.add(imageFile);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to pick image: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Log detailed information about the images
      for (int i = 0; i < _selectedImages.length; i++) {
        final file = _selectedImages[i];
        final fileSize = await file.length();
        final fileExists = await file.exists();
        final fileExtension = file.path.split('.').last.toLowerCase();

        debugPrint('Image $i details:');
        debugPrint('  - Path: ${file.path}');
        debugPrint('  - Size: $fileSize bytes');
        debugPrint('  - File exists: $fileExists');
        debugPrint('  - File extension: $fileExtension');
      }

      // Upload images one by one
      final List<PropertyImage> uploadedImages = [];

      // Get the auth token
      final authState = ref.read(authProvider);
      if (authState.token == null) {
        throw Exception('You must be logged in to upload images');
      }

      final propertyService = ref.read(propertyServiceProvider);
      final imageUploadService = ref.read(imageUploadServiceProvider);

      // Get the property ID from the widget
      int propertyId = widget.property.id;

      // Log the property ID for debugging
      debugPrint('Using property ID: $propertyId');

      // Validate the property ID
      if (propertyId <= 0) {
        throw Exception(
            'Invalid property ID: $propertyId. Please create a property first.');
      }

      // Now upload images with the valid property ID
      for (final imageFile in _selectedImages) {
        try {
          // Try different upload methods
          String? imageUrl;

          // First try the URL parameter approach
          debugPrint('Trying URL parameter approach');
          imageUrl = await imageUploadService.uploadImageWithUrlParam(
            propertyId,
            imageFile,
            authState.token!,
          );

          // If that fails, try the simple approach with no field name
          if (imageUrl == null) {
            debugPrint(
                'URL parameter approach failed, trying simple approach with no field name');
            imageUrl = await imageUploadService.uploadImageSimple(
              propertyId,
              imageFile,
              authState.token!,
            );
          }

          // If that fails, try the form-data approach with multiple field names
          if (imageUrl == null) {
            debugPrint(
                'Simple approach failed, trying form-data approach with multiple field names');
            imageUrl = await imageUploadService.uploadImageFormData(
              propertyId,
              imageFile,
              authState.token!,
            );
          }

          // If that fails, try the direct approach
          if (imageUrl == null) {
            debugPrint('Form-data approach failed, trying direct approach');
            imageUrl = await imageUploadService.uploadImageDirect(
              propertyId,
              imageFile,
              authState.token!,
            );
          }

          // If that also fails, try the original approach
          if (imageUrl == null) {
            debugPrint(
                'Direct approach failed, trying original approach with multiple field names');

            // List of common field names to try
            final fieldNames = ['file', 'image', 'photo', 'picture'];

            for (final fieldName in fieldNames) {
              try {
                debugPrint('Attempting upload with field name: $fieldName');
                imageUrl = await propertyService.uploadSingleImage(
                  propertyId,
                  imageFile,
                  authState.token!,
                  fieldName,
                );

                if (imageUrl != null) {
                  debugPrint('Upload successful with field name: $fieldName');
                  break; // Exit the loop if upload is successful
                }
              } catch (e) {
                debugPrint('Upload failed with field name $fieldName: $e');
                // Continue to the next field name
              }
            }
          }

          if (imageUrl != null) {
            uploadedImages.add(PropertyImage(
              id: 0, // Will be assigned by the server
              propertyId: propertyId,
              imageUrl: imageUrl,
              isPrimary: uploadedImages.isEmpty, // First image is primary
              createdAt: DateTime.now().toIso8601String(),
            ));

            debugPrint('Image uploaded successfully: $imageUrl');
          }
        } catch (e) {
          debugPrint('Error uploading image: $e');
          // Continue with other images even if one fails
        }
      }

      if (uploadedImages.isNotEmpty) {
        // Refresh property details to show new images
        await ref
            .read(propertyProvider.notifier)
            .fetchPropertyById(widget.property.id.toString());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${uploadedImages.length} images uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to upload any images');
      }
    } catch (e) {
      debugPrint('Error in _uploadImages: $e');

      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to upload images: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload images: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
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
        title: const Text('Add Property Images'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Images to ${widget.property.title}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Select images to upload to your property listing. The first image will be set as the primary image.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 24),

            // Image selection button
            AppButton(
              text: 'Select Images',
              onPressed: _pickImage,
              type: ButtonType.outline,
              icon: Icons.photo_library,
              isFullWidth: true,
            ),
            const SizedBox(height: 16),

            // Display selected images
            if (_selectedImages.isNotEmpty) ...[
              const Text(
                'Selected Images:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImages[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
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
                      if (index == 0)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Primary',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Upload button
            AppButton(
              text: 'Upload Images',
              onPressed: _uploadImages,
              isLoading: _isLoading,
              isFullWidth: true,
            ),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
