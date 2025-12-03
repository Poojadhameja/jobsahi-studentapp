import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/token_storage.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../../../shared/widgets/common/top_snackbar.dart';

class JobStepScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobStepScreen({super.key, required this.job});

  @override
  State<JobStepScreen> createState() => _JobStepScreenState();
}

class _JobStepScreenState extends State<JobStepScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage.instance;
  bool _isSubmitting = false;
  bool _hasCoverLetterText = false;

  @override
  void initState() {
    super.initState();
    _coverLetterController.addListener(_onCoverLetterChanged);
  }

  @override
  void dispose() {
    _coverLetterController.removeListener(_onCoverLetterChanged);
    _coverLetterController.dispose();
    super.dispose();
  }

  void _onCoverLetterChanged() {
    final hasText = _coverLetterController.text.trim().isNotEmpty;
    if (_hasCoverLetterText != hasText) {
      setState(() {
        _hasCoverLetterText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Scaffold(
        backgroundColor: AppConstants.cardBackgroundColor,
        appBar: SimpleAppBar(
          title: 'Job Application / नौकरी आवेदन',
          showBackButton: true,
          onBack: _navigateBack,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: _buildMainCard(),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: AppConstants.cardBackgroundColor,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitCoverLetter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            _hasCoverLetterText
                                ? 'Submit and apply'
                                : 'Direct apply',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJobOverviewSection(widget.job),
            const SizedBox(height: AppConstants.largePadding),
            Divider(height: 1, thickness: 0.6, color: Colors.grey.shade300),
            const SizedBox(height: AppConstants.largePadding),
            _buildCoverLetterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildJobOverviewSection(Map<String, dynamic> job) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.work, color: AppConstants.primaryColor, size: 24),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job['title']?.toString() ?? 'Job Title',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job['company']?.toString() ?? 'Company Name',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job['location']?.toString() ?? 'Location',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Application progress section removed as per requirement

  Widget _buildCoverLetterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cover Letter (Optional) / कवर लेटर (वैकल्पिक)',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        TextFormField(
          controller: _coverLetterController,
          maxLines: 14,
          minLines: 10,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText:
                'Introduce yourself, highlight your strengths, and explain how you can add value.',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppConstants.secondaryColor,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitCoverLetter() async {
    _closeKeyboard();
    // Cover letter is optional, so we can submit without validation
    final coverLetter = _coverLetterController.text.trim();
    final jobIdValue = widget.job['id'];
    final jobId = _parseId(jobIdValue);

    if (jobId == null) {
      _showErrorSnackBar('Invalid job information. Please try again later.');
      return;
    }

    final studentIdString = await _tokenStorage.getUserId();
    int? studentId = _parseId(studentIdString);

    if (studentId == null) {
      studentId = _parseId(widget.job['student_id']);
    }

    if (studentId == null) {
      _showErrorSnackBar(
        'Could not determine student profile. Please log in again.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _apiService.submitJobApplication(
        jobId: jobId,
        studentId: studentId,
        coverLetter: coverLetter.isEmpty ? null : coverLetter,
      );

      if (!mounted) return;

      final jobWithApplication = Map<String, dynamic>.from(widget.job);
      jobWithApplication['id'] = jobId;
      jobWithApplication['job_id'] = jobId.toString();
      if (response.data != null) {
        jobWithApplication['application'] = response.data;
      }
      jobWithApplication['application_status'] =
          response.data?['status'] ?? 'pending';

      Map<String, dynamic>? skillTestInfo;
      final applicationIdValue =
          response.data?['application_id'] ??
          response.data?['id'] ??
          response.data?['applicationId'];
      final applicationId = int.tryParse(applicationIdValue?.toString() ?? '');

      if (applicationId != null) {
        try {
          final result = await _apiService.startSkillTest(
            applicationId: applicationId,
          );
          skillTestInfo = result;
        } catch (e) {
          debugPrint('🔴 [Jobs] Failed to start skill test: $e');
        }
      }

      if (skillTestInfo != null) {
        jobWithApplication['skill_test_response'] = skillTestInfo;
      }

      context.pushNamed(
        'jobApplicationSuccess',
        pathParameters: {'id': jobId.toString()},
        extra: jobWithApplication,
      );
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'Failed to submit application. Please try again.';

      final errorString = e.toString();
      if (errorString.startsWith('Exception: ')) {
        final extractedMessage = errorString
            .substring('Exception: '.length)
            .trim();
        if (extractedMessage.isNotEmpty && extractedMessage != 'null') {
          errorMessage = extractedMessage;
        }
      } else if (errorString.isNotEmpty && errorString != 'null') {
        errorMessage = errorString;
      }

      _showErrorSnackBar(errorMessage);
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    return null;
  }

  void _closeKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _navigateBack() {
    final jobId = widget.job['id']?.toString();
    if (jobId == null || jobId.isEmpty) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.go(AppRoutes.home);
      }
      return;
    }

    final jobPayload = Map<String, dynamic>.from(widget.job);
    jobPayload['id'] = jobId;

    context.goNamed(
      'jobDetails',
      pathParameters: {'id': jobId},
      extra: jobPayload,
    );
  }

  Future<bool> _handleBackNavigation() async {
    _navigateBack();
    return false;
  }

  void _showErrorSnackBar(String message) {
    TopSnackBar.showError(context, message: message);
  }
}
