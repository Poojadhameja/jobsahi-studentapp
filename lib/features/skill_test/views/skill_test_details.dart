/// Skills Test Details Screen
/// Displays available skill tests for job-related skills with filtering options

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../bloc/skill_test_bloc.dart';
import '../bloc/skill_test_event.dart';
import '../bloc/skill_test_state.dart';

class SkillTestDetailsScreen extends StatelessWidget {
  /// Job data to filter relevant skill tests
  final Map<String, dynamic> job;

  const SkillTestDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SkillTestBloc()..add(LoadSkillTestDetailsEvent(job: job)),
      child: _SkillTestDetailsScreenView(job: job),
    );
  }
}

class _SkillTestDetailsScreenView extends StatelessWidget {
  final Map<String, dynamic> job;

  const _SkillTestDetailsScreenView({required this.job});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SkillTestBloc, SkillTestState>(
      listener: (context, state) {
        if (state is NavigateToInstructionsState) {
          context.go(AppRoutes.skillTestInstructionsWithId(state.testId));
        } else if (state is NavigateToFAQState) {
          context.go(AppRoutes.skillTestFAQWithId(state.testId));
        }
      },
      child: BlocBuilder<SkillTestBloc, SkillTestState>(
        builder: (context, state) {
          Map<String, dynamic> skillTest = {};
          bool isBookmarked = false;

          if (state is SkillTestDetailsLoaded) {
            skillTest = state.skillTest;
            isBookmarked = state.isBookmarked;
          }

          return Scaffold(
            backgroundColor: AppConstants.cardBackgroundColor,
            appBar: SimpleAppBar(
              title: 'Skills Test/स्किल्स टेस्ट',
              showBackButton: true,
              actions: [
                IconButton(
                  onPressed: () {
                    context.read<SkillTestBloc>().add(
                      ToggleTestBookmarkEvent(testId: 'test_1'),
                    );
                  },
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked
                        ? AppConstants.warningColor
                        : AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      child: _buildMainCard(context, skillTest),
                    ),
                  ),

                  // Fixed bottom button
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: AppConstants.cardBackgroundColor,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: _buildBottomSection(context, skillTest),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the main card containing all content
  Widget _buildMainCard(BuildContext context, Map<String, dynamic> test) {
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
          _buildTestOverviewSection(test),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: AppConstants.defaultPadding,
            ),
            height: 1,
            color: Colors.grey.shade200,
          ),

          // Test details section
          _buildTestDetailsSection(test),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: AppConstants.defaultPadding,
            ),
            height: 1,
            color: Colors.grey.shade200,
          ),

          // Bottom section removed - now fixed at bottom
        ],
      ),
    );
  }

  /// Builds the test overview section
  Widget _buildTestOverviewSection(Map<String, dynamic> test) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (test['color'] as Color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            test['icon'] as IconData,
            color: test['color'] as Color,
            size: 24,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                test['title'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                test['subtitle'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the test details section
  Widget _buildTestDetailsSection(Map<String, dynamic> test) {
    final details = [
      {
        'title': '${test['mcqs']} MCQs in ${test['time']} Mins',
        'subtitle': 'परीक्षा हिंदी में होगी',
      },
      {
        'title': '${test['passingMarks']}% marks to pass',
        'subtitle': 'शपथ लें कि आप स्वयं उत्तर देंगे',
      },
      {
        'title': 'This is your ${test['attempts']}st attempt',
        'subtitle': 'पास न होने पर 2 और प्रयास मिलेंगी',
      },
      {
        'title': 'Results remain private',
        'subtitle': 'केवल पास होने पर ही रिक्रूटर्स के साथ साझा किये जाएंगे',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header without icon
        const Text(
          'Test Details / परीक्षा विवरण',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Details list
        ...details.map(
          (detail) =>
              _buildTestDetailItem(detail['title']!, detail['subtitle']!),
        ),
      ],
    );
  }

  /// Builds a test detail item
  Widget _buildTestDetailItem(String title, String subtitle) {
    // Define icons for each detail type
    IconData getIconForDetail(String title) {
      if (title.contains('MCQs') || title.contains('Mins')) {
        return Icons.quiz;
      } else if (title.contains('marks') || title.contains('pass')) {
        return Icons.grade;
      } else if (title.contains('attempt')) {
        return Icons.repeat;
      } else if (title.contains('private') || title.contains('Results')) {
        return Icons.privacy_tip;
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
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              getIconForDetail(title),
              color: AppConstants.successColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.successColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the bottom section with provider and button
  Widget _buildBottomSection(BuildContext context, Map<String, dynamic> test) {
    return Column(
      children: [
        Text(
          'इस परीक्षा को देने वाले छात्रों की संख्या के साथ पूरा करें',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<SkillTestBloc>().add(
                ViewTestInstructionsEvent(testId: 'test_1'),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: const Text(
              'Ready For Test',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
