import 'package:flutter/material.dart';
import '../../utils/navigation_service.dart';
import '../../utils/app_constants.dart';
import '../../widgets/global/custom_app_bar.dart';
import 'about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: const CustomAppBar(
        title: 'Setting/सेटिंग्स',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              children: [
                _buildSettingItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Account Setting / खाता सेटिंग',
                  onTap: () {
                    // TODO: Navigate to Account Setting Page
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Password Change / पासवर्ड बदलें',
                  onTap: () {

                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notification / नोटिफिकेशन',
                  onTap: () {
                    // TODO: Navigate to Notification Page
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
                    // TODO: Navigate to FAQs Page
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.article_outlined,
                  title: 'Terms & Conditions / नियम और शर्तें',
                  onTap: () {
                    // TODO: Navigate to Terms Page
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy / गोपनीयता नीति',
                  onTap: () {
                    // TODO: Navigate to Privacy Page
                  },
                ),
              ],
            ),
          ),
        ],
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
            Icon(
              icon, 
              color: AppConstants.primaryColor, 
              size: 24,
            ),
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
