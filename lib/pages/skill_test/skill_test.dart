/// Skills Test Screen
/// Displays available skill tests for job-related skills with filtering options

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import 'skill_test_info.dart';

class SkillTestScreen extends StatefulWidget {
  /// Job data to filter relevant skill tests
  final Map<String, dynamic> job;

  const SkillTestScreen({super.key, required this.job});

  @override
  State<SkillTestScreen> createState() => _SkillTestScreenState();
}

class _SkillTestScreenState extends State<SkillTestScreen> {
  /// Selected level filter
  String _selectedLevel = 'All';

  /// Available skill levels
  final List<String> _skillLevels = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  /// Mock skill tests data based on job category
  List<Map<String, dynamic>> get _skillTests {
    final jobCategory = widget.job['category'] ?? 'Electrician';

    // Return tests related to the job category
    switch (jobCategory.toLowerCase()) {
      case 'electrician':
        return [
          {
            'title': 'इलेक्ट्रीशियन अप्रेंटिस',
            'subtitle': 'Beginner',
            'icon': Icons.electrical_services,
            'color': Colors.blue,
            'mcqs': 14,
            'time': 15,
            'passingMarks': 42,
            'attempts': 1,
            'isPrivate': true,
            'provider': 'Satpuda ITI',
            'level': 'Beginner',
          },
          {
            'title': 'इलेक्ट्रिकल मेंटेनेंस',
            'subtitle': 'Intermediate',
            'icon': Icons.build,
            'color': Colors.orange,
            'mcqs': 20,
            'time': 25,
            'passingMarks': 50,
            'attempts': 2,
            'isPrivate': true,
            'provider': 'Technical Institute',
            'level': 'Intermediate',
          },
          {
            'title': 'इंडस्ट्रियल इलेक्ट्रिकल',
            'subtitle': 'Advanced',
            'icon': Icons.factory,
            'color': Colors.red,
            'mcqs': 25,
            'time': 30,
            'passingMarks': 60,
            'attempts': 1,
            'isPrivate': true,
            'provider': 'Industrial Training Center',
            'level': 'Advanced',
          },
        ];
      case 'fitter':
        return [
          {
            'title': 'फिटर अप्रेंटिस',
            'subtitle': 'Beginner',
            'icon': Icons.handyman,
            'color': Colors.green,
            'mcqs': 12,
            'time': 15,
            'passingMarks': 40,
            'attempts': 1,
            'isPrivate': true,
            'provider': 'Mechanical ITI',
            'level': 'Beginner',
          },
          {
            'title': 'मशीन फिटिंग',
            'subtitle': 'Intermediate',
            'icon': Icons.precision_manufacturing,
            'color': Colors.purple,
            'mcqs': 18,
            'time': 20,
            'passingMarks': 50,
            'attempts': 2,
            'isPrivate': true,
            'provider': 'Technical College',
            'level': 'Intermediate',
          },
        ];
      default:
        return [
          {
            'title': 'बेसिक स्किल टेस्ट',
            'subtitle': 'Beginner',
            'icon': Icons.quiz,
            'color': Colors.blue,
            'mcqs': 10,
            'time': 15,
            'passingMarks': 40,
            'attempts': 1,
            'isPrivate': true,
            'provider': 'General Training',
            'level': 'Beginner',
          },
        ];
    }
  }

  /// Get filtered skill tests based on selected level
  List<Map<String, dynamic>> get _filteredSkillTests {
    if (_selectedLevel == 'All') {
      return _skillTests;
    }
    return _skillTests
        .where((test) => test['level'] == _selectedLevel)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(
        title: 'Skills Test/स्किल्स टेस्ट',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Level filter chips
              _buildLevelFilter(),
              const SizedBox(height: AppConstants.largePadding),

              // Skill tests list
              _buildSkillTestsList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the level filter chips
  Widget _buildLevelFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Level / स्तर चुनें',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Wrap(
          spacing: 8,
          children: _skillLevels.map((level) {
            final isSelected = _selectedLevel == level;
            return FilterChip(
              label: Text(level),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedLevel = level;
                });
              },
              selectedColor: AppConstants.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppConstants.primaryColor,
              backgroundColor: Colors.grey.shade100,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppConstants.primaryColor
                    : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Builds the skill tests list
  Widget _buildSkillTestsList() {
    final filteredTests = _filteredSkillTests;

    if (filteredTests.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.quiz_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No tests available for $_selectedLevel level',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'कोई टेस्ट उपलब्ध नहीं है',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Tests for ${widget.job['category'] ?? 'Job'} / उपलब्ध टेस्ट',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        ...filteredTests.map((test) => _buildSkillTestCard(test)),
      ],
    );
  }

  /// Builds a single skill test card
  Widget _buildSkillTestCard(Map<String, dynamic> test) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header with icon and title
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
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
            ),
          ),

          // Test details
          _buildTestDetailItem(
            '${test['mcqs']} MCQs in ${test['time']} Mins',
            'परीक्षा हिंदी में होगी',
          ),
          _buildTestDetailItem(
            '${test['passingMarks']}% marks to pass',
            'शपथ लें कि आप स्वयं उत्तर देंगे',
          ),
          _buildTestDetailItem(
            'This is your ${test['attempts']}st attempt',
            'पास न होने पर 2 और प्रयास मिलेंगी',
          ),
          _buildTestDetailItem(
            'Results remain private',
            'केवल पास होने पर ही रिक्रूटर्स के साथ साझा किये जाएंगे',
          ),

          // Bottom section with provider and button
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
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
                    onPressed: () => _navigateToTestInfo(test),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Ready For Test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a test detail item
  Widget _buildTestDetailItem(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
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
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to test info screen
  void _navigateToTestInfo(Map<String, dynamic> test) {
    NavigationService.navigateTo(
      SkillTestInfoScreen(job: widget.job, test: test),
    );
  }
}
