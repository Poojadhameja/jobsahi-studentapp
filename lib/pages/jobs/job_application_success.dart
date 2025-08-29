import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../widgets/global/simple_app_bar.dart';
import '../skill_test/skill_test_details.dart';

/// Job Application Success Screen
/// Shows confirmation after successful job application submission
class JobApplicationSuccessScreen extends StatelessWidget {
  /// Job data
  final Map<String, dynamic> job;

  const JobApplicationSuccessScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SimpleAppBar(
        title: 'Application Submitted',
        showBackButton: true,
      ),
      body: _buildSuccessContent(context),
    );
  }

  /// Builds the success content
  Widget _buildSuccessContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success icon
          _buildSuccessIcon(),

          const SizedBox(height: 32),

          // Success heading
          Text(
            'Application Submitted!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Success message in Hindi
          Text(
            'आपका आवेदन सफलतापूर्वक ${job['company'] ?? 'Company'} को ${job['title'] ?? 'Job'} पद के लिए भेज दिया गया है |',
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textPrimaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  /// Builds the success icon
  Widget _buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Document icon
          Icon(Icons.description, size: 60, color: AppConstants.primaryColor),
          // Checkmark
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppConstants.successColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the action buttons
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Track Application button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _trackApplication(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Track Application',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Take Test button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _takeTest(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Take Test',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// Navigates to track application
  void _trackApplication(BuildContext context) {
    // TODO: Navigate to application tracking screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application tracking coming soon!'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  /// Navigates to take skill test
  void _takeTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SkillTestDetailsScreen(job: job)),
    );
  }
}
