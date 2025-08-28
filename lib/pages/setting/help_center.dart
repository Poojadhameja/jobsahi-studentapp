import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../widgets/global/custom_app_bar.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _feedbackController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Help Center/हेल्प सेंटर',
        showBackButton: true,
        showSearchBar: false,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              tabs: const [
                Tab(text: 'Feedback'),
                Tab(text: 'FAQs'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Feedback Tab
                _buildFeedbackTab(),

                // FAQs Tab
                _buildFaqsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Send Feedback',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.secondaryColor,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: AppConstants.smallPadding),

          // Subtitle
          Text(
            'हमें बताएं कि आपको ऐप का कौन-सा हिस्सा पसंद है या हम इसे बेहतर कैसे बना सकते हैं',
            style: AppConstants.bodyStyle.copyWith(
              color: const Color(0xFF424242),
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppConstants.largePadding),

          // Feedback Input
          TextField(
            controller: _feedbackController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Enter Feedback',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide(
                  color: AppConstants.secondaryColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
            ),
          ),

          const SizedBox(height: AppConstants.largePadding),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _feedbackController.text.trim().isNotEmpty
                  ? () {
                      // Handle feedback submission
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feedback submitted successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _feedbackController.clear();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.secondaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Text(
                'Submit Feedback',
                style: AppConstants.buttonTextStyle.copyWith(
                  color: _feedbackController.text.trim().isNotEmpty
                      ? Colors.white
                      : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.secondaryColor,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: AppConstants.smallPadding),

          // Subtitle
          Text(
            'नौकरी के लिए आवेदन करते समय पूछे जाने वाले सामान्य प्रश्नों की सूची:',
            style: AppConstants.bodyStyle.copyWith(
              color: const Color(0xFF424242),
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppConstants.largePadding),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search keywords',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide(
                  color: AppConstants.secondaryColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
            ),
            onChanged: (value) {
              // Handle search functionality
              setState(() {});
            },
          ),

          const SizedBox(height: AppConstants.largePadding),

          // FAQ List
          _buildFaqItem(
            question: 'मैं नौकरी के लिए आवेदन कैसे करूँ?',
            answer:
                'नौकरी के लिए आवेदन करने के लिए आपको पहले अपना अकाउंट बनाना होगा और फिर अपना प्रोफाइल पूरा करना होगा।',
            isExpanded: false,
          ),

          _buildFaqItem(
            question: 'क्या आवेदन करने के लिए अकाउंट बनाना ज़रूरी है?',
            answer:
                'हाँ, अधिकतर जॉब पोर्टल्स पर आवेदन करने के लिए अकाउंट बनाना ज़रूरी होता है इससे आप अपनी एप्लिकेशन की स्थिति ट्रैक कर सकते हैं और कई पदों के लिए आवेदन कर सकते हैं',
            isExpanded: true,
          ),

          _buildFaqItem(
            question: 'आवेदन करने के लिए कौन-कौन से दस्तावेज़ चाहिए होते हैं?',
            answer:
                'आवेदन के लिए आपको अपना रिज्यूमे, फोटो, और आवश्यक प्रमाणपत्र अपलोड करने होंगे।',
            isExpanded: false,
          ),

          _buildFaqItem(
            question: 'क्या मैं एक साथ कई नौकरियों के लिए आवेदन कर सकता हूँ?',
            answer: 'हाँ, आप एक साथ कई नौकरियों के लिए आवेदन कर सकते हैं।',
            isExpanded: false,
          ),

          _buildFaqItem(
            question: 'क्या मैं आवेदन सबमिट करने के बाद उसे अपडेट कर सकता हूँ?',
            answer:
                'हाँ, आप अपना आवेदन सबमिट करने के बाद भी अपडेट कर सकते हैं।',
            isExpanded: false,
          ),

          _buildFaqItem(
            question: 'मुझे कैसे पता चलेगा कि मेरा आवेदन सफल रहा या नहीं?',
            answer:
                'आपको ईमेल या SMS के माध्यम से अपने आवेदन की स्थिति के बारे में सूचित किया जाएगा।',
            isExpanded: false,
          ),

          _buildFaqItem(
            question: 'अगर मुझे किसी कंपनी से जवाब नहीं मिले तो क्या करूँ?',
            answer:
                'अगर आपको जवाब नहीं मिलता है, तो आप कंपनी से सीधे संपर्क कर सकते हैं या हमारी सहायता टीम से संपर्क कर सकते हैं।',
            isExpanded: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required bool isExpanded,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: AppConstants.bodyStyle.copyWith(
          color: const Color(0xFF424242),
          fontWeight: FontWeight.w500,
        ),
      ),
      iconColor: AppConstants.secondaryColor,
      collapsedIconColor: AppConstants.secondaryColor,
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Text(
            answer,
            style: AppConstants.bodyStyle.copyWith(
              color: const Color(0xFF666666),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
