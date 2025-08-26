import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/custom_app_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: const CustomAppBar(
        title: 'About/हमारे बारे में',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main title section
            _buildMainTitle(),
            const SizedBox(height: AppConstants.largePadding),
            
            // Content sections
            _buildContentSection(),
            const SizedBox(height: AppConstants.largePadding),
            
            // Company info section
            _buildCompanyInfo(),
            const SizedBox(height: AppConstants.largePadding),
            
            // Contact section
            _buildContactSection(),
            const SizedBox(height: AppConstants.largePadding),
            
            // Back button
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Info icon
          Icon(
            Icons.info_outline,
            size: 48,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Main title
          Text(
            'About JOBSAHI',
            style: AppConstants.headingStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppConstants.smallPadding),
          
          // Subtitle
          Text(
            'Satpuda Group\'s Jobsahi.com',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppConstants.secondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Mission',
            style: AppConstants.subheadingStyle.copyWith(
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Mission content in Hindi
          _buildMissionParagraph(
            'JOBSAHI शिक्षा और रोजगार के बीच की खाई को पाटने के लिए प्रतिबद्ध है, '
            'विशेष रूप से IT और Polytechnic छात्रों के लिए।'
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          _buildMissionParagraph(
            'हमारा प्लेटफॉर्म कुशल व्यक्तियों को प्रमुख उद्योगों से जोड़ने के लिए '
            'डिज़ाइन किया गया है, जो पूर्णकालिक नौकरियां, प्रशिक्षुता और अनुबंध भूमिकाएं प्रदान करता है।'
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          _buildMissionParagraph(
            'हमारा मिशन तकनीकी प्रतिभा को सशक्त बनाना है, '
            'उद्योग की मांगों के आधार पर व्यक्तिगत करियर विकास समाधान और '
            'स्किल-अप प्रोग्राम प्रदान करके।'
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          _buildMissionParagraph(
            'JOBSAHI एक पारदर्शी और कुशल पारिस्थितिकी तंत्र बनाने का प्रयास करता है, '
            'Satpuda Group के दो दशकों के तकनीकी शिक्षा अनुभव का लाभ उठाते हुए, '
            'जहां छात्र, संस्थान और उद्योग एक कुशल और भविष्य-तैयार कार्यबल '
            'बनाने के लिए सहयोग करते हैं।'
          ),
        ],
      ),
    );
  }

  Widget _buildMissionParagraph(String text) {
    return Text(
      text,
      style: AppConstants.bodyStyle.copyWith(
        height: 1.6,
        color: AppConstants.textPrimaryColor,
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Information',
            style: AppConstants.subheadingStyle.copyWith(
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          _buildInfoRow('Company', 'Satpuda Group'),
          _buildInfoRow('Founded', '2004'),
          _buildInfoRow('Industry', 'Technical Education & Job Placement'),
          _buildInfoRow('Headquarters', 'Central India'),
          _buildInfoRow('Specialization', 'IT, Polytechnic, Skill Development'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppConstants.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppConstants.bodyStyle.copyWith(
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: AppConstants.subheadingStyle.copyWith(
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          
          _buildContactRow(Icons.email_outlined, 'Email', 'info@jobsahi.com'),
          _buildContactRow(Icons.phone_outlined, 'Phone', '+91 12345 67890'),
          _buildContactRow(Icons.location_on_outlined, 'Address', 'Central India'),
          _buildContactRow(Icons.language_outlined, 'Website', 'www.jobsahi.com'),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppConstants.secondaryColor,
            size: 20,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppConstants.captionStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                Text(
                  value,
                  style: AppConstants.bodyStyle.copyWith(
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => NavigationService.goBack(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
            side: BorderSide(color: AppConstants.secondaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
          child: Text(
            'BACK',
            style: AppConstants.buttonTextStyle.copyWith(
              color: AppConstants.secondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
