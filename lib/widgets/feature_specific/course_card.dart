/// Course Card Widget
/// Displays course information in a card format

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

class CourseCard extends StatelessWidget {
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Course logo/icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppConstants.successColor,
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 30),
        ),
        const SizedBox(width: AppConstants.smallPadding),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Category: ${course['category'] ?? ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        // Save/bookmark button
        IconButton(
          onPressed: onSaveToggle,
          icon: Icon(
            course['isSaved'] == true ? Icons.bookmark : Icons.bookmark_border,
            color: course['isSaved'] == true
                ? AppConstants.primaryColor
                : AppConstants.textSecondaryColor,
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
        const Spacer(),
        // Rating
        _buildRating(),
      ],
    );
  }

  Widget _buildRating() {
    final rating = course['rating'] ?? 0.0;
    final totalRatings = course['totalRatings'] ?? 0;

    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating.floor() ? Icons.star : Icons.star_border,
            color: Colors.orange,
            size: 16,
          );
        }),
        const SizedBox(width: 4),
        Text(
          '($totalRatings)',
          style: const TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.successColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          'Course View',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onSaveToggle,
                    icon: Icon(
                      course['isSaved'] == true
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: course['isSaved'] == true
                          ? AppConstants.primaryColor
                          : AppConstants.textSecondaryColor,
                      size: 20,
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
                  ...List.generate(5, (index) {
                    final rating = course['rating'] ?? 0.0;
                    return Icon(
                      index < rating.floor() ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 14,
                    );
                  }),
                  const Spacer(),
                  ElevatedButton(
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
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Course View',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
