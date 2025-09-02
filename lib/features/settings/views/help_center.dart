import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

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
      backgroundColor: AppConstants.backgroundColor,
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
                            Icons.help_outline,
                            size: 45,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Help Center",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Get help and find answers to your questions",
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

            // Tab Bar
            Container(
              color: AppConstants.cardBackgroundColor,
              child: TabBar(
                controller: _tabController,
                labelColor: AppConstants.primaryColor,
                unselectedLabelColor: AppConstants.textSecondaryColor,
                indicatorColor: AppConstants.primaryColor,
                indicatorWeight: 3,
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
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
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
                  onChanged: (value) {
                    // Rebuild UI when text changes to enable/disable button
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter Feedback',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      borderSide: BorderSide(
                        color: AppConstants.secondaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(
                      AppConstants.defaultPadding,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding),
              ],
            ),
          ),
        ),

        // Fixed bottom button
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppConstants.cardBackgroundColor,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: SizedBox(
            width: double.infinity,
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
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
                elevation: 2,
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Text(
                'Submit Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _feedbackController.text.trim().isNotEmpty
                      ? Colors.white
                      : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqsTab() {
    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
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
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
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
                      'हाँ, अधिकतर जॉब पोर्टल्स पर आवेदन करने के लिए अकाउंट बनाना ज़रूरी होता है इससे आप अपनी एप्लिकेशन की स्थिति ट्रैक कर स हैं और कई पदों के लिए आवेदन कर सकते हैं',
                  isExpanded: true,
                ),

                _buildFaqItem(
                  question:
                      'आवेदन करने के लिए कौन-कौन से दस्तावेज़ चाहिए होते हैं?',
                  answer:
                      'आवेदन के लिए आपको अपना रिज्यूमे, फोटो, और आवश्यक प्रमाणपत्र अपलोड करने होंगे।',
                  isExpanded: false,
                ),

                _buildFaqItem(
                  question:
                      'क्या मैं एक साथ कई नौकरियों के लिए आवेदन कर सकता हूँ?',
                  answer:
                      'हाँ, आप एक साथ कई नौकरियों के लिए आवेदन कर सकते हैं।',
                  isExpanded: false,
                ),

                _buildFaqItem(
                  question:
                      'क्या मैं आवेदन सबमिट करने के बाद उसे अपडेट कर सकता हूँ?',
                  answer:
                      'हाँ, आप अपना आवेदन सबमिट करने के बाद भी अपडेट कर सकते हैं।',
                  isExpanded: false,
                ),

                _buildFaqItem(
                  question:
                      'मुझे कैसे पता चलेगा कि मेरा आवेदन सफल रहा या नहीं?',
                  answer:
                      'आपको ईमेल या SMS के माध्यम से अपने आवेदन की स्थिति के बारे में सूचित किया जाएगा।',
                  isExpanded: false,
                ),

                _buildFaqItem(
                  question:
                      'अगर मुझे किसी कंपनी से जवाब नहीं मिले तो क्या करूँ?',
                  answer:
                      'अगर आपको जवाब नहीं मिलता है, तो आप कंपनी से सीधे संपर्क कर सकते हैं या हमारी सहायता टीम से संपर्क कर सकते हैं।',
                  isExpanded: false,
                ),
              ],
            ),
          ),
        ),

        // Fixed bottom button
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppConstants.cardBackgroundColor,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle FAQ action
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
              child: const Text(
                'Need More Help?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
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
