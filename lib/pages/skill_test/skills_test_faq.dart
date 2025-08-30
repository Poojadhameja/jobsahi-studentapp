/// Skills Test FAQ Screen
/// Displays multiple choice questions for skill tests with timer

library;

import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/skills_test_data.dart';

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

  /// Selected answers for each question (optionId -> questionId)
  final Map<String, String> _selectedAnswers = {};

  /// Test data from API-compatible data source
  late final Map<String, dynamic> _testData;

  /// Questions data from API-compatible data source
  late final List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();

    // Initialize test data from API-compatible data source
    _testData = SkillsTestData.electricianTest;
    _questions = SkillsTestData.electricianQuestions;

    // Set timer based on test data
    _remainingTime = (_testData['duration'] as int) * 60;

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
  void _selectAnswer(String questionId, String optionId) {
    setState(() {
      _selectedAnswers[questionId] = optionId;
    });
  }

  /// Submits the test
  void _submitTest() async {
    _timer?.cancel();

    // Show completion message
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Test Completed!'),
          content: Text(
            'You have completed the test with ${_selectedAnswers.length} questions answered.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Skills Test/टेस्ट FAQ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Course/Test Information Section with Timer
            _buildCourseInfoSection(),

            // Progress indicator
            _buildProgressIndicator(),

            // Questions list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Questions
                    ..._questions.map((question) {
                      return _buildQuestionCard(question);
                    }),

                    const SizedBox(height: 100), // Space for submit button
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

  /// Builds the progress indicator
  Widget _buildProgressIndicator() {
    final answeredCount = _selectedAnswers.length;
    final totalQuestions = _questions.length;
    final progress = totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: $answeredCount/$totalQuestions',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  /// Builds the course information section with timer
  Widget _buildCourseInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Blue wave-like logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'W',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Course details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _testData['title'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'By ${_testData['provider'] as String}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatTime(_remainingTime),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single question card
  Widget _buildQuestionCard(Map<String, dynamic> question) {
    final questionId = question['id'] as String;
    final options = question['options'] as List<Map<String, dynamic>>;
    final isAnswered = _selectedAnswers.containsKey(questionId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAnswered ? Colors.green.shade300 : Colors.grey.shade200,
          width: isAnswered ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header with status
          Row(
            children: [
              Expanded(
                child: Text(
                  question['question'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ),
              if (isAnswered)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Answered',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Options grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.0,
            ),
            itemCount: options.length,
            itemBuilder: (context, optionIndex) {
              final option = options[optionIndex];
              final optionId = option['id'] as String;
              final isSelected = _selectedAnswers[questionId] == optionId;

              return GestureDetector(
                onTap: () => _selectAnswer(questionId, optionId),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            option['text'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected ? Colors.blue : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      // Selected indicator
                      if (isSelected)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _submitTest,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5C9A24),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
