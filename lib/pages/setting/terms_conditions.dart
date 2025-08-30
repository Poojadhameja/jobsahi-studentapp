import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../widgets/global/custom_app_bar.dart';

class TermsConditionsPage extends StatefulWidget {
  const TermsConditionsPage({super.key});

  @override
  State<TermsConditionsPage> createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Terms & Conditions / नियम और शर्तें',
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
                    'नियम और शर्तें',
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
                    'Application Terms & Conditions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.secondaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Content paragraphs
                  _buildParagraph(
                    'Job Sahi आपकी व्यक्तिगत जानकारी को किसी भी अनधिकृत तृतीय पक्ष के साथ साझा नहीं करता है',
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  _buildParagraph(
                    'हालाँकि, एक वैश्विक निगम के रूप में, Workday विभिन्न देशों में मौजूद अपनी संबद्ध कंपनियों और संसाधनों के माध्यम से आपकी जानकारी का उपयोग कर सकता है',
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  _buildParagraph(
                    'Workday अपने समूह की कंपनियों और अन्य तृतीय पक्षों के साथ आपकी जानकारी को साझा या स्थानांतरित कर सकता है ताकि सेवाएं प्रदान की जा सकें',
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  _buildParagraph(
                    'यह स्थानांतरण यूरोपीय आर्थिक क्षेत्र और भारत के बाहर भी हो सकता है',
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Checkbox and agreement text
                  Row(
                    children: [
                      Checkbox(
                        value: isAgreed,
                        onChanged: (value) {
                          setState(() {
                            isAgreed = value ?? false;
                          });
                        },
                        activeColor: AppConstants.secondaryColor,
                        side: BorderSide(
                          color: AppConstants.secondaryColor,
                          width: 2,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'I agree Term & Conditions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppConstants.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.largePadding),
                ],
              ),
            ),
          ),

          // Fixed bottom button container
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isAgreed
                    ? () {
                        // Handle accept action
                        Navigator.of(context).pop();
                      }
                    : null,
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
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                ),
                child: Text(
                  'Accept',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isAgreed ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: AppConstants.bodyStyle.copyWith(
        color: const Color(0xFF424242),
        height: 1.6,
        fontSize: 15,
      ),
    );
  }
}
