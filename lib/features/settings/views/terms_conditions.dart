import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

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
                    onPressed: () => Navigator.of(context).pop(),
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
                          "Please read and accept our terms of service",
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
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            'I have read and agree to the Terms & Conditions',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppConstants.textPrimaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.largePadding),

                    // Accept button
                    SizedBox(
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
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.defaultPadding,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Accept Terms & Conditions',
                          style: AppConstants.buttonTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isAgreed ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
