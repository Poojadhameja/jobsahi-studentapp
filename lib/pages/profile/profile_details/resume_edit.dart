/// Resume Edit Screen
/// Allows users to upload, view, and manage their resume/CV files

library;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/navigation_service.dart';
import '../../../data/user_data.dart';

class ResumeEditScreen extends StatefulWidget {
  const ResumeEditScreen({super.key});

  @override
  State<ResumeEditScreen> createState() => _ResumeEditScreenState();
}

class _ResumeEditScreenState extends State<ResumeEditScreen> {
  String? _uploadedFileName;
  String? _lastUpdatedDate;
  bool _isUploading = false;
  int _resumeFileSize = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = UserData.currentUser;
    
    // Load resume data from user data or set default
    _uploadedFileName = user['resume_file_name'] ?? 'Morgan Carter CV 7 Year Experience';
    _lastUpdatedDate = user['resume_last_updated'] ?? '17 July 2024';
    
    // Load file size if available
    _resumeFileSize = user['resume_file_size'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            _buildHeader(),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    // Instruction text
                    _buildInstructionText(),
                    const SizedBox(height: AppConstants.largePadding),

                    // Upload existing resume option
                    _buildUploadOption(),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // OR separator
                    _buildOrSeparator(),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Build new resume option
                    _buildBuildOption(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header with back button and title
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => NavigationService.goBack(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppConstants.textPrimaryColor,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            'Resume',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the instruction text in Hindi
  Widget _buildInstructionText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: const Text(
        'अपना रिज़्यूमे अपलोड करें या नया बनाएँ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppConstants.textPrimaryColor,
          height: 1.4,
        ),
      ),
    );
  }

  /// Builds the upload existing resume option
  Widget _buildUploadOption() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppConstants.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // PDF icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppConstants.errorColor,
                  borderRadius: BorderRadius.circular(
                    AppConstants.smallBorderRadius,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Pdf',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),

              // File details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _uploadedFileName ?? 'No resume uploaded',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_lastUpdatedDate != null)
                      Text(
                        'अपडेटेड दिनांक: $_lastUpdatedDate',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    if (_resumeFileSize > 0)
                      Text(
                        'Size: ${_formatFileSize(_resumeFileSize)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Upload area - made smaller
          GestureDetector(
            onTap: _isUploading ? null : _handleUploadResume,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: _isUploading 
                    ? AppConstants.backgroundColor.withValues(alpha: 0.5)
                    : AppConstants.cardBackgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                border: Border.all(
                  color: _isUploading 
                      ? AppConstants.borderColor.withValues(alpha: 0.3)
                      : AppConstants.borderColor,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isUploading) ...[
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Processing file...',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 24,
                      color: AppConstants.accentColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Click to upload resume/CV',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'PDF, DOC, DOCX • Max 5MB',
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Upload button - only enabled when resume exists
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isUploading || _uploadedFileName == null) ? null : () => _handleUpdateResume(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _uploadedFileName == null 
                    ? AppConstants.borderColor.withValues(alpha: 0.3)
                    : AppConstants.secondaryColor,
                foregroundColor: _uploadedFileName == null 
                    ? AppConstants.textSecondaryColor
                    : Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.defaultPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.smallBorderRadius,
                  ),
                ),
                elevation: 0,
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _uploadedFileName != null
                          ? 'Update Resume'
                          : 'No Resume to Update',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the OR separator
  Widget _buildOrSeparator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppConstants.borderColor.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppConstants.borderColor.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  /// Builds the build new resume option
  Widget _buildBuildOption() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppConstants.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // PDF icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppConstants.errorColor,
                  borderRadius: BorderRadius.circular(
                    AppConstants.smallBorderRadius,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Pdf',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),

              // Build details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Build Resume',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'हमारे बिल्डर का उपयोग करके एक नया रिज़्यूमे बनाएं',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Get Started button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _handleBuildResume(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.secondaryColor,
                side: const BorderSide(
                  color: AppConstants.secondaryColor,
                  width: 2,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.defaultPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.smallBorderRadius,
                  ),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles resume upload action with enhanced functionality
  Future<void> _handleUploadResume() async {
    try {
      setState(() {
        _isUploading = true;
      });

      // Pick file from device
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        // Validate file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          _showMessage('File size should be less than 5MB');
          return;
        }

        // Validate minimum file size (prevent empty files)
        if (file.size < 1024) { // Less than 1KB
          _showMessage('File seems to be empty or too small');
          return;
        }

        // Validate file extension
        String extension = file.extension?.toLowerCase() ?? '';
        if (!['pdf', 'doc', 'docx'].contains(extension)) {
          _showMessage('Please select a valid file (PDF, DOC, DOCX)');
          return;
        }

        // Validate filename
        if (file.name.isEmpty || file.name.length > 100) {
          _showMessage('Invalid filename. Please use a shorter name');
          return;
        }

        // Check for duplicate files
        if (_uploadedFileName == file.name) {
          _showMessage('A file with this name already exists. Please rename the file.');
          return;
        }

        // Simulate file upload process
        await Future.delayed(const Duration(seconds: 2));

        // Update state with new file information
        setState(() {
          _uploadedFileName = file.name;
          _lastUpdatedDate = _getCurrentDate();
          _resumeFileSize = file.size;
        });

        // Update user data
        UserData.currentUser['resume_file_name'] = _uploadedFileName;
        UserData.currentUser['resume_last_updated'] = _lastUpdatedDate;
        UserData.currentUser['resume_file_size'] = _resumeFileSize;

        // Show success message
        _showMessage('Resume uploaded successfully!');

        // TODO: Implement actual file upload to server
        // - Upload file to cloud storage
        // - Update user profile in database
        // - Handle upload errors and retry logic
      } else {
        // User canceled file picker
        _showMessage('File selection cancelled');
      }
    } catch (e) {
      String errorMessage = 'Error uploading resume';
      
      // Provide more specific error messages
      if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please allow file access.';
      } else if (e.toString().contains('storage')) {
        errorMessage = 'Storage error. Please check available space.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = 'Error uploading resume: ${e.toString()}';
      }
      
      _showMessage(errorMessage);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  /// Handles resume update action (only called when resume exists)
  void _handleUpdateResume() {
    if (_uploadedFileName == null) {
      _showMessage('No resume to update. Please upload a resume first.');
      return;
    }
    
    // Show message that update is not implemented yet
    _showMessage('Update functionality will be implemented soon. For now, please upload a new resume.');
    
    // TODO: Implement resume update functionality
    // This could include:
    // - Opening the current resume for editing
    // - Allowing users to modify existing resume details
    // - Re-uploading with the same name
  }

  /// Handles resume building action
  void _handleBuildResume() {
    // TODO: Navigate to resume builder screen
    // This could include:
    // - Form-based resume creation
    // - Template selection
    // - Step-by-step wizard

    // Show message
    _showMessage('Opening resume builder...');
  }

  /// Shows a temporary message to the user
  void _showMessage(String message) {
    final context = NavigationService.context;
    if (context == null) return;
    
    // TODO: Implement proper toast/snackbar message
    // For now, show a simple dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Gets the current date in the required format
  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  /// Formats file size for display
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
