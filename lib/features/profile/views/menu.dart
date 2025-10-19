import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/data/user_data.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/services/location_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  /// Gets user's current location for display
  Future<String> _getUserLocation() async {
    try {
      final locationService = LocationService.instance;
      await locationService.initialize();

      // Try to get saved location first
      final savedLocation = await locationService.getSavedLocation();
      if (savedLocation != null) {
        return savedLocation.address ??
            '${savedLocation.latitude.toStringAsFixed(4)}, ${savedLocation.longitude.toStringAsFixed(4)}';
      }

      // If no saved location, try to get current location
      final currentLocation = await locationService.getCurrentLocation();
      if (currentLocation != null) {
        return currentLocation.address ??
            '${currentLocation.latitude.toStringAsFixed(4)}, ${currentLocation.longitude.toStringAsFixed(4)}';
      }

      return 'Location not available';
    } catch (e) {
      return 'Location not available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          // Navigate to login screen after successful logout
          context.go(AppRoutes.loginOtpEmail);
        } else if (state is AuthError) {
          // Show error message if logout fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppConstants.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
                // Navigate back to previous screen
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
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
    final user = UserData.currentUser;

    return GestureDetector(
      onTap: () {
        // Navigate to profile details when profile header is tapped
        context.push(AppRoutes.profileDetails);
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppConstants.backgroundColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Row(
          children: [
            // Profile image
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(
                user['profileImage'] ?? AppConstants.defaultProfileImage,
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['email'] ?? 'user@email.com',
                    style: const TextStyle(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<String>(
                    future: _getUserLocation(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Getting location...',
                          style: TextStyle(
                            color: AppConstants.textSecondaryColor,
                          ),
                        );
                      }
                      return Text(
                        snapshot.data ?? 'Location not available',
                        style: const TextStyle(
                          color: AppConstants.textSecondaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the menu options section
  Widget _buildMenuOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          icon: Icons.track_changes,
          title: 'Job Status / नौकरी की स्थिति',
          onTap: () {
            context.push(AppRoutes.jobStatus);
          },
        ),
        _buildOptionTile(
          icon: Icons.timeline,
          title: 'Track Application / आवेदन ट्रैक करें',
          onTap: () {
            context.push(AppRoutes.applicationTracker);
          },
        ),
        _buildOptionTile(
          icon: Icons.chat_outlined,
          title: 'My Chats / आपकी बातचीत',
          onTap: () {
            context.push(AppRoutes.messages);
          },
        ),
        _buildOptionTile(
          icon: Icons.favorite_outline,
          title: 'Personalize Jobfeed / पसंद की नौकरी',
          onTap: () {
            context.push(AppRoutes.personalizeJobfeed);
          },
        ),
        _buildOptionTile(
          icon: Icons.feedback_outlined,
          title: 'Feedback / प्रतिक्रिया',
          onTap: () {
            context.push(AppRoutes.helpCenter);
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
    return ListTile(
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
      onTap: onTap,
    );
  }

  /// Shows logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _logout(dialogContext);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppConstants.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles logout
  void _logout(BuildContext context) {
    // Dispatch logout event to AuthBloc
    context.read<AuthBloc>().add(const LogoutEvent());
  }
}
