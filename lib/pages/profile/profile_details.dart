import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../data/user_data.dart';
import '../../utils/navigation_service.dart';
import 'resume.dart';

/// ---------------- PROFILE DETAILS SCREEN ----------------
class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  /// Boolean flags to control expand/collapse state of each section
  bool _isProfileExpanded = true;
  bool _isSummaryExpanded = true;
  bool _isEducationExpanded = true;
  bool _isSkillsExpanded = true;
  bool _isExperienceExpanded = true;
  bool _isCertificatesExpanded = true;
  bool _isResumeExpanded = true;

  /// State variables for resume details
  String? _uploadedResumeFileName;
  String? _lastResumeUpdatedDate;

  @override
  void initState() {
    super.initState();
    // Initialize with mock data or actual user data if available
    _uploadedResumeFileName = 'Morgan Carter CV 7 Year Expriance'; // Example file name
    _lastResumeUpdatedDate = '17 July 2024'; // Example last updated date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,

      /// AppBar with back button & title
      appBar: AppBar(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.textPrimaryColor),
          onPressed: () => NavigationService.goBack(), // Go back to previous screen
        ),
        title: const Text(
          'Profile Details',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      /// Main body wrapped with scroll view
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Profile Section
              _buildProfileSection(),
              const SizedBox(height: AppConstants.defaultPadding),

              // Profile Summary Section
              _buildProfileSummarySection(),
              const SizedBox(height: AppConstants.defaultPadding),

              // Education Section
              _buildEducationSection(),
              const SizedBox(height: AppConstants.defaultPadding),

              // Key Skills Section
              _buildKeySkillsSection(),
              const SizedBox(height: AppConstants.defaultPadding),

              // Experience Section
              _buildExperienceSection(),
              const SizedBox(height: AppConstants.defaultPadding),

              // Certificates Section
              _buildCertificatesSection(),
              const SizedBox(height: AppConstants.defaultPadding),

              // Resume/CV Section
              _buildResumeSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- PROFILE SECTION ----------------
  /// Shows user details like Email, Location, Phone, Experience
  Widget _buildProfileSection() {
    final user = UserData.currentUser; // Get current user data
    
    return _buildSectionCard(
      title: 'Profile / आपकी जानकारी',
      icon: Icons.person_outline,
      isExpanded: _isProfileExpanded,
      onEditTap: () => _toggleSection('profile'),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email', user['email'] ?? 'info@example.com'),
          _buildInfoRow(Icons.location_on_outlined, 'Location', user['location'] ?? 'Noida, India'),
          _buildInfoRow(Icons.phone_outlined, 'Phone', user['phone'] ?? '+01 987 654 3210'),
          _buildInfoRow(Icons.work_outline, 'Experience', user['experience'] ?? '8 Year'),
        ],
      ),
    );
  }

  /// ---------------- PROFILE SUMMARY SECTION ----------------
  /// Shows a short description about the user with "Read More" option
  Widget _buildProfileSummarySection() {
    final user = UserData.currentUser;
    final summary = user['summary'] ??
        'I design visually engaging, user-focused websites, specializing in UX/UI, responsive design, and creating seamless digital experiences.';
    
    return _buildSectionCard(
      title: 'Profile summary / प्रोफ़ाइल झलक',
      icon: Icons.book_outlined,
      isExpanded: _isSummaryExpanded,
      onEditTap: () => _toggleSection('summary'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Text
          Text(
            summary,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),

          // Read More button opens full dialog
          GestureDetector(
            onTap: () => _showFullProfileSummary(summary),
            child: Text(
              'Read More',
              style: TextStyle(
                color: AppConstants.accentColor,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- EDUCATION SECTION ----------------
  /// Displays education fields like Qualification, Institute, Course
  Widget _buildEducationSection() {
    return _buildSectionCard(
      title: 'Education',
      icon: Icons.school_outlined,
      isExpanded: _isEducationExpanded,
      onEditTap: () => _toggleSection('education'),
      child: Column(
        children: [
          _buildEducationField('Highest Qualification', 'Select', Icons.school_outlined),
          _buildEducationField('Institute name', 'e.g., Electrician, Fitter,', Icons.business_outlined),
          _buildEducationField('Course Name', 'Marksheet/Certified PDF', Icons.description_outlined),
        ],
      ),
    );
  }

  /// ---------------- KEY SKILLS SECTION ----------------
  /// Displays list of user's skills in chip format
  Widget _buildKeySkillsSection() {
    final user = UserData.currentUser;
    
    List<String> userSkills = [];
    try {
      final skillsData = user['skills'];
      if (skillsData is List) {
        userSkills = skillsData.whereType<String>().toList();
      }
    } catch (e) {
      userSkills = []; // Handle errors safely
    }
    
    // Default fallback skills if none found
    if (userSkills.isEmpty) {
      userSkills = ['HTML', 'CSS', 'Photoshop', 'Figma', 'XD'];
    }
    
    return _buildSectionCard(
      title: 'Key Skills',
      icon: Icons.grid_view_outlined,
      isExpanded: _isSkillsExpanded,
      onEditTap: () => _toggleSection('skills'),
      child: Wrap(
        spacing: AppConstants.smallPadding,
        runSpacing: AppConstants.smallPadding,
        children: userSkills.map((skill) => _buildSkillChip(skill)).toList(),
      ),
    );
  }

  /// ---------------- EXPERIENCE SECTION ----------------
  /// Displays user's work experience with company, position, and duration
  Widget _buildExperienceSection() {
    return _buildSectionCard(
      title: 'Experience',
      icon: Icons.work_outline,
      isExpanded: _isExperienceExpanded,
      onEditTap: () => _toggleSection('experience'),
      child: Column(
        children: [
          _buildExperienceItem('E-commerce Websites', 'example.com', 'July 2016 - July 2019'),
          const Divider(height: 1, color: AppConstants.borderColor),
          _buildExperienceItem('Custom Web Applications', 'example.com', 'April 2019 - Oct 2021'),
        ],
      ),
    );
  }

  /// ---------------- CERTIFICATES SECTION ----------------
  /// Displays certificates section with file upload functionality
  Widget _buildCertificatesSection() {
    return _buildSectionCard(
      title: 'Certificates',
      icon: Icons.badge_outlined,
      isExpanded: _isCertificatesExpanded,
      onEditTap: () => _toggleSection('certificates'),
      child: _buildCertificateUploadArea(),
    );
  }

  /// ---------------- RESUME/CV SECTION ----------------
  /// Displays resume/CV upload section with file management
  Widget _buildResumeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppConstants.borderColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header for Resume/CV section
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Icon(Icons.description_outlined, color: AppConstants.primaryColor),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'Resume/CV',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _pickFile, // Trigger file picker on "Update" button tap
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor, // Blue background
                    foregroundColor: AppConstants.backgroundColor, // White text
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: AppConstants.smallPadding),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                    ),
                  ),
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppConstants.borderColor), // Separator

          // Upload Area
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: GestureDetector(
              onTap: _pickFile, // Trigger file picker when upload area is tapped
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding * 2),
                decoration: BoxDecoration(
                  color: AppConstants.cardBackgroundColor, // Light blue background
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: AppConstants.borderColor.withValues(alpha: 0.5), // Lighter border
                    style: BorderStyle.solid, // Solid border as in image
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined, // Upward arrow icon
                      size: 48,
                      color: AppConstants.primaryColor,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      'Click to upload documents',
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Display Uploaded File (conditionally)
          if (_uploadedResumeFileName != null && _uploadedResumeFileName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: AppConstants.smallPadding),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.smallPadding),
                    decoration: BoxDecoration(
                      color: Colors.red, // Specific red for PDF icon as in image
                      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                    ),
                    child: const Text(
                      'Pdf',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _uploadedResumeFileName!,
                        style: TextStyle(
                          color: AppConstants.textPrimaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_lastResumeUpdatedDate != null && _lastResumeUpdatedDate!.isNotEmpty)
                        Text(
                          'Updated Last: $_lastResumeUpdatedDate',
                          style: TextStyle(
                            color: AppConstants.textSecondaryColor.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppConstants.defaultPadding), // Bottom padding for the section
        ],
      ),
    );
  }

  /// ---------------- REUSABLE COMPONENTS ----------------

  /// Reusable card UI for each section
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onEditTap,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppConstants.borderColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Section Header with Title + Edit Button
          ListTile(
            leading: Icon(icon, color: AppConstants.primaryColor, size: 24),
            title: Text(
              title,
              style: const TextStyle(
                color: AppConstants.secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: AppConstants.primaryColor, size: 20),
              onPressed: () => _navigateToEditPage(title), // Navigate to edit page
            ),
          ),

          // Section Content (Shown only if expanded)
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.defaultPadding,
                right: AppConstants.defaultPadding,
                bottom: AppConstants.defaultPadding,
              ),
              child: child,
            ),
        ],
      ),
    );
  }

  /// Row with icon, label & value (used in profile section)
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.primaryColor, size: 20),
          const SizedBox(width: AppConstants.smallPadding),

          // Label + Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      color: AppConstants.textPrimaryColor,
                      fontSize: 14,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Education field with label + placeholder
  Widget _buildEducationField(String label, String placeholder, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.primaryColor, size: 20),
          const SizedBox(width: AppConstants.smallPadding),

          // Label + Input Container
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: 12,
                    )),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.smallPadding,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                    border: Border.all(
                      color: AppConstants.borderColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    placeholder,
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Skill chip design
  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(
          color: AppConstants.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Experience item with company, position, and duration
  Widget _buildExperienceItem(String company, String position, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  position,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            duration,
            style: const TextStyle(
              fontSize: 13,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Certificate upload area with file picker functionality
  Widget _buildCertificateUploadArea() {
    return Column(
      children: [
        // Upload Area
        GestureDetector(
          onTap: _pickCertificateFile, // Trigger file picker when upload area is tapped
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding * 2),
            decoration: BoxDecoration(
              color: AppConstants.cardBackgroundColor, // Light background
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: AppConstants.borderColor.withValues(alpha: 0.5), // Lighter border
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined, // Upload icon
                  size: 48,
                  color: AppConstants.primaryColor,
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  'Click to upload documents',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  'Supported formats: PDF, DOC, DOCX',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        
        // Alternative upload button
        ElevatedButton(
          onPressed: _pickCertificateFile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.accentColor,
            foregroundColor: AppConstants.backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            ),
          ),
          child: const Text('Upload Certificate'),
        ),
      ],
    );
  }

  /// ---------------- NAVIGATION & ACTIONS ----------------

  /// Navigate to section-specific edit pages
  void _navigateToEditPage(String sectionTitle) {
    switch (sectionTitle) {
      case 'Profile / आपकी जानकारी':
        // Navigate to Profile Edit Page
        break;
      case 'Profile summary / प्रोफ़ाइल झलक':
        // Navigate to Summary Edit Page
        break;
      case 'Education':
        // Navigate to Education Edit Page
        break;
      case 'Key Skills':
        // Navigate to Skills Edit Page
        break;
      case 'Experience':
        // Navigate to Experience Edit Page
        break;
      case 'Certificates':
        // Navigate to Certificates Edit Page
        break;
      case 'Resume/CV':
        // Navigate to Resume Edit Page
        NavigationService.smartNavigate(
          destination: const ResumeScreen(),
        );
        break;
    }
  }

  /// Handles picking a file from the device's drive
  void _pickFile() async {
    // TODO: Add 'file_picker: ^latest_version' to your pubspec.yaml dependencies
    // and import 'package:file_picker/file_picker.dart'; at the top of the file.

    // Example implementation using file_picker:
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf', 'doc', 'docx'], // Specify allowed file types
    // );

    // if (result != null) {
    //   PlatformFile file = result.files.first;
    //   print('Picked file: ${file.name}');
    //   setState(() {
    //     _uploadedResumeFileName = file.name;
    //     // You might want to format the date as needed
    //     _lastResumeUpdatedDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
    //   });
    //   // TODO: Implement logic to upload the file to your backend/storage
    // } else {
    //   // User canceled the picker
    //   print('File picking canceled.');
    // }
    
    // For now, let's just simulate an update for demonstration
    setState(() {
      _uploadedResumeFileName = 'New_Resume_Updated.pdf';
      _lastResumeUpdatedDate = '25 July 2024';
    });
    // TODO: Replace this with actual file picker implementation
    // This simulates file pick and update for demonstration purposes
  }

  /// Handles picking a file for certificates
  void _pickCertificateFile() async {
    // TODO: Add 'file_picker: ^latest_version' to your pubspec.yaml dependencies
    // and import 'package:file_picker/file_picker.dart'; at the top of the file.

    // Example implementation using file_picker:
    // FilePickerResult? result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf', 'doc', 'docx'], // Specify allowed file types
    // );

    // if (result != null) {
    //   PlatformFile file = result.files.first;
    //   print('Picked certificate file: ${file.name}');
    //   // TODO: Implement logic to upload the file to your backend/storage
    // } else {
    //   // User canceled the picker
    //   print('Certificate file picking canceled.');
    // }
    
    // For now, let's just simulate an update for demonstration
    setState(() {
      // _uploadedResumeFileName = 'New_Certificate_Updated.pdf'; // Example file name
      // _lastResumeUpdatedDate = '25 July 2024'; // Example last updated date
    });
    // TODO: Replace this with actual file picker implementation
    // This simulates file pick and update for demonstration purposes
  }

  /// Show full profile summary in a dialog box
  void _showFullProfileSummary(String summary) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Summary'),
          content: SingleChildScrollView(
            child: Text(
              summary,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Toggle expand/collapse for different sections
  void _toggleSection(String section) {
    setState(() {
      switch (section) {
        case 'profile':
          _isProfileExpanded = !_isProfileExpanded;
          break;
        case 'summary':
          _isSummaryExpanded = !_isSummaryExpanded;
          break;
        case 'education':
          _isEducationExpanded = !_isEducationExpanded;
          break;
        case 'skills':
          _isSkillsExpanded = !_isSkillsExpanded;
          break;
        case 'experience':
          _isExperienceExpanded = !_isExperienceExpanded;
          break;
        case 'certificates':
          _isCertificatesExpanded = !_isCertificatesExpanded;
          break;
        case 'resume':
          _isResumeExpanded = !_isResumeExpanded;
          break;
      }
    });
  }
}

