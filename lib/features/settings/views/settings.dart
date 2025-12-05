import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/app_constants.dart';

/// Settings Page
///
/// ⚠️ IMPORTANT: This page does NOT use location services.
/// No location permission checks or location service initialization happens here.
/// If you see location-related dialogs when opening this page, it's likely from:
/// - Android system automatically prompting for location accuracy
/// - Some other part of the app checking location in background
///
/// This page only handles:
/// - Password change
/// - Notification permissions
/// - Notification preferences
/// - Privacy policy
/// - Terms & conditions
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        // Handle system back button
        if (context.canPop()) {
          context.pop();
        }
      },
      child: Scaffold(
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
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
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

                    // Notification icon removed
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
                        context.push(AppRoutes.changePassword);
                      },
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: 'Notification Settings / नोटिफिकेशन सेटिंग्स',
                      onTap: () {
                        context.push(AppRoutes.notificationSettings);
                      },
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy / गोपनीयता नीति',
                      onTap: () {
                        context.push(AppRoutes.privacyPolicy);
                      },
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.article_outlined,
                      title: 'Terms & Conditions / नियम और शर्तें',
                      onTap: () {
                        context.push(AppRoutes.termsConditions);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    final borderRadius = BorderRadius.circular(AppConstants.borderRadius);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            leading: Icon(icon, color: AppConstants.primaryColor, size: 24),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppConstants.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
