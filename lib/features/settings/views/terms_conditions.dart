import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_state.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(),
      child: _TermsConditionsPageView(),
    );
  }
}

class _TermsConditionsPageView extends StatelessWidget {
  const _TermsConditionsPageView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
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
                                  Icons.article_outlined,
                                  size: 45,
                                  color: AppConstants.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Terms & Conditions",
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

                  // Main content
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
                              title: 'Acceptance of Terms',
                              content:
                                  'By accessing or using JobSahi, you agree to be bound by these Terms and Conditions.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'Description of Services',
                              content:
                                  'JobSahi provides a job portal platform including: job search and applications, resume upload and profile creation, profile image upload, achievement certificate upload, communication between candidates and recruiters.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'User Accounts',
                              content:
                                  'You must provide accurate details, minimum age must be 16 years, and only one account per person. You are responsible for your account activity, keep login credentials confidential, and inform us of any unauthorized access.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'Location Permission',
                              content:
                                  'Location is used only when you allow GPS access, it is used only to detect current location for jobs near you, you may deny permission and still use the app, location is not tracked continuously in background.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'User Content',
                              content:
                                  'Resume/CV, profile image, achievement certificates, education and experience information. You retain ownership of uploaded content. You grant JobSahi permission to use it only for job-related services.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'Job Applications',
                              content:
                                  'JobSahi does not guarantee employment. Recruiters are responsible for hiring decisions.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'Privacy',
                              content:
                                  'Your information is handled according to our Privacy Policy.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'Data Deletion',
                              content:
                                  'You may delete data from your profile or request full account deletion. Email: Info@jobsahi.com, Phone: 6262604110',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'Limitation of Liability',
                              content:
                                  'The platform is provided "as is" without warranties.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'Termination',
                              content:
                                  'Your account may be terminated for policy violations or misuse.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'Governing Law',
                              content:
                                  'These Terms are governed by the laws of India.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'Changes',
                              content:
                                  'Terms may be updated from time to time.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'Contact',
                              content:
                                  'Email: Info@jobsahi.com, Phone: 6262604110',
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
      },
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
            height: 1.6,
            fontSize: 14,
          ),
        ),
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
}
