import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../utils/app_constants.dart';
import '../../../data/user_data.dart';
import '../../../utils/navigation_service.dart';

class CertificatesEditScreen extends StatefulWidget {
  const CertificatesEditScreen({super.key});

  @override
  State<CertificatesEditScreen> createState() => _CertificatesEditScreenState();
}

class _CertificatesEditScreenState extends State<CertificatesEditScreen> {
  final List<Map<String, dynamic>> _uploadedCertificates = [];
  bool _isUploadingCertificate = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = UserData.currentUser;
    try {
      final certificatesData = user['certificates'];
      if (certificatesData is List) {
        _uploadedCertificates.addAll(certificatesData.whereType<Map<String, dynamic>>());
      }
    } catch (e) {
      // Handle errors safely
    }
    
    // Add default certificates if none found (ITI relevant)
    if (_uploadedCertificates.isEmpty) {
      _uploadedCertificates.addAll([
        {
          'name': 'ITI Electrician Certificate.pdf',
          'type': 'Certificate',
          'uploadDate': '15 July 2024',
          'size': 1024000,
          'extension': 'pdf',
        },
        {
          'name': 'Safety Training Certificate.jpg',
          'type': 'Image Document',
          'uploadDate': '10 July 2024',
          'size': 2048000,
          'extension': 'jpg',
        },
      ]);
    }
  }

  Future<void> _pickCertificateFile() async {
    try {
      setState(() {
        _isUploadingCertificate = true;
      });

      // Pick file from device
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        
        // Validate file size (max 10MB for better user experience)
        if (file.size > 10 * 1024 * 1024) {
          _showMessage('File size should be less than 10MB');
          return;
        }

        // Validate minimum file size (prevent empty files)
        if (file.size < 1024) { // Less than 1KB
          _showMessage('File seems to be empty or too small');
          return;
        }

        // Validate file extension
        String extension = file.extension?.toLowerCase() ?? '';
        if (!['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'].contains(extension)) {
          _showMessage('Please select a valid file (PDF, DOC, DOCX, JPG, PNG)');
          return;
        }

        // Validate filename
        if (file.name.isEmpty || file.name.length > 100) {
          _showMessage('Invalid filename. Please use a shorter name');
          return;
        }

        // Simulate file upload process with better feedback
        _showMessage('Processing file...');
        await Future.delayed(const Duration(seconds: 1));

        // Determine certificate type based on filename or extension
        String certificateType = _determineCertificateType(file.name, extension);

        // Check for duplicate files
        bool isDuplicate = _uploadedCertificates.any((cert) => 
          cert['name'].toLowerCase() == file.name.toLowerCase()
        );
        
        if (isDuplicate) {
          _showMessage('A file with this name already exists. Please rename the file.');
          return;
        }

        // Add certificate to list
        setState(() {
          _uploadedCertificates.add({
            'name': file.name,
            'type': certificateType,
            'uploadDate': _getCurrentDate(),
            'size': file.size,
            'extension': extension,
            'uploadTime': DateTime.now().millisecondsSinceEpoch, // Add timestamp for sorting
          });
        });

        // Show success message
        _showMessage('Certificate uploaded successfully!');
        
        // TODO: Implement actual file upload to server
        // - Upload file to cloud storage
        // - Update user profile in database
        // - Handle upload errors and retry logic
        
      } else {
        // User canceled file picker
        _showMessage('File selection cancelled');
      }
    } catch (e) {
      String errorMessage = 'Error uploading certificate';
      
      // Provide more specific error messages
      if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please allow file access.';
      } else if (e.toString().contains('storage')) {
        errorMessage = 'Storage error. Please check available space.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = 'Error uploading certificate: ${e.toString()}';
      }
      
      _showMessage(errorMessage);
    } finally {
      setState(() {
        _isUploadingCertificate = false;
      });
    }
  }

  void _deleteCertificate(Map<String, dynamic> certificate) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Certificate'),
          content: Text('Are you sure you want to delete "${certificate['name']}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _uploadedCertificates.remove(certificate);
                });
                _showMessage('Certificate deleted successfully!');
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

  void _saveCertificates() {
    if (_uploadedCertificates.isNotEmpty) {
      try {
        // TODO: Save to backend/database
        setState(() {
          // Update local user data
          UserData.currentUser['certificates'] = _uploadedCertificates;
        });
        
        _showMessage('Certificates updated successfully!');
        Future.delayed(const Duration(seconds: 1), () {
          NavigationService.goBack();
        });
      } catch (e) {
        _showMessage('Error saving certificates: ${e.toString()}');
      }
    } else {
      _showMessage('Please add at least one certificate');
    }
  }

  void _showMessage(String message) {
    if (mounted) { // Check if widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains('Error') || message.contains('Error') 
              ? AppConstants.errorColor 
              : AppConstants.primaryColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _determineCertificateType(String filename, String extension) {
    String lowerFilename = filename.toLowerCase();
    
    if (lowerFilename.contains('certificate') || lowerFilename.contains('cert')) {
      return 'Certificate';
    } else if (lowerFilename.contains('license') || lowerFilename.contains('lic')) {
      return 'License';
    } else if (lowerFilename.contains('id') || lowerFilename.contains('aadhar') || lowerFilename.contains('pan')) {
      return 'ID Proof';
    } else if (lowerFilename.contains('experience') || lowerFilename.contains('exp')) {
      return 'Experience Letter';
    } else if (extension == 'pdf') {
      return 'PDF Document';
    } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
      return 'Image Document';
    } else {
      return 'Document';
    }
  }

  Color _getCertificateColor(String type) {
    switch (type.toLowerCase()) {
      case 'certificate':
        return AppConstants.successColor;
      case 'license':
        return AppConstants.accentColor;
      case 'id proof':
        return AppConstants.warningColor;
      case 'experience letter':
        return AppConstants.primaryColor;
      case 'pdf document':
        return AppConstants.errorColor;
      case 'image document':
        return AppConstants.secondaryColor;
      default:
        return AppConstants.primaryColor;
    }
  }

  IconData _getCertificateIcon(String type) {
    switch (type.toLowerCase()) {
      case 'certificate':
        return Icons.verified;
      case 'license':
        return Icons.drive_file_rename_outline;
      case 'id proof':
        return Icons.badge;
      case 'experience letter':
        return Icons.description;
      case 'pdf document':
        return Icons.picture_as_pdf;
      case 'image document':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.textPrimaryColor),
          onPressed: () => NavigationService.goBack(),
        ),
        title: const Text(
          'Edit Certificates',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload Section
                    _buildUploadSection(),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Current Certificates
                    _buildCurrentCertificatesSection(),
                  ],
                ),
              ),
            ),
            // Bottom Save Button
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppConstants.cardBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCertificates,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.defaultPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  child: Text(
                    AppConstants.saveChangesText,
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

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppConstants.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload New Certificate',
            style: TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          
          // Upload Area
          GestureDetector(
            onTap: _isUploadingCertificate ? null : _pickCertificateFile,
            child: MouseRegion(
              cursor: _isUploadingCertificate ? SystemMouseCursors.basic : SystemMouseCursors.click,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding * 2),
                decoration: BoxDecoration(
                  color: _isUploadingCertificate 
                      ? AppConstants.backgroundColor.withValues(alpha: 0.5)
                      : AppConstants.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: _isUploadingCertificate 
                        ? AppConstants.borderColor.withValues(alpha: 0.3)
                        : AppConstants.borderColor,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isUploadingCertificate) ...[
                      SizedBox(
                        height: 48,
                        width: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Processing file...',
                        style: TextStyle(
                          color: AppConstants.textPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: AppConstants.accentColor,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Click to upload documents',
                        style: TextStyle(
                          color: AppConstants.textPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Supported formats: PDF, DOC, DOCX, JPG, PNG' ,
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Max file size: 5MB',
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          
          // Alternative upload button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUploadingCertificate ? null : _pickCertificateFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                ),
                elevation: 0,
              ),
              child: _isUploadingCertificate
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        const Text('Uploading...'),
                      ],
                    )
                  : const Text('Upload Certificate'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentCertificatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Certificates (${_uploadedCertificates.length})',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        if (_uploadedCertificates.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.cardBackgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: AppConstants.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(
                'No certificates uploaded yet. Upload some certificates to get started!',
                style: TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ..._uploadedCertificates.map((cert) => _buildCertificateTile(cert)),
      ],
    );
  }

  Widget _buildCertificateTile(Map<String, dynamic> certificate) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppConstants.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Certificate icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getCertificateColor(certificate['type']),
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            ),
            child: Icon(
              _getCertificateIcon(certificate['type']),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          
          // Certificate details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${certificate['type']} • ${certificate['uploadDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Size: ${_formatFileSize(certificate['size'])}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Delete button
          IconButton(
            onPressed: () => _deleteCertificate(certificate),
            icon: const Icon(
              Icons.delete_outline,
              color: AppConstants.errorColor,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
