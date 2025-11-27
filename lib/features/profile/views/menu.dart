import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/network_error_helper.dart';
import '../../../shared/data/user_data.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../../../shared/widgets/loaders/jobsahi_loader.dart';
import '../../../shared/widgets/profile/profile_header_card.dart';
import '../../../shared/services/location_service.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger profile load when entering the menu if not already in progress/completed.
    final profileBloc = context.read<ProfileBloc>();
    final currentState = profileBloc.state;
    if (currentState is! ProfileLoading &&
        currentState is! ProfileDetailsLoaded) {
      profileBloc.add(const LoadProfileDataEvent());
    }
  }

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

      return 'Location not provided';
    } catch (e) {
      return 'Location not provided';
    }
  }

  String? _extractLocation(dynamic locationValue) {
    if (locationValue == null) {
      return null;
    }

    final locationString = locationValue.toString().trim();
    if (locationString.isEmpty || locationString.toLowerCase() == 'null') {
      return null;
    }

    return locationString;
  }

  String? _extractBio(dynamic bioValue) {
    if (bioValue == null) {
      return null;
    }

    final bioString = bioValue.toString().trim();
    if (bioString.isEmpty || bioString.toLowerCase() == 'null') {
      return null;
    }

    return bioString;
  }

  /// Handle back navigation
  void _handleBackNavigation(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackNavigation(context);
        }
      },
      child: KeyboardDismissWrapper(
        child: Scaffold(
          backgroundColor: AppConstants.cardBackgroundColor,
          appBar: AppBar(
            backgroundColor: AppConstants.cardBackgroundColor,
            elevation: 0,
            title: const Text(
              'Menu',
              style: TextStyle(
                color: AppConstants.textPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppConstants.textPrimaryColor,
              ),
              onPressed: () {
                _handleBackNavigation(context);
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  // Profile header
                  _buildProfileHeader(context),
                  const SizedBox(height: AppConstants.largePadding),

                  // Menu options
                  _buildMenuOptions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the profile header section
  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppConstants.largePadding),
            child: Center(
              child: JobsahiLoader(
                size: 48,
                strokeWidth: 3,
                message: 'Loading profile...',
                showMessage: true,
              ),
            ),
          );
        }

        if (state is ProfileDetailsLoaded) {
          final userProfile = state.userProfile;
          final location = _extractLocation(userProfile['location']);

          Widget headerCard(String? resolvedLocation) {
            return ProfileHeaderCard(
              name: userProfile['name']?.toString().isNotEmpty == true
                  ? userProfile['name'] as String
                  : (UserData.currentUser['name'] ?? 'User Name'),
              email: userProfile['email']?.toString().isNotEmpty == true
                  ? userProfile['email'] as String
                  : (UserData.currentUser['email'] ?? 'user@email.com'),
              location: resolvedLocation,
              profileImagePath:
                  state.profileImagePath ?? userProfile['profileImage'],
              bio: _extractBio(userProfile['bio']),
              onTap: () => context.push(AppRoutes.profileDetails),
              margin: EdgeInsets.zero,
            );
          }

          if (location != null && location.isNotEmpty) {
            return headerCard(location);
          }

          return FutureBuilder<String>(
            future: _getUserLocation(),
            builder: (context, snapshot) {
              final detectedLocation = snapshot.connectionState ==
                          ConnectionState.done &&
                      snapshot.hasData &&
                      snapshot.data!.isNotEmpty
                  ? snapshot.data
                  : null;
              return headerCard(detectedLocation);
            },
          );
        }

        if (state is ProfileError) {
          // Check if it's a network error
          final isNetworkError = NetworkErrorHelper.isNetworkError(state.message);
          
          if (isNetworkError) {
            return NoInternetErrorWidget(
              errorMessage: state.message,
              onRetry: () {
                context.read<ProfileBloc>().add(const LoadProfileDataEvent());
              },
              showImage: true,
              enablePullToRefresh: true,
            );
          }
          
          // For non-network errors, show fallback with error message
          final fallbackUser = UserData.currentUser;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeaderCard(
                name: fallbackUser['name'] ?? 'User Name',
                email: fallbackUser['email'] ?? 'user@email.com',
                location: _extractLocation(fallbackUser['location'] ?? '') ??
                    'Location not provided',
                profileImagePath: fallbackUser['profileImage'],
                bio: _extractBio(fallbackUser['bio']),
                onTap: () => context.push(AppRoutes.profileDetails),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                state.message,
                style: const TextStyle(
                  color: AppConstants.errorColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton.icon(
                onPressed: () => context
                    .read<ProfileBloc>()
                    .add(const LoadProfileDataEvent()),
                icon: const Icon(Icons.refresh, color: AppConstants.primaryColor),
                label: const Text('Retry',
                    style: TextStyle(color: AppConstants.primaryColor)),
              ),
            ],
          );
        }

        // Default fallback while waiting for first state.
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppConstants.largePadding),
          child: JobsahiLoader(
            size: 48,
            strokeWidth: 3,
            message: 'Loading profile...',
            showMessage: true,
          ),
        );
      },
    );
  }

  /// Builds the menu options section
  Widget _buildMenuOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          icon: Icons.timeline,
          title: 'Track Application / आवेदन ट्रैक करें',
          onTap: () {
            context.push('${AppRoutes.applicationTracker}?fromProfile=true');
          },
        ),
        _buildOptionTile(
          icon: Icons.favorite_outline,
          title: 'Personalize Jobfeed / जॉबफ़ीड पर्सनलाइज़ करें',
          onTap: () {
            context.push(AppRoutes.personalizeJobfeed);
          },
        ),
        _buildOptionTile(
          icon: Icons.help_outline,
          title: 'FAQs / सामान्य प्रश्न',
          onTap: () {
            context.push(AppRoutes.faqs);
          },
        ),
        _buildOptionTile(
          icon: Icons.info_outline,
          title: 'About / हमारे बारे में',
          onTap: () {
            context.push(AppRoutes.about);
          },
        ),
        _buildOptionTile(
          icon: Icons.support_agent_outlined,
          title: 'Contact Us / संपर्क करें',
          onTap: () {
            context.push(AppRoutes.contactUs);
          },
        ),
        _buildOptionTile(
          icon: Icons.feedback_outlined,
          title: 'Feedback / प्रतिक्रिया',
          onTap: () {
            context.push(AppRoutes.feedback);
          },
        ),
        _buildOptionTile(
          icon: Icons.settings_outlined,
          title: 'Settings / सेटिंग्स',
          onTap: () {
            context.push(AppRoutes.settings);
          },
        ),
        _buildOptionTile(
          icon: Icons.logout,
          title: 'Logout / लॉगआउट',
          onTap: () {
            _showLogoutDialog(context);
          },
          isDestructive: true,
        ),
      ],
    );
  }

  /// Builds an option tile
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final borderRadius = BorderRadius.circular(AppConstants.borderRadius);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: onTap,
          splashColor: isDestructive
              ? AppConstants.errorColor.withOpacity(0.2)
              : null,
          highlightColor: isDestructive
              ? AppConstants.errorColor.withOpacity(0.1)
              : null,
          hoverColor: isDestructive
              ? AppConstants.errorColor.withOpacity(0.1)
              : null,
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            leading: Icon(
              icon,
              color: isDestructive
                  ? AppConstants.errorColor
                  : AppConstants.textPrimaryColor,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isDestructive
                    ? AppConstants.errorColor
                    : AppConstants.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  /// Shows logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            // Hide the dialog and navigate to login screen
            Navigator.of(dialogContext).pop();
            context.go(AppRoutes.loginOtpEmail);
          } else if (state is AuthError) {
            // Hide the dialog and show error
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppConstants.errorColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: _LogoutDialog(),
      ),
    );
  }
}

/// Logout dialog widget that shows confirmation and then loader
class _LogoutDialog extends StatefulWidget {
  @override
  State<_LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<_LogoutDialog> {
  bool _isLoggingOut = false;

  void _handleLogout() {
    setState(() {
      _isLoggingOut = true;
    });

    // Dispatch logout event to AuthBloc
    context.read<AuthBloc>().add(const LogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                children: [
                  if (!_isLoggingOut) ...[
                    Text(
                      'Logout',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.errorColor,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _isLoggingOut
                      ? JobsahiLoader(
                          size: 50,
                          strokeWidth: 4,
                          message: 'Logging out',
                          showMessage: true,
                        )
                      : const Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                ],
              ),
            ),

            // Action buttons
            if (!_isLoggingOut) ...[
              Container(height: 1, color: Colors.grey.shade300),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black54,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ),
                  Container(height: 40, width: 1, color: Colors.grey.shade300),
                  Expanded(
                    child: TextButton(
                      onPressed: _handleLogout,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppConstants.errorColor,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppConstants.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
