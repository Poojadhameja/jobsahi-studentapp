import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/services/location_service.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'enhanced_profile_details.dart';

/// ---------------- PROFILE DETAILS SCREEN ----------------
class ProfileDetailsScreen extends StatelessWidget {
  final bool isFromBottomNavigation;

  const ProfileDetailsScreen({super.key, this.isFromBottomNavigation = false});

  @override
  Widget build(BuildContext context) {
    // Use the enhanced profile details screen
    return EnhancedProfileDetailsScreen(
      isFromBottomNavigation: isFromBottomNavigation,
    );
  }
}

class _ProfileDetailsView extends StatelessWidget {
  final bool isFromBottomNavigation;

  const _ProfileDetailsView({required this.isFromBottomNavigation});

  /// Gets user's current location for display
  Future<String> _getUserLocation() async {
    try {
      final locationService = LocationService.instance;
      await locationService.initialize();

      // Try to get saved location first
      final savedLocation = await locationService.getSavedLocation();
      if (savedLocation != null) {
        return '${savedLocation.latitude.toStringAsFixed(4)}, ${savedLocation.longitude.toStringAsFixed(4)}';
      }

      // If no saved location, try to get current location
      final currentLocation = await locationService.getCurrentLocation();
      if (currentLocation != null) {
        return '${currentLocation.latitude.toStringAsFixed(4)}, ${currentLocation.longitude.toStringAsFixed(4)}';
      }

      return 'Location not available';
    } catch (e) {
      return 'Location not available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is CertificateDeletedSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is ProfileImageRemovedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image removed successfully!'),
            ),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is ProfileDetailsLoaded) {
          return _buildProfileDetails(context, state);
        } else if (state is ProfileError) {
          return Scaffold(
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
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildProfileDetails(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    return KeyboardDismissWrapper(
      child: Scaffold(
        backgroundColor: AppConstants.cardBackgroundColor,

        /// AppBar with back button & title (only when not from bottom navigation)
        appBar: isFromBottomNavigation
            ? null
            : AppBar(
                backgroundColor: AppConstants.backgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppConstants.textPrimaryColor,
                  ),
                  onPressed: () => context.pop(), // Go back to previous screen
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
                // Profile Image Section (Center)
                _buildProfileImageSection(context, state),
                const SizedBox(height: AppConstants.defaultPadding),

                // Profile Section
                _buildProfileSection(context, state),
                const SizedBox(height: AppConstants.defaultPadding),

                // Profile Summary Section
                _buildProfileSummarySection(context, state),
                const SizedBox(height: AppConstants.defaultPadding),

                // Education Section
                _buildEducationSection(context, state),
                const SizedBox(height: AppConstants.defaultPadding),

                // Key Skills Section
                _buildKeySkillsSection(context, state),
                const SizedBox(height: AppConstants.defaultPadding),

                // Experience Section
                _buildExperienceSection(context, state),
                const SizedBox(height: AppConstants.defaultPadding),

                // Certificates Section
                _buildCertificatesSection(context, state),
                const SizedBox(height: AppConstants.defaultPadding),

                // Resume/CV Section
                _buildResumeSection(context, state),
                const SizedBox(height: AppConstants.defaultPadding),

                // Location Section
                _buildLocationSection(context, state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------- PROFILE IMAGE SECTION ----------------
  /// Shows profile image at the center with upload functionality
  Widget _buildProfileImageSection(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image
          GestureDetector(
            onTap: () => _showProfileImageOptions(context, state),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppConstants.primaryColor, width: 3),
              ),
              child: ClipOval(
                child: state.profileImagePath != null
                    ? Image.asset(
                        state.profileImagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultProfileImage();
                        },
                      )
                    : _buildDefaultProfileImage(),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.smallPadding),

          // Upload/Change Text
          Text(
            state.profileImagePath != null ? 'Change Photo' : 'Upload Photo',
            style: const TextStyle(
              color: AppConstants.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),
        ],
      ),
    );
  }

  /// Builds default profile image placeholder
  Widget _buildDefaultProfileImage() {
    return Container(
      color: AppConstants.cardBackgroundColor,
      child: const Icon(
        Icons.person,
        size: 60,
        color: AppConstants.textSecondaryColor,
      ),
    );
  }

  /// Shows options for profile image (upload/remove)
  void _showProfileImageOptions(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext dialogContext) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.profileImagePath != null) ...[
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    context.read<ProfileBloc>().add(
                      const RemoveProfileImageEvent(),
                    );
                  },
                ),
                const Divider(),
              ],
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppConstants.primaryColor,
                ),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _uploadProfileImage(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppConstants.primaryColor,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _uploadProfileImage(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Handles profile image upload
  void _uploadProfileImage(BuildContext context) {
    // TODO: Implement actual image picker functionality
    // For now, simulate upload with sample data
    context.read<ProfileBloc>().add(
      const UpdateProfileImageEvent(
        imagePath: 'assets/images/profile/sample_profile.jpg',
      ),
    );
    _showMessage(context, 'Profile image uploaded successfully!');
  }

  /// ---------------- PROFILE SECTION ----------------
  /// Shows user details like Email, Location, Phone, Experience
  Widget _buildProfileSection(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    final user = state.userProfile;
    return _buildSectionCard(
      context: context,
      state: state,
      title: 'Profile',
      icon: Icons.person_outline,
      section: 'profile',
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email', user['email'] ?? 'N/A'),
          FutureBuilder<String>(
            future: _getUserLocation(),
            builder: (context, snapshot) {
              return _buildInfoRow(
                Icons.location_on_outlined,
                'Location',
                snapshot.data ?? 'Getting location...',
              );
            },
          ),
          _buildInfoRow(
            Icons.work_outline,
            'Experience',
            user['experience'] ?? '8 Year',
          ),
        ],
      ),
    );
  }

  /// ---------------- PROFILE SUMMARY SECTION ----------------
  /// Shows a short description about the user with "Read More" option
  Widget _buildProfileSummarySection(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    final user = state.userProfile;
    final summary = user['bio'] ?? 'No summary available';
    final isLongSummary = summary.length > 100;

    return _buildSectionCard(
      context: context,
      state: state,
      title: 'Profile Summary',
      icon: Icons.description_outlined,
      section: 'summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLongSummary ? '${summary.substring(0, 100)}...' : summary,
            style: const TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (isLongSummary) ...[
            const SizedBox(height: AppConstants.smallPadding),
            GestureDetector(
              onTap: () => _showFullProfileSummary(context, summary),
              child: const Text(
                'Read More',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ---------------- EDUCATION SECTION ----------------
  /// Displays education fields like Qualification, Institute, Course
  Widget _buildEducationSection(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    final user = state.userProfile;
    return _buildSectionCard(
      context: context,
      state: state,
      title: 'Education',
      icon: Icons.school_outlined,
      section: 'education',
      child: Column(
        children: [
          _buildEducationField(
            'Qualification',
            user['qualification'] ?? 'ITI (Industrial Training Institute)',
            Icons.school_outlined,
          ),
          _buildEducationField(
            'Institute',
            user['institute'] ?? 'Government ITI, Mumbai',
            Icons.location_city_outlined,
          ),
          _buildEducationField(
            'Course',
            user['course'] ?? 'Electrician',
            Icons.book_outlined,
          ),
          _buildEducationField(
            'Passing Year',
            user['passingYear'] ?? '2020',
            Icons.calendar_today_outlined,
          ),
        ],
      ),
    );
  }

  /// ---------------- KEY SKILLS SECTION ----------------
  /// Displays list of user's skills in chip format
  Widget _buildKeySkillsSection(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    final userSkills = state.skills;

    return _buildSectionCard(
      context: context,
      state: state,
      title: 'Key Skills',
      icon: Icons.grid_view_outlined,
      section: 'skills',
      child: Wrap(
        spacing: AppConstants.smallPadding,
        runSpacing: AppConstants.smallPadding,
        children: userSkills.map((skill) => _buildSkillChip(skill)).toList(),
      ),
    );
  }

  /// ---------------- EXPERIENCE SECTION ----------------
  /// Displays user's work experience with company, position, and duration
  Widget _buildExperienceSection(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    final experiences = state.experience;

    return _buildSectionCard(
      context: context,
      state: state,
      title: 'Experience',
      icon: Icons.work_outline,
      section: 'experience',
      child: Column(
        children: experiences.isEmpty
            ? [
                const Text(
                  'No experience added yet',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ]
            : experiences
                  .map(
                    (exp) => _buildExperienceItem(
                      exp['company'] ?? 'N/A',
                      exp['position'] ?? 'N/A',
                      exp['startDate'] ?? 'N/A',
                      exp['endDate'],
                    ),
                  )
                  .toList(),
      ),
    );
  }

  /// ---------------- CERTIFICATES SECTION ----------------
  /// Displays certificates section with file upload functionality
  Widget _buildCertificatesSection(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    return _buildSectionCard(
      context: context,
      state: state,
      title: 'Certificates',
      icon: Icons.badge_outlined,
      section: 'certificates',
      child: _buildCertificateUploadArea(context, state),
    );
  }

  /// ---------------- RESUME/CV SECTION ----------------
  /// Displays resume/CV section with file management
  Widget _buildResumeSection(BuildContext context, ProfileDetailsLoaded state) {
    return _buildSectionCard(
      context: context,
      state: state,
      title: 'Resume/CV',
      icon: Icons.description_outlined,
      section: 'resume',
      child: _buildResumeContent(context, state),
    );
  }

  /// ---------------- LOCATION SECTION ----------------
  /// Displays current location with update functionality
  Widget _buildLocationSection(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    return _buildSectionCard(
      context: context,
      state: state,
      title: 'Current Location',
      icon: Icons.location_on_outlined,
      section: 'location',
      child: _buildLocationContent(context, state),
    );
  }

  /// Builds the content for resume section
  Widget _buildResumeContent(BuildContext context, ProfileDetailsLoaded state) {
    return Column(
      children: [
        if (state.resumeFileName != null) ...[
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.cardBackgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppConstants.borderColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.description,
                  color: AppConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.resumeFileName!,
                        style: const TextStyle(
                          color: AppConstants.textPrimaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (state.lastResumeUpdatedDate != null)
                        Text(
                          'Updated: ${state.lastResumeUpdatedDate}',
                          style: const TextStyle(
                            color: AppConstants.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.download,
                    color: AppConstants.primaryColor,
                  ),
                  onPressed: () =>
                      _showMessage(context, 'Downloading resume...'),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.cardBackgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: AppConstants.borderColor,
                style: BorderStyle.solid,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.upload_file,
                  color: AppConstants.textSecondaryColor,
                  size: 48,
                ),
                SizedBox(height: AppConstants.smallPadding),
                Text(
                  'No resume uploaded yet',
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

  /// Builds the content for location section
  Widget _buildLocationContent(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    return FutureBuilder<LocationData?>(
      future: LocationService.instance.getSavedLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.cardBackgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppConstants.borderColor),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: AppConstants.smallPadding),
                const Text(
                  'Error loading location',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                ElevatedButton(
                  onPressed: () => _updateLocation(context),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final locationData = snapshot.data;

        if (locationData == null) {
          return Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.cardBackgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppConstants.borderColor),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.location_off,
                  color: AppConstants.textSecondaryColor,
                  size: 48,
                ),
                const SizedBox(height: AppConstants.smallPadding),
                const Text(
                  'No location data available',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                ElevatedButton(
                  onPressed: () => _updateLocation(context),
                  child: const Text('Get Current Location'),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppConstants.cardBackgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppConstants.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppConstants.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Location',
                          style: TextStyle(
                            color: AppConstants.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Lat: ${locationData.latitude.toStringAsFixed(4)}, Lng: ${locationData.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            color: AppConstants.textPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last updated: ${_formatDateTime(locationData.timestamp)}',
                          style: const TextStyle(
                            color: AppConstants.textSecondaryColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: AppConstants.primaryColor,
                    ),
                    onPressed: () => _updateLocation(context),
                    tooltip: 'Update Location',
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateLocation(context),
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text('Update Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _testLocationUpdate(context),
                      icon: const Icon(Icons.bug_report, size: 18),
                      label: const Text('Test API'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.warningColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Updates the current location
  Future<void> _updateLocation(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Updating location...'),
            ],
          ),
        ),
      );

      final locationService = LocationService.instance;
      final success = await locationService.completeLocationFlow(
        context: context,
      );

      // Hide loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location updated successfully!'),
              backgroundColor: AppConstants.successColor,
            ),
          );
          // Refresh the page to show updated location
          context.read<ProfileBloc>().add(const LoadProfileDataEvent());
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update location. Please try again.'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating location: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  /// Test location update with sample data
  Future<void> _testLocationUpdate(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Testing location update...'),
            ],
          ),
        ),
      );

      final locationService = LocationService.instance;
      final success = await locationService.testLocationUpdate();

      // Hide loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Test location update successful! Check logs for details.',
              ),
              backgroundColor: AppConstants.successColor,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Test location update failed! Check logs for details.',
              ),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error in test location update: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  /// Formats DateTime for display
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// ---------------- REUSABLE COMPONENTS ----------------

  /// Reusable card UI for each section
  Widget _buildSectionCard({
    required BuildContext context,
    required ProfileDetailsLoaded state,
    required String title,
    required IconData icon,
    required String section,
    required Widget child,
  }) {
    final isExpanded = state.sectionExpansionStates[section] ?? false;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with title, icon, and expand/collapse button
          InkWell(
            onTap: () => context.read<ProfileBloc>().add(
              ToggleSectionEvent(section: section),
            ),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  Icon(icon, color: AppConstants.primaryColor, size: 24),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                      size: 20,
                    ),
                    onPressed: () => _navigateToEditPage(context, title),
                  ),
                ],
              ),
            ),
          ),

          // Content (shown when expanded)
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

  /// Row with icon, label & value (used in profile section)
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
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
                    color: AppConstants.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppConstants.textPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
          Icon(icon, color: AppConstants.textSecondaryColor, size: 20),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  placeholder,
                  style: const TextStyle(
                    color: AppConstants.textPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
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

  /// Experience item with company, position, and duration
  Widget _buildExperienceItem(
    String company,
    String position,
    String startDate,
    String? endDate,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            company,
            style: const TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            position,
            style: const TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$startDate - ${endDate ?? 'Present'}',
            style: const TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Certificate display area (read-only)
  Widget _buildCertificateUploadArea(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    return Column(
      children: [
        if (state.certificates.isNotEmpty) ...[
          ...state.certificates.map(
            (certificate) => Container(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
              decoration: BoxDecoration(
                color: AppConstants.cardBackgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: AppConstants.borderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCertificateIcon(certificate['type']),
                    color: _getCertificateColor(certificate['type']),
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          certificate['name'],
                          style: const TextStyle(
                            color: AppConstants.textPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${certificate['type']} • ${certificate['uploadDate']}',
                          style: const TextStyle(
                            color: AppConstants.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () =>
                        _showDeleteCertificateDialog(context, certificate),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.cardBackgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: AppConstants.borderColor,
                style: BorderStyle.solid,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.upload_file,
                  color: AppConstants.textSecondaryColor,
                  size: 48,
                ),
                SizedBox(height: AppConstants.smallPadding),
                Text(
                  'No certificates uploaded yet',
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
  void _navigateToEditPage(BuildContext context, String sectionTitle) {
    switch (sectionTitle) {
      case 'Profile':
        context.go(AppRoutes.profileEdit);
        break;
      case 'Profile Summary':
        context.go(AppRoutes.profileSummaryEdit);
        break;
      case 'Education':
        context.go(AppRoutes.profileEducationEdit);
        break;
      case 'Key Skills':
        context.go(AppRoutes.profileSkillsEdit);
        break;
      case 'Experience':
        context.go(AppRoutes.profileExperienceEdit);
        break;
      case 'Certificates':
        context.go(AppRoutes.profileCertificatesEdit);
        break;
      case 'Resume/CV':
        context.go(AppRoutes.profileResumeEdit);
        break;
      case 'Current Location':
        _updateLocation(context);
        break;
    }
  }

  /// Show full profile summary in a dialog box
  void _showFullProfileSummary(BuildContext context, String summary) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Profile Summary'),
          content: SingleChildScrollView(
            child: Text(
              summary,
              style: const TextStyle(
                color: AppConstants.textPrimaryColor,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Show delete certificate confirmation dialog
  void _showDeleteCertificateDialog(
    BuildContext context,
    Map<String, dynamic> certificate,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Certificate'),
          content: Text(
            'Are you sure you want to delete "${certificate['name']}"?',
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
                  DeleteCertificateEvent(certificate: certificate),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Gets certificate color based on type
  Color _getCertificateColor(String type) {
    switch (type.toLowerCase()) {
      case 'certificate':
        return Colors.blue;
      case 'license':
        return Colors.green;
      case 'id proof':
        return Colors.orange;
      default:
        return AppConstants.primaryColor;
    }
  }

  /// Gets certificate icon based on type
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

  /// Show message to user
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
