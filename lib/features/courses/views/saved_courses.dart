/// Saved Courses Page
/// Shows user's bookmarked/saved courses

library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/data/course_data.dart';
import '../../../shared/widgets/cards/course_card.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';

class SavedCoursesPage extends StatefulWidget {
  const SavedCoursesPage({super.key});

  @override
  State<SavedCoursesPage> createState() => _SavedCoursesPageState();
}

class _SavedCoursesPageState extends State<SavedCoursesPage> {
  List<Map<String, dynamic>> _savedCourses = [];

  @override
  void initState() {
    super.initState();
    _loadSavedCourses();
  }

  void _loadSavedCourses() {
    setState(() {
      _savedCourses = CourseData.getSavedCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: _savedCourses.isEmpty
          ? _buildEmptyState()
          : _buildSavedCoursesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: AppConstants.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              'No Saved Courses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            const Text(
              'You haven\'t saved any courses yet.\nBrowse courses and save the ones you\'re interested in.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondaryColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            ElevatedButton(
              onPressed: () {
                // Switch to Learning Center tab
                DefaultTabController.of(context).animateTo(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.largePadding,
                  vertical: AppConstants.defaultPadding,
                ),
              ),
              child: const Text(
                'Browse Courses',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCoursesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _savedCourses.length,
      itemBuilder: (context, index) {
        final course = _savedCourses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: CourseCard(
            course: course,
            onTap: () => _navigateToCourseDetails(course),
            onSaveToggle: () => _toggleCourseSaved(course['id']),
          ),
        );
      },
    );
  }

  void _navigateToCourseDetails(Map<String, dynamic> course) {
    context.go(AppRoutes.courseDetailsWithId(course['id']));
  }

  void _toggleCourseSaved(String courseId) {
    setState(() {
      CourseData.toggleCourseSaved(courseId);
      _loadSavedCourses(); // Refresh the saved courses list
    });
  }
}

/// Standalone Saved Courses Screen
/// Can be used as a separate screen outside of tabs
class SavedCoursesScreen extends StatefulWidget {
  const SavedCoursesScreen({super.key});

  @override
  State<SavedCoursesScreen> createState() => _SavedCoursesScreenState();
}

class _SavedCoursesScreenState extends State<SavedCoursesScreen> {
  List<Map<String, dynamic>> _savedCourses = [];

  @override
  void initState() {
    super.initState();
    _loadSavedCourses();
  }

  void _loadSavedCourses() {
    setState(() {
      _savedCourses = CourseData.getSavedCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.cardBackgroundColor,
        elevation: 0,
        title: const Text(
          'Saved Courses',
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
      ),
      body: _savedCourses.isEmpty
          ? _buildEmptyState()
          : _buildSavedCoursesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: AppConstants.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              'No Saved Courses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            const Text(
              'You haven\'t saved any courses yet.\nBrowse courses and save the ones you\'re interested in.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondaryColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            ElevatedButton(
              onPressed: () {
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.largePadding,
                  vertical: AppConstants.defaultPadding,
                ),
              ),
              child: const Text(
                'Browse Courses',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCoursesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _savedCourses.length,
      itemBuilder: (context, index) {
        final course = _savedCourses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: CourseCard(
            course: course,
            onTap: () => _navigateToCourseDetails(course),
            onSaveToggle: () => _toggleCourseSaved(course['id']),
          ),
        );
      },
    );
  }

  void _navigateToCourseDetails(Map<String, dynamic> course) {
    context.go(AppRoutes.courseDetailsWithId(course['id']));
  }

  void _toggleCourseSaved(String courseId) {
    setState(() {
      CourseData.toggleCourseSaved(courseId);
      _loadSavedCourses(); // Refresh the saved courses list
    });
  }
}
