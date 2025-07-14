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

class EditPropertyScreen extends ConsumerStatefulWidget {
  final Property2 property;

  const EditPropertyScreen({
    super.key,
    required this.property,
  });

  @override
  ConsumerState<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends ConsumerState<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxGuestsController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _totalRoomsController = TextEditingController();
  final _totalBedsController = TextEditingController();

  String _selectedPropertyType = 'House';
  List<Facility> _selectedFacilities = [];
  List<File> _newImages = [];
  List<String> _existingImageUrls = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _titleController.text = widget.property.title;
    _descriptionController.text = widget.property.description;
    _addressController.text = widget.property.address;
    _cityController.text = widget.property.city;
    _priceController.text = widget.property.rentPerDay.toString();
    _maxGuestsController.text = widget.property.guest.toString();
    _latitudeController.text = widget.property.latitude.toString();
    _longitudeController.text = widget.property.longitude.toString();
    _selectedPropertyType = widget.property.propertyType;
    _selectedFacilities = List.from(widget.property.facilities);
    _existingImageUrls =
        widget.property.images.map((img) => img.imageUrl).toList();

    // Initialize property type specific fields
    if (widget.property.totalBedrooms != null) {
      _bedroomsController.text = widget.property.totalBedrooms.toString();
    }
    if (widget.property.totalRooms != null) {
      _totalRoomsController.text = widget.property.totalRooms.toString();
    }
    if (widget.property.totalBeds != null) {
      _totalBedsController.text = widget.property.totalBeds.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _maxGuestsController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _bedroomsController.dispose();
    _totalRoomsController.dispose();
    _totalBedsController.dispose();
    super.dispose();
  }

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

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _onLocationSelected(double latitude, double longitude, String address) {
    setState(() {
      _latitudeController.text = latitude.toString();
      _longitudeController.text = longitude.toString();
      _addressController.text = address;
    });
  }

  Future<void> _updateProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_existingImageUrls.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated property object
      final updatedProperty = Property2(
        propertyId: widget.property.propertyId,
        userId: widget.property.userId,
        title: _titleController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        city: _cityController.text,
        propertyType: _selectedPropertyType,
        latitude: double.tryParse(_latitudeController.text) ?? 0.0,
        longitude: double.tryParse(_longitudeController.text) ?? 0.0,
        rentPerDay: double.parse(_priceController.text),
        guest: int.parse(_maxGuestsController.text),
        hostName: widget.property.hostName,
        rating: widget.property.rating,
        images: widget.property.images, // Will be updated by the service
        facilities: _selectedFacilities,
        reviews: widget.property.reviews,
        avgRating: widget.property.avgRating,
        reviewCount: widget.property.reviewCount,
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

      // Update property with images
      final result =
          await ref.read(propertyProvider2.notifier).updatePropertyWithImages(
                property: updatedProperty,
                imageFiles: _newImages,
                existingImageUrls:
                    _existingImageUrls.isNotEmpty ? _existingImageUrls : null,
              );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update property: $e'),
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
    final facilityState = ref.watch(facilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Property'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _titleController,
                      label: 'Property Title',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a property title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Property Type Section
                    _buildSectionTitle('Property Type'),
                    const SizedBox(height: 16),

                    _buildPropertyTypeSelector(),
                    const SizedBox(height: 16),

                    _buildPropertyTypeSpecificFields(),
                    const SizedBox(height: 24),

                    // Location Section
                    _buildSectionTitle('Location'),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _addressController,
                      label: 'Address',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _cityController,
                      label: 'City',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location Picker
                    SizedBox(
                      height: 200,
                      child: LocationPickerMap(
                        initialLatitude:
                            double.tryParse(_latitudeController.text) ?? 0.0,
                        initialLongitude:
                            double.tryParse(_longitudeController.text) ?? 0.0,
                        onLocationSelected: (lat, lng, address, city) =>
                            _onLocationSelected(lat, lng, address),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pricing and Capacity Section
                    _buildSectionTitle('Pricing & Capacity'),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _priceController,
                            label: 'Price per Day (RS)',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            controller: _maxGuestsController,
                            label: 'Max Guests',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter max guests';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Facilities Section
                    _buildSectionTitle('Facilities'),
                    const SizedBox(height: 16),

                    _buildFacilitiesSection(facilityState),
                    const SizedBox(height: 24),

                    // Images Section
                    _buildSectionTitle('Property Images'),
                    const SizedBox(height: 16),

                    _buildImagesSection(),
                    const SizedBox(height: 32),

                    // Update Button
                    AppButton(
                      text: 'Update Property',
                      onPressed: _updateProperty,
                      isFullWidth: true,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFacilitiesSection(FacilityState facilityState) {
    if (facilityState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (facilityState.facilities.isEmpty) {
      return const Text('No facilities available');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: facilityState.facilities.map((facility) {
        final isSelected =
            _selectedFacilities.any((f) => f.facilityId == facility.facilityId);

        return FilterChip(
          label: Text(facility.facilityType),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedFacilities.add(facility);
              } else {
                _selectedFacilities
                    .removeWhere((f) => f.facilityId == facility.facilityId);
              }
            });
          },
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primary,
        );
      }).toList(),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Images Button
        AppButton(
          text: 'Add New Images',
          onPressed: _pickImages,
          type: ButtonType.outline,
          icon: Icons.photo_library,
          isFullWidth: true,
        ),
        const SizedBox(height: 16),

        // Existing Images
        if (_existingImageUrls.isNotEmpty) ...[
          const Text(
            'Current Images:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _existingImageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _existingImageUrls[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeExistingImage(index),
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
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // New Images
        if (_newImages.isNotEmpty) ...[
          const Text(
            'New Images to Upload:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _newImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _newImages[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
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
                    ],
                  ),
                );
              },
            ),
          ),
        ],

        // Image Guidelines
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Image Guidelines:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '• Maximum 10MB per image\n'
                '• Supported formats: JPG, PNG, GIF\n'
                '• First image will be set as primary\n'
                '• All existing images will be replaced with new ones',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.text,
      ),
    );
  }

  Widget _buildPropertyTypeSelector() {
    final propertyTypes = ['House', 'Flat', 'Apartment', 'Room'];

    return DropdownButtonFormField<String>(
      value: _selectedPropertyType,
      decoration: const InputDecoration(
        labelText: 'Property Type',
        border: OutlineInputBorder(),
      ),
      items: propertyTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPropertyType = value;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a property type';
        }
        return null;
      },
    );
  }

  Widget _buildPropertyTypeSpecificFields() {
    switch (_selectedPropertyType) {
      case 'House':
        return AppTextField(
          controller: _bedroomsController,
          label: 'Number of Bedrooms',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter number of bedrooms';
            }
            return null;
          },
        );
      case 'Flat':
      case 'Apartment':
        return AppTextField(
          controller: _totalRoomsController,
          label: 'Total Rooms',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter total rooms';
            }
            return null;
          },
        );
      case 'Room':
        return AppTextField(
          controller: _totalBedsController,
          label: 'Total Beds',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter total beds';
            }
            return null;
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
