import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import 'job_step3.dart';

class JobStep2Screen extends StatefulWidget {
  /// Job data for the application
  final Map<String, dynamic> job;

  const JobStep2Screen({super.key, required this.job});

  @override
  State<JobStep2Screen> createState() => _JobStep2ScreenState();
}

class _JobStep2ScreenState extends State<JobStep2Screen> {
  /// Text editing controllers
  final _skillsController = TextEditingController();
  final _coverLetterController = TextEditingController();

  /// Whether the form is being submitted
  bool _isSubmitting = false;

  @override
  void dispose() {
    _skillsController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

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

          // Form section
          _buildFormSection(),

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
                    'Step 2 of 3',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  Text(
                    '66%',
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
                value: 0.66,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppConstants.successColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              const Text(
                'Skills & Cover Letter / कौशल और कवर लेटर',
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

  /// Builds the form section
  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Information / अतिरिक्त जानकारी',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Skills field
        _buildFormField(
          controller: _skillsController,
          label: 'Skills / कौशल',
          hint: 'अपने प्रासंगिक कौशल दर्ज करें',
          prefixIcon: Icons.psychology,
          maxLines: 3,
        ),
        const SizedBox(height: 20),

        // Cover Letter field
        _buildFormField(
          controller: _coverLetterController,
          label: 'Cover Letter / कवर लेटर',
          hint:
              'इस पद में आपकी रुचि क्यों है, यह बताते हुए एक संक्षिप्त कवर लेटर लिखें...',
          prefixIcon: Icons.description,
          maxLines: 8,
        ),
      ],
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

        // Next button
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _goToNextStep,
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
                : Text(
                    'Next Step',
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

  /// Goes to the next step
  void _goToNextStep() {
    // Close keyboard first
    _closeKeyboard(context);

    setState(() {
      _isSubmitting = true;
    });

    // Simulate processing
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isSubmitting = false;
      });

      // Navigate to next step
      NavigationService.smartNavigate(
        destination: JobStep3Screen(job: widget.job),
      );
    });
  }

  /// Helper method for form fields with modern styling (from create account page)
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF144B75)),
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 15,
            ),
          ),
        ),
        const SizedBox(height: 7),
      ],
    );
  }
}
