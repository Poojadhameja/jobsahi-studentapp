/// Job Application Step 1 Screen

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import 'job_step2.dart';

class JobStep1Screen extends StatefulWidget {
  /// Job data for the application
  final Map<String, dynamic> job;

  const JobStep1Screen({
    super.key,
    required this.job,
  });

  @override
  State<JobStep1Screen> createState() => _JobStep1ScreenState();
}

class _JobStep1ScreenState extends State<JobStep1Screen> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  /// Text editing controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  
  /// Whether the form is being submitted
  bool _isSubmitting = false;

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
    _experienceController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(
        title: 'Application Step 1',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job information header
                _buildJobHeader(),
                const SizedBox(height: AppConstants.largePadding),
                
                // Progress indicator
                _buildProgressIndicator(),
                const SizedBox(height: AppConstants.largePadding),
                
                // Form fields
                _buildFormFields(),
                const SizedBox(height: AppConstants.largePadding),
                
                // Next button
                _buildNextButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Loads user data into form fields
  void _loadUserData() {
    // TODO: Load from user data service
    _nameController.text = 'Rahul Kumar';
    _emailController.text = 'rahul.kumar@email.com';
    _phoneController.text = '+91 98765 43210';
    _experienceController.text = '2 years';
    _educationController.text = '12th Pass';
  }

  /// Builds the job information header
  Widget _buildJobHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.job['title'] ?? 'Job Title',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.job['company'] ?? 'Company Name',
            style: const TextStyle(
              color: AppConstants.successColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.job['location'] ?? 'Location',
            style: const TextStyle(
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the progress indicator
  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1 of 3',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        LinearProgressIndicator(
          value: 0.33,
          backgroundColor: AppConstants.backgroundColor,
          valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        const Text(
          'Basic Information',
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  /// Builds the form fields
  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
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

  /// Builds the next button
  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _goToNextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Goes to the next step
  void _goToNextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate processing
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isSubmitting = false;
        });
        
        // Navigate to next step
        NavigationService.navigateTo(JobStep2Screen(job: widget.job));
      });
    }
  }
}
