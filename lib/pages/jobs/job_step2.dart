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
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

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
        title: 'Application Step 2',
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

                // Navigation buttons
                _buildNavigationButtons(),
              ],
            ),
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
          'Step 2 of 3',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        LinearProgressIndicator(
          value: 0.66,
          backgroundColor: AppConstants.backgroundColor,
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        const Text(
          'Skills & Cover Letter',
          style: TextStyle(color: AppConstants.textSecondaryColor),
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
          'Additional Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Skills
        TextFormField(
          controller: _skillsController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Skills',
            hintText: 'Enter your relevant skills',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.psychology),
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Cover Letter
        TextFormField(
          controller: _coverLetterController,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: 'Cover Letter',
            hintText:
                'Write a brief cover letter explaining why you are interested in this position...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.description),
            alignLabelWithHint: true,
          ),
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
              NavigationService.goBack();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: const Text(
              'Back',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),

        // Next button
        Expanded(
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  /// Goes to the next step
  void _goToNextStep() {
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
}
