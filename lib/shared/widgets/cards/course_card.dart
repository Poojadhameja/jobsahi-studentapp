/// Course Card Widget
/// Displays course information in a card format

library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

class CourseCard extends StatelessWidget {
  static const Color backgroundColor = Color(0xFFF5F9FC);

  final Map<String, dynamic> course;
  final VoidCallback onTap;
  final VoidCallback onSaveToggle;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    required this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white, // Pure white background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppConstants.smallPadding),
            _buildCourseInfo(),
            const SizedBox(height: AppConstants.smallPadding),
            _buildRatingAndDuration(),
            const SizedBox(height: AppConstants.smallPadding),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Course logo/icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppConstants.successColor,
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 24),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        // Course title and category
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['title'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Category: ${course['category'] ?? ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseInfo() {
    return Text(
      course['description'] ?? '',
      style: const TextStyle(
        fontSize: 14,
        color: AppConstants.textSecondaryColor,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRatingAndDuration() {
    return Row(
      children: [
        // Duration
        Text(
          'Duration: ${course['duration'] ?? ''}',
          style: const TextStyle(
            fontSize: 14,
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return Row(
      children: [
        // Course View button
        Expanded(
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.smallBorderRadius,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Course View',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        // Save button on the right side (matching job card style)
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onSaveToggle,
            customBorder: const CircleBorder(),
            splashColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade200,
            radius: 20,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(
                course['isSaved'] == true
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: course['isSaved'] == true
                    ? AppConstants.primaryColor
                    : AppConstants.textSecondaryColor,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact Course Card for horizontal lists
class CompactCourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onTap;
  final VoidCallback onSaveToggle;

  const CompactCourseCard({
    super.key,
    required this.course,
    required this.onTap,
    required this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white, // Pure white background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Container(
        width: 288.8,
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppConstants.successColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.smallBorderRadius,
                    ),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    course['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Category: ${course['category'] ?? ''}',
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.textSecondaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Duration: ${course['duration'] ?? ''}',
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.successColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.smallBorderRadius,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Course View',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onSaveToggle,
                    customBorder: const CircleBorder(),
                    splashColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade200,
                    radius: 16,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      child: Icon(
                        course['isSaved'] == true
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: course['isSaved'] == true
                            ? AppConstants.primaryColor
                            : AppConstants.textSecondaryColor,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
