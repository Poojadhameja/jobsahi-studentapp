import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../data/user_data.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Text editing controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();

  /// Whether the form is being saved
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(title: 'Edit Profile', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile image section
                _buildProfileImageSection(),
                const SizedBox(height: AppConstants.largePadding),

                // Form fields
                _buildFormFields(),
                const SizedBox(height: AppConstants.largePadding),

                // Save button
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Loads user data into form fields
  void _loadUserData() {
    final user = UserData.currentUser;
    _nameController.text = user['name'] ?? '';
    _emailController.text = user['email'] ?? '';
    _phoneController.text = user['phone'] ?? '';
    _locationController.text = user['location'] ?? '';
    _experienceController.text = user['experience'] ?? '';
    _educationController.text = user['education'] ?? '';
  }

  /// Builds the profile image section
  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          // Profile image
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(
                  UserData.currentUser['profileImage'] ??
                      AppConstants.defaultProfileImage,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppConstants.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),

          // Change photo button
          TextButton(
            onPressed: () {
              // TODO: Implement image picker
            },
            child: const Text(
              'Change Photo',
              style: TextStyle(
                color: AppConstants.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the form fields
  Widget _buildFormFields() {
    return Column(
      children: [
        // Full Name
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: AppConstants.nameLabel,
            hintText: 'Enter your full name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.nameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Email
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: AppConstants.emailLabel,
            hintText: 'Enter your email address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.email),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.emailRequired;
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return AppConstants.invalidEmail;
            }
            return null;
          },
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Phone Number
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: AppConstants.phoneLabel,
            hintText: 'Enter your phone number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.phone),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.phoneRequired;
            }
            if (value.length < 10) {
              return AppConstants.invalidPhone;
            }
            return null;
          },
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Location
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Location',
            hintText: 'Enter your location',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.location_on),
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Experience
        TextFormField(
          controller: _experienceController,
          decoration: InputDecoration(
            labelText: 'Experience',
            hintText: 'Enter your experience',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.work),
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Education
        TextFormField(
          controller: _educationController,
          decoration: InputDecoration(
            labelText: 'Education',
            hintText: 'Enter your education',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.school),
          ),
        ),
      ],
    );
  }

  /// Builds the save button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                AppConstants.saveChangesText,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// Saves the profile information
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isSaving = false;
        });

        // Show success message and go back
        _showSuccessSnackBar('Profile updated successfully');
        Future.delayed(const Duration(seconds: 1), () {
          NavigationService.goBack();
        });
      });
    }
  }

  /// Shows success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }
}
