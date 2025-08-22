import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import 'application_submitted.dart';

class TakeSkillTestScreen extends StatefulWidget {
  const TakeSkillTestScreen({super.key});

  @override
  State<TakeSkillTestScreen> createState() => _TakeSkillTestScreenState();
}

class _TakeSkillTestScreenState extends State<TakeSkillTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Take a skills test'),
        backgroundColor: AppConstants.backgroundColor,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main icon
              _buildMainIcon(),
              const SizedBox(height: AppConstants.largePadding),

              // Main heading
              _buildMainHeading(),
              const SizedBox(height: AppConstants.defaultPadding),

              // Hindi text
              _buildHindiText(),
              const SizedBox(height: AppConstants.largePadding),

              // Buttons
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the main circular icon with lightbulb
  Widget _buildMainIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: AppConstants.successColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.lightbulb_outline, size: 60, color: Colors.white),
    );
  }

  /// Builds the main heading
  Widget _buildMainHeading() {
    return const Text(
      'Take a skills test',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E3A8A), // Dark blue color
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds the Hindi text section
  Widget _buildHindiText() {
    return Column(
      children: [
        const Text(
          'एक टेस्ट दें और नौकरी के लिए चयनित होने की संभावनाएं बढ़ाएँ |',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF1E3A8A), // Dark blue color
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'आप अपनी कौशलता और विशेषज्ञता को संभावित नियोक्ताओं के सामने प्रदर्शित कर सकते हैं।',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF1E3A8A), // Dark blue color
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the action buttons
  Widget _buildButtons() {
    return Column(
      children: [
        // Continue With Test button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _continueWithTest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Continue With Test',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // SKIP button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _skipTest,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.successColor,
              side: const BorderSide(
                color: AppConstants.successColor,
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'SKIP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// Handles continue with test button press
  void _continueWithTest() {
    // TODO: Implement test functionality
    // For now, show a dialog indicating test completion
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Test Completed!'),
        content: const Text(
          'Congratulations! You have completed the skills test. Your results will be shared with the employer.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog and navigate to ApplicationSubmitted page
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ApplicationSubmittedScreen(),
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handles skip test button press
  void _skipTest() {
    // Navigate to ApplicationSubmitted page and replace current screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ApplicationSubmittedScreen(),
      ),
    );
  }
}
