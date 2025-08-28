import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../data/user_data.dart';
import '../../utils/navigation_service.dart';
import 'resume.dart';
import 'profile_details/profile_edit.dart';
import 'profile_details/profile_summary_edit.dart';
import 'profile_details/education_edit.dart';
import 'profile_details/skills_edit.dart';
import 'profile_details/experience_edit.dart';
import 'profile_details/certificates_edit.dart';

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
  
  /// State variables for certificates
  final List<Map<String, dynamic>> _uploadedCertificates = [];

  @override
  void initState() {
    super.initState();
    // Initialize with mock data or actual user data if available
    _uploadedResumeFileName = 'Morgan Carter CV 7 Year Experience'; // Example file name
    _lastResumeUpdatedDate = '17 July 2024'; // Example last updated date
    
    // Initialize with sample certificates to show by default
    _uploadedCertificates.addAll([
      {
        'name': 'ITI Certificate.pdf',
        'type': 'Certificate',
        'uploadDate': '15 July 2024',
        'size': 1024000,
        'extension': 'pdf',
      },
      {
        'name': 'Safety Training License.pdf',
        'type': 'License',
        'uploadDate': '10 July 2024',
        'size': 850000,
        'extension': 'pdf',
      },
      {
        'name': 'Aadhar Card.jpg',
        'type': 'ID Proof',
        'uploadDate': '5 July 2024',
        'size': 450000,
        'extension': 'jpg',
      },
    ]);
    
    // Set all sections to be collapsed by default (showing down arrows)
    _isProfileExpanded = false;
    _isSummaryExpanded = false;
    _isEducationExpanded = false;
    _isSkillsExpanded = false;
    _isExperienceExpanded = false;
    _isCertificatesExpanded = false;
    _isResumeExpanded = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning from edit pages
    setState(() {});
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
    final user = UserData.currentUser;
    final qualification = user['education_qualification'] ?? '';
    final course = user['education_course'] ?? '';
    
    return _buildSectionCard(
      title: 'Education',
      icon: Icons.school_outlined,
      isExpanded: _isEducationExpanded,
      onEditTap: () => _toggleSection('education'),
      child: Column(
        children: [
          _buildEducationField('Highest Qualification', qualification.isNotEmpty ? qualification : 'Select', Icons.school_outlined),
          _buildEducationField('Institute name', user['education_institute'] ?? 'Not specified', Icons.business_outlined),
          _buildEducationField('Course Name', course.isNotEmpty ? course : 'Not specified', Icons.description_outlined),
          
          // Show year and percentage for completed education
          if (qualification.isNotEmpty && qualification != 'Select') ...[
            const SizedBox(height: AppConstants.smallPadding),
            _buildEducationField('Year of Completion', user['education_year'] ?? 'Not specified', Icons.calendar_today_outlined),
            _buildEducationField('Percentage/CGPA', user['education_percentage'] ?? 'Not specified', Icons.grade_outlined),
          ],
          
          // Show additional fields based on qualification type
          if (qualification.contains('ITI') || qualification.contains('Diploma')) ...[
            const SizedBox(height: AppConstants.smallPadding),
            _buildEducationField('Trade/Specialization', course.isNotEmpty ? course : 'Not specified', Icons.work_outline),
            _buildEducationField('Practical Training', 'Completed', Icons.build_outlined),
          ],
          
          // Show additional fields for degree courses
          if (qualification.contains('Bachelor') || qualification.contains('Master')) ...[
            const SizedBox(height: AppConstants.smallPadding),
            _buildEducationField('Major/Subject', course.isNotEmpty ? course : 'Not specified', Icons.book_outlined),
            _buildEducationField('University', user['education_institute'] ?? 'Not specified', Icons.account_balance_outlined),
          ],
          
          // Show additional fields for school education
          if (qualification.contains('10th') || qualification.contains('12th')) ...[
            const SizedBox(height: AppConstants.smallPadding),
            _buildEducationField('Board', user['education_institute'] ?? 'Not specified', Icons.school_outlined),
            _buildEducationField('Stream', course.isNotEmpty ? course : 'Not specified', Icons.trending_up_outlined),
          ],
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
    
    // Default fallback skills if none found (ITI relevant)
    if (userSkills.isEmpty) {
      userSkills = ['Electrical Wiring', 'Safety Procedures', 'Basic Hand Tools', 'Quality Awareness', 'Teamwork'];
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
    final user = UserData.currentUser;
    List<Map<String, dynamic>> experiences = [];
    
    try {
      final experiencesData = user['experiences'];
      if (experiencesData is List) {
        experiences = experiencesData.whereType<Map<String, dynamic>>().toList();
      }
    } catch (e) {
      experiences = []; // Handle errors safely
    }
    
    // Default fallback experiences if none found
    if (experiences.isEmpty) {
      experiences = [
        {'company': 'E-commerce Websites', 'position': 'example.com', 'startDate': 'July 2016', 'endDate': 'July 2019'},
        {'company': 'Custom Web Applications', 'position': 'example.com', 'startDate': 'April 2019', 'endDate': 'Oct 2021'},
      ];
    }
    
    return _buildSectionCard(
      title: 'Experience',
      icon: Icons.work_outline,
      isExpanded: _isExperienceExpanded,
      onEditTap: () => _toggleSection('experience'),
      child: Column(
        children: [
          ...experiences.map((exp) => _buildExperienceItem(
            exp['company'] ?? '',
            exp['position'] ?? '',
            '${exp['startDate'] ?? ''} - ${exp['endDate'] ?? ''}',
          )),
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
    return _buildSectionCard(
      title: 'Resume/CV',
      icon: Icons.description_outlined,
      isExpanded: _isResumeExpanded,
      onEditTap: () => _toggleSection('resume'),
      child: _buildResumeContent(),
    );
  }

  /// Builds the content for resume section
  Widget _buildResumeContent() {
    return Column(
      children: [
        // Display Uploaded File
        if (_uploadedResumeFileName != null && _uploadedResumeFileName!.isNotEmpty) ...[
          Row(
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
              Expanded(
                child: Column(
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
              ),
            ],
          ),
        ] else ...[
          // No resume uploaded yet
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.cardBackgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
              border: Border.all(
                color: AppConstants.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppConstants.textSecondaryColor, size: 20),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    'No resume uploaded yet.',
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
              ],
            ),
          ),
        ],
      ],
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
          // Section Header with Title + Edit Button + Toggle Arrow
          ListTile(
            leading: Icon(icon, color: AppConstants.primaryColor, size: 24),
            title: Text(
              title,
              style: const TextStyle(
                color: AppConstants.textPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit Button
                IconButton(
                  icon: const Icon(Icons.edit, color: AppConstants.primaryColor, size: 20),
                  onPressed: () => _navigateToEditPage(title), // Navigate to edit page
                ),
                // Toggle Arrow Button
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppConstants.primaryColor,
                    size: 24,
                  ),
                  onPressed: onEditTap, // This will toggle the section
                ),
              ],
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

  /// Certificate display area (read-only)
  Widget _buildCertificateUploadArea() {
    return Column(
      children: [
        // Display uploaded certificates
        if (_uploadedCertificates.isNotEmpty) ...[
          ..._uploadedCertificates.map((cert) => _buildCertificateTile(cert)),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.cardBackgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
              border: Border.all(
                color: AppConstants.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppConstants.textSecondaryColor, size: 20),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'No certificates uploaded yet.',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// ---------------- NAVIGATION & ACTIONS ----------------

  /// Navigate to section-specific edit pages
  void _navigateToEditPage(String sectionTitle) {
    switch (sectionTitle) {
      case 'Profile / आपकी जानकारी':
        // Navigate to Profile Edit Page
        NavigationService.smartNavigate(
          destination: const ProfileEditScreen(),
        );
        break;
      case 'Profile summary / प्रोफ़ाइल झलक':
        // Navigate to Summary Edit Page
        NavigationService.smartNavigate(
          destination: const ProfileSummaryEditScreen(),
        );
        break;
      case 'Education':
        // Navigate to Education Edit Page
        NavigationService.smartNavigate(
          destination: const EducationEditScreen(),
        );
        break;
      case 'Key Skills':
        // Navigate to Skills Edit Page
        NavigationService.smartNavigate(
          destination: const SkillsEditScreen(),
        );
        break;
      case 'Experience':
        // Navigate to Experience Edit Page
        NavigationService.smartNavigate(
          destination: const ExperienceEditScreen(),
        );
        break;
      case 'Certificates':
        // Navigate to Certificates Edit Page
        NavigationService.smartNavigate(
          destination: const CertificatesEditScreen(),
        );
        break;
      case 'Resume/CV':
        // Navigate to Resume Edit Page
        NavigationService.smartNavigate(
          destination: const ResumeScreen(),
        );
        break;
    }
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

  /// Gets certificate color based on type
  Color _getCertificateColor(String type) {
    switch (type.toLowerCase()) {
      case 'certificate':
        return Colors.green;
      case 'license':
        return Colors.blue;
      case 'id proof':
        return Colors.orange;
      case 'experience letter':
        return Colors.purple;
      case 'educational document':
        return Colors.indigo;
      case 'training certificate':
        return Colors.cyan;
      case 'pdf document':
        return Colors.red;
      case 'image document':
        return Colors.teal;
      case 'word document':
        return Colors.blueGrey;
      default:
        return AppConstants.primaryColor;
    }
  }

  /// Gets certificate icon based on type
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
      case 'educational document':
        return Icons.school;
      case 'training certificate':
        return Icons.psychology;
      case 'pdf document':
        return Icons.picture_as_pdf;
      case 'image document':
        return Icons.image;
      case 'word document':
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Builds a certificate tile for display
  Widget _buildCertificateTile(Map<String, dynamic> certificate) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(
          color: AppConstants.borderColor.withValues(alpha: 0.2),
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

  /// Deletes a certificate from the list
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

  /// Shows a snackbar message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
      ),
    );
  }

}

