import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/common/app_button.dart';
import '../../components/common/app_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/image_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _errorMessage;

  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      _errorMessage = null;
      _selectedImage = null; // Clear selected image when toggling edit mode
    });

    if (!_isEditing) {
      // Reset form if canceling edit
      final user = ref.read(authProvider).user;
      _firstNameController.text = user?.firstName ?? '';
      _lastNameController.text = user?.lastName ?? '';
      _emailController.text = user?.email ?? '';
      _phoneController.text = user?.phone ?? '';
      _addressController.text = user?.address ?? '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Upload the image immediately
        await _uploadImage();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploadingImage = true;
      _errorMessage = null;
    });

    try {
      // Use the ImageService from the provider
      final imageService = ref.read(imageServiceProvider);

      // Get the auth token
      final token = ref.read(authProvider).token;
      if (token == null) {
        throw Exception('Authentication token is missing');
      }

      // Upload the image
      final imageUrl =
          await imageService.uploadProfileImage(_selectedImage!, token);

      if (imageUrl.isEmpty) {
        throw Exception('Server returned an empty image URL');
      }

      // Update the user profile with the new image URL
      await ref.read(authProvider.notifier).updateProfileImage(imageUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile image updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Failed to upload image: ${e.toString().replaceAll('Exception: ', '')}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final currentUser = ref.read(authProvider).user;
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
          );

          await ref.read(authProvider.notifier).updateProfile(updatedUser);

          if (mounted) {
            setState(() {
              _isEditing = false;
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _toggleEditMode,
            child: Text(_isEditing ? 'Cancel' : 'Edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (user.profileImage != null
                              ? NetworkImage(user.profileImage!)
                              : null),
                      child:
                          (_selectedImage == null && user.profileImage == null)
                              ? const Icon(Icons.person, size: 50)
                              : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: _isUploadingImage
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // First Name
              AppTextField(
                controller: _firstNameController,
                label: 'First Name',
                hint: 'Enter your first name',
                enabled: _isEditing,
                prefixIcon: Icons.person_outline,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your first name'
                    : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Last Name
              AppTextField(
                controller: _lastNameController,
                label: 'Last Name',
                hint: 'Enter your last name',
                enabled: _isEditing,
                prefixIcon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Email
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                enabled: _isEditing,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),

              // Phone
              AppTextField(
                controller: _phoneController,
                label: 'Phone',
                hint: 'Enter your phone number',
                enabled: _isEditing,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 16),

              // Address
              AppTextField(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter your address',
                enabled: _isEditing,
                prefixIcon: Icons.home_outlined,
                maxLines: 3,
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

              const SizedBox(height: 24),

              // Save button
              if (_isEditing)
                AppButton(
                  text: 'Save Changes',
                  onPressed: _saveChanges,
                  isLoading: _isLoading,
                  isFullWidth: true,
                ),

              // Account info
              if (!_isEditing) ...[
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoItem('Account Type', user.isHost ? 'Host' : 'Guest'),
                _buildInfoItem('Member Since', _formatDate(user.createdAt)),
                _buildInfoItem('Account ID', '#${user.id}'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
