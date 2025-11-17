import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
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
      listenWhen: (previous, current) {
        if (current is ProfileDetailsLoaded) {
          if (current.statusMessage == null) {
            return false;
          }
          final previousKey = previous is ProfileDetailsLoaded
              ? previous.statusMessageKey
              : -1;
          return current.statusMessageKey != previousKey;
        }
        return current is CertificateDeletedSuccess ||
            current is ProfileImageRemovedSuccess ||
            current is ProfileError;
      },
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
        } else if (state is ProfileDetailsLoaded) {
          final message = state.statusMessage;
          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: state.statusIsError
                    ? AppConstants.errorColor
                    : AppConstants.successColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is ProfileDetailsLoaded) {
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
        // Show content immediately or simple loading without text
        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          body: Center(
            child: CircularProgressIndicator(
              color: AppConstants.secondaryColor,
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
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(context, state),

                  // Profile Content
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      children: [
                        // Profile Sections
                        _buildProfileSections(context, state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (state.isSyncing)
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      color: AppConstants.primaryColor,
                      backgroundColor: AppConstants.primaryColor.withValues(
                        alpha: 0.2,
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
                    _capitalizeEachWord(user['name'] ?? 'User Name'),
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
                        (() {
                          final raw = user['location'];
                          if (raw is String && raw.trim().isNotEmpty) {
                            return raw.trim();
                          }
                          return 'Location not provided';
                        })(),
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
                        'About me',
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

  /// Capitalize the first letter of each word (e.g., 'ram kumar' -> 'Ram Kumar')
  String _capitalizeEachWord(String input) {
    if (input.isEmpty) return input;
    final words = input.trim().split(RegExp(r'\\s+'));
    return words
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1) : ''}',
        )
        .join(' ');
  }

  /// Format date to "22 Jan 2021" format
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString();
    final month = months[date.month - 1];
    final year = date.year.toString();
    return '$day $month $year';
  }

  /// Parse date from various formats to DateTime
  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;

    try {
      // Try ISO format (yyyy-MM-dd)
      if (dateStr.contains('-')) {
        return DateTime.tryParse(dateStr);
      }
      // Try DD/MM/YYYY or MM/DD/YYYY
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          // Try DD/MM/YYYY first
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            if (month <= 12 && day <= 31) {
              return DateTime(year, month, day);
            }
          }
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  /// Format gender value to proper case (Male, Female, Other)
  String _formatGender(String gender) {
    if (gender.isEmpty) return gender;
    final lowerGender = gender.toLowerCase().trim();
    if (lowerGender == 'male') {
      return 'Male';
    } else if (lowerGender == 'female') {
      return 'Female';
    } else if (lowerGender == 'other') {
      return 'Other';
    }
    // If it's already in proper format or unknown, capitalize first letter
    return '${gender[0].toUpperCase()}${gender.length > 1 ? gender.substring(1).toLowerCase() : ''}';
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
      backgroundColor: AppConstants.cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final viewInsets = MediaQuery.of(sheetContext).viewInsets.bottom;
        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                        _buildMainCard(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name *',
                                border: OutlineInputBorder(),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                final name = value?.trim() ?? '';
                                if (name.isEmpty) {
                                  return 'Name is required';
                                }
                                final lettersOnly = name.replaceAll(
                                  RegExp(r'[^a-zA-Z]'),
                                  '',
                                );
                                if (lettersOnly.length < 3) {
                                  return 'Name must have at least 3 letters';
                                }
                                final words = name
                                    .split(RegExp(r'\s+'))
                                    .where((w) => w.isNotEmpty)
                                    .toList();
                                if (words.length < 2) {
                                  return 'Name must have at least 2 words';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
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
                                labelText: 'About me',
                                hintText:
                                    'Write a short summary about yourself',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 4,
                              validator: (value) {
                                final bio = value?.trim() ?? '';
                                if (bio.isNotEmpty) {
                                  final lettersOnly = bio.replaceAll(
                                    RegExp(r'[^a-zA-Z]'),
                                    '',
                                  );
                                  if (lettersOnly.length < 15) {
                                    return 'About me must have at least 15 letters';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Fixed bottom button
              Container(
                padding: EdgeInsets.only(
                  left: AppConstants.defaultPadding,
                  right: AppConstants.defaultPadding,
                  top: AppConstants.defaultPadding,
                  bottom: viewInsets + AppConstants.defaultPadding,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.cardBackgroundColor,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      final updatedName = nameController.text.trim();
                      final updatedEmail = emailController.text.trim();
                      final updatedLocation = locationController.text.trim();
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Save Changes',
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
          case 'general_info':
            return _buildGeneralInformationEditSheet(
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  /// Builds main card container matching skill test instructions design
  Widget _buildMainCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSheetHeader(context: context, title: 'Edit Skills'),
                      const SizedBox(height: AppConstants.defaultPadding),
                      _buildMainCard(
                        children: [
                          if (skillsDraft.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                AppConstants.defaultPadding,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Text(
                                'No skills added yet. Add your skills to improve your profile.',
                                style: TextStyle(
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                            ),
                          if (skillsDraft.isNotEmpty) ...[
                            ...List.generate(skillsDraft.length, (index) {
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
                            const SizedBox(height: AppConstants.defaultPadding),
                          ],
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: newSkillController,
                                  decoration: const InputDecoration(
                                    labelText: 'Add new skill',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLength: 25,
                                  onSubmitted: (value) =>
                                      addSkill(value, setModalState),
                                ),
                              ),
                              const SizedBox(width: AppConstants.smallPadding),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ElevatedButton.icon(
                                  onPressed: () => addSkill(
                                    newSkillController.text,
                                    setModalState,
                                  ),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Fixed bottom button
              Container(
                padding: EdgeInsets.only(
                  left: AppConstants.defaultPadding,
                  right: AppConstants.defaultPadding,
                  top: AppConstants.defaultPadding,
                  bottom: viewInsets + AppConstants.defaultPadding,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.cardBackgroundColor,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final sanitizedSkills = skillsDraft
                          .map((skill) => skill.trim())
                          .where((skill) => skill.isNotEmpty)
                          .toList();
                      bloc.add(
                        UpdateProfileSkillsInlineEvent(skills: sanitizedSkills),
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Save Changes',
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                      _buildMainCard(
                        children: [
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
                                border: Border.all(
                                  color: AppConstants.borderColor,
                                ),
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
                                        onPressed: () =>
                                            deleteExperience(index),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: AppConstants.smallPadding,
                                  ),
                                  TextFormField(
                                    key: ValueKey('experience_company_$index'),
                                    initialValue:
                                        (experience['company'] ?? '') as String,
                                    decoration: const InputDecoration(
                                      labelText: 'Company *',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setModalState(() {
                                        experience['company'] = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                    height: AppConstants.smallPadding,
                                  ),
                                  TextFormField(
                                    key: ValueKey('experience_position_$index'),
                                    initialValue:
                                        (experience['position'] ?? '')
                                            as String,
                                    decoration: const InputDecoration(
                                      labelText: 'Position *',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setModalState(() {
                                        experience['position'] = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                    height: AppConstants.smallPadding,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Builder(
                                          builder: (context) {
                                            final startDateStr =
                                                (experience['startDate'] ?? '')
                                                    as String;
                                            DateTime? startDate = _parseDate(
                                              startDateStr,
                                            );
                                            final displayStartDate =
                                                startDate != null
                                                ? _formatDate(startDate)
                                                : '';

                                            return TextFormField(
                                              key: ValueKey(
                                                'experience_start_${index}_${experience['startDate']}',
                                              ),
                                              initialValue: displayStartDate,
                                              readOnly: true,
                                              decoration: const InputDecoration(
                                                labelText: 'Start Date',
                                                hintText: 'Select date',
                                                border: OutlineInputBorder(),
                                                suffixIcon: Icon(
                                                  Icons.calendar_today,
                                                ),
                                              ),
                                              onTap: () async {
                                                final pickedDate =
                                                    await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          startDate ??
                                                          DateTime.now(),
                                                      firstDate: DateTime(1900),
                                                      lastDate: DateTime.now(),
                                                    );
                                                if (pickedDate != null) {
                                                  setModalState(() {
                                                    experience['startDate'] =
                                                        '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                                                  });
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: AppConstants.smallPadding,
                                      ),
                                      Expanded(
                                        child: Builder(
                                          builder: (context) {
                                            final endDateStr =
                                                (experience['endDate'] ?? '')
                                                    as String;
                                            final isPresent =
                                                endDateStr.toLowerCase() ==
                                                    'present' ||
                                                endDateStr.isEmpty;
                                            DateTime? endDate = isPresent
                                                ? null
                                                : _parseDate(endDateStr);
                                            final displayEndDate = isPresent
                                                ? 'Present'
                                                : (endDate != null
                                                      ? _formatDate(endDate)
                                                      : '');

                                            return TextFormField(
                                              key: ValueKey(
                                                'experience_end_${index}_${experience['endDate']}',
                                              ),
                                              initialValue: displayEndDate,
                                              readOnly: true,
                                              decoration: const InputDecoration(
                                                labelText: 'End Date',
                                                hintText:
                                                    'Select date or leave for Present',
                                                border: OutlineInputBorder(),
                                                suffixIcon: Icon(
                                                  Icons.calendar_today,
                                                ),
                                              ),
                                              onTap: () async {
                                                final pickedDate =
                                                    await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          endDate ??
                                                          DateTime.now(),
                                                      firstDate: DateTime(1900),
                                                      lastDate: DateTime.now(),
                                                    );
                                                if (pickedDate != null) {
                                                  setModalState(() {
                                                    experience['endDate'] =
                                                        '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                                                  });
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: AppConstants.smallPadding,
                                  ),
                                  TextFormField(
                                    key: ValueKey(
                                      'experience_description_$index',
                                    ),
                                    initialValue:
                                        (experience['description'] ?? '')
                                            as String,
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
                          const SizedBox(height: AppConstants.defaultPadding),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: addEmptyExperience,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Experience'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Fixed bottom button
              Container(
                padding: EdgeInsets.only(
                  left: AppConstants.defaultPadding,
                  right: AppConstants.defaultPadding,
                  top: AppConstants.defaultPadding,
                  bottom: viewInsets + AppConstants.defaultPadding,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.cardBackgroundColor,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: SizedBox(
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
                              'description': (exp['description'] ?? '').trim(),
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Save Changes',
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
              'startYear': '',
              'endYear': '',
              'isPursuing': false,
              'pursuingYear': null,
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                      _buildMainCard(
                        children: [
                          if (educationDrafts.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                AppConstants.defaultPadding,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Text(
                                'No education added yet. Use the button below to add your education history.',
                                style: TextStyle(
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                            ),
                          if (educationDrafts.isNotEmpty)
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
                                  border: Border.all(
                                    color: AppConstants.borderColor,
                                  ),
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
                                          onPressed: () =>
                                              deleteEducation(index),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    TextFormField(
                                      key: ValueKey(
                                        'education_qualification_$index',
                                      ),
                                      initialValue:
                                          education['qualification'] != null
                                          ? education['qualification']
                                                .toString()
                                          : '',
                                      decoration: const InputDecoration(
                                        labelText: 'Qualification *',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setModalState(() {
                                          education['qualification'] = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    TextFormField(
                                      key: ValueKey(
                                        'education_institute_$index',
                                      ),
                                      initialValue:
                                          education['institute'] != null
                                          ? education['institute'].toString()
                                          : '',
                                      decoration: const InputDecoration(
                                        labelText: 'Institute *',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setModalState(() {
                                          education['institute'] = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            key: ValueKey(
                                              'education_startYear_$index',
                                            ),
                                            initialValue:
                                                education['startYear'] != null
                                                ? education['startYear']
                                                      .toString()
                                                : '',
                                            decoration: const InputDecoration(
                                              labelText: 'Start Year',
                                              border: OutlineInputBorder(),
                                              hintText: 'e.g., 2020',
                                            ),
                                            keyboardType: TextInputType.number,
                                            maxLength: 4,
                                            onChanged: (value) {
                                              setModalState(() {
                                                education['startYear'] = value;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: AppConstants.smallPadding,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            key: ValueKey(
                                              'education_endYear_$index',
                                            ),
                                            initialValue:
                                                education['endYear'] != null
                                                ? education['endYear']
                                                      .toString()
                                                : '',
                                            decoration: const InputDecoration(
                                              labelText: 'End Year',
                                              border: OutlineInputBorder(),
                                              hintText: 'e.g., 2024',
                                            ),
                                            keyboardType: TextInputType.number,
                                            maxLength: 4,
                                            enabled:
                                                !(education['isPursuing'] ==
                                                    true),
                                            onChanged: (value) {
                                              setModalState(() {
                                                education['endYear'] = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Currently Pursuing'),
                                      value: education['isPursuing'] == true,
                                      onChanged: (value) {
                                        setModalState(() {
                                          education['isPursuing'] =
                                              value ?? false;
                                          if (value == true) {
                                            education['endYear'] = '';
                                          }
                                        });
                                      },
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    if (education['isPursuing'] == true) ...[
                                      const SizedBox(
                                        height: AppConstants.smallPadding,
                                      ),
                                      DropdownButtonFormField<int>(
                                        key: ValueKey(
                                          'education_pursuingYear_$index',
                                        ),
                                        value: () {
                                          // Get the pursuingYear value
                                          final pursuingYear =
                                              education['pursuingYear'];
                                          if (pursuingYear == null) return null;

                                          // Try to parse as int
                                          int? yearValue;
                                          if (pursuingYear is int) {
                                            yearValue = pursuingYear;
                                          } else {
                                            yearValue = int.tryParse(
                                              pursuingYear.toString(),
                                            );
                                          }

                                          // Only return if it's a valid academic year (1-4)
                                          // If it's a full year like 2024, return null
                                          if (yearValue != null &&
                                              yearValue >= 1 &&
                                              yearValue <= 4) {
                                            return yearValue;
                                          }
                                          return null;
                                        }(),
                                        decoration: const InputDecoration(
                                          labelText: 'Pursuing Year',
                                          border: OutlineInputBorder(),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 1,
                                            child: Text('1st Year'),
                                          ),
                                          DropdownMenuItem(
                                            value: 2,
                                            child: Text('2nd Year'),
                                          ),
                                          DropdownMenuItem(
                                            value: 3,
                                            child: Text('3rd Year'),
                                          ),
                                          DropdownMenuItem(
                                            value: 4,
                                            child: Text('4th Year'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setModalState(() {
                                            education['pursuingYear'] = value;
                                          });
                                        },
                                      ),
                                    ],
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    TextFormField(
                                      key: ValueKey('education_cgpa_$index'),
                                      initialValue: education['cgpa'] != null
                                          ? education['cgpa'].toString()
                                          : '',
                                      decoration: const InputDecoration(
                                        labelText: 'CGPA / Percentage',
                                        border: OutlineInputBorder(),
                                        hintText: 'e.g., 8.5 or 85%',
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setModalState(() {
                                          education['cgpa'] = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                          const SizedBox(height: AppConstants.defaultPadding),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: addEducation,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Education'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Fixed bottom button
              Container(
                padding: EdgeInsets.only(
                  left: AppConstants.defaultPadding,
                  right: AppConstants.defaultPadding,
                  top: AppConstants.defaultPadding,
                  bottom: viewInsets + AppConstants.defaultPadding,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.cardBackgroundColor,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final sanitizedEducation = educationDrafts
                          .map(
                            (edu) => {
                              'qualification': (edu['qualification'] ?? '')
                                  .toString()
                                  .trim(),
                              'institute': (edu['institute'] ?? '')
                                  .toString()
                                  .trim(),
                              'startYear': (edu['startYear'] ?? '')
                                  .toString()
                                  .trim(),
                              'endYear': (edu['endYear'] ?? '')
                                  .toString()
                                  .trim(),
                              'isPursuing':
                                  edu['isPursuing'] == true ||
                                  edu['isPursuing'] == 1 ||
                                  edu['isPursuing'] == '1' ||
                                  edu['isPursuing'] == 'true',
                              'pursuingYear': edu['pursuingYear'],
                              'cgpa': (edu['cgpa'] ?? '').toString().trim(),
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Save Changes',
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
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
    final contactEmailController = TextEditingController(
      text: userProfile['contactEmail']?.toString().isNotEmpty == true
          ? userProfile['contactEmail']?.toString() ?? ''
          : (userProfile['email']?.toString() ?? ''),
    );
    final contactPhoneController = TextEditingController(
      text: userProfile['contactPhone']?.toString().isNotEmpty == true
          ? userProfile['contactPhone']?.toString() ?? ''
          : (userProfile['phone']?.toString() ?? ''),
    );

    return Builder(
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
                        _buildMainCard(
                          children: [
                            TextFormField(
                              controller: contactEmailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter email address',
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
                              controller: contactPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                hintText: 'Enter phone number',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                final phone = value?.trim() ?? '';
                                if (phone.isEmpty) {
                                  return 'Phone is required';
                                }
                                if (phone.length < 6) {
                                  return 'Enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Fixed bottom button
              Container(
                padding: EdgeInsets.only(
                  left: AppConstants.defaultPadding,
                  right: AppConstants.defaultPadding,
                  top: AppConstants.defaultPadding,
                  bottom: viewInsets + AppConstants.defaultPadding,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.cardBackgroundColor,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      final contactEmail = contactEmailController.text.trim();
                      final contactPhone = contactPhoneController.text.trim();

                      // Get current values from state to preserve other fields
                      final currentState = bloc.state;
                      if (currentState is ProfileDetailsLoaded) {
                        final currentProfile = currentState.userProfile;

                        bloc.add(
                          UpdateProfileContactInlineEvent(
                            email: currentProfile['email']?.toString() ?? '',
                            phone: currentProfile['phone']?.toString() ?? '',
                            location:
                                currentProfile['location']?.toString() ?? '',
                            gender: currentProfile['gender']?.toString(),
                            dateOfBirth: currentProfile['dateOfBirth']
                                ?.toString(),
                            contactEmail: contactEmail.isNotEmpty
                                ? contactEmail
                                : null,
                            contactPhone: contactPhone.isNotEmpty
                                ? contactPhone
                                : null,
                          ),
                        );
                      }
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Save Changes',
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
        );
      },
    );
  }

  Widget _buildGeneralInformationEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required Map<String, dynamic> userProfile,
  }) {
    final formKey = GlobalKey<FormState>();

    // Parse existing gender value
    String? selectedGender;
    final existingGender =
        userProfile['gender']?.toString().toLowerCase() ?? '';
    if (existingGender == 'male') {
      selectedGender = 'Male';
    } else if (existingGender == 'female') {
      selectedGender = 'Female';
    } else if (existingGender == 'other') {
      selectedGender = 'Other';
    }

    // Parse existing date of birth
    DateTime? selectedDate;
    final dobText = userProfile['dateOfBirth']?.toString() ?? '';
    if (dobText.isNotEmpty) {
      selectedDate = _parseDate(dobText);
    }

    final dobController = TextEditingController(
      text: selectedDate != null ? _formatDate(selectedDate) : '',
    );
    final aadharController = TextEditingController(
      text: userProfile['aadharNumber']?.toString() ?? '',
    );

    // Get existing languages
    List<String> languages = [];
    if (userProfile['languages'] != null) {
      if (userProfile['languages'] is List) {
        languages = List<String>.from(userProfile['languages']);
      } else if (userProfile['languages'] is String) {
        languages = (userProfile['languages'] as String)
            .split(',')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();
      }
    }

    final languageInputController = TextEditingController();

    // Use mutable variables that persist across rebuilds
    String? currentGender = selectedGender;
    DateTime? currentDate = selectedDate;

    return Builder(
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        return StatefulBuilder(
          builder: (context, setState) {
            void addLanguage(String language) {
              final trimmed = language.trim();
              if (trimmed.isNotEmpty && !languages.contains(trimmed)) {
                setState(() {
                  languages.add(trimmed);
                  languageInputController.clear();
                });
              }
            }

            void removeLanguage(String language) {
              setState(() {
                languages.remove(language);
              });
            }

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSheetHeader(
                              context: context,
                              title: 'Edit General Information',
                            ),
                            const SizedBox(height: AppConstants.defaultPadding),
                            _buildMainCard(
                              children: [
                                DropdownButtonFormField<String>(
                                  value: currentGender,
                                  decoration: const InputDecoration(
                                    labelText: 'Gender',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Male',
                                      child: Text('Male'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Female',
                                      child: Text('Female'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Other',
                                      child: Text('Other'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      currentGender = value;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: AppConstants.smallPadding,
                                ),
                                TextFormField(
                                  controller: dobController,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Date of Birth',
                                    hintText: 'Select date',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  onTap: () async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          currentDate ?? DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (pickedDate != null) {
                                      setState(() {
                                        currentDate = pickedDate;
                                        dobController.text = _formatDate(
                                          pickedDate,
                                        );
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: AppConstants.smallPadding,
                                ),
                                const Text(
                                  'Languages',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: AppConstants.smallPadding,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: languageInputController,
                                        decoration: const InputDecoration(
                                          labelText: 'Add Language',
                                          hintText: 'e.g., Hindi, English',
                                          border: OutlineInputBorder(),
                                        ),
                                        textCapitalization:
                                            TextCapitalization.words,
                                        onFieldSubmitted: (value) {
                                          addLanguage(value);
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: AppConstants.smallPadding,
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        final value =
                                            languageInputController.text;
                                        addLanguage(value);
                                      },
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Add'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: AppConstants.smallPadding,
                                ),
                                if (languages.isNotEmpty)
                                  Wrap(
                                    spacing: AppConstants.smallPadding,
                                    runSpacing: AppConstants.smallPadding,
                                    children: languages.map((lang) {
                                      return Chip(
                                        label: Text(lang),
                                        deleteIcon: const Icon(
                                          Icons.close,
                                          size: 18,
                                        ),
                                        onDeleted: () => removeLanguage(lang),
                                      );
                                    }).toList(),
                                  ),
                                const SizedBox(
                                  height: AppConstants.defaultPadding,
                                ),
                                TextFormField(
                                  controller: aadharController,
                                  decoration: const InputDecoration(
                                    labelText: 'Aadhar Number',
                                    hintText: '12-digit Aadhar number',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  maxLength: 12,
                                  validator: (value) {
                                    if (value != null &&
                                        value.trim().isNotEmpty) {
                                      if (value.trim().length != 12) {
                                        return 'Aadhar number must be 12 digits';
                                      }
                                      if (!RegExp(
                                        r'^\d+$',
                                      ).hasMatch(value.trim())) {
                                        return 'Aadhar number must contain only digits';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Fixed bottom button
                  Container(
                    padding: EdgeInsets.only(
                      left: AppConstants.defaultPadding,
                      right: AppConstants.defaultPadding,
                      top: AppConstants.defaultPadding,
                      bottom: viewInsets + AppConstants.defaultPadding,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.cardBackgroundColor,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          final gender = currentGender;
                          final dob = currentDate != null
                              ? '${currentDate!.year}-${currentDate!.month.toString().padLeft(2, '0')}-${currentDate!.day.toString().padLeft(2, '0')}'
                              : '';
                          final aadhar = aadharController.text.trim();

                          // Create a copy of languages list to ensure it's properly passed
                          final languagesList = List<String>.from(languages);

                          bloc.add(
                            UpdateProfileGeneralInfoInlineEvent(
                              gender: gender,
                              dateOfBirth: dob.isNotEmpty ? dob : null,
                              languages: languagesList,
                              aadharNumber: aadhar.isNotEmpty ? aadhar : null,
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Save Changes',
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
            );
          },
        );
      },
    );
  }

  Widget _buildSocialLinksEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required Map<String, dynamic> userProfile,
  }) {
    // Get existing social links from array or build from individual fields
    List<Map<String, dynamic>> socialLinks = [];
    if (userProfile['socialLinks'] is List) {
      socialLinks = List<Map<String, dynamic>>.from(
        (userProfile['socialLinks'] as List).map((link) {
          if (link is Map<String, dynamic>) {
            return Map<String, dynamic>.from(link);
          }
          return <String, dynamic>{};
        }),
      );
    } else {
      // Fallback: Build from individual fields
      final portfolio = userProfile['portfolioLink']?.toString() ?? '';
      final linkedin = userProfile['linkedinUrl']?.toString() ?? '';
      final github = userProfile['githubUrl']?.toString() ?? '';
      final twitter = userProfile['twitterUrl']?.toString() ?? '';

      if (portfolio.isNotEmpty) {
        socialLinks.add({'title': 'Portfolio', 'profile_url': portfolio});
      }
      if (linkedin.isNotEmpty) {
        socialLinks.add({'title': 'LinkedIn', 'profile_url': linkedin});
      }
      if (github.isNotEmpty) {
        socialLinks.add({'title': 'GitHub', 'profile_url': github});
      }
      if (twitter.isNotEmpty) {
        socialLinks.add({'title': 'Twitter', 'profile_url': twitter});
      }
    }

    return Builder(
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        String? validateUrl(String? value) {
          final trimmed = value?.trim() ?? '';
          if (trimmed.isEmpty) {
            return 'URL is required';
          }
          final uri = Uri.tryParse(trimmed);
          if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
            return 'Enter a valid URL starting with http or https';
          }
          return null;
        }

        String? validateTitle(String? value) {
          final trimmed = value?.trim() ?? '';
          if (trimmed.isEmpty) {
            return 'Title is required';
          }
          return null;
        }

        return StatefulBuilder(
          builder: (context, setState) {
            final formKey = GlobalKey<FormState>();

            void addSocialLink() {
              socialLinks.add({'title': '', 'profile_url': ''});
              setState(() {});
            }

            void removeSocialLink(int index) {
              socialLinks.removeAt(index);
              setState(() {});
            }

            void updateSocialLink(int index, String field, String value) {
              socialLinks[index][field] = value;
              setState(() {});
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
                        ...socialLinks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final link = entry.value;
                          final titleController = TextEditingController(
                            text: link['title']?.toString() ?? '',
                          );
                          final urlController = TextEditingController(
                            text: link['profile_url']?.toString() ?? '',
                          );

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppConstants.smallPadding,
                            ),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  AppConstants.smallPadding,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Link ${index + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              removeSocialLink(index);
                                            });
                                          },
                                          color: Colors.red,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    TextFormField(
                                      controller: titleController,
                                      decoration: const InputDecoration(
                                        labelText:
                                            'Title * (e.g., Portfolio, LinkedIn, GitHub)',
                                        hintText: 'Portfolio',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        updateSocialLink(index, 'title', value);
                                      },
                                      validator: validateTitle,
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    TextFormField(
                                      controller: urlController,
                                      decoration: const InputDecoration(
                                        labelText: 'URL *',
                                        hintText: 'https://example.com',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.url,
                                      onChanged: (value) {
                                        updateSocialLink(
                                          index,
                                          'profile_url',
                                          value,
                                        );
                                      },
                                      validator: validateUrl,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: AppConstants.smallPadding),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              addSocialLink();
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Social Link'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                        const SizedBox(height: AppConstants.largePadding),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Validate all form fields
                              if (!formKey.currentState!.validate()) {
                                return;
                              }

                              // Filter out empty links (both fields must be filled)
                              final validLinks = socialLinks
                                  .where((link) {
                                    final title =
                                        link['title']?.toString().trim() ?? '';
                                    final url =
                                        link['profile_url']
                                            ?.toString()
                                            .trim() ??
                                        '';
                                    return title.isNotEmpty && url.isNotEmpty;
                                  })
                                  .map(
                                    (link) => {
                                      'title':
                                          link['title']?.toString().trim() ??
                                          '',
                                      'profile_url':
                                          link['profile_url']
                                              ?.toString()
                                              .trim() ??
                                          '',
                                    },
                                  )
                                  .toList();

                              bloc.add(
                                UpdateProfileSocialLinksInlineEvent(
                                  socialLinks: validLinks,
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
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
        // General Information Section (First)
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'General Information',
          icon: Icons.info_outline,
          section: 'general_info',
          child: _buildGeneralInformationContent(state.userProfile),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

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
          title: 'Socials',
          icon: Icons.link_outlined,
          section: 'social',
          child: _buildSocialLinksContent(context, state.userProfile),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        // Contact Info - Email
        _buildContactItem(
          icon: Icons.email_outlined,
          label: 'Email',
          value: userProfile['contactEmail']?.toString().isNotEmpty == true
              ? userProfile['contactEmail']
              : (userProfile['email'] ?? 'Not provided'),
        ),
        // Contact Info - Phone
        _buildContactItem(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: userProfile['contactPhone']?.toString().isNotEmpty == true
              ? userProfile['contactPhone']
              : (userProfile['phone'] ?? 'Not provided'),
        ),
      ],
    );
  }

  /// General Information Content
  Widget _buildGeneralInformationContent(Map<String, dynamic> userProfile) {
    return Column(
      children: [
        if (userProfile['gender'] != null)
          _buildContactItem(
            icon: Icons.person_outline,
            label: 'Gender',
            value: _formatGender(userProfile['gender']?.toString() ?? ''),
          ),
        if (userProfile['dateOfBirth'] != null)
          _buildContactItem(
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: userProfile['dateOfBirth'],
          ),
        if (userProfile['languages'] != null) ...[
          _buildLanguagesContactItem(userProfile['languages']) ??
              const SizedBox.shrink(),
        ],
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
    // Get social links from array or build from individual fields
    List<Map<String, dynamic>> socialLinks = [];
    if (userProfile['socialLinks'] is List) {
      socialLinks = List<Map<String, dynamic>>.from(
        (userProfile['socialLinks'] as List).whereType<Map<String, dynamic>>(),
      );
    } else {
      // Fallback: Build from individual fields
      final portfolio = userProfile['portfolioLink']?.toString() ?? '';
      final linkedin = userProfile['linkedinUrl']?.toString() ?? '';
      final github = userProfile['githubUrl']?.toString() ?? '';
      final twitter = userProfile['twitterUrl']?.toString() ?? '';

      if (portfolio.isNotEmpty) {
        socialLinks.add({'title': 'Portfolio', 'profile_url': portfolio});
      }
      if (linkedin.isNotEmpty) {
        socialLinks.add({'title': 'LinkedIn', 'profile_url': linkedin});
      }
      if (github.isNotEmpty) {
        socialLinks.add({'title': 'GitHub', 'profile_url': github});
      }
      if (twitter.isNotEmpty) {
        socialLinks.add({'title': 'Twitter', 'profile_url': twitter});
      }
    }

    // Filter out empty links
    socialLinks = socialLinks.where((link) {
      final title = link['title']?.toString().trim() ?? '';
      final url = link['profile_url']?.toString().trim() ?? '';
      return title.isNotEmpty && url.isNotEmpty;
    }).toList();

    if (socialLinks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.link_outlined,
        title: 'No Social Links Added',
        subtitle: 'Add your portfolio and social media profiles',
      );
    }

    // Helper to get icon based on title
    IconData getIconForTitle(String title) {
      final lowerTitle = title.toLowerCase();
      if (lowerTitle.contains('portfolio') || lowerTitle.contains('website')) {
        return Icons.web_outlined;
      } else if (lowerTitle.contains('linkedin')) {
        return Icons.work_outline;
      } else if (lowerTitle.contains('github')) {
        return Icons.code_outlined;
      } else if (lowerTitle.contains('twitter')) {
        return Icons.alternate_email;
      } else if (lowerTitle.contains('facebook')) {
        return Icons.facebook;
      } else {
        return Icons.link_outlined;
      }
    }

    return Column(
      children: socialLinks.map((link) {
        final title = link['title']?.toString() ?? 'Link';
        final url = link['profile_url']?.toString() ?? '';
        return _buildSocialLinkItem(
          icon: getIconForTitle(title),
          label: title,
          value: url,
          onTap: () => _openUrl(context, url),
        );
      }).toList(),
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
      width: double.infinity,
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
    // Get all fields
    final qualification = edu['qualification']?.toString() ?? '';
    final institute = edu['institute']?.toString() ?? '';
    final startYear = edu['startYear']?.toString() ?? '';
    final endYear = edu['endYear']?.toString() ?? '';
    final isPursuing =
        edu['isPursuing'] == true ||
        edu['isPursuing'] == 1 ||
        edu['isPursuing'] == '1' ||
        edu['isPursuing'] == 'true';
    final pursuingYear = edu['pursuingYear'];
    final cgpa = edu['cgpa']?.toString() ?? '';

    // Build year display - start date always shown, end date only if not pursuing
    String yearDisplay = '';
    if (isPursuing) {
      // Show start year - pursuing status (end date not shown)
      String pursuingText = '';
      if (pursuingYear != null) {
        final yearNum = pursuingYear is int
            ? pursuingYear
            : int.tryParse(pursuingYear.toString());
        if (yearNum != null && yearNum >= 1 && yearNum <= 4) {
          final yearText = yearNum == 1
              ? '1st Year'
              : yearNum == 2
              ? '2nd Year'
              : yearNum == 3
              ? '3rd Year'
              : '4th Year';
          pursuingText = 'Pursuing ($yearText)';
        } else {
          pursuingText = 'Pursuing';
        }
      } else {
        pursuingText = 'Pursuing';
      }

      // Combine start year with pursuing status
      if (startYear.isNotEmpty) {
        yearDisplay = '$startYear - $pursuingText';
      } else {
        yearDisplay = pursuingText;
      }
    } else {
      // Show start year - end year (not pursuing)
      if (startYear.isNotEmpty && endYear.isNotEmpty) {
        yearDisplay = '$startYear - $endYear';
      } else if (endYear.isNotEmpty) {
        yearDisplay = endYear;
      } else if (startYear.isNotEmpty) {
        yearDisplay = startYear;
      }
    }

    return Container(
      width: double.infinity,
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
          // Qualification
          if (qualification.isNotEmpty)
            Text(
              qualification,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          // Institute
          if (institute.isNotEmpty) ...[
            if (qualification.isNotEmpty) const SizedBox(height: 4),
            Text(
              institute,
              style: const TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
          // Year and CGPA
          if (yearDisplay.isNotEmpty || cgpa.isNotEmpty) ...[
            if (qualification.isNotEmpty || institute.isNotEmpty)
              const SizedBox(height: 4),
            Row(
              children: [
                if (yearDisplay.isNotEmpty)
                  Text(
                    yearDisplay,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                if (yearDisplay.isNotEmpty && cgpa.isNotEmpty)
                  const Text(
                    ' • ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                if (cgpa.isNotEmpty)
                  Text(
                    'CGPA: $cgpa',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
              ],
            ),
          ],
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

  Widget? _buildLanguagesContactItem(dynamic languages) {
    if (languages == null) return null;

    String languagesString = '';
    if (languages is List) {
      languagesString = languages.join(', ');
    } else if (languages is String) {
      languagesString = languages;
    }

    if (languagesString.isEmpty) return null;

    return _buildContactItem(
      icon: Icons.language_outlined,
      label: 'Languages',
      value: languagesString,
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

  Future<void> _openUrl(BuildContext context, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid URL'),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // Ensure URL has a scheme (http:// or https://)
      String urlToLaunch = url.trim();
      if (!urlToLaunch.startsWith('http://') &&
          !urlToLaunch.startsWith('https://')) {
        urlToLaunch = 'https://$urlToLaunch';
      }

      final uri = Uri.parse(urlToLaunch);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open URL: $urlToLaunch'),
              backgroundColor: AppConstants.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening URL: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
