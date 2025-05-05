import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/common/app_button.dart';
import '../../components/common/app_text_field.dart';
import '../../models/property.dart';
import '../../models/property_amenity.dart';
import '../../models/amenity.dart';
import '../../providers/property_provider.dart';
import '../../providers/amenity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/amenity_converter.dart';

class UploadPropertyScreen extends ConsumerStatefulWidget {
  const UploadPropertyScreen({super.key});

  @override
  ConsumerState<UploadPropertyScreen> createState() =>
      _UploadPropertyScreenState();
}

class _UploadPropertyScreenState extends ConsumerState<UploadPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for form fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _maxGuestsController = TextEditingController();

  String _selectedPropertyType = 'apartment';
  final List<String> _propertyTypes = [
    'apartment',
    'house',
    'villa',
    'cabin',
    'hotel',
    'other',
  ];

  final List<int> _selectedAmenityIds = [];
  List<Amenity> _availableAmenities = [];

  // Image selection
  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _isLoadingAmenities = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch amenities when the screen loads, but use Future.microtask to avoid
    // modifying the provider during widget initialization
    Future.microtask(() => _fetchAmenities());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _maxGuestsController.dispose();
    super.dispose();
  }

  Future<void> _fetchAmenities() async {
    if (!mounted) return;

    setState(() {
      _isLoadingAmenities = true;
    });

    try {
      // Wrap the provider update in a Future to ensure it happens after the widget tree is built
      await Future(() async {
        await ref.read(amenityProvider.notifier).fetchAmenities();
      });

      // Only read the state after the Future completes
      if (!mounted) return;
      final amenityState = ref.read(amenityProvider);

      setState(() {
        _availableAmenities = amenityState.amenities;
        _isLoadingAmenities = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load amenities: ${e.toString()}';
        _isLoadingAmenities = false;
      });
    }
  }

  void _toggleAmenity(int amenityId) {
    setState(() {
      if (_selectedAmenityIds.contains(amenityId)) {
        _selectedAmenityIds.remove(amenityId);
      } else {
        _selectedAmenityIds.add(amenityId);
      }
    });
  }

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

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _uploadProperty() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Check if images are selected
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one image for your property'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check authentication status
      final authState = ref.read(authProvider);
      if (authState.token == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'You must be logged in to upload a property';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You must be logged in to upload a property'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      debugPrint('Authentication check passed, token available');

      try {
        // Log the start of the upload process
        debugPrint('Starting property upload process with images');

        // Create property amenities from selected amenity IDs
        final List<PropertyAmenity> amenities = _selectedAmenityIds.map((id) {
          // Find the amenity in the available amenities list
          final amenity = _availableAmenities.firstWhere(
            (a) => a.id == id,
            orElse: () => Amenity(
              id: id,
              name: 'Unknown',
              icon: 'default_icon',
              createdAt: DateTime.now().toIso8601String(),
            ),
          );
          // Convert Amenity to PropertyAmenity using the converter
          return AmenityConverter.toPropertyAmenity(amenity);
        }).toList();

        debugPrint('Selected amenities: ${amenities.length}');
        debugPrint('Selected images: ${_selectedImages.length}');

        // Create property object
        final property = Property(
          id: 0, // Will be assigned by the server
          hostId: 0, // Will be assigned by the server
          title: _titleController.text,
          description: _descriptionController.text,
          address: _addressController.text,
          city: _cityController.text,
          state: _stateController.text,
          country: _countryController.text,
          zipCode: _zipCodeController.text,
          latitude: 0.0, // Would need to be determined from address
          longitude: 0.0, // Would need to be determined from address
          pricePerNight: double.parse(_priceController.text),
          bedrooms: int.parse(_bedroomsController.text),
          bathrooms: int.parse(_bathroomsController.text),
          maxGuests: int.parse(_maxGuestsController.text),
          propertyType: _selectedPropertyType,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          hostFirstName: '', // Will be filled by the server
          hostLastName: '', // Will be filled by the server
          images: [], // Images will be uploaded with the property
          amenities: amenities,
          reviews: [],
        );

        debugPrint('Property object created');

        // Create the property with images in a single request
        debugPrint('Creating property with images in one request');
        final createdProperty = await ref
            .read(propertyProvider.notifier)
            .createPropertyWithImagesInOneRequest(
              property: property,
              imageFiles: _selectedImages,
            );

        // Log detailed information about the created property
        debugPrint(
            'Property created successfully with ID: ${createdProperty.id}');
        debugPrint('Created property details:');
        debugPrint('  - Title: ${createdProperty.title}');
        debugPrint('  - ID: ${createdProperty.id}');
        debugPrint('  - Host ID: ${createdProperty.hostId}');
        debugPrint('  - Created At: ${createdProperty.createdAt}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Property created successfully with images!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to the previous screen or to a property details screen
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint('Error in _uploadProperty: $e');

        if (mounted) {
          // Extract the most relevant part of the error message
          String errorMsg = e.toString();
          String detailedError = 'Unknown error';

          // Clean up the error message for display
          if (errorMsg.contains('Exception:')) {
            errorMsg = errorMsg.replaceAll('Exception:', '').trim();
          }

          // Further clean up nested exceptions
          if (errorMsg
              .contains('Error creating property with images: Exception:')) {
            errorMsg = errorMsg
                .replaceAll(
                    'Error creating property with images: Exception:', '')
                .trim();
          }

          // Check for specific error patterns and provide more detailed diagnostics
          if (errorMsg.contains('Cannot destructure property')) {
            debugPrint('Detected API format error');
            errorMsg =
                'Server error: The property data format is incorrect. Please try again.';
            detailedError =
                'API response format mismatch. The server returned data in an unexpected format.';
          } else if (errorMsg.contains('Failed to upload') ||
              errorMsg.contains('image')) {
            debugPrint('Detected image upload error');
            errorMsg =
                'Failed to upload images. Please try again with smaller or fewer images.';
            detailedError =
                'Image upload failed. This could be due to large file sizes, unsupported formats, or server limitations.';
          } else if (errorMsg.contains('Connection refused') ||
              errorMsg.contains('Failed host lookup')) {
            debugPrint('Detected network connectivity error');
            errorMsg =
                'Network error: Cannot connect to the server. Please check your internet connection.';
            detailedError =
                'Network connectivity issue. The app cannot reach the server.';
          } else if (errorMsg.contains('Unauthorized') ||
              errorMsg.contains('401')) {
            debugPrint('Detected authentication error');
            errorMsg =
                'Authentication error: Your session may have expired. Please log in again.';
            detailedError =
                'Authentication failed. The server rejected the authentication token.';
          } else if (errorMsg.contains('timeout') ||
              errorMsg.contains('timed out')) {
            debugPrint('Detected timeout error');
            errorMsg =
                'Request timed out. The server took too long to respond.';
            detailedError =
                'Network timeout. The request took too long to complete.';
          }

          // Log the cleaned error message and detailed diagnostics
          debugPrint('Cleaned error message: $errorMsg');
          debugPrint('Detailed diagnostics: $detailedError');

          // Set the error message for display
          setState(() {
            _errorMessage = '$errorMsg\n\nDiagnostic details: $detailedError';
          });

          // Show a snackbar with the error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Failed to upload property: $errorMsg'),
                  const SizedBox(height: 4),
                  Text(
                    'Diagnostic details: $detailedError',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration:
                  const Duration(seconds: 15), // Show longer for error messages
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Property'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Property Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              AppTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter property title',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),

              // Description
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter property description',
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              const SizedBox(height: 16),

              // Price
              AppTextField(
                controller: _priceController,
                label: 'Price per Night',
                hint: 'Enter price',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a price'
                    : null,
              ),
              const SizedBox(height: 16),

              // Property Type
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Property Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedPropertyType,
                    decoration: InputDecoration(
                      hintText: 'Select property type',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppBorderRadius.medium),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _propertyTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type.substring(0, 1).toUpperCase() +
                            type.substring(1)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPropertyType = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Address fields
              const Text(
                'Address Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Address
              AppTextField(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter property address',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter an address'
                    : null,
              ),
              const SizedBox(height: 16),

              // City
              AppTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Enter city',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a city'
                    : null,
              ),
              const SizedBox(height: 16),

              // State
              AppTextField(
                controller: _stateController,
                label: 'State/Province',
                hint: 'Enter state or province',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a state or province'
                    : null,
              ),
              const SizedBox(height: 16),

              // Country
              AppTextField(
                controller: _countryController,
                label: 'Country',
                hint: 'Enter country',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a country'
                    : null,
              ),
              const SizedBox(height: 16),

              // Zip Code
              AppTextField(
                controller: _zipCodeController,
                label: 'Zip/Postal Code',
                hint: 'Enter zip or postal code',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a zip or postal code'
                    : null,
              ),
              const SizedBox(height: 24),

              // Property details
              const Text(
                'Property Specifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Bedrooms
              AppTextField(
                controller: _bedroomsController,
                label: 'Bedrooms',
                hint: 'Number of bedrooms',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter number of bedrooms'
                    : null,
              ),
              const SizedBox(height: 16),

              // Bathrooms
              AppTextField(
                controller: _bathroomsController,
                label: 'Bathrooms',
                hint: 'Number of bathrooms',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter number of bathrooms'
                    : null,
              ),
              const SizedBox(height: 16),

              // Max Guests
              AppTextField(
                controller: _maxGuestsController,
                label: 'Maximum Guests',
                hint: 'Maximum number of guests',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter maximum number of guests'
                    : null,
              ),
              const SizedBox(height: 24),

              // Note about images
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Images',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You will be able to add images to your property after creating it.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amenities
              const Text(
                'Amenities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Display amenities for selection
              _isLoadingAmenities
                  ? const Center(child: CircularProgressIndicator())
                  : _availableAmenities.isEmpty
                      ? const Text('No amenities available')
                      : Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _availableAmenities.map((amenity) {
                            final isSelected =
                                _selectedAmenityIds.contains(amenity.id);
                            return FilterChip(
                              label: Text(amenity.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                _toggleAmenity(amenity.id);
                              },
                              backgroundColor: Colors.white,
                              selectedColor: AppColors.primary.withAlpha(50),
                              checkmarkColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppBorderRadius.small),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
              const SizedBox(height: 32),

              // Images section
              const SizedBox(height: 24),
              const Text(
                'Property Images',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Select images for your property. The first image will be the primary image shown in listings.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),

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
                            onTap: () => _removeImage(index),
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

              // Submit button
              AppButton(
                text: 'Upload Property',
                onPressed: _uploadProperty,
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
      ),
    );
  }
}
