/// Skills Test Instructions Screen
/// Displays test information and instructions before starting the test

library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import 'skills_test_faq.dart';

class SkillTestInstructionsScreen extends StatefulWidget {
  /// Job data for context
  final Map<String, dynamic> job;

  /// Test data to display information
  final Map<String, dynamic> test;

  const SkillTestInstructionsScreen({
    super.key,
    required this.job,
    required this.test,
  });

  @override
  State<SkillTestInstructionsScreen> createState() =>
      _SkillTestInstructionsScreenState();
}

class _SkillTestInstructionsScreenState
    extends State<SkillTestInstructionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(
        title: 'Skills Test Info / स्किल्स टेस्ट जानकारी',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: _buildMainCard(),
              ),
            ),

            // Fixed bottom button
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppConstants.cardBackgroundColor,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: _buildStartTestButton(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main card containing all content
  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test overview section
          _buildTestOverviewSection(),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: AppConstants.defaultPadding,
            ),
            height: 1,
            color: Colors.grey.shade200,
          ),

          // Instructions section
          _buildInstructionsSection(),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: AppConstants.defaultPadding,
            ),
            height: 1,
            color: Colors.grey.shade200,
          ),

          // Good luck message
          _buildGoodLuckMessage(),

          // Button removed - now fixed at bottom
        ],
      ),
    );
  }

  /// Builds the test overview section
  Widget _buildTestOverviewSection() {
    return Row(
      children: [
        // Left side - Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (widget.test['color'] as Color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.test['icon'] as IconData,
            color: widget.test['color'] as Color,
            size: 24,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),

        // Right side - Test details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.test['title'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'By ${widget.test['provider']}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              // Time and MCQ tags
              Wrap(
                spacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppConstants.successColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.test['time']} Mins',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppConstants.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppConstants.successColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.test['mcqs']} MCQs',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppConstants.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the instructions section
  Widget _buildInstructionsSection() {
    final instructions = [
      'प्रत्येक परीक्षा के लिए एक निर्धारित समय सीमा होती है |',
      'परीक्षा शुरू करने से पहले सुनिश्चित करें कि आपका इंटरनेट कनेक्शन स्थिर हो |',
      '"Attempt Test" बटन पर क्लिक करने के बाद, आप परीक्षा छोड़ नहीं पाएंगे |',
      'सभी प्रश्नों को ध्यानपूर्वक पढ़ें और उत्तर सोच-समझकर दें |',
      'परीक्षा समाप्त होने के बाद परिणाम जल्द ही उपलब्ध कराए जाएंगे |',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header without icon
        const Text(
          'Instructions / निर्देश',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Instructions list
        ...instructions.map(
          (instruction) => _buildInstructionItem(instruction),
        ),
      ],
    );
  }

  /// Builds a single instruction item
  Widget _buildInstructionItem(String instruction) {
    // Define icons for each instruction type
    IconData getIconForInstruction(String instruction) {
      if (instruction.contains('समय सीमा') || instruction.contains('time')) {
        return Icons.access_time;
      } else if (instruction.contains('इंटरनेट') ||
          instruction.contains('internet')) {
        return Icons.wifi;
      } else if (instruction.contains('Attempt Test') ||
          instruction.contains('बटन')) {
        return Icons.play_circle_outline;
      } else if (instruction.contains('प्रश्न') ||
          instruction.contains('questions')) {
        return Icons.question_answer;
      } else if (instruction.contains('परिणाम') ||
          instruction.contains('result')) {
        return Icons.assessment;
      } else {
        return Icons.info_outline; // Default icon
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              getIconForInstruction(instruction),
              color: AppConstants.successColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(
                fontSize: 14,
                color: AppConstants.textPrimaryColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the good luck message
  Widget _buildGoodLuckMessage() {
    return Row(
      children: [
        Icon(Icons.thumb_up, color: AppConstants.successColor, size: 20),
        const SizedBox(width: 8),
        const Text(
          'Good luck for test',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  /// Builds the start test button
  Widget _buildStartTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _startTest(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Start Test',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Handles starting the test
  void _startTest() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Test?'),
        content: const Text(
          'Are you sure you want to start the test? You won\'t be able to leave once started.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _proceedToTest();
            },
            child: const Text('Start Test'),
          ),
        ],
      ),
    );
  }

  /// Proceeds to the actual test
  void _proceedToTest() {
    // Navigate to the skills test FAQ screen
    context.go(AppRoutes.skillTestFAQWithId(widget.test['id']));
  }
}
