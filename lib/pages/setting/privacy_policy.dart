import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../widgets/global/custom_app_bar.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Privacy Policy/गोपनीयता नीति',
        showBackButton: true,
        showSearchBar: false,
        onBackPressed: () {
          // Navigate back to settings page
          Navigator.of(context).pop();
        },
      ),
      body: Column(
        children: [
          // Top thin horizontal line
          Container(height: 1, color: const Color(0xFFE0E0E0)),

          // Header with info icon and title
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.secondaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppConstants.secondaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    'गोपनीयता नीति',
                    style: AppConstants.headingStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF424242),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom thin horizontal line
          Container(height: 1, color: const Color(0xFFE0E0E0)),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main heading
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.secondaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Personal Identification Information Section
                  _buildSection(
                    title: 'Personal Identification Information',
                    content:
                        'जब आप हमारी सेवाओं के साथ इंटरैक्ट करते हैं, तो आप जो जानकारी साझा करना चुनते हैं, हम उसे एकत्र कर सकते हैं',
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Non-Personal Identification Information Section
                  _buildSection(
                    title: 'Non-Personal Identification Information',
                    content:
                        'हम उपयोगकर्ताओं से गैर-व्यक्तिगत जानकारी भी एकत्र कर सकते हैं, जैसे कि ब्राउज़र प्रकार, ऑपरेटिंग सिस्टम, IP एड्रेस, इंटरनेट सेवा प्रदाता, आदि',
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // How We Use Collected Information Section
                  _buildUsageSection(),

                  const SizedBox(height: AppConstants.largePadding),
                ],
              ),
            ),
          ),

          // Fixed bottom button container
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.secondaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  AppConstants.nextButton,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.secondaryColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          content,
          style: AppConstants.bodyStyle.copyWith(
            color: const Color(0xFF424242),
            height: 1.6,
            fontSize: 15,
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
          'How We Use Collected Information?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.secondaryColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'Job Sahi App उपयोगकर्ताओं की जानकारी निम्न उद्देश्यों के लिए एकत्र करता है:',
          style: AppConstants.bodyStyle.copyWith(
            color: const Color(0xFF424242),
            height: 1.6,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Bullet points
        _buildBulletPoint(
          'दिया गया व्यक्तिगत डेटा:',
          'नौकरी के मिलान हेतु जानकारी, जिसे नियोक्ताओं के साथ साझा किया जा सकता है',
        ),
        const SizedBox(height: AppConstants.smallPadding),

        _buildBulletPoint(
          'स्थान जानकारी:',
          'पास के स्थानों में नौकरियों की जानकारी देने हेतु',
        ),
        const SizedBox(height: AppConstants.smallPadding),

        _buildBulletPoint(
          'कॉल लॉग:',
          'यह ट्रैक करता है कि कॉल सफल रही या नहीं, और सफल कॉल पर किस नौकरी के बारे में बात हुई',
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppConstants.secondaryColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppConstants.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF424242),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppConstants.bodyStyle.copyWith(
                  color: const Color(0xFF424242),
                  height: 1.6,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
