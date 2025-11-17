import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';

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
    return SingleChildScrollView(
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

          // Skill test status info
          if (job['skill_test_response'] is Map<String, dynamic>)
            ...[
              _buildSkillTestInfoCard(
                job['skill_test_response'] as Map<String, dynamic>,
              ),
              const SizedBox(height: 32),
            ],

          // Skill test not available message
          if (!_hasSkillTest())
            ...[
              _buildSkillTestNotAvailableMessage(),
              const SizedBox(height: 32),
            ],

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

        // Take Test button (only show if skill test is required)
        if (_hasSkillTest())
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

  /// Check if skill test exists for this job
  bool _hasSkillTest() {
    final skillTestInfo =
        job['skill_test_response'] is Map<String, dynamic>
            ? job['skill_test_response'] as Map<String, dynamic>
            : null;
    
    // Check if skill test response exists and has valid test_id
    if (skillTestInfo != null) {
      final testId = skillTestInfo['test_id']?.toString();
      if (testId != null && testId.isNotEmpty) {
        return true;
      }
    }
    
    // Also check if job has skill_test_available flag
    final hasSkillTestAvailable = job['skill_test_available'] == true ||
        job['has_skill_test'] == true;
    
    return hasSkillTestAvailable;
  }

  /// Navigates to track application
  void _trackApplication(BuildContext context) {
    // Extract application ID from job data
    final applicationData = job['application'] is Map<String, dynamic>
        ? job['application'] as Map<String, dynamic>
        : null;
  
    final applicationId = job['application_id']?.toString() ??
        applicationData?['application_id']?.toString() ??
        applicationData?['id']?.toString() ??
        job['applicationId']?.toString();

    if (applicationId == null || applicationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application ID not available.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to application detail page
    final navigationData = Map<String, dynamic>.from(job);
    navigationData['_navigation_source'] = 'job_application_success'; // Track navigation source

    context.pushNamed(
      'studentApplicationDetail',
      pathParameters: {'id': applicationId},
      extra: navigationData,
    );
  }

  /// Navigates to take skill test
  void _takeTest(BuildContext context) {
    final jobId = job['job_id']?.toString().trim().isNotEmpty == true
        ? job['job_id'].toString().trim()
        : job['id']?.toString().trim();
    final skillTestInfo =
        job['skill_test_response'] is Map<String, dynamic>
            ? job['skill_test_response'] as Map<String, dynamic>
            : null;
    final skillTestId = skillTestInfo?['test_id']?.toString();
    final fallbackJobId = (jobId != null && jobId.isNotEmpty)
        ? jobId
        : (skillTestId != null && skillTestId.isNotEmpty
            ? skillTestId
            : 'job_skill_test');

    final jobPayload = Map<String, dynamic>.from(job);
    jobPayload['id'] = fallbackJobId;
    jobPayload['job_id'] = fallbackJobId;
    jobPayload.putIfAbsent(
      'category',
      () {
        if (job['category'] != null) return job['category'];
        if (job['job_type_display'] != null) {
          return job['job_type_display'];
        }
        final tags = job['tags'];
        if (tags is List && tags.isNotEmpty) {
          return tags.first.toString();
        }
        return 'general';
      },
    );
    if (skillTestInfo != null) {
      jobPayload['skill_test_response'] = skillTestInfo;
    }

    context.pushNamed(
      'skillTestDetails',
      pathParameters: {'id': fallbackJobId},
      extra: jobPayload,
    );
  }

  /// Builds message when skill test is not available
  Widget _buildSkillTestNotAvailableMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'The skill test is not available or required. Once available, it will appear in your application tracking details.',
              style: TextStyle(
                fontSize: 13,
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillTestInfoCard(Map<String, dynamic> info) {
    final message = info['message']?.toString() ?? 'Skill test updated.';
    final alreadyExists = info['already_exists'] == true;
    final testId = info['test_id']?.toString();
    final created = info['status'] == true;
    final color = created ? AppConstants.successColor : AppConstants.primaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  alreadyExists ? Icons.restart_alt : Icons.flash_on,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alreadyExists
                          ? 'Skill Test Ready'
                          : 'Skill Test Created',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    if (testId != null && testId.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Test ID: $testId',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
