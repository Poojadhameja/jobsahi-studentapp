/// Job Application Step 3 Screen

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import '../skill_test/skill_test_details.dart';
import '../home/home.dart';

class JobStep3Screen extends StatefulWidget {
  /// Job data for the application
  final Map<String, dynamic> job;

  const JobStep3Screen({super.key, required this.job});

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
        title: 'Job Application / नौकरी आवेदन',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: _buildMainCard(),
        ),
      ),
    );
  }

  /// Builds the main card containing all content
  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job overview section
          _buildJobOverviewSection(),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: AppConstants.defaultPadding,
            ),
            height: 1,
            color: Colors.grey.shade200,
          ),

          // Progress section
          _buildProgressSection(),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: AppConstants.defaultPadding,
            ),
            height: 1,
            color: Colors.grey.shade200,
          ),

          // Review section
          _buildReviewSection(),

          const SizedBox(height: AppConstants.largePadding),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// Builds the job overview section
  Widget _buildJobOverviewSection() {
    return Row(
      children: [
        // Left side - Job icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.work, color: AppConstants.primaryColor, size: 24),
        ),
        const SizedBox(width: AppConstants.defaultPadding),

        // Right side - Job details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.job['title'] ?? 'Job Title',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.job['company'] ?? 'Company Name',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the progress section
  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Application Progress / आवेदन प्रगति',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Step 3 of 3',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  Text(
                    '100%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 1.0,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppConstants.successColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              const Text(
                'Review & Submit / समीक्षा और जमा करें',
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
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
          'Review Your Application / अपने आवेदन की समीक्षा करें',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Personal information
        _buildReviewCard(
          title: 'Personal Information',
          icon: Icons.person,
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
          icon: Icons.description,
          items: [
            'Skills: Electrician, Basic Electronics, Safety Protocols',
            'Cover Letter: I am interested in this position...',
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Terms and conditions
        _buildTermsAndConditionsWithIcon(),
      ],
    );
  }

  /// Builds a review card
  Widget _buildReviewCard({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppConstants.successColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _buildItemRow(item),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a properly formatted item row with label and value
  Widget _buildItemRow(String item) {
    // Split the item into label and value (e.g., "Name: Rahul Kumar" -> "Name:" and "Rahul Kumar")
    final colonIndex = item.indexOf(':');
    if (colonIndex == -1) {
      // If no colon found, return the item as is
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade100, width: 0.5),
        ),
        child: Text(
          item,
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      );
    }

    final label = item.substring(0, colonIndex + 1); // Include the colon
    final value = item.substring(colonIndex + 1).trim(); // Remove leading space

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label (bold, smaller font) - Fixed width for alignment
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Value (normal weight, normal size)
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the terms and conditions section with icon
  Widget _buildTermsAndConditionsWithIcon() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.gavel,
                  color: AppConstants.successColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: const Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          const Text(
            'By submitting this application, you agree to our terms and conditions. Your information will be shared with the employer for evaluation purposes.',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the navigation buttons
  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // Back button
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // Close keyboard first
              _closeKeyboard(context);
              NavigationService.goBack();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppConstants.successColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Text(
              'Back',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.successColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),

        // Submit button
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitApplication,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              elevation: 2,
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
                    'Submit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  /// Closes the keyboard
  void _closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// Submits the application
  void _submitApplication() {
    // Close keyboard first
    _closeKeyboard(context);

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
        title: const Text('Application Submitted! / आवेदन जमा हो गया!'),
        content: const Text(
          'Your job application has been submitted successfully. Now you need to take a skills test to complete your application. / आपका नौकरी आवेदन सफलतापूर्वक जमा हो गया है। अब आपको अपना आवेदन पूरा करने के लिए एक कौशल परीक्षा देनी होगी।',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to home screen
              NavigationService.smartNavigate(destination: const HomeScreen());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: const Text('Later / बाद में'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to skills test screen
              NavigationService.navigateTo(
                SkillTestDetailsScreen(job: widget.job),
              );
            },
            child: const Text('Take Skills Test / कौशल परीक्षा दें'),
          ),
        ],
      ),
    );
  }
}
