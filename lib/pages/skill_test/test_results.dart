/// Test Results Screen
/// Displays test results with correct/wrong answers and navigation options

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';

class TestResultsScreen extends StatelessWidget {
  /// Number of correct answers
  final int correctAnswers;

  /// Number of wrong answers
  final int wrongAnswers;

  /// Total number of questions
  final int totalQuestions;

  const TestResultsScreen({
    super.key,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(
        title: 'Test results/टेस्ट परिणाम',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              const Spacer(),

              // Results card
              _buildResultsCard(),

              const Spacer(),

              // Back to home button
              _buildBackToHomeButton(),

              const SizedBox(height: AppConstants.defaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the results display card
  Widget _buildResultsCard() {
    // Calculate percentage
    double percentage = (correctAnswers / totalQuestions) * 100;

    // Determine performance message
    String performanceMessage;
    Color performanceColor;
    IconData performanceIcon;

    if (percentage >= 80) {
      performanceMessage = 'Excellent Work!';
      performanceColor = AppConstants.successColor;
      performanceIcon = Icons.star;
    } else if (percentage >= 60) {
      performanceMessage = 'Good Work';
      performanceColor = AppConstants.successColor;
      performanceIcon = Icons.thumb_up;
    } else if (percentage >= 40) {
      performanceMessage = 'Average Work';
      performanceColor = AppConstants.warningColor;
      performanceIcon = Icons.help_outline;
    } else {
      performanceMessage = 'Need Improvement';
      performanceColor = AppConstants.errorColor;
      performanceIcon = Icons.trending_down;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Performance icon and message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: performanceColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(performanceIcon, size: 48, color: performanceColor),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Performance message
          Text(
            performanceMessage,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: performanceColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.largePadding),

          // Results breakdown
          _buildResultRow(
            'Correct Answer:',
            correctAnswers.toString(),
            AppConstants.successColor,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildResultRow(
            'Wrong Answer:',
            wrongAnswers.toString(),
            AppConstants.errorColor,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildResultRow(
            'Total Questions:',
            totalQuestions.toString(),
            AppConstants.textPrimaryColor,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildResultRow(
            'Percentage:',
            '${percentage.toStringAsFixed(1)}%',
            AppConstants.secondaryColor,
          ),

          const SizedBox(height: AppConstants.largePadding),

          // Additional feedback
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppConstants.secondaryColor,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  _getFeedbackMessage(percentage),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single result row
  Widget _buildResultRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// Gets feedback message based on performance
  String _getFeedbackMessage(double percentage) {
    if (percentage >= 80) {
      return 'Outstanding performance! You have excellent knowledge in this field.';
    } else if (percentage >= 60) {
      return 'Good job! Keep practicing to improve your skills further.';
    } else if (percentage >= 40) {
      return 'You\'re on the right track. Review the topics and try again.';
    } else {
      return 'Don\'t worry! Focus on the basics and practice regularly.';
    }
  }

  /// Builds the back to home button
  Widget _buildBackToHomeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _goBackToHome,
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
          'Back To Home',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Navigates back to home
  void _goBackToHome() {
    // Navigate back to home screen
    NavigationService.navigateToNamed('/home');
  }
}
