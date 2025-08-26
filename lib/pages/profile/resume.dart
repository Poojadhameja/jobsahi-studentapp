/// Resume Screen
/// Allows users to upload an existing resume or build a new one

library;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  String? _uploadedFileName;
  String? _lastUpdatedDate;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing resume data if available
    _uploadedFileName = 'Morgan Carter CV 7 Year Expriance';
    _lastUpdatedDate = '17 July 2024';
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
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
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
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Upload button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUploading ? null : () => _handleUploadResume(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.secondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.defaultPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
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
                      _uploadedFileName != null ? 'Update Resume' : 'Upload Resume',
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
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
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
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
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
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
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

  /// Handles resume upload action
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

      if (result != null) {
        PlatformFile file = result.files.first;
        
        // Validate file size (max 10MB)
        if (file.size > 10 * 1024 * 1024) {
          _showMessage('File size should be less than 10MB');
          return;
        }

        // Validate file extension
        String extension = file.extension?.toLowerCase() ?? '';
        if (!['pdf', 'doc', 'docx'].contains(extension)) {
          _showMessage('Please select a valid PDF, DOC, or DOCX file');
          return;
        }

        // Simulate file upload process
        await Future.delayed(const Duration(seconds: 2));

        // Update state with new file information
        setState(() {
          _uploadedFileName = file.name;
          _lastUpdatedDate = _getCurrentDate();
        });

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
      _showMessage('Error uploading resume: ${e.toString()}');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
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

  /// Handles resume deletion action
  void _handleDeleteResume() {
    showDialog(
      context: NavigationService.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Resume'),
          content: const Text('Are you sure you want to delete your resume? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmDeleteResume();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.errorColor,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Confirms and executes resume deletion
  void _confirmDeleteResume() {
    setState(() {
      _uploadedFileName = null;
      _lastUpdatedDate = null;
    });
    
    _showMessage('Resume deleted successfully!');
    
    // TODO: Implement actual resume deletion from server
    // - Remove file from cloud storage
    // - Update user profile in database
  }

  /// Shows a temporary message to the user
  void _showMessage(String message) {
    // TODO: Implement proper toast/snackbar message
    // For now, show a simple dialog
    showDialog(
      context: NavigationService.context!,
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
