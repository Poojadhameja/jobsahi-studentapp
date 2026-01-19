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
                              title: 'Data Sharing',
                              content:
                                  'Jobsahi आपकी व्यक्तिगत जानकारी को किसी भी अनधिकृत तृतीय पक्ष के साथ साझा नहीं करता है। आपकी जानकारी केवल सेवाओं को प्रदान करने, कानूनी अनुपालन और सुरक्षा उद्देश्यों के लिए उपयोग की जाती है।',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'International Transfer',
                              content:
                                  'एक वैश्विक संगठन के रूप में, हमारी संबद्ध कंपनियों और संसाधनों के माध्यम से आपकी जानकारी विभिन्न देशों में सुरक्षित सर्वरों पर संसाधित की जा सकती है। हम लागू कानूनों के अनुरूप आवश्यक सुरक्षा उपायों का पालन करते हैं।',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'Third‑party Processing',
                              content:
                                  'सेवाएं प्रदान करने के लिए, Jobsahi विश्वसनीय तृतीय‑पक्ष भागीदारों के साथ काम कर सकता है। ऐसे मामलों में, हम यह सुनिश्चित करते हैं कि वे सख्ती से गोपनीयता और सुरक्षा मानकों का पालन करें तथा डेटा का उपयोग केवल निर्दिष्ट उद्देश्य के लिए करें।',
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCardSection(
                            child: _buildSection(
                              title: 'Your Consent',
                              content:
                                  'हमारी सेवाओं का उपयोग करते समय आप इन शर्तों से सहमत होते हैं। यदि आप इन शर्तों से असहमत हैं, तो कृपया सेवाओं का उपयोग बंद करें और किसी भी प्रश्न के लिए हमसे संपर्क करें।',
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
