import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/app_constants.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
        } else {
          context.go(AppRoutes.settings);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header section with icon, title, description and back button
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        } else {
                          context.go(AppRoutes.settings);
                        }
                      },
                    ),
                    const SizedBox(height: 4),

                    // Icon and title
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Color(0xFFE0E7EF),
                            child: Icon(
                              Icons.privacy_tip_outlined,
                              size: 45,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Privacy Policy",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Satpuda Group's Jobsahi.com",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4F789B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Main content (styled like About page sections)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.largePadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildCardSection(
                        child: _buildSection(
                          title: 'Consent',
                          content:
                              'By using JobSahi, you agree to this Privacy Policy.',
                        ),
                      ),
                      const SizedBox(height: 20),
                    _buildCardSection(
                      child: _buildSection(
                        title: 'Information We Collect',
                        content:
                            '2.1 Information provided directly by the user: Name, Email address, Mobile number, City/State (if provided manually), Educational qualifications, Work experience, Skills, Job preferences, Resume/CV, Profile image, Achievement certificates.',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCardSection(
                      child: _buildSection(
                        title: 'Location Information (optional)',
                        content:
                            '2.2 JobSahi may access your location only in the following condition: when you give permission for location access, to detect current location using GPS, only if you don\'t want to manually enter your address/location. You have full control: you can allow or deny GPS permission, the app works even if location permission is denied, you can turn off permission anytime from phone settings. We do not continuously track location in background.',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCardSection(
                      child: _buildSection(
                        title: 'We do NOT collect',
                        content:
                            '2.3 We do NOT collect: IP tracking data, device identification for tracking, browser history, app usage analytics logs, pages viewed history.',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCardSection(
                      child: _buildSection(
                        title: 'How We Use Your Information',
                        content:
                            '3. To create and manage your account, to help you apply for jobs, to show nearby or relevant jobs (if location permission is allowed), to share your profile with recruiters when you apply.',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCardSection(
                      child: _buildSection(
                        title: 'Information Sharing',
                        content:
                            '4. Recruiters when you apply for jobs, authorities when required by law. We do not sell your personal data.',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCardSection(
                      child: _buildSection(
                        title: 'Data Retention',
                        content:
                            '5. Your information is stored as long as your account is active or until you request deletion.',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCardSection(
                      child: _buildSection(
                        title: 'Data Control and Deletion',
                        content:
                            '6. You can manage your data in your account: edit or delete personal profile details, edit or delete resume, edit or delete profile image, edit or delete achievement certificates. To permanently delete your account and all data: Email: Info@jobsahi.com, Phone: 6262604110. Your account will be deleted within 30 days.',
                      ),
                    ),
                      const SizedBox(height: 20),
                      _buildCardSection(
                        child: _buildSection(
                          title: 'Children\'s Privacy',
                          content:
                              'JobSahi is not intended for users under 16 years of age.',
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCardSection(
                        child: _buildSection(
                          title: 'Changes to Policy',
                          content:
                              'This policy may be updated from time to time.',
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCardSection(
                        child: _buildSection(
                          title: 'Contact',
                          content:
                              'For any questions, contact us: Email: Info@jobsahi.com, Phone: 6262604110',
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          content,
          style: AppConstants.bodyStyle.copyWith(
            color: const Color(0xFF4F789B),
            height: 1.6, // About page line-height
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildUsageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How We Use Collected Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        _buildUsageItem('To provide and maintain our services'),
        _buildUsageItem('To notify you about changes to our services'),
        _buildUsageItem('To provide customer support'),
        _buildUsageItem('To gather analysis or valuable information'),
        _buildUsageItem('To monitor the usage of our services'),
        _buildUsageItem('To detect, prevent and address technical issues'),
      ],
    );
  }

  Widget _buildCardSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildUsageItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppConstants.secondaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Text(
              text,
              style: AppConstants.bodyStyle.copyWith(
                color: const Color(0xFF424242),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
