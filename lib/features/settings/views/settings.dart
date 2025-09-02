import 'package:flutter/material.dart';
import '../../../core/utils/navigation_service.dart';
import '../../../core/utils/app_constants.dart';
import 'about_page.dart';
import 'privacy_policy.dart';
import 'terms_conditions.dart';
import 'help_center.dart';
import 'notification_permission.dart';
import '../../auth/views/change_password.dart';

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
                      NavigationService.smartNavigate(
                        destination: const NotificationPermissionPage(),
                      );
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
                      NavigationService.smartNavigate(
                        destination: const ChangePasswordPage(),
                      );
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notification / नोटिफिकेशन',
                    onTap: () {
                      NavigationService.smartNavigate(
                        destination: const NotificationPermissionPage(),
                      );
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'About / हमारे बारे में',
                    onTap: () {
                      NavigationService.smartNavigate(
                        destination: const AboutPage(),
                      );
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'FAQs / सामान्य प्रश्न',
                    onTap: () {
                      NavigationService.smartNavigate(
                        destination: const HelpCenterPage(),
                      );
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.article_outlined,
                    title: 'Terms & Conditions / नियम और शर्तें',
                    onTap: () {
                      NavigationService.smartNavigate(
                        destination: const TermsConditionsPage(),
                      );
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy / गोपनीयता नीति',
                    onTap: () {
                      NavigationService.smartNavigate(
                        destination: const PrivacyPolicyPage(),
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
