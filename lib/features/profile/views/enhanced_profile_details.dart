import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/widgets/loaders/jobsahi_loader.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Enhanced Profile Details Screen with Modern UI/UX
class EnhancedProfileDetailsScreen extends StatelessWidget {
  final bool isFromBottomNavigation;

  const EnhancedProfileDetailsScreen({
    super.key,
    this.isFromBottomNavigation = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(const LoadProfileDataEvent()),
      child: _EnhancedProfileDetailsView(
        isFromBottomNavigation: isFromBottomNavigation,
      ),
    );
  }
}

class _EnhancedProfileDetailsView extends StatelessWidget {
  final bool isFromBottomNavigation;

  const _EnhancedProfileDetailsView({required this.isFromBottomNavigation});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is CertificateDeletedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppConstants.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ProfileImageRemovedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image removed successfully!'),
              backgroundColor: AppConstants.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppConstants.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            body: Center(
              child: JobsahiLoader(
                size: 60,
                strokeWidth: 4,
                message: 'Loading profile...',
                showMessage: true,
              ),
            ),
          );
        } else if (state is ProfileDetailsLoaded) {
          return _buildEnhancedProfileDetails(context, state);
        } else if (state is ProfileError) {
          return Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            body: NoInternetErrorWidget(
              errorMessage: state.message,
              onRetry: () {
                context.read<ProfileBloc>().add(const LoadProfileDataEvent());
              },
              showImage: true,
              enablePullToRefresh: true,
            ),
          );
        }
        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          body: Center(
            child: JobsahiLoader(
              size: 60,
              strokeWidth: 4,
              message: 'Loading...',
              showMessage: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedProfileDetails(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    return KeyboardDismissWrapper(
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(context, state),

              // Profile Content
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    // Quick Stats Cards
                    _buildQuickStatsCards(context, state),
                    const SizedBox(height: AppConstants.largePadding),

                    // Profile Sections
                    _buildProfileSections(context, state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Profile Header Section
  Widget _buildProfileHeader(BuildContext context, ProfileDetailsLoaded state) {
    final user = state.userProfile;
    final rawBio = user['bio'];
    final String? profileBio =
        rawBio is String && rawBio.trim().isNotEmpty ? rawBio.trim() : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.defaultPadding,
            AppConstants.smallPadding,
            AppConstants.defaultPadding,
            AppConstants.defaultPadding,
          ),
          child: Column(
            children: [
              // Top Navigation Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  if (!isFromBottomNavigation)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    )
                  else
                    const SizedBox(width: 48), // Spacer for alignment
                  // Action Buttons
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => _navigateToEditProfile(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () => _shareProfile(context),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.smallPadding),

              // Profile Image (Centered)
              Stack(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: state.profileImagePath != null
                          ? ClipOval(
                              child: Image.asset(
                                state.profileImagePath!,
                                fit: BoxFit.cover,
                                width: 64,
                                height: 64,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultProfileImage();
                                },
                              ),
                            )
                          : _buildDefaultProfileImage(),
                    ),
                  ),
                  // Online Status Indicator
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppConstants.successColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.smallPadding),

              // User Info (Centered)
              Column(
                children: [
                  Text(
                    user['name'] ?? 'User Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['email'] ?? 'user@email.com',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user['location'] ?? 'Location not set',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (profileBio != null) ...[
                const SizedBox(height: AppConstants.defaultPadding),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      AppConstants.smallBorderRadius,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile Brief',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profileBio,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppConstants.defaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  /// Quick Stats Cards
  Widget _buildQuickStatsCards(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.work_outline,
            title: 'Experience',
            value: '${state.experience.length} Years',
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: _buildStatCard(
            icon: Icons.school_outlined,
            title: 'Education',
            value: state.education.isNotEmpty ? 'Graduated' : 'Not Set',
            color: AppConstants.secondaryColor,
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star_outline,
            title: 'Skills',
            value: '${state.skills.length} Skills',
            color: AppConstants.warningColor,
          ),
        ),
      ],
    );
  }

  /// Individual Stat Card
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Profile Sections
  Widget _buildProfileSections(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    return Column(
      children: [
        // Skills Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Skills & Expertise',
          icon: Icons.star_outline,
          section: 'skills',
          child: _buildSkillsContent(state.skills),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Experience Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Work Experience',
          icon: Icons.work_outline,
          section: 'experience',
          child: _buildExperienceContent(state.experience),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Education Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Education',
          icon: Icons.school_outlined,
          section: 'education',
          child: _buildEducationContent(state.education),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Documents Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Documents & Certificates',
          icon: Icons.folder_outlined,
          section: 'certificates',
          child: _buildDocumentsContent(context, state),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Contact & Social Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Contact & Social',
          icon: Icons.contact_page_outlined,
          section: 'contact',
          child: _buildContactContent(state.userProfile),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Social Links Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Social Links & Portfolio',
          icon: Icons.link_outlined,
          section: 'social',
          child: _buildSocialLinksContent(context, state.userProfile),
        ),
      ],
    );
  }

  /// Modern Section Card with Better UX
  Widget _buildModernSectionCard({
    required BuildContext context,
    required ProfileDetailsLoaded state,
    required String title,
    required IconData icon,
    required String section,
    required Widget child,
  }) {
    final isExpanded = state.sectionExpansionStates[section] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.read<ProfileBloc>().add(
                ToggleSectionEvent(section: section),
              ),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              child: Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppConstants.textSecondaryColor,
                      ),
                      onPressed: () => context.read<ProfileBloc>().add(
                        ToggleSectionEvent(section: section),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: AppConstants.primaryColor,
                        size: 18,
                      ),
                      onPressed: () => _navigateToEditSection(context, section),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.defaultPadding,
                0,
                AppConstants.defaultPadding,
                AppConstants.defaultPadding,
              ),
              child: child,
            ),
        ],
      ),
    );
  }

  /// Skills Content
  Widget _buildSkillsContent(List<String> skills) {
    if (skills.isEmpty) {
      return _buildEmptyState(
        icon: Icons.star_outline,
        title: 'No Skills Added',
        subtitle: 'Add your skills to showcase your expertise',
      );
    }

    return Wrap(
      spacing: AppConstants.smallPadding,
      runSpacing: AppConstants.smallPadding,
      children: skills.map((skill) => _buildSkillChip(skill)).toList(),
    );
  }

  /// Experience Content
  Widget _buildExperienceContent(List<Map<String, dynamic>> experience) {
    if (experience.isEmpty) {
      return _buildEmptyState(
        icon: Icons.work_outline,
        title: 'No Experience Added',
        subtitle: 'Add your work experience to build your profile',
      );
    }

    return Column(
      children: experience.map((exp) => _buildExperienceCard(exp)).toList(),
    );
  }

  /// Education Content
  Widget _buildEducationContent(List<Map<String, dynamic>> education) {
    if (education.isEmpty) {
      return _buildEmptyState(
        icon: Icons.school_outlined,
        title: 'No Education Added',
        subtitle: 'Add your educational background',
      );
    }

    return Column(
      children: education.map((edu) => _buildEducationCard(edu)).toList(),
    );
  }

  /// Documents Content
  Widget _buildDocumentsContent(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    return Column(
      children: [
        // Resume
        if (state.resumeFileName != null)
          _buildDocumentCard(
            icon: Icons.description,
            title: 'Resume',
            fileName: state.resumeFileName!,
            lastUpdated: state.lastResumeUpdatedDate ?? 'Unknown',
            onDownload: () => _downloadResume(context),
          ),

        // Certificates
        if (state.certificates.isNotEmpty) ...[
          const SizedBox(height: AppConstants.smallPadding),
          ...state.certificates.map(
            (cert) => _buildDocumentCard(
              icon: _getCertificateIcon(cert['type'] ?? ''),
              title: cert['name'] ?? 'Document',
              fileName: cert['name'] ?? 'Document',
              lastUpdated: cert['uploadDate'] ?? 'Unknown',
              onDownload: () => _downloadDocument(context, cert),
              onDelete: () => _deleteDocument(context, cert),
            ),
          ),
        ],

        if (state.resumeFileName == null && state.certificates.isEmpty)
          _buildEmptyState(
            icon: Icons.folder_outlined,
            title: 'No Documents Added',
            subtitle: 'Upload your resume and certificates',
          ),
      ],
    );
  }

  /// Contact Content
  Widget _buildContactContent(Map<String, dynamic> userProfile) {
    return Column(
      children: [
        _buildContactItem(
          icon: Icons.email_outlined,
          label: 'Email',
          value: userProfile['email'] ?? 'Not provided',
        ),
        _buildContactItem(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: userProfile['phone'] ?? 'Not provided',
        ),
        _buildContactItem(
          icon: Icons.location_on_outlined,
          label: 'Location',
          value: userProfile['location'] ?? 'Not provided',
        ),
        if (userProfile['gender'] != null)
          _buildContactItem(
            icon: Icons.person_outline,
            label: 'Gender',
            value: userProfile['gender'],
          ),
        if (userProfile['dateOfBirth'] != null)
          _buildContactItem(
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: userProfile['dateOfBirth'],
          ),
        if (userProfile['languages'] != null &&
            userProfile['languages'].toString().isNotEmpty)
          _buildContactItem(
            icon: Icons.language_outlined,
            label: 'Languages',
            value: userProfile['languages'],
          ),
        if (userProfile['aadharNumber'] != null &&
            userProfile['aadharNumber'].toString().isNotEmpty)
          _buildContactItem(
            icon: Icons.badge_outlined,
            label: 'Aadhar Number',
            value: userProfile['aadharNumber'],
          ),
      ],
    );
  }

  /// Social Links Content
  Widget _buildSocialLinksContent(
    BuildContext context,
    Map<String, dynamic> userProfile,
  ) {
    final hasPortfolio =
        userProfile['portfolioLink'] != null &&
        userProfile['portfolioLink'].toString().isNotEmpty;
    final hasLinkedIn =
        userProfile['linkedinUrl'] != null &&
        userProfile['linkedinUrl'].toString().isNotEmpty;

    if (!hasPortfolio && !hasLinkedIn) {
      return _buildEmptyState(
        icon: Icons.link_outlined,
        title: 'No Social Links Added',
        subtitle: 'Add your portfolio and LinkedIn profile',
      );
    }

    return Column(
      children: [
        if (hasPortfolio)
          _buildSocialLinkItem(
            icon: Icons.web_outlined,
            label: 'Portfolio',
            value: userProfile['portfolioLink'],
            onTap: () => _openUrl(context, userProfile['portfolioLink']),
          ),
        if (hasLinkedIn)
          _buildSocialLinkItem(
            icon: Icons.work_outline,
            label: 'LinkedIn',
            value: userProfile['linkedinUrl'],
            onTap: () => _openUrl(context, userProfile['linkedinUrl']),
          ),
      ],
    );
  }

  /// Helper Widgets
  Widget _buildDefaultProfileImage() {
    return Container(
      color: AppConstants.backgroundColor,
      child: const Icon(
        Icons.person,
        size: 36,
        color: AppConstants.textSecondaryColor,
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          color: AppConstants.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exp['company'] ?? 'Company',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            exp['position'] ?? 'Position',
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${exp['startDate']} - ${exp['endDate'] ?? 'Present'}',
            style: const TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          if (exp['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              exp['description'],
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.textPrimaryColor,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationCard(Map<String, dynamic> edu) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            edu['qualification'] ?? 'Qualification',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            edu['course'] ?? 'Course',
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${edu['passingYear'] ?? 'Year'} • CGPA: ${edu['cgpa'] ?? 'N/A'}',
            style: const TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required IconData icon,
    required String title,
    required String fileName,
    required String lastUpdated,
    required VoidCallback onDownload,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 20),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                Text(
                  'Updated: $lastUpdated',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppConstants.primaryColor),
            onPressed: onDownload,
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: AppConstants.errorColor),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.textSecondaryColor, size: 20),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinkItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppConstants.primaryColor, size: 20),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new,
                color: AppConstants.primaryColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppConstants.textSecondaryColor),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Navigation and Actions
  void _navigateToEditProfile(BuildContext context) {
    // Navigate to profile edit screen
    context.push(AppRoutes.profileEdit);
  }

  void _navigateToEditSection(BuildContext context, String section) {
    switch (section) {
      case 'skills':
        context.push(AppRoutes.profileSkillsEdit);
        break;
      case 'experience':
        context.push(AppRoutes.profileExperienceEdit);
        break;
      case 'education':
        context.push(AppRoutes.profileEducationEdit);
        break;
      case 'certificates':
        context.push(AppRoutes.profileCertificatesEdit);
        break;
      case 'contact':
        context.push(AppRoutes.profileEdit);
        break;
      case 'social':
        context.push(AppRoutes.profileEdit);
        break;
    }
  }

  void _openUrl(BuildContext context, String url) {
    // TODO: Implement URL launcher
    // For now, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: $url'),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareProfile(BuildContext context) {
    // Implement profile sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile sharing feature coming soon!'),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadResume(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading resume...'),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadDocument(BuildContext context, Map<String, dynamic> document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${document['name'] ?? 'document'}...'),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteDocument(BuildContext context, Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: Text(
            'Are you sure you want to delete "${document['name'] ?? 'document'}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<ProfileBloc>().add(
                  DeleteCertificateEvent(certificate: document),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  IconData _getCertificateIcon(String type) {
    switch (type.toLowerCase()) {
      case 'certificate':
        return Icons.school;
      case 'license':
        return Icons.verified;
      case 'id proof':
        return Icons.badge;
      default:
        return Icons.description;
    }
  }
}
