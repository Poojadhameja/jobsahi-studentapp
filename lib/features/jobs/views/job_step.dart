/// Job Step Screen
/// Single step page for job application with student information and resume/CV upload

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../../../core/di/injection_container.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';

class JobStepScreen extends StatelessWidget {
  /// Job data for the application
  final Map<String, dynamic> job;

  const JobStepScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<JobsBloc>()..add(LoadJobApplicationFormEvent(job: job)),
      child: _JobStepScreenView(job: job),
    );
  }
}

class _JobStepScreenView extends StatefulWidget {
  final Map<String, dynamic> job;

  const _JobStepScreenView({required this.job});

  @override
  State<_JobStepScreenView> createState() => _JobStepScreenViewState();
}

class _JobStepScreenViewState extends State<_JobStepScreenView> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Text editing controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Initialize controllers with BLoC state data
  void _initializeControllers() {
    final state = context.read<JobsBloc>().state;
    if (state is JobApplicationFormLoaded) {
      _nameController.text = state.formData['name'] ?? '';
      _emailController.text = state.formData['email'] ?? '';
      _phoneController.text = state.formData['phone'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobsBloc, JobsState>(
      listener: (context, state) {
        if (state is JobApplicationSubmitted) {
          context.go(AppRoutes.jobApplicationSuccess);
        } else if (state is ResumeFilePicked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resume file picked: ${state.resumeFile.name}'),
              backgroundColor: AppConstants.successColor,
            ),
          );
        } else if (state is ResumeFileRemoved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resume file removed'),
              backgroundColor: AppConstants.warningColor,
            ),
          );
        }
      },
      child: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          Map<String, dynamic> job = widget.job;
          Map<String, String> formData = {};
          PlatformFile? resumeFile;
          bool isSubmitting = false;

          if (state is JobApplicationFormLoaded) {
            job = state.job;
            formData = state.formData;
            resumeFile = state.resumeFile;
          } else if (state is JobApplicationSubmitting) {
            isSubmitting = true;
            // Keep previous state data
            if (context.read<JobsBloc>().state is JobApplicationFormLoaded) {
              final prevState =
                  context.read<JobsBloc>().state as JobApplicationFormLoaded;
              job = prevState.job;
              formData = prevState.formData;
              resumeFile = prevState.resumeFile;
            }
          }

          return Scaffold(
            backgroundColor: AppConstants.cardBackgroundColor,
            appBar: const SimpleAppBar(
              title: 'Job Application / नौकरी आवेदन',
              showBackButton: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      child: _buildMainCard(context, job, formData, resumeFile),
                    ),
                  ),

                  // Fixed bottom button
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: AppConstants.cardBackgroundColor,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: _buildSubmitButton(
                      context,
                      isSubmitting,
                      formData,
                      resumeFile,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the job overview section
  Widget _buildJobOverviewSection(Map<String, dynamic> job) {
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
                job['title'] ?? 'Job Title',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job['company'] ?? 'Company Name',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job['location'] ?? 'Location',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

  /// Builds the form section
  Widget _buildFormSection(
    BuildContext context,
    Map<String, String> formData,
    PlatformFile? resumeFile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information & Documents / व्यक्तिगत जानकारी और दस्तावेज़',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),

        // Info about existing documents
        if (resumeFile != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppConstants.successColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppConstants.successColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your existing Resume/CV is already loaded. You can keep it or replace with a new file.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppConstants.successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (resumeFile != null)
          const SizedBox(height: AppConstants.defaultPadding),

        // Full Name
        _buildFormField(
          controller: _nameController,
          label: 'Full Name* / पूरा नाम*',
          hint: 'नाम',
          prefixIcon: Icons.person,
          onChanged: (value) {
            context.read<JobsBloc>().add(
              UpdateJobApplicationFormEvent(field: 'name', value: value),
            );
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Name is required / नाम आवश्यक है';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Email
        _buildFormField(
          controller: _emailController,
          label: 'Email Address* / ईमेल पता*',
          hint: 'ईमेल पता',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            context.read<JobsBloc>().add(
              UpdateJobApplicationFormEvent(field: 'email', value: value),
            );
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required / ईमेल आवश्यक है';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email / कृपया एक वैध ईमेल दर्ज करें';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Phone Number
        _buildFormField(
          controller: _phoneController,
          label: 'Phone Number* / फोन नंबर*',
          hint: 'मोबाइल नंबर',
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            context.read<JobsBloc>().add(
              UpdateJobApplicationFormEvent(field: 'phone', value: value),
            );
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required / फोन नंबर आवश्यक है';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number / कृपया एक वैध फोन नंबर दर्ज करें';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Resume/CV Upload Section
        _buildResumeCVUploadSection(context, resumeFile),
      ],
    );
  }

  /// Builds the resume/CV upload section
  Widget _buildResumeCVUploadSection(
    BuildContext context,
    PlatformFile? resumeFile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Resume/CV / रिज्यूमे/सीवी',
            style: TextStyle(fontSize: 13, color: Color(0xFF144B75)),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              if (resumeFile != null) ...[
                // Show selected file with preview
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.description,
                          color: AppConstants.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      resumeFile.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppConstants.textPrimaryColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppConstants.successColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Existing',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppConstants.successColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${(resumeFile.size / 1024).toStringAsFixed(1)} KB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                'Tap edit to replace or keep existing file',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            context.read<JobsBloc>().add(
                              const PickResumeFileEvent(),
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: AppConstants.primaryColor,
                          ),
                          tooltip: 'Replace Resume/CV',
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<JobsBloc>().add(
                              const RemoveResumeFileEvent(),
                            );
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Remove Resume/CV',
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ],
                    ),

                    // File preview section
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                size: 16,
                                color: AppConstants.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Document Preview / दस्तावेज़ पूर्वावलोकन',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _viewFullDocument(),
                            child: Container(
                              height: 125,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: _buildDocumentPreview(resumeFile),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Show upload button
                InkWell(
                  onTap: () {
                    context.read<JobsBloc>().add(const PickResumeFileEvent());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade400,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload Resume/CV / रिज्यूमे/सीवी अपलोड करें',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PDF, DOC, DOCX (Max 5MB)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (resumeFile == null)
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              'Resume/CV is required / रिज्यूमे/सीवी आवश्यक है',
              style: TextStyle(fontSize: 12, color: Colors.red.shade600),
            ),
          ),
      ],
    );
  }

  /// Helper method for form fields with modern styling
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll('*', ''),
            style: const TextStyle(fontSize: 13, color: Color(0xFF144B75)),
            children: [
              if (label.contains('*'))
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          onChanged: onChanged,
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
          validator: validator,
        ),
        const SizedBox(height: 7),
      ],
    );
  }

  /// Builds the submit button
  Widget _buildSubmitButton(
    BuildContext context,
    bool isSubmitting,
    Map<String, String> formData,
    PlatformFile? resumeFile,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting
            ? null
            : () => _submitApplication(context, formData, resumeFile),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 2,
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Submit and Take a Skill Test',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// Builds the document preview content
  Widget _buildDocumentPreview(PlatformFile resumeFile) {
    final fileName = resumeFile.name;
    final extension = fileName.split('.').last.toLowerCase();

    // For PDF files, show a more realistic preview
    if (extension == 'pdf') {
      return Container(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            // PDF header bar
            Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'PDF',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // PDF content preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Document title
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Name line
                      Container(
                        height: 5,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Email line
                      Container(
                        height: 5,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Phone line
                      Container(
                        height: 5,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Content lines
                      for (int i = 0; i < 3; i++) ...[
                        Container(
                          height: 3,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // For Word documents, show a different preview
    if (extension == 'doc' || extension == 'docx') {
      return Container(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            // Word header bar
            Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'DOC',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Word content preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Document title
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Content lines
                      for (int i = 0; i < 4; i++) ...[
                        Container(
                          height: 3,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default preview for other file types
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            size: 32,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            fileName,
            style: TextStyle(
              fontSize: 11,
              color: AppConstants.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          Text(
            'Tap to view full document',
            style: TextStyle(
              fontSize: 10,
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Navigates to view full document
  void _viewFullDocument() {
    // TODO: Navigate to full document viewer
    // For now, showing a snackbar message
    _showErrorSnackBar('Full document viewer coming soon!');

    // Future implementation:
    // NavigationService.smartNavigate(
    //   destination: DocumentViewerScreen(document: _resumeCVFile!),
    // );
  }

  /// Shows error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Closes the keyboard
  void _closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// Submits the application
  void _submitApplication(
    BuildContext context,
    Map<String, String> formData,
    PlatformFile? resumeFile,
  ) {
    // Close keyboard first
    _closeKeyboard(context);

    if (_formKey.currentState!.validate() && resumeFile != null) {
      context.read<JobsBloc>().add(
        SubmitJobApplicationEvent(formData: formData, resumeFile: resumeFile),
      );
    } else {
      if (resumeFile == null) {
        _showErrorSnackBar('Please upload your Resume/CV');
      }
    }
  }

  /// Builds the main card containing all content
  Widget _buildMainCard(
    BuildContext context,
    Map<String, dynamic> job,
    Map<String, String> formData,
    PlatformFile? resumeFile,
  ) {
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
            // Job overview section
            _buildJobOverviewSection(job),

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
            _buildFormSection(context, formData, resumeFile),

            // Submit button removed - now fixed at bottom
          ],
        ),
      ),
    );
  }
}
