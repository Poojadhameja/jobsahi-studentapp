/// Saved Courses Page
/// Shows user's bookmarked/saved courses

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/cards/course_card.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_event.dart';
import '../bloc/courses_state.dart';

class SavedCoursesPage extends StatelessWidget {
  const SavedCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CoursesBloc()..add(LoadSavedCoursesEvent()),
      child: const _SavedCoursesPageView(),
    );
  }
}

class _SavedCoursesPageView extends StatelessWidget {
  const _SavedCoursesPageView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        List<Map<String, dynamic>> savedCourses = [];
        if (state is CoursesLoaded) {
          savedCourses = state.savedCourses;
        }

        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          body: savedCourses.isEmpty
              ? _buildEmptyState(context)
              : _buildSavedCoursesList(context, savedCourses),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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

  Widget _buildSavedCoursesList(
    BuildContext context,
    List<Map<String, dynamic>> savedCourses,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: savedCourses.length,
      itemBuilder: (context, index) {
        final course = savedCourses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: CourseCard(
            course: course,
            onTap: () => _navigateToCourseDetails(context, course),
            onSaveToggle: () => _toggleCourseSaved(context, course['id']),
          ),
        );
      },
    );
  }

  void _navigateToCourseDetails(
    BuildContext context,
    Map<String, dynamic> course,
  ) {
    context.go(AppRoutes.courseDetailsWithId(course['id']));
  }

  void _toggleCourseSaved(BuildContext context, String courseId) {
    final state = context.read<CoursesBloc>().state;
    if (state is CoursesLoaded) {
      final isSaved = state.savedCourseIds.contains(courseId);
      if (isSaved) {
        context.read<CoursesBloc>().add(UnsaveCourseEvent(courseId: courseId));
      } else {
        context.read<CoursesBloc>().add(SaveCourseEvent(courseId: courseId));
      }
    }
  }
}

/// Standalone Saved Courses Screen
/// Can be used as a separate screen outside of tabs
class SavedCoursesScreen extends StatelessWidget {
  const SavedCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CoursesBloc()..add(LoadSavedCoursesEvent()),
      child: const _SavedCoursesScreenView(),
    );
  }
}

class _SavedCoursesScreenView extends StatelessWidget {
  const _SavedCoursesScreenView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        List<Map<String, dynamic>> savedCourses = [];
        if (state is CoursesLoaded) {
          savedCourses = state.savedCourses;
        }

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
              icon: const Icon(
                Icons.arrow_back,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          body: savedCourses.isEmpty
              ? _buildEmptyState(context)
              : _buildSavedCoursesList(context, savedCourses),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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

  Widget _buildSavedCoursesList(
    BuildContext context,
    List<Map<String, dynamic>> savedCourses,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: savedCourses.length,
      itemBuilder: (context, index) {
        final course = savedCourses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: CourseCard(
            course: course,
            onTap: () => _navigateToCourseDetails(context, course),
            onSaveToggle: () => _toggleCourseSaved(context, course['id']),
          ),
        );
      },
    );
  }

  void _navigateToCourseDetails(
    BuildContext context,
    Map<String, dynamic> course,
  ) {
    context.go(AppRoutes.courseDetailsWithId(course['id']));
  }

  void _toggleCourseSaved(BuildContext context, String courseId) {
    final state = context.read<CoursesBloc>().state;
    if (state is CoursesLoaded) {
      final isSaved = state.savedCourseIds.contains(courseId);
      if (isSaved) {
        context.read<CoursesBloc>().add(UnsaveCourseEvent(courseId: courseId));
      } else {
        context.read<CoursesBloc>().add(SaveCourseEvent(courseId: courseId));
      }
    }
  }
}
