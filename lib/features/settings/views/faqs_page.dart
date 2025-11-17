import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

class FaqsPage extends StatefulWidget {
  const FaqsPage({super.key});

  @override
  State<FaqsPage> createState() => _FaqsPageState();
}

class _FaqsPageState extends State<FaqsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
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
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppConstants.textPrimaryColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFFE0E7EF),
                          child: Icon(
                            Icons.help_outline,
                            size: 45,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "FAQs",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Find answers to commonly asked questions",
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Text(
                      'नौकरी के लिए आवेदन करते समय पूछे जाने वाले सामान्य प्रश्नों की सूची:',
                      style: AppConstants.bodyStyle.copyWith(
                        color: const Color(0xFF424242),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppConstants.largePadding),

                    // Search
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
                      onChanged: (value) => setState(() {}),
                    ),

                    const SizedBox(height: AppConstants.largePadding),

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
                      question: 'आवेदन करने के लिए कौन-कौन से दस्तावेज़ चाहिए होते हैं?',
                      answer: 'आवेदन के लिए आपको अपना रिज्यूमे, फोटो, और आवश्यक प्रमाणपत्र अपलोड करने होंगे।',
                      isExpanded: false,
                    ),
                    _buildFaqItem(
                      question: 'क्या मैं एक साथ कई नौकरियों के लिए आवेदन कर सकता हूँ?',
                      answer: 'हाँ, आप एक साथ कई नौकरियों के लिए आवेदन कर सकते हैं।',
                      isExpanded: false,
                    ),
                    _buildFaqItem(
                      question: 'क्या मैं आवेदन सबमिट करने के बाद उसे अपडेट कर सकता हूँ?',
                      answer: 'हाँ, आप अपना आवेदन सबमिट करने के बाद भी अपडेट कर सकते हैं।',
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
                    const SizedBox(height: AppConstants.largePadding),

                    // Additional FAQs tailored to the app
                    _buildFaqItem(
                      question: 'क्या कवर लेटर आवश्यक है? न्यूनतम कितने अक्षर लिखने हैं?',
                      answer:
                          'हाँ, कवर लेटर आवश्यक है ताकि आप अपने बारे में और इस भूमिका के लिए अपनी उपयुक्तता को स्पष्ट कर सकें। न्यूनतम 50 अक्षर लिखना अनिवार्य है, लिखने के दौरान काउंटर दिखेगा।',
                      isExpanded: false,
                    ),
                    _buildFaqItem(
                      question: 'Feedback कितनी बार भेज सकते हैं?',
                      answer:
                          'हर 14 दिनों की विंडो में अधिकतम 2 बार Feedback भेज सकते हैं। लिमिट पार होने पर आपको अगली तारीख भी दिखाई जाएगी जब आप फिर से भेज सकेंगे।',
                      isExpanded: false,
                    ),
                    _buildFaqItem(
                      question: 'मेरा प्रोफाइल पूरा कैसे करूँ और क्यों जरूरी है?',
                      answer:
                          'प्रोफाइल में शिक्षा, कौशल, अनुभव और रिज्यूमे जोड़ें। पूरा प्रोफाइल होने से रिकमेंडेड जॉब्स बेहतर मिलती हैं और चयन की संभावना बढ़ती है।',
                      isExpanded: false,
                    ),
                    _buildFaqItem(
                      question: 'लोकेशन क्यों मांगी जाती है?',
                      answer:
                          'लोकेशन से हम आपके नजदीक की नौकरियां दिखा पाते हैं और रिलेवेंट रिकमेंडेशन दे पाते हैं। आप कभी भी सेटिंग्स में लोकेशन अपडेट कर सकते हैं।',
                      isExpanded: false,
                    ),
                    _buildFaqItem(
                      question: 'पासवर्ड भूल गया/गई हूँ—कैसे रिसेट करें?',
                      answer:
                          'लॉगिन स्क्रीन पर “Forgot Password” विकल्प चुनें। ईमेल/फोन वेरिफाई करके नया पासवर्ड सेट कर सकते हैं।',
                      isExpanded: false,
                    ),
                    _buildFaqItem(
                      question: 'Notifications कैसे कंट्रोल करें?',
                      answer:
                          'Settings → Notification में जाकर आप महत्वपूर्ण अपडेट, जॉब अलर्ट और अन्य सूचनाओं के लिए प्राथमिकताएं चुन सकते हैं।',
                      isExpanded: false,
                    ),
                    _buildFaqItem(
                      question: 'मेरे डेटा/गोपनीयता की सुरक्षा कैसे होती है?',
                      answer:
                          'हम आपकी गोपनीयता को प्राथमिकता देते हैं। डेटा एन्क्रिप्शन और नियंत्रित एक्सेस नीतियों का पालन किया जाता है। अधिक जानकारी के लिए Privacy Policy देखें।',
                      isExpanded: false,
                    ),
                    _buildFaqItem(
                      question: 'Contact Us कहाँ मिलेगा?',
                      answer:
                          'Menu में “Contact Us / संपर्क करें” विकल्प से आप ईमेल/फोन/एड्रेस देख सकते हैं और टीम से संपर्क कर सकते हैं।',
                      isExpanded: false,
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

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required bool isExpanded,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 4,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppConstants.defaultPadding,
            0,
            AppConstants.defaultPadding,
            AppConstants.defaultPadding,
          ),
          title: Text(
            question,
            style: TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconColor: AppConstants.secondaryColor,
          collapsedIconColor: AppConstants.secondaryColor,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: AppConstants.bodyStyle.copyWith(
                  color: const Color(0xFF4F789B),
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


