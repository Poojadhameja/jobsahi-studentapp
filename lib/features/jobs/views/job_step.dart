import 'package:flutter/material.dart';

import '../../../core/utils/app_constants.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/token_storage.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';

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

  @override
  void dispose() {
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
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
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
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
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
                      : const Text(
                          'Submit Application',
                          style: TextStyle(
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
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
              height: 1,
              color: Colors.grey.shade200,
            ),
            _buildProgressSection(),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
              height: 1,
              color: Colors.grey.shade200,
            ),
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
                children: const [
                  Text(
                    'Step 1 of 1',
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
                'Complete Application / पूर्ण आवेदन',
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

  Widget _buildCoverLetterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cover Letter / कवर लेटर',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        const Text(
          'Share a short summary about yourself and why you are the right fit for this opportunity.',
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        TextFormField(
          controller: _coverLetterController,
          maxLines: 8,
          minLines: 6,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText:
                'Introduce yourself, highlight your strengths, and explain how you can add value.',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 18,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Cover letter is required / कवर लेटर आवश्यक है';
            }
            if (value.trim().length < 50) {
              return 'Please write at least 50 characters / कृपया कम से कम 50 वर्ण लिखें';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _submitCoverLetter() async {
    _closeKeyboard();
    if (_formKey.currentState!.validate()) {
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
          coverLetter: coverLetter,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isNotEmpty
                  ? response.message
                  : 'Application submitted successfully.',
            ),
            backgroundColor: AppConstants.successColor,
          ),
        );

        Navigator.of(context).pop(true);
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar(e.toString());
      } finally {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      _showErrorSnackBar('Please enter your cover letter.');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}


