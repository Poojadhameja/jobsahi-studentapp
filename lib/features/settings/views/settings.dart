import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/app_constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header section with back icon, title, and notification icon
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppConstants.textPrimaryColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  // Title
                  Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Notification icon
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppConstants.textPrimaryColor,
                    ),
                    onPressed: () {
                      // Handle notification tap
                      context.go(AppRoutes.notificationPermission);
                    },
                  ),
                ],
              ),
            ),

            // Settings list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSettingItem(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Password Change / पासवर्ड बदलें',
                    onTap: () {
                      context.go(AppRoutes.changePassword);
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notification / नोटिफिकेशन',
                    onTap: () {
                      context.go(AppRoutes.notificationPermission);
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'About / हमारे बारे में',
                    onTap: () {
                      context.go(AppRoutes.about);
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'FAQs / सामान्य प्रश्न',
                    onTap: () {
                      context.go(AppRoutes.helpCenter);
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.article_outlined,
                    title: 'Terms & Conditions / नियम और शर्तें',
                    onTap: () {
                      context.go(AppRoutes.termsConditions);
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy / गोपनीयता नीति',
                    onTap: () {
                      context.go(AppRoutes.privacyPolicy);
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

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(icon, color: AppConstants.primaryColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppConstants.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
