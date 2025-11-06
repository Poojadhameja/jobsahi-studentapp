import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
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
    final String? profileBio = rawBio is String && rawBio.trim().isNotEmpty
        ? rawBio.trim()
        : null;

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
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  else
                    const SizedBox(width: 48), // Spacer for alignment
                  // Action Buttons
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => _showProfileInfoEditSheet(
                          context: context,
                          state: state,
                        ),
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

  void _showProfileInfoEditSheet({
    required BuildContext context,
    required ProfileDetailsLoaded state,
  }) {
    final parentContext = context;
    final bloc = parentContext.read<ProfileBloc>();
    final nameController = TextEditingController(
      text: state.userProfile['name']?.toString() ?? '',
    );
    final emailController = TextEditingController(
      text: state.userProfile['email']?.toString() ?? '',
    );
    final locationController = TextEditingController(
      text: state.userProfile['location']?.toString() ?? '',
    );
    final bioController = TextEditingController(
      text: state.userProfile['bio']?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final viewInsets = MediaQuery.of(sheetContext).viewInsets.bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: viewInsets),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSheetHeader(
                        context: sheetContext,
                        title: 'Edit Profile Info',
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) {
                            return 'Email is required';
                          }
                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );
                          if (!emailRegex.hasMatch(email)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      TextFormField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Location is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      TextFormField(
                        controller: bioController,
                        decoration: const InputDecoration(
                          labelText: 'Profile Brief',
                          hintText: 'Write a short summary about yourself',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: AppConstants.largePadding),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }
                            final updatedName = nameController.text.trim();
                            final updatedEmail = emailController.text.trim();
                            final updatedLocation = locationController.text
                                .trim();
                            final updatedBio = bioController.text.trim();

                            bloc.add(
                              UpdateProfileHeaderInlineEvent(
                                name: updatedName,
                                email: updatedEmail,
                                location: updatedLocation,
                                bio: updatedBio.isNotEmpty ? updatedBio : null,
                              ),
                            );
                            Navigator.of(sheetContext).pop();
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text('Profile details updated.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditSectionSheet({
    required BuildContext context,
    required String section,
    required ProfileDetailsLoaded state,
  }) {
    final bloc = context.read<ProfileBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        switch (section) {
          case 'skills':
            return _buildSkillsEditSheet(
              parentContext: context,
              bloc: bloc,
              initialSkills: state.skills,
            );
          case 'experience':
            return _buildExperienceEditSheet(
              parentContext: context,
              bloc: bloc,
              initialExperience: state.experience,
            );
          case 'education':
            return _buildEducationEditSheet(
              parentContext: context,
              bloc: bloc,
              initialEducation: state.education,
            );
          case 'resume':
            return _buildResumeEditSheet(
              parentContext: context,
              bloc: bloc,
              resumeFileName: state.resumeFileName,
              lastUpdated: state.lastResumeUpdatedDate,
              downloadUrl: state.resumeDownloadUrl,
            );
          case 'certificates':
            return _buildCertificatesEditSheet(
              parentContext: context,
              bloc: bloc,
              initialCertificates: state.certificates,
            );
          case 'contact':
            return _buildContactEditSheet(
              parentContext: context,
              bloc: bloc,
              userProfile: state.userProfile,
            );
          case 'social':
            return _buildSocialLinksEditSheet(
              parentContext: context,
              bloc: bloc,
              userProfile: state.userProfile,
            );
          default:
            return _buildUnsupportedSectionSheet(sheetContext, section);
        }
      },
    );
  }

  Widget _buildUnsupportedSectionSheet(BuildContext context, String section) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final title = section.isEmpty
        ? 'Edit Section'
        : 'Edit ${section[0].toUpperCase()}${section.substring(1)}';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: viewInsets,
          left: AppConstants.defaultPadding,
          right: AppConstants.defaultPadding,
          top: AppConstants.defaultPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSheetHeader(context: context, title: title),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              'Editing for this section will be available soon.',
              style: TextStyle(color: AppConstants.textSecondaryColor),
            ),
            const SizedBox(height: AppConstants.largePadding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHeader({
    required BuildContext context,
    required String title,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildSkillsEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required List<String> initialSkills,
  }) {
    final skillsDraft = List<String>.from(initialSkills);
    final newSkillController = TextEditingController();

    void addSkill(String value, void Function(void Function()) setModalState) {
      final trimmedValue = value.trim();
      if (trimmedValue.isEmpty) {
        return;
      }
      final exists = skillsDraft.any(
        (skill) => skill.toLowerCase() == trimmedValue.toLowerCase(),
      );
      if (exists) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(
            content: Text('Skill already exists.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      setModalState(() {
        skillsDraft.add(trimmedValue);
        newSkillController.clear();
      });
    }

    return StatefulBuilder(
      builder: (context, setModalState) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: viewInsets),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSheetHeader(context: context, title: 'Edit Skills'),
                    const SizedBox(height: AppConstants.defaultPadding),
                    if (skillsDraft.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundColor,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        child: const Text(
                          'No skills added yet. Add your skills to improve your profile.',
                          style: TextStyle(
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ),
                    Column(
                      children: List.generate(skillsDraft.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.smallPadding,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  key: ValueKey('skill_field_$index'),
                                  initialValue: skillsDraft[index],
                                  decoration: InputDecoration(
                                    labelText: 'Skill ${index + 1}',
                                    border: const OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setModalState(() {
                                      skillsDraft[index] = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Remove skill',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppConstants.errorColor,
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    skillsDraft.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    TextField(
                      controller: newSkillController,
                      decoration: InputDecoration(
                        labelText: 'Add new skill',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () =>
                              addSkill(newSkillController.text, setModalState),
                        ),
                      ),
                      onSubmitted: (value) => addSkill(value, setModalState),
                    ),
                    const SizedBox(height: AppConstants.largePadding),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final sanitizedSkills = skillsDraft
                              .map((skill) => skill.trim())
                              .where((skill) => skill.isNotEmpty)
                              .toList();
                          bloc.add(
                            UpdateProfileSkillsInlineEvent(
                              skills: sanitizedSkills,
                            ),
                          );
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            const SnackBar(
                              content: Text('Skills updated.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExperienceEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required List<Map<String, dynamic>> initialExperience,
  }) {
    final experienceDrafts = initialExperience
        .map((exp) => Map<String, dynamic>.from(exp))
        .toList();

    if (experienceDrafts.isEmpty) {
      experienceDrafts.add({
        'company': '',
        'position': '',
        'startDate': '',
        'endDate': '',
        'description': '',
      });
    }

    return StatefulBuilder(
      builder: (context, setModalState) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        void addEmptyExperience() {
          setModalState(() {
            experienceDrafts.add({
              'company': '',
              'position': '',
              'startDate': '',
              'endDate': '',
              'description': '',
            });
          });
        }

        void deleteExperience(int index) {
          setModalState(() {
            experienceDrafts.removeAt(index);
            if (experienceDrafts.isEmpty) {
              addEmptyExperience();
            }
          });
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: viewInsets),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSheetHeader(
                      context: context,
                      title: 'Edit Work Experience',
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    ...List.generate(experienceDrafts.length, (index) {
                      final experience = experienceDrafts[index];
                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: AppConstants.defaultPadding,
                        ),
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundColor,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                          border: Border.all(color: AppConstants.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Experience ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  tooltip: 'Delete experience',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppConstants.errorColor,
                                  ),
                                  onPressed: () => deleteExperience(index),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            TextFormField(
                              key: ValueKey('experience_company_$index'),
                              initialValue:
                                  (experience['company'] ?? '') as String,
                              decoration: const InputDecoration(
                                labelText: 'Company',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  experience['company'] = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            TextFormField(
                              key: ValueKey('experience_position_$index'),
                              initialValue:
                                  (experience['position'] ?? '') as String,
                              decoration: const InputDecoration(
                                labelText: 'Position',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  experience['position'] = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    key: ValueKey('experience_start_$index'),
                                    initialValue:
                                        (experience['startDate'] ?? '')
                                            as String,
                                    decoration: const InputDecoration(
                                      labelText: 'Start Date',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setModalState(() {
                                        experience['startDate'] = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: AppConstants.smallPadding,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    key: ValueKey('experience_end_$index'),
                                    initialValue:
                                        (experience['endDate'] ?? '') as String,
                                    decoration: const InputDecoration(
                                      labelText: 'End Date',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setModalState(() {
                                        experience['endDate'] = value.isEmpty
                                            ? 'Present'
                                            : value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            TextFormField(
                              key: ValueKey('experience_description_$index'),
                              initialValue:
                                  (experience['description'] ?? '') as String,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              onChanged: (value) {
                                setModalState(() {
                                  experience['description'] = value;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: addEmptyExperience,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Experience'),
                      ),
                    ),
                    const SizedBox(height: AppConstants.largePadding),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final sanitizedExperience = experienceDrafts
                              .map(
                                (exp) => {
                                  'company': (exp['company'] ?? '').trim(),
                                  'position': (exp['position'] ?? '').trim(),
                                  'startDate': (exp['startDate'] ?? '').trim(),
                                  'endDate': (exp['endDate'] ?? '').trim(),
                                  'description': (exp['description'] ?? '')
                                      .trim(),
                                },
                              )
                              .where(
                                (exp) => exp.values.any(
                                  (value) => value.toString().isNotEmpty,
                                ),
                              )
                              .toList();

                          final hasInvalidEntry = sanitizedExperience.any(
                            (exp) =>
                                (exp['company'] as String).isEmpty ||
                                (exp['position'] as String).isEmpty ||
                                (exp['startDate'] as String).isEmpty,
                          );

                          if (hasInvalidEntry) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please fill company, position, and start date for each experience.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          bloc.add(
                            UpdateProfileExperienceListEvent(
                              experience: sanitizedExperience,
                            ),
                          );
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            const SnackBar(
                              content: Text('Work experience updated.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEducationEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required List<Map<String, dynamic>> initialEducation,
  }) {
    final educationDrafts = initialEducation
        .map((edu) => Map<String, dynamic>.from(edu))
        .toList();

    return StatefulBuilder(
      builder: (context, setModalState) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        void addEducation() {
          setModalState(() {
            educationDrafts.add({
              'qualification': '',
              'institute': '',
              'course': '',
              'passingYear': '',
              'cgpa': '',
            });
          });
        }

        void deleteEducation(int index) {
          setModalState(() {
            educationDrafts.removeAt(index);
          });
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: viewInsets),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSheetHeader(
                      context: context,
                      title: 'Edit Education',
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    if (educationDrafts.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundColor,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        child: const Text(
                          'No education added yet. Use the button below to add your education history.',
                          style: TextStyle(
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ),
                    ...List.generate(educationDrafts.length, (index) {
                      final education = educationDrafts[index];
                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: AppConstants.defaultPadding,
                        ),
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundColor,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                          border: Border.all(color: AppConstants.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Education ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  tooltip: 'Delete education',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppConstants.errorColor,
                                  ),
                                  onPressed: () => deleteEducation(index),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            TextFormField(
                              key: ValueKey('education_qualification_$index'),
                              initialValue:
                                  (education['qualification'] ?? '') as String,
                              decoration: const InputDecoration(
                                labelText: 'Qualification',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  education['qualification'] = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            TextFormField(
                              key: ValueKey('education_institute_$index'),
                              initialValue:
                                  (education['institute'] ?? '') as String,
                              decoration: const InputDecoration(
                                labelText: 'Institute',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  education['institute'] = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            TextFormField(
                              key: ValueKey('education_course_$index'),
                              initialValue:
                                  (education['course'] ?? '') as String,
                              decoration: const InputDecoration(
                                labelText: 'Course / Field of Study',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  education['course'] = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    key: ValueKey('education_passing_$index'),
                                    initialValue:
                                        (education['passingYear'] ?? '')
                                            as String,
                                    decoration: const InputDecoration(
                                      labelText: 'Year of Completion',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setModalState(() {
                                        education['passingYear'] = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: AppConstants.smallPadding,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    key: ValueKey('education_cgpa_$index'),
                                    initialValue:
                                        (education['cgpa'] ?? '') as String,
                                    decoration: const InputDecoration(
                                      labelText: 'CGPA / Percentage',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setModalState(() {
                                        education['cgpa'] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: addEducation,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Education'),
                      ),
                    ),
                    const SizedBox(height: AppConstants.largePadding),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final sanitizedEducation = educationDrafts
                              .map(
                                (edu) => {
                                  'qualification': (edu['qualification'] ?? '')
                                      .trim(),
                                  'institute': (edu['institute'] ?? '').trim(),
                                  'course': (edu['course'] ?? '').trim(),
                                  'passingYear': (edu['passingYear'] ?? '')
                                      .trim(),
                                  'cgpa': (edu['cgpa'] ?? '').trim(),
                                },
                              )
                              .where(
                                (edu) => edu.values.any(
                                  (value) => value.toString().isNotEmpty,
                                ),
                              )
                              .toList();

                          final hasInvalidEntry = sanitizedEducation.any(
                            (edu) =>
                                (edu['qualification'] as String).isEmpty ||
                                (edu['institute'] as String).isEmpty,
                          );

                          if (hasInvalidEntry) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Qualification and institute are required.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          bloc.add(
                            UpdateProfileEducationListEvent(
                              education: sanitizedEducation,
                            ),
                          );
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            const SnackBar(
                              content: Text('Education updated.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResumeEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    String? resumeFileName,
    String? lastUpdated,
    String? downloadUrl,
  }) {
    final nameController = TextEditingController(text: resumeFileName ?? '');
    final dateController = TextEditingController(text: lastUpdated ?? '');
    final urlController = TextEditingController(text: downloadUrl ?? '');
    final formKey = GlobalKey<FormState>();

    return StatefulBuilder(
      builder: (context, setModalState) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        String? validateUrl(String? value) {
          final trimmed = value?.trim() ?? '';
          if (trimmed.isEmpty) {
            return null;
          }
          final uri = Uri.tryParse(trimmed);
          if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
            return 'Enter a valid URL starting with http or https';
          }
          return null;
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: viewInsets),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSheetHeader(context: context, title: 'Edit Resume'),
                      const SizedBox(height: AppConstants.defaultPadding),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Resume File Name',
                          hintText: 'Resume.pdf',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      TextFormField(
                        controller: dateController,
                        decoration: const InputDecoration(
                          labelText: 'Last Updated',
                          hintText: 'e.g., 15 July 2024',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      TextFormField(
                        controller: urlController,
                        decoration: const InputDecoration(
                          labelText: 'Resume URL (optional)',
                          hintText: 'https://example.com/resume.pdf',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.url,
                        validator: validateUrl,
                      ),
                      const SizedBox(height: AppConstants.largePadding),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }
                            final name = nameController.text.trim();
                            final updated = dateController.text.trim();
                            final url = urlController.text.trim();
                            final hasOtherValues =
                                updated.isNotEmpty || url.isNotEmpty;

                            if (name.isEmpty && hasOtherValues) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Resume name is required when other details are provided.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            bloc.add(
                              UpdateProfileResumeInlineEvent(
                                fileName: name,
                                lastUpdated: updated.isNotEmpty
                                    ? updated
                                    : null,
                                downloadUrl: url.isNotEmpty ? url : null,
                              ),
                            );
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text('Resume details updated.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCertificatesEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required List<Map<String, dynamic>> initialCertificates,
  }) {
    final certificateDrafts = initialCertificates
        .map((cert) => Map<String, dynamic>.from(cert))
        .toList();

    if (certificateDrafts.isEmpty) {
      certificateDrafts.add({
        'name': '',
        'type': 'Certificate',
        'uploadDate': '',
        'path': '',
        'extension': '',
        'size': 0,
      });
    }

    const certificateTypes = ['Certificate', 'License', 'ID Proof', 'Other'];

    String inferExtensionFromInputs({
      required String name,
      required String url,
    }) {
      final candidates = <String>[name, url];
      for (final candidate in candidates) {
        final trimmed = candidate.trim();
        if (trimmed.contains('.')) {
          final parts = trimmed.split('.');
          final ext = parts.isNotEmpty ? parts.last.trim() : '';
          if (ext.isNotEmpty) {
            return ext;
          }
        }
      }
      return 'file';
    }

    String? validateUrl(String? value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) {
        return null;
      }
      final uri = Uri.tryParse(trimmed);
      if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return 'Enter a valid URL starting with http or https';
      }
      return null;
    }

    return StatefulBuilder(
      builder: (context, setModalState) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        void addCertificate() {
          setModalState(() {
            certificateDrafts.add({
              'name': '',
              'type': 'Certificate',
              'uploadDate': '',
              'path': '',
              'extension': '',
              'size': 0,
            });
          });
        }

        void removeCertificate(int index) {
          setModalState(() {
            certificateDrafts.removeAt(index);
            if (certificateDrafts.isEmpty) {
              addCertificate();
            }
          });
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: viewInsets),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSheetHeader(
                      context: context,
                      title: 'Manage Certificates',
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    ...List.generate(certificateDrafts.length, (index) {
                      final certificate = certificateDrafts[index];
                      final selectedType =
                          certificate['type']?.toString() ?? 'Certificate';

                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: AppConstants.defaultPadding,
                        ),
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundColor,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                          border: Border.all(color: AppConstants.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Certificate ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  tooltip: 'Delete certificate',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppConstants.errorColor,
                                  ),
                                  onPressed: () => removeCertificate(index),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            TextFormField(
                              key: ValueKey('certificate_name_$index'),
                              initialValue:
                                  certificate['name']?.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Certificate Name',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  certificate['name'] = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            DropdownButtonFormField<String>(
                              value: certificateTypes.contains(selectedType)
                                  ? selectedType
                                  : 'Certificate',
                              items: certificateTypes
                                  .map(
                                    (type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setModalState(() {
                                  certificate['type'] = value;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Certificate Type',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            TextFormField(
                              key: ValueKey('certificate_date_$index'),
                              initialValue:
                                  certificate['uploadDate']?.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Achievement Date',
                                hintText: 'e.g., 10 July 2024',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  certificate['uploadDate'] = value;
                                });
                              },
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            TextFormField(
                              key: ValueKey('certificate_url_$index'),
                              initialValue:
                                  certificate['path']?.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Certificate URL (optional)',
                                hintText: 'https://example.com/certificate.pdf',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.url,
                              onChanged: (value) {
                                setModalState(() {
                                  certificate['path'] = value;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: addCertificate,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Certificate'),
                      ),
                    ),
                    const SizedBox(height: AppConstants.largePadding),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final sanitizedCertificates =
                              <Map<String, dynamic>>[];
                          String? urlValidationMessage;
                          var hasValidationError = false;

                          for (final certificate in certificateDrafts) {
                            final name =
                                certificate['name']?.toString().trim() ?? '';
                            final type =
                                certificate['type']?.toString().trim() ?? '';
                            final uploadDate =
                                certificate['uploadDate']?.toString().trim() ??
                                '';
                            final url =
                                certificate['path']?.toString().trim() ?? '';

                            final hasAnyValue = [
                              name,
                              type,
                              uploadDate,
                              url,
                            ].any((value) => value.isNotEmpty);

                            if (hasAnyValue && name.isEmpty) {
                              hasValidationError = true;
                              break;
                            }

                            final validationMessage = validateUrl(url);
                            if (validationMessage != null) {
                              urlValidationMessage = validationMessage;
                              break;
                            }

                            if (name.isEmpty) {
                              continue;
                            }

                            sanitizedCertificates.add({
                              'name': name,
                              'type': type.isNotEmpty ? type : 'Certificate',
                              'uploadDate': uploadDate.isNotEmpty
                                  ? uploadDate
                                  : 'Not specified',
                              'extension': inferExtensionFromInputs(
                                name: name,
                                url: url,
                              ),
                              if (url.isNotEmpty) 'path': url,
                              'size': certificate['size'] is num
                                  ? (certificate['size'] as num).toInt()
                                  : 0,
                            });
                          }

                          if (hasValidationError) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please provide a name for each certificate.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          if (urlValidationMessage != null) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                content: Text(urlValidationMessage),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          bloc.add(
                            UpdateProfileCertificatesInlineEvent(
                              certificates: sanitizedCertificates,
                            ),
                          );
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            const SnackBar(
                              content: Text('Certificates updated.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required Map<String, dynamic> userProfile,
  }) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController(
      text: userProfile['email']?.toString() ?? '',
    );
    final phoneController = TextEditingController(
      text: userProfile['phone']?.toString() ?? '',
    );
    final locationController = TextEditingController(
      text: userProfile['location']?.toString() ?? '',
    );
    final genderController = TextEditingController(
      text: userProfile['gender']?.toString() ?? '',
    );
    final dobController = TextEditingController(
      text: userProfile['dateOfBirth']?.toString() ?? '',
    );

    return Builder(
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: viewInsets,
              left: AppConstants.defaultPadding,
              right: AppConstants.defaultPadding,
              top: AppConstants.defaultPadding,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSheetHeader(
                      context: context,
                      title: 'Edit Contact Details',
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );
                        if (!emailRegex.hasMatch(email)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (phone.isEmpty) {
                          return 'Phone number is required';
                        }
                        if (phone.length < 6) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    TextFormField(
                      controller: genderController,
                      decoration: const InputDecoration(
                        labelText: 'Gender (optional)',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    TextFormField(
                      controller: dobController,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth (optional)',
                        hintText: 'DD/MM/YYYY',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppConstants.largePadding),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          final email = emailController.text.trim();
                          final phone = phoneController.text.trim();
                          final location = locationController.text.trim();
                          final gender = genderController.text.trim();
                          final dob = dobController.text.trim();

                          bloc.add(
                            UpdateProfileContactInlineEvent(
                              email: email,
                              phone: phone,
                              location: location,
                              gender: gender.isNotEmpty ? gender : null,
                              dateOfBirth: dob.isNotEmpty ? dob : null,
                            ),
                          );
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            const SnackBar(
                              content: Text('Contact details updated.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialLinksEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required Map<String, dynamic> userProfile,
  }) {
    final formKey = GlobalKey<FormState>();
    final portfolioController = TextEditingController(
      text: userProfile['portfolioLink']?.toString() ?? '',
    );
    final linkedinController = TextEditingController(
      text: userProfile['linkedinUrl']?.toString() ?? '',
    );

    return Builder(
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        String? validateUrl(String? value) {
          final trimmed = value?.trim() ?? '';
          if (trimmed.isEmpty) {
            return null;
          }
          final uri = Uri.tryParse(trimmed);
          if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
            return 'Enter a valid URL starting with http or https';
          }
          return null;
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: viewInsets,
              left: AppConstants.defaultPadding,
              right: AppConstants.defaultPadding,
              top: AppConstants.defaultPadding,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSheetHeader(
                      context: context,
                      title: 'Edit Social Links',
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    TextFormField(
                      controller: portfolioController,
                      decoration: const InputDecoration(
                        labelText: 'Portfolio URL',
                        hintText: 'https://yourportfolio.com',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                      validator: validateUrl,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    TextFormField(
                      controller: linkedinController,
                      decoration: const InputDecoration(
                        labelText: 'LinkedIn Profile URL',
                        hintText: 'https://linkedin.com/in/username',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                      validator: validateUrl,
                    ),
                    const SizedBox(height: AppConstants.largePadding),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          final portfolio = portfolioController.text.trim();
                          final linkedin = linkedinController.text.trim();

                          bloc.add(
                            UpdateProfileSocialLinksInlineEvent(
                              portfolioLink: portfolio.isNotEmpty
                                  ? portfolio
                                  : null,
                              linkedinUrl: linkedin.isNotEmpty
                                  ? linkedin
                                  : null,
                            ),
                          );
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            const SnackBar(
                              content: Text('Social links updated.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

        // Resume Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Resume',
          icon: Icons.description_outlined,
          section: 'resume',
          child: _buildResumeContent(context, state),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Certificates Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Certificates',
          icon: Icons.folder_outlined,
          section: 'certificates',
          child: _buildCertificatesContent(context, state),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Contact Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Contact',
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
                      onPressed: () => _showEditSectionSheet(
                        context: context,
                        section: section,
                        state: state,
                      ),
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

  /// Certificates Content
  Widget _buildResumeContent(BuildContext context, ProfileDetailsLoaded state) {
    final resumeName = state.resumeFileName?.trim() ?? '';
    final updatedDate = state.lastResumeUpdatedDate?.trim() ?? '';

    if (resumeName.isEmpty) {
      return _buildEmptyState(
        icon: Icons.description_outlined,
        title: 'No Resume Uploaded',
        subtitle: 'Upload your resume to attract employers',
      );
    }

    return _buildDocumentCard(
      icon: Icons.description,
      title: 'Resume',
      fileName: resumeName,
      lastUpdated: updatedDate.isNotEmpty ? updatedDate : 'Unknown',
      onDownload: () => _downloadResume(context, state.resumeDownloadUrl),
    );
  }

  Widget _buildCertificatesContent(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    final certificates = state.certificates
        .where(
          (cert) => (cert['type'] ?? '').toString().toLowerCase() != 'resume',
        )
        .toList();

    return Column(
      children: [
        // Certificates
        if (certificates.isNotEmpty) ...[
          ...certificates.map(
            (cert) => _buildDocumentCard(
              icon: _getCertificateIcon(cert['type'] ?? ''),
              title: cert['name'] ?? 'Document',
              fileName: cert['name'] ?? 'Document',
              lastUpdated: cert['uploadDate'] ?? 'Unknown',
              onDownload: () => _downloadDocument(context, cert),
            ),
          ),
        ],

        if (certificates.isEmpty)
          _buildEmptyState(
            icon: Icons.folder_outlined,
            title: 'No Certificates Added',
            subtitle: 'Upload your certificates to showcase achievements',
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

  void _downloadResume(BuildContext context, String? url) {
    final message = url != null && url.isNotEmpty
        ? 'Opening resume: $url'
        : 'Downloading resume...';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
