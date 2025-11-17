import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.largePadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),

                    /// Back button
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppConstants.textPrimaryColor,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 4),

                    /// Profile avatar & title
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Color(0xFFE0E7EF),
                            child: Icon(
                              Icons.info_outline,
                              size: 45,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "About JOBSAHI",
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

                    /// Mission section
                    _buildMissionSection(),
                    const SizedBox(height: 20),

                    /// Company info section
                    _buildCompanyInfoSection(),
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

  /// Builds the mission section with modern styling
  Widget _buildMissionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Mission',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),

          _buildMissionParagraph(
            'JOBSAHI शिक्षा और रोजगार के बीच की खाई को पाटने के लिए प्रतिबद्ध है, '
            'विशेष रूप से IT और Polytechnic छात्रों के लिए।',
          ),

          const SizedBox(height: 12),

          _buildMissionParagraph(
            'हमारा प्लेटफॉर्म कुशल व्यक्तियों को प्रमुख उद्योगों से जोड़ने के लिए '
            'डिज़ाइन किया गया है, जो पूर्णकालिक नौकरियां, प्रशिक्षुता और अनुबंध भूमिकाएं प्रदान करता है।',
          ),

          const SizedBox(height: 12),

          _buildMissionParagraph(
            'हमारा मिशन तकनीकी प्रतिभा को सशक्त बनाना है, '
            'उद्योग की मांगों के आधार पर व्यक्तिगत करियर विकास समाधान और '
            'स्किल-अप प्रोग्राम प्रदान करके।',
          ),

          const SizedBox(height: 12),

          _buildMissionParagraph(
            'JOBSAHI एक पारदर्शी और कुशल पारिस्थितिकी तंत्र बनाने का प्रयास करता है, '
            'Satpuda Group के दो दशकों के तकनीकी शिक्षा अनुभव का लाभ उठाते हुए, '
            'जहां छात्र, संस्थान और उद्योग एक कुशल और भविष्य-तैयार कार्यबल '
            'बनाने के लिए सहयोग करते हैं।',
          ),
        ],
      ),
    );
  }

  Widget _buildMissionParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.6,
        color: Color(0xFF4F789B),
      ),
    );
  }

  /// Builds the company info section with modern styling
  Widget _buildCompanyInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),

          _buildInfoRow(Icons.business, 'Company', 'Satpuda Group'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today, 'Founded', '2004'),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.work,
            'Industry',
            'Technical Education & Job Placement',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, 'Headquarters', 'Central India'),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.school,
            'Specialization',
            'IT, Polytechnic, Skill Development',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF58B248)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Contact section extracted to separate Contact Us page
}
