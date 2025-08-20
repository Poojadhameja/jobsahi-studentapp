/// Job Application Step 3 Screen

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import '../home/home.dart';

class JobStep3Screen extends StatefulWidget {
  /// Job data for the application
  final Map<String, dynamic> job;

  const JobStep3Screen({
    super.key,
    required this.job,
  });

  @override
  State<JobStep3Screen> createState() => _JobStep3ScreenState();
}

class _JobStep3ScreenState extends State<JobStep3Screen> {
  /// Whether the application is being submitted
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(
        title: 'Application Step 3',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job information header
              _buildJobHeader(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Progress indicator
              _buildProgressIndicator(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Review section
              _buildReviewSection(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Submit button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
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
          'Step 3 of 3',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        LinearProgressIndicator(
          value: 1.0,
          backgroundColor: AppConstants.backgroundColor,
          valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        const Text(
          'Review & Submit',
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  /// Builds the review section
  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Your Application',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Personal information
        _buildReviewCard(
          title: 'Personal Information',
          items: [
            'Name: Rahul Kumar',
            'Email: rahul.kumar@email.com',
            'Phone: +91 98765 43210',
            'Experience: 2 years',
            'Education: 12th Pass',
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Additional information
        _buildReviewCard(
          title: 'Additional Information',
          items: [
            'Skills: Electrician, Basic Electronics, Safety Protocols',
            'Cover Letter: I am interested in this position...',
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Terms and conditions
        _buildTermsAndConditions(),
      ],
    );
  }

  /// Builds a review card
  Widget _buildReviewCard({
    required String title,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              item,
              style: const TextStyle(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          )),
        ],
      ),
    );
  }

  /// Builds the terms and conditions section
  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms & Conditions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          const Text(
            'By submitting this application, you agree to our terms and conditions. Your information will be shared with the employer for evaluation purposes.',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitApplication,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.secondaryColor,
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
                'Submit Application',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Submits the application
  void _submitApplication() {
    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isSubmitting = false;
      });

      // Show success dialog
      _showSuccessDialog();
    });
  }

  /// Shows success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Application Submitted!'),
        content: const Text(
          'Your job application has been submitted successfully. You will receive a confirmation email shortly.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to home screen
               NavigationService.smartNavigate(destination: const HomeScreen());
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
