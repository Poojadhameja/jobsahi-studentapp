import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../data/user_data.dart';
import '../../utils/navigation_service.dart';

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
      // appBar: const SimpleAppBar(title: 'Edit Profile', showBackButton: true),
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
        _buildStyledFormField(
          controller: _nameController,
          label: AppConstants.nameLabel,
          hint: 'Enter your full name',
          icon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.nameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Email
        _buildStyledFormField(
          controller: _emailController,
          label: AppConstants.emailLabel,
          hint: 'Enter your email address',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
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
        _buildStyledFormField(
          controller: _phoneController,
          label: AppConstants.phoneLabel,
          hint: 'Enter your phone number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
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
        _buildStyledFormField(
          controller: _locationController,
          label: 'Location',
          hint: 'Enter your location',
          icon: Icons.location_on,
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Experience
        _buildStyledFormField(
          controller: _experienceController,
          label: 'Experience',
          hint: 'Enter your experience',
          icon: Icons.work,
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Education
        _buildStyledFormField(
          controller: _educationController,
          label: 'Education',
          hint: 'Enter your education',
          icon: Icons.school,
        ),
      ],
    );
  }

  /// Builds a styled form field with consistent design
  Widget _buildStyledFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1E3A8A), // Dark blue color
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        // Input field
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF6B7280), // Medium grey color
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF1F5F9), // Light blue-grey background
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6), // Blue border when focused
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444), // Red border for errors
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF6B7280), // Medium grey icon color
              size: 20,
            ),
          ),
          style: const TextStyle(
            color: Color(0xFF1F2937), // Dark grey text color
            fontSize: 14,
          ),
          validator: validator,
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
          padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
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
            : Text(
                AppConstants.saveChangesText,
                style: AppConstants.buttonTextStyle,
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