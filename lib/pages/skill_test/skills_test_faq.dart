/// Skills Test FAQ Screen
/// Displays multiple choice questions for skill tests with timer

library;

import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import 'test_results.dart';

class SkillsTestFAQScreen extends StatefulWidget {
  /// Job data for context
  final Map<String, dynamic> job;

  /// Test data to display information
  final Map<String, dynamic> test;

  const SkillsTestFAQScreen({super.key, required this.job, required this.test});

  @override
  State<SkillsTestFAQScreen> createState() => _SkillsTestFAQScreenState();
}

class _SkillsTestFAQScreenState extends State<SkillsTestFAQScreen> {
  /// Timer for the test
  Timer? _timer;

  /// Remaining time in seconds
  int _remainingTime = 15 * 60; // 15 minutes

  /// Current question index
  int _currentQuestionIndex = 0;

  /// Selected answers for each question
  Map<int, int> _selectedAnswers = {};

  /// Mock questions data
  final List<Map<String, dynamic>> _questions = [
    {
      'question':
          '1. ITI की पढ़ाई के बाद कौन-कौन से स्किल टेस्ट जरूरी होते हैं?',
      'options': [
        'खेल परीक्षा',
        'तकनीकी कौशल परीक्षा',
        'सामान्य ज्ञान टेस्ट',
        'चित्रकला टेस्ट',
      ],
    },
    {
      'question':
          '2. इलेक्ट्रिकल सर्किट में कौन सा कंपोनेंट करंट को नियंत्रित करता है?',
      'options': ['रेजिस्टर', 'कैपेसिटर', 'इंडक्टर', 'डायोड'],
    },
    {
      'question': '3. AC और DC में क्या अंतर है?',
      'options': [
        'AC में वोल्टेज बदलता है, DC में नहीं',
        'DC में करंट एक दिशा में बहता है',
        'AC में फ्रीक्वेंसी होती है',
        'सभी सही हैं',
      ],
    },
    {
      'question': '4. इलेक्ट्रिकल सेफ्टी के लिए क्या जरूरी है?',
      'options': ['ग्राउंडिंग', 'फ्यूज प्रोटेक्शन', 'इंसुलेशन', 'सभी सही हैं'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Starts the countdown timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        _submitTest();
      }
    });
  }

  /// Formats time as MM:SS
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Handles answer selection
  void _selectAnswer(int questionIndex, int optionIndex) {
    setState(() {
      _selectedAnswers[questionIndex] = optionIndex;
    });
  }

  /// Submits the test
  void _submitTest() {
    _timer?.cancel();

    // Calculate results
    int correctAnswers = 0;
    int wrongAnswers = 0;

    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers.containsKey(i)) {
        // Mock correct answer (first option is always correct for demo)
        if (_selectedAnswers[i] == 0) {
          correctAnswers++;
        } else {
          wrongAnswers++;
        }
      }
    }

    // Navigate to results page
    NavigationService.navigateToReplacement(
      TestResultsScreen(
        correctAnswers: correctAnswers,
        wrongAnswers: wrongAnswers,
        totalQuestions: _questions.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(
        title: 'Skills Test/टेस्ट FAQ',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timer and test info header
            _buildTestHeader(),

            // Questions list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    // Test provider info
                    _buildTestProviderInfo(),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Questions
                    ..._questions.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> question = entry.value;
                      return _buildQuestionCard(index, question);
                    }).toList(),

                    const SizedBox(height: AppConstants.largePadding),
                  ],
                ),
              ),
            ),

            // Submit button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// Builds the test header with timer
  Widget _buildTestHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Test info
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
                  '${widget.test['mcqs']} MCQs • ${widget.test['time']} Mins',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppConstants.successColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Text(
              _formatTime(_remainingTime),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the test provider info card
  Widget _buildTestProviderInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Provider logo/icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (widget.test['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Center(
              child: Text(
                'W',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.test['color'] as Color,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),

          // Provider details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.test['provider'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.test['mcqs']} Questions • ${widget.test['time']} Minutes',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single question card
  Widget _buildQuestionCard(int questionIndex, Map<String, dynamic> question) {
    bool isAnswered = _selectedAnswers.containsKey(questionIndex);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Text(
            question['question'] as String,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Options grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppConstants.defaultPadding,
              mainAxisSpacing: AppConstants.defaultPadding,
              childAspectRatio: 2.5,
            ),
            itemCount: (question['options'] as List<String>).length,
            itemBuilder: (context, optionIndex) {
              bool isSelected = _selectedAnswers[questionIndex] == optionIndex;

              return GestureDetector(
                onTap: () => _selectAnswer(questionIndex, optionIndex),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppConstants.secondaryColor.withValues(alpha: 0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(
                      AppConstants.smallBorderRadius,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? AppConstants.secondaryColor
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      question['options'][optionIndex] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? AppConstants.secondaryColor
                            : AppConstants.textPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the submit button
  Widget _buildSubmitButton() {
    bool allQuestionsAnswered = _selectedAnswers.length == _questions.length;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: allQuestionsAnswered ? _submitTest : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: allQuestionsAnswered
                ? AppConstants.secondaryColor
                : Colors.grey.shade300,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
          child: Text(
            allQuestionsAnswered
                ? 'Submit'
                : 'Complete all questions to submit',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
