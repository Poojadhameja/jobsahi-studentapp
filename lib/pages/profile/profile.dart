import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../data/user_data.dart';
import '../../utils/navigation_service.dart';
import 'profile_details.dart';
import 'job_status.dart';
import '../../auth/login_otp_email.dart';
import '../jobs/application_tracker.dart';
import '../setting/settings.dart';
import 'personalize_jobfeed.dart';
import '../messages/inbox_screen.dart';
import '../setting/help_center.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Profile header
              _buildProfileHeader(),
              const SizedBox(height: AppConstants.largePadding),

              // Profile options
              _buildProfileOptions(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the profile header section
  Widget _buildProfileHeader() {
    final user = UserData.currentUser;

    return GestureDetector(
      onTap: () {
        // Navigate to profile details when profile header is tapped
        NavigationService.smartNavigate(
          destination: const ProfileDetailsScreen(
            isFromBottomNavigation: false,
          ),
        );
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
                  Text(
                    user['phone'] ?? 'phone',
                    style: const TextStyle(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the profile options section
  Widget _buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          icon: Icons.track_changes,
          title: 'Job Status / नौकरी की स्थिति',
          onTap: () {
            NavigationService.smartNavigate(
              destination: const JobStatusScreen(),
            );
          },
        ),
        _buildOptionTile(
          icon: Icons.timeline,
          title: 'Track Application / आवेदन ट्रैक करें',
          onTap: () {
            NavigationService.smartNavigate(
              destination: const ApplicationTrackerScreen(isFromProfile: true),
            );
          },
        ),
        _buildOptionTile(
          icon: Icons.chat_outlined,
          title: 'My Chats / आपकी बातचीत',
          onTap: () {
            NavigationService.smartNavigate(
              destination: InboxScreen(isFromProfile: true),
            );
          },
        ),
        _buildOptionTile(
          icon: Icons.favorite_outline,
          title: 'Personalize Jobfeed / पसंद की नौकरी',
          onTap: () {
            NavigationService.smartNavigate(
              destination: const PersonalizeJobfeedScreen(),
            );
          },
        ),
        _buildOptionTile(
          icon: Icons.feedback_outlined,
          title: 'Feedback / प्रतिक्रिया',
          onTap: () {
            NavigationService.smartNavigate(
              destination: const HelpCenterPage(),
            );
          },
        ),
        _buildOptionTile(
          icon: Icons.settings_outlined,
          title: 'Settings / सेटिंग्स',
          onTap: () {
            NavigationService.smartNavigate(destination: const SettingsPage());
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
              _logout();
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
  void _logout() {
    // TODO: Clear user data and navigate to login screen
    NavigationService.smartNavigate(destination: const LoginOtpEmailScreen());
  }
}
