/// Course Details Page
/// Detailed view of a specific course with all information
/// Updated to match job details section design

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_event.dart';
import '../bloc/courses_state.dart';
import '../../../core/di/injection_container.dart';
import '../../../shared/widgets/common/navigation_helper.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';

class CourseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CoursesBloc>(),
      child: _CourseDetailsPageView(course: course),
    );
  }
}

class _CourseDetailsPageView extends StatefulWidget {
  final Map<String, dynamic> course;

  const _CourseDetailsPageView({required this.course});

  @override
  State<_CourseDetailsPageView> createState() => _CourseDetailsPageViewState();
}

class _CourseDetailsPageViewState extends State<_CourseDetailsPageView> {
  Map<String, dynamic>? _currentCourseData;
  bool? _currentBookmarkState;

  @override
  void initState() {
    super.initState();
    // Fetch course details by ID when screen loads
    final courseId = int.tryParse(widget.course['id']?.toString() ?? '');
    if (courseId != null) {
      context.read<CoursesBloc>().add(
        LoadCourseDetailsEvent(courseId: courseId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoursesBloc, CoursesState>(
      listener: (context, state) {
        if (state is CoursesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<CoursesBloc, CoursesState>(
        builder: (context, state) {
          // Use course details from API if available, otherwise use passed course
          Map<String, dynamic> displayCourse =
              _currentCourseData ?? widget.course;
          bool isBookmarked = false;
          bool isLoading = false;

          if (state is CoursesLoading) {
            isLoading = true;
            isBookmarked = _currentBookmarkState ?? false;
          } else if (state is CourseDetailsLoaded) {
            displayCourse = state.course;
            isBookmarked = state.course['isSaved'] == true;
            _currentCourseData = displayCourse;
            _currentBookmarkState = isBookmarked;
          } else if (state is CourseSavedState) {
            isBookmarked = true;
            _currentBookmarkState = true;
          } else if (state is CourseUnsavedState) {
            isBookmarked = false;
            _currentBookmarkState = false;
          } else {
            if (_currentCourseData != null) {
              displayCourse = _currentCourseData!;
              isBookmarked = _currentBookmarkState ?? false;
            } else {
              displayCourse = widget.course;
              isBookmarked = false;
            }
          }

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                _handleBackNavigation(context);
              }
            },
            child: Scaffold(
              backgroundColor: AppConstants.cardBackgroundColor,
              appBar: const SimpleAppBar(
                title: 'Course Details',
                showBackButton: true,
              ),
              bottomNavigationBar: isLoading
                  ? null
                  : _buildEnrollButton(context, displayCourse),
              body: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.secondaryColor,
                      ),
                    )
                  : RefreshIndicator(
                      color: AppConstants.secondaryColor,
                      onRefresh: () async {
                        final courseId = int.tryParse(
                          displayCourse['id']?.toString() ?? '',
                        );
                        if (courseId != null) {
                          context.read<CoursesBloc>().add(
                            LoadCourseDetailsEvent(courseId: courseId),
                          );
                        }
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              // Course header section with card
                              Padding(
                                padding: const EdgeInsets.all(
                                  AppConstants.defaultPadding,
                                ),
                                child: _buildCourseHeaderCard(
                                  context,
                                  displayCourse,
                                  isBookmarked,
                                ),
                              ),

                              // Tab bar (fixed at bottom of header)
                              _buildTabBar(),

                              // Tab content with fixed height based on screen
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height -
                                    MediaQuery.of(context).padding.top -
                                    kToolbarHeight -
                                    200,
                                child: _buildTabContent(displayCourse),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the course header card (similar to job header)
  Widget _buildCourseHeaderCard(
    BuildContext context,
    Map<String, dynamic> currentCourse,
    bool isBookmarked,
  ) {
    final title = _capitalizeFirst(
      currentCourse['title']?.toString() ?? 'Course Title',
    );
    final instituteName =
        currentCourse['institute']?.toString() ??
        'Institute ${currentCourse['institute_id'] ?? ''}';

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Course icon (matching course card style)
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppConstants.successColor,
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          // Right side - Course details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Bookmark in a Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _capitalizeFirst(instituteName),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppConstants.successColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bookmark button
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      alignment: Alignment.topCenter,
                      onPressed: () {
                        final courseId = currentCourse['id']?.toString() ?? '';
                        if (isBookmarked) {
                          context.read<CoursesBloc>().add(
                            UnsaveCourseEvent(courseId: courseId),
                          );
                        } else {
                          context.read<CoursesBloc>().add(
                            SaveCourseEvent(courseId: courseId),
                          );
                        }
                      },
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked
                            ? AppConstants.warningColor
                            : Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                if (currentCourse['id'] != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Course ID: ${currentCourse['id']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Capitalizes the first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Builds the tab bar
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: const TabBar(
        labelColor: AppConstants.textPrimaryColor,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        indicatorColor: AppConstants.primaryColor,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'About'),
          Tab(text: 'Institute'),
          Tab(text: 'Reviews and Rating'),
        ],
      ),
    );
  }

  /// Builds the tab content
  Widget _buildTabContent(Map<String, dynamic> currentCourse) {
    return TabBarView(
      children: [
        // About tab
        _buildAboutTab(currentCourse),

        // Institute tab
        _buildInstituteTab(currentCourse),

        // Review tab
        _buildReviewsTab(currentCourse),
      ],
    );
  }

  /// Builds the About tab
  Widget _buildAboutTab(Map<String, dynamic> currentCourse) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About the course section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About the course',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  currentCourse['description']?.toString() ??
                      currentCourse['module_description']?.toString() ??
                      'No description available.',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Course Information Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildSimpleCourseInformation(currentCourse),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Skills/Tags Section
          if (currentCourse['skills_list'] != null &&
              (currentCourse['skills_list'] as List).isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Skills Covered',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  _buildSkillsList(currentCourse),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds simple course information section with icons
  Widget _buildSimpleCourseInformation(Map<String, dynamic> currentCourse) {
    final fee = currentCourse['fees'] != null
        ? '₹${currentCourse['fees'].toString()}'
        : 'Fee not specified';
    final duration =
        currentCourse['duration']?.toString() ?? 'Duration not specified';
    final mode = currentCourse['mode']?.toString() ?? 'Mode not specified';
    final category =
        currentCourse['category']?.toString() ?? 'Category not specified';
    final instructor = currentCourse['instructor_name']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fee
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInfoItemWithIcon(Icons.currency_rupee, 'Fee', fee),
        ),

        // Duration
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInfoItemWithIcon(
            Icons.access_time,
            'Duration',
            duration,
          ),
        ),

        // Mode
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInfoItemWithIcon(
            Icons.computer,
            'Mode',
            mode == 'online'
                ? 'Online'
                : mode == 'offline'
                ? 'Offline'
                : mode,
          ),
        ),

        // Category
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInfoItemWithIcon(Icons.category, 'Category', category),
        ),

        // Instructor
        if (instructor != null && instructor.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInfoItemWithIcon(
              Icons.person_outline,
              'Instructor',
              instructor,
            ),
          ),

        // Batch Limit
        if (currentCourse['batch_limit'] != null &&
            currentCourse['batch_limit'] > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInfoItemWithIcon(
              Icons.people_outline,
              'Batch Limit',
              currentCourse['batch_limit'].toString(),
            ),
          ),

        // Certification
        if (currentCourse['certification_allowed'] == true)
          _buildInfoItemWithIcon(
            Icons.verified,
            'Certification',
            'Certificate provided',
          ),
      ],
    );
  }

  /// Builds an info item with icon (similar to job details)
  Widget _buildInfoItemWithIcon(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: AppConstants.successColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds skills list
  Widget _buildSkillsList(Map<String, dynamic> currentCourse) {
    final List<dynamic> skills =
        currentCourse['skills_list'] as List<dynamic>? ?? [];

    if (skills.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text(
          'No skills information available.',
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      children: skills
          .map(
            (skill) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: AppConstants.successColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      skill.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.textPrimaryColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  /// Builds the Institute tab
  Widget _buildInstituteTab(Map<String, dynamic> currentCourse) {
    final instituteId = currentCourse['institute_id']?.toString() ?? '';
    final instituteName =
        currentCourse['institute']?.toString() ?? 'Institute $instituteId';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Institute Information card
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Institute Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildInfoItemWithIcon(
                  Icons.school,
                  'Institute Name',
                  instituteName,
                ),
                if (instituteId.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInfoItemWithIcon(
                    Icons.tag,
                    'Institute ID',
                    instituteId,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Review tab
  Widget _buildReviewsTab(Map<String, dynamic> currentCourse) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 80,
            color: AppConstants.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'We are working on this feature. It will be available soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the enroll button at the bottom
  Widget _buildEnrollButton(
    BuildContext context,
    Map<String, dynamic> currentCourse,
  ) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 20),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(
          AppConstants.defaultPadding,
          0,
          AppConstants.defaultPadding,
          AppConstants.defaultPadding,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            // TODO: Implement enrollment functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Enrollment functionality coming soon'),
                backgroundColor: AppConstants.successColor,
              ),
            );
          },
          child: const Text(
            'Enroll Now',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _handleBackNavigation(BuildContext context) {
    // Try using NavigationHelper first (for tab-based navigation)
    final handled = NavigationHelper.goBack();
    if (!handled) {
      // If NavigationHelper doesn't handle it, try context.pop()
      if (context.canPop()) {
        context.pop();
      } else {
        // Fallback: Navigate to learning/courses section
        context.go(AppRoutes.learning);
      }
    }
  }
}
