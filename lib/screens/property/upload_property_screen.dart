import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/common/app_button.dart';
import '../../components/common/app_text_field.dart';
import '../../components/map/location_picker_map.dart';
import '../../models/property2.dart';
import '../../models/facility.dart';
import '../../providers/property_provider2.dart';
import '../../providers/facility_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

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
  final _totalRoomsController = TextEditingController();
  final _totalBedsController = TextEditingController();
  final _latitudeController = TextEditingController(text: '0.0');
  final _longitudeController = TextEditingController(text: '0.0');

  String _selectedPropertyType = 'House';
  final List<String> _propertyTypes = [
    'House',
    'Flat',
    'Apartment',
    'Room',
  ];

  final List<int> _selectedFacilityIds = [];
  List<Facility> _availableFacilities = [];

  // Image selection
  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _isLoadingFacilities = false;
  String? _errorMessage;

  // Map state
  bool _isMapInitialized = false;

  @override
  void initState() {
    super.initState();
    // Fetch facilities when the screen loads, but use Future.microtask to avoid
    // modifying the provider during widget initialization
    Future.microtask(() {
      _fetchFacilities();
      _initializeMap();
    });
  }

  void _initializeMap() {
    setState(() {
      _isMapInitialized = true;
    });

    // If latitude and longitude are not set, try to use a default location
    if (_latitudeController.text == '0.0' &&
        _longitudeController.text == '0.0') {
      // Default to a central location (San Francisco)
      _latitudeController.text = '37.7749';
      _longitudeController.text = '-122.4194';
    }
  }

  // Method to update the map when coordinates are manually entered
  void _updateMapFromCoordinates() {
    // Validate the coordinates
    final latitude = double.tryParse(_latitudeController.text);
    final longitude = double.tryParse(_longitudeController.text);

    if (latitude == null || longitude == null) {
      // Show error message if coordinates are invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please enter valid latitude and longitude coordinates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Force rebuild of the map with new coordinates
    setState(() {
      _isMapInitialized = false;
    });

    // Use Future.delayed to ensure the state change has taken effect
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isMapInitialized = true;
        });
      }
    });
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
    _totalRoomsController.dispose();
    _totalBedsController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _fetchFacilities() async {
    if (!mounted) return;

    setState(() {
      _isLoadingFacilities = true;
    });

    try {
      // Wrap the provider update in a Future to ensure it happens after the widget tree is built
      await Future(() async {
        await ref.read(facilityProvider.notifier).fetchFacilities();
      });

      // Only read the state after the Future completes
      if (!mounted) return;
      final facilityState = ref.read(facilityProvider);

      setState(() {
        _availableFacilities = facilityState.facilities;
        _isLoadingFacilities = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load facilities: ${e.toString()}';
        _isLoadingFacilities = false;
      });
    }
  }

  void _toggleFacility(int facilityId) {
    setState(() {
      if (_selectedFacilityIds.contains(facilityId)) {
        _selectedFacilityIds.remove(facilityId);
      } else {
        _selectedFacilityIds.add(facilityId);
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      // Check if we already have 10 images
      if (_selectedImages.length >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Maximum 10 images allowed. Please remove some images first.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        List<File> newImages = [];

        for (var pickedFile in pickedFiles) {
          // Check if adding this image would exceed the limit
          if (_selectedImages.length + newImages.length >= 10) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Only ${10 - _selectedImages.length} more images can be added. Maximum 10 images allowed.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            break;
          }

          final imageFile = File(pickedFile.path);

          // Verify the file exists
          if (await imageFile.exists()) {
            debugPrint('Image selected: ${imageFile.path}');
            newImages.add(imageFile);
          } else {
            debugPrint('Selected image file does not exist: ${imageFile.path}');
          }
        }

        if (mounted && newImages.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(newImages);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${newImages.length} image(s) added successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to pick images: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to select images. Please try again.'),
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

  // Validate that all selected images exist and are accessible
  Future<bool> _validateImages() async {
    List<File> invalidImages = [];

    // Check maximum number of images (10 as per guide)
    if (_selectedImages.length > 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Maximum 10 images allowed. Please remove some images.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    for (var image in _selectedImages) {
      try {
        if (!await image.exists()) {
          debugPrint('Image does not exist: ${image.path}');
          invalidImages.add(image);
        } else {
          // Try to read the file to ensure it's accessible
          final fileSize = await image.length();
          debugPrint('Image validated: ${image.path} ($fileSize bytes)');

          // Check if file size is too large (> 10MB as per guide)
          if (fileSize > 10 * 1024 * 1024) {
            debugPrint('Image too large: ${image.path} ($fileSize bytes)');
            invalidImages.add(image);
          }

          // Check file extension for supported formats (JPG, JPEG, PNG, GIF)
          final extension = image.path.toLowerCase().split('.').last;
          if (!['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
            debugPrint('Unsupported image format: ${image.path}');
            invalidImages.add(image);
          }
        }
      } catch (e) {
        debugPrint('Error validating image ${image.path}: $e');
        invalidImages.add(image);
      }
    }

    if (invalidImages.isNotEmpty) {
      // Remove invalid images
      setState(() {
        _selectedImages.removeWhere((img) => invalidImages.contains(img));
      });

      // Show error message
      if (mounted) {
        String message =
            '${invalidImages.length} invalid image(s) were removed.';
        if (invalidImages.any((img) => img.path.contains('scaled_'))) {
          message +=
              ' The image picker may be creating temporary files that are being cleaned up.';
        }

        // Add specific reasons for removal
        if (invalidImages.any((img) {
          final extension = img.path.toLowerCase().split('.').last;
          return !['jpg', 'jpeg', 'png', 'gif'].contains(extension);
        })) {
          message +=
              ' Some images were removed due to unsupported format. Only JPG, JPEG, PNG, and GIF are allowed.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$message Please select new images.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      return _selectedImages
          .isNotEmpty; // Return true if we still have valid images
    }

    return true;
  }

  // Validate property type specific fields
  String? _validatePropertyTypeSpecificFields() {
    switch (_selectedPropertyType) {
      case 'House':
        if (_bedroomsController.text.isEmpty) {
          return 'Total bedrooms is required for House properties';
        }
        final bedrooms = int.tryParse(_bedroomsController.text);
        if (bedrooms == null || bedrooms <= 0) {
          return 'Total bedrooms must be greater than 0';
        }
        break;
      case 'Flat':
      case 'Apartment':
        if (_totalRoomsController.text.isEmpty) {
          return 'Total rooms is required for Flat/Apartment properties';
        }
        final rooms = int.tryParse(_totalRoomsController.text);
        if (rooms == null || rooms <= 0) {
          return 'Total rooms must be greater than 0';
        }
        break;
      case 'Room':
        if (_totalBedsController.text.isEmpty) {
          return 'Total beds is required for Room properties';
        }
        final beds = int.tryParse(_totalBedsController.text);
        if (beds == null || beds <= 0) {
          return 'Total beds must be greater than 0';
        }
        break;
    }
    return null;
  }

  Future<void> _uploadProperty() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate property type specific fields
      String? typeSpecificError = _validatePropertyTypeSpecificFields();
      if (typeSpecificError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(typeSpecificError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

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

      // Validate images before proceeding
      if (!await _validateImages()) {
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

        // Create facilities from selected facility IDs
        final List<Facility> facilities = _selectedFacilityIds.map((id) {
          // Find the facility in the available facilities list
          final facility = _availableFacilities.firstWhere(
            (f) => f.facilityId == id,
            orElse: () => Facility(
              facilityId: id,
              facilityType: 'Unknown',
            ),
          );
          // Return the facility
          return facility;
        }).toList();

        debugPrint('Selected facilities: ${facilities.length}');
        debugPrint('Selected images: ${_selectedImages.length}');

        // Create property object with property type specific fields
        final property = Property2(
          propertyId: 0, // Will be assigned by the server
          userId: 0, // Will be assigned by the server
          title: _titleController.text,
          description: _descriptionController.text,
          address: _addressController.text,
          city: _cityController.text,
          propertyType: _selectedPropertyType,
          latitude: double.tryParse(_latitudeController.text) ?? 0.0,
          longitude: double.tryParse(_longitudeController.text) ?? 0.0,
          rentPerDay: double.parse(_priceController.text),
          guest: int.parse(_maxGuestsController.text),
          hostName: '', // Will be filled by the server
          rating: 0.0, // Default value
          images: [], // Images will be uploaded with the property
          facilities: facilities,
          reviews: [],
          avgRating: 0.0, // Default value
          reviewCount: 0, // Default value
          // Property type specific fields based on the guide
          totalBedrooms: _selectedPropertyType == 'House'
              ? int.tryParse(_bedroomsController.text)
              : null,
          totalRooms: (_selectedPropertyType == 'Flat' ||
                  _selectedPropertyType == 'Apartment')
              ? int.tryParse(_totalRoomsController.text)
              : null,
          totalBeds: _selectedPropertyType == 'Room'
              ? int.tryParse(_totalBedsController.text)
              : null,
        );

        debugPrint('Property object created');

        // Create the property with images in a single request
        debugPrint('Creating property with images in one request');
        final createdProperty =
            await ref.read(propertyProvider2.notifier).createPropertyWithImages(
                  property: property,
                  imageFiles: _selectedImages,
                );

        // Log detailed information about the created property
        debugPrint(
            'Property created successfully with ID: ${createdProperty.propertyId}');
        debugPrint('Created property details:');
        debugPrint('  - Title: ${createdProperty.title}');
        debugPrint('  - ID: ${createdProperty.propertyId}');
        debugPrint('  - User ID: ${createdProperty.userId}');
        debugPrint('  - Host Name: ${createdProperty.hostName}');

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
              errorMsg.contains('image') ||
              errorMsg.contains('PathNotFoundException') ||
              errorMsg.contains('No such file or directory')) {
            debugPrint('Detected image upload error');
            errorMsg =
                'Failed to upload images. Please try again with different images.';
            detailedError =
                'Image upload failed. This could be due to temporary files being removed, large file sizes, or unsupported formats.';
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

  // Build property type specific fields based on selected property type
  Widget _buildPropertyTypeSpecificFields() {
    switch (_selectedPropertyType) {
      case 'House':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'House Specifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _bedroomsController,
              label: 'Total Bedrooms *',
              hint: 'Number of bedrooms',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Total bedrooms is required for House properties';
                }
                final bedrooms = int.tryParse(value);
                if (bedrooms == null || bedrooms <= 0) {
                  return 'Total bedrooms must be greater than 0';
                }
                return null;
              },
            ),
          ],
        );
      case 'Flat':
      case 'Apartment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_selectedPropertyType Specifications',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _totalRoomsController,
              label: 'Total Rooms *',
              hint: 'Total number of rooms',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Total rooms is required for $_selectedPropertyType properties';
                }
                final rooms = int.tryParse(value);
                if (rooms == null || rooms <= 0) {
                  return 'Total rooms must be greater than 0';
                }
                return null;
              },
            ),
          ],
        );
      case 'Room':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Room Specifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _totalBedsController,
              label: 'Total Beds *',
              hint: 'Total number of beds',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Total beds is required for Room properties';
                }
                final beds = int.tryParse(value);
                if (beds == null || beds <= 0) {
                  return 'Total beds must be greater than 0';
                }
                return null;
              },
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
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
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPropertyType = value!;
                        // Clear property type specific fields when type changes
                        _bedroomsController.clear();
                        _totalRoomsController.clear();
                        _totalBedsController.clear();
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

              // Map for location selection
              const Text(
                'Select Location on Map',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              _isMapInitialized
                  ? LocationPickerMap(
                      initialLatitude:
                          double.tryParse(_latitudeController.text) ?? 0.0,
                      initialLongitude:
                          double.tryParse(_longitudeController.text) ?? 0.0,
                      onLocationSelected: (latitude, longitude, address, city) {
                        setState(() {
                          _latitudeController.text = latitude.toString();
                          _longitudeController.text = longitude.toString();
                          _addressController.text = address;
                          _cityController.text = city;
                        });
                      },
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
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

              // Location coordinates
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _latitudeController,
                      label: 'Latitude',
                      hint: 'Property latitude',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                      ],
                      onChanged: (_) => _updateMapFromCoordinates(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _longitudeController,
                      label: 'Longitude',
                      hint: 'Property longitude',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                      ],
                      onChanged: (_) => _updateMapFromCoordinates(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppButton(
                text: 'Update Map from Coordinates',
                onPressed: _updateMapFromCoordinates,
                type: ButtonType.outline,
                icon: Icons.refresh,
                isFullWidth: true,
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

              // Property type specific fields
              _buildPropertyTypeSpecificFields(),
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

              // Amenities
              // const Text(
              //   'Amenities',
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(height: 16),

              // Display facilities for selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Facilities',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _fetchFacilities,
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _isLoadingFacilities
                      ? const Center(child: CircularProgressIndicator())
                      : _availableFacilities.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('No facilities available'),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap refresh to load facilities',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            )
                          : Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _availableFacilities.map((facility) {
                                final isSelected = _selectedFacilityIds
                                    .contains(facility.facilityId);
                                return FilterChip(
                                  label: Text(facility.facilityType),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    _toggleFacility(facility.facilityId);
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor:
                                      AppColors.primary.withAlpha(50),
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
                ],
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
                'Select images for your property (up to 10 images). The first image will be the primary image shown in listings. Supported formats: JPG, JPEG, PNG, GIF (max 10MB each).',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),

              // Image selection button
              if (_selectedImages.length >= 10)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library, color: Colors.grey.shade500),
                      const SizedBox(width: 8),
                      Text(
                        'Maximum Images Reached (10/10)',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              else
                AppButton(
                  text: 'Select Images (${_selectedImages.length}/10)',
                  onPressed: () => _pickImage(),
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
