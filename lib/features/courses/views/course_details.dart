/// Course Details Page
/// Detailed view of a specific course with all informationr

library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/data/course_data.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';

class CourseDetailsPage extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetailsPage({super.key, required this.course});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  late Map<String, dynamic> course;

  @override
  void initState() {
    super.initState();
    course = widget.course;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppConstants.backgroundColor, // Changed to white background
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseHeader(),
            _buildCourseInfo(),
            _buildFeesAndRatings(),
            _buildAboutCourse(),
            _buildOfflineBenefits(),
            const SizedBox(height: AppConstants.largePadding),
          ],
        ),
      ),
      bottomNavigationBar: _buildContactButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.cardBackgroundColor,
      elevation: 0,
      title: const Text(
        'Course Details/कोर्स विवरण',
        style: TextStyle(
          color: AppConstants.primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back, color: AppConstants.primaryColor),
      ),
      actions: [
        IconButton(
          onPressed: _toggleCourseSaved,
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

  Widget _buildCourseHeader() {
    return Container(
      margin: const EdgeInsets.only(
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
      ),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Course logo/image placeholder
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: const Icon(
              Icons.school,
              size: 80,
              color: AppConstants.successColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            course['title'] ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfo() {
    return Container(
      margin: const EdgeInsets.only(
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
      ),
      child: Row(
        children: [
          Expanded(child: _buildCategoryCard()),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(child: _buildDurationCard()),
        ],
      ),
    );
  }

  Widget _buildCategoryCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            course['category'] ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Duration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            course['duration'] ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeesAndRatings() {
    return Container(
      margin: const EdgeInsets.only(
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
      ),
      child: Row(
        children: [
          Expanded(child: _buildFeesCard()),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(child: _buildRatingsCard()),
        ],
      ),
    );
  }

  Widget _buildFeesCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fees',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            '₹${course['fees']?.toString() ?? '0'}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsCard() {
    final rating = course['rating'] ?? 0.0;
    final totalRatings = course['totalRatings'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ratings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < rating.floor() ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 20,
                );
              }),
            ],
          ),
          Text(
            '($totalRatings reviews)',
            style: const TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCourse() {
    return Container(
      margin: const EdgeInsets.only(
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
      ),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Course',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            course['fullDescription'] ?? course['description'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textPrimaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBenefits() {
    final benefits = course['benefits'] as List<String>? ?? [];

    return Container(
      margin: const EdgeInsets.only(
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
      ),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Offline Course Benefits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ...benefits.map((benefit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppConstants.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: Text(
                      benefit,
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
          }),
        ],
      ),
    );
  }

  Widget _buildContactButton() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: const BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _contactNow,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.successColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.defaultPadding,
            ),
          ),
          child: const Text(
            'Contact Now',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _toggleCourseSaved() {
    setState(() {
      CourseData.toggleCourseSaved(course['id']);
      // Update local course data instead of mutating widget.course
      course = Map<String, dynamic>.from(course);
      course['isSaved'] = !course['isSaved'];
    });
  }

  void _contactNow() {
    // TODO: Implement contact functionality
    // This could open a phone dialer, email client, or contact form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact functionality will be implemented'),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }
}
