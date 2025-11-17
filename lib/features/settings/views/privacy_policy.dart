import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/app_constants.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onPressed: () => context.go(AppRoutes.settings),
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
                        title: 'Personal Identification Information',
                        content:
                            'जब आप हमारी सेवाओं के साथ इंटरैक्ट करते हैं, तो आप जो जानकारी साझा करना चुनते हैं, हम उसे एकत्र कर सकते हैं। इसमें नाम, ईमेल, फोन नंबर, प्रोफाइल विवरण आदि शामिल हो सकते हैं।',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCardSection(
                      child: _buildSection(
                        title: 'Non-Personal Identification Information',
                        content:
                            'हम गैर-व्यक्तिगत जानकारी भी एकत्र कर सकते हैं, जैसे ब्राउज़र/डिवाइस जानकारी, ऑपरेटिंग सिस्टम, IP एड्रेस और उपयोग पैटर्न ताकि अनुभव सुधारा जा सके।',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCardSection(child: _buildUsageSection()),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
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
