/// Profile Screen

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../data/user_data.dart';
import '../../utils/navigation_service.dart';
import 'user_profile.dart';
import '../../auth/signin.dart';

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
              _buildProfileOptions(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the profile header section
  Widget _buildProfileHeader() {
    final user = UserData.currentUser;

    return Container(
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
                  user['location'] ?? 'Location',
                  style: const TextStyle(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Edit button
          IconButton(
            onPressed: () {
              NavigationService.navigateTo(const UserProfileScreen());
            },
            icon: const Icon(Icons.edit, color: AppConstants.accentColor),
          ),
        ],
      ),
    );
  }

  /// Builds the profile options section
  Widget _buildProfileOptions() {
    return Column(
      children: [
        _buildOptionTile(
          icon: Icons.person_outline,
          title: 'Personal Information',
          subtitle: 'Update your personal details',
          onTap: () {
            NavigationService.navigateTo(const UserProfileScreen());
          },
        ),
        _buildOptionTile(
          icon: Icons.work_outline,
          title: 'My Applications',
          subtitle: 'View your job applications',
          onTap: () {
            // TODO: Navigate to applications screen
          },
        ),
        _buildOptionTile(
          icon: Icons.bookmark_outline,
          title: 'Saved Jobs',
          subtitle: 'View your saved jobs',
          onTap: () {
            // TODO: Navigate to saved jobs screen
          },
        ),
        _buildOptionTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage your notifications',
          onTap: () {
            // TODO: Navigate to notifications screen
          },
        ),
        _buildOptionTile(
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'App settings and preferences',
          onTap: () {
            // TODO: Navigate to settings screen
          },
        ),
        _buildOptionTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {
            // TODO: Navigate to help screen
          },
        ),
        _buildOptionTile(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          onTap: () {
            _showLogoutDialog();
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
    required String subtitle,
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
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppConstants.textSecondaryColor),
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
  void _showLogoutDialog() {
    showDialog(
      context: NavigationService.context!,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
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
    // TODO: Clear user data and navigate to signin screen
    NavigationService.navigateToAndClear(const SigninScreen());
  }
}
