/// Learning Center Page
/// Main courses page with search, filters, and course listings

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/cards/course_card.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/widgets/common/custom_tab_structure.dart';
import '../../../shared/widgets/common/empty_state_widget.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_event.dart';
import '../bloc/courses_state.dart';

class LearningCenterPage extends StatefulWidget {
  const LearningCenterPage({super.key});

  @override
  State<LearningCenterPage> createState() => _LearningCenterPageState();
}

class _LearningCenterPageState extends State<LearningCenterPage> {
  @override
  void initState() {
    super.initState();
    // Load courses only if not already loaded
    final currentState = context.read<CoursesBloc>().state;
    if (currentState is! CoursesLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<CoursesBloc>().add(
            const LoadCoursesEvent(forceRefresh: false),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _LearningCenterPageView();
  }
}

class _LearningCenterPageView extends StatefulWidget {
  @override
  State<_LearningCenterPageView> createState() =>
      _LearningCenterPageViewState();
}

class _LearningCenterPageViewState extends State<_LearningCenterPageView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      buildWhen: (previous, current) {
        // Only rebuild on actual state changes
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is CoursesLoaded && current is CoursesLoaded) {
          // For loaded states, check if data actually changed
          return previous.filteredCourses != current.filteredCourses ||
                 previous.savedCourseIds != current.savedCourseIds ||
                 previous.showFilters != current.showFilters;
        }
        return true;
      },
      builder: (context, state) {
        return KeyboardDismissWrapper(
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: DefaultTabController(
                        length: 2,
                        child: Builder(
                          builder: (innerContext) {
                            return CustomTabStructure(
                              tabs: const [
                                TabConfig(title: 'All Courses'),
                                TabConfig(title: 'Saved Courses'),
                              ],
                              tabContents: [
                                _buildLearningCenterTab(innerContext, state),
                                _buildSavedCoursesTab(),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                // Filter chips overlay - positioned above everything with animation
                // Position right after tab bar border (same as jobs section: 48 + 8 = 56)
                Positioned(
                  top:
                      56, // Tab bar height (48px) + bottom padding (8px) = 56px
                  left: 0,
                  right: 0,
                  child: BlocBuilder<CoursesBloc, CoursesState>(
                    buildWhen: (previous, current) {
                      // Only rebuild when filters visibility changes
                      if (previous is! CoursesLoaded || current is! CoursesLoaded) return true;
                      return previous.showFilters != current.showFilters ||
                             previous.selectedCategory != current.selectedCategory ||
                             previous.selectedLevel != current.selectedLevel ||
                             previous.selectedDuration != current.selectedDuration ||
                             previous.selectedInstitute != current.selectedInstitute;
                    },
                    builder: (context, state) {
                      if (state is CoursesLoaded) {
                        final showFilters = state.showFilters;
                        return TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0.0,
                            end: showFilters ? 1.0 : 0.0,
                          ),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return ClipRect(
                              child: Transform.translate(
                                offset: Offset(0, -80 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              ),
                            );
                          },
                          child: _buildFilterChips(context, state),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLearningCenterTab(BuildContext context, CoursesState state) {
    // Handle error state
    if (state is CoursesError) {
      return NoInternetErrorWidget(
        errorMessage: state.message,
        onRetry: () {
          context.read<CoursesBloc>().add(
            const LoadCoursesEvent(forceRefresh: false),
          );
        },
        showImage: true,
        enablePullToRefresh: true,
      );
    }

    // Handle CourseSavedState or CourseUnsavedState - reload courses
    // These states should not be emitted from courses list, but handle as fallback
    if (state is CourseSavedState || state is CourseUnsavedState) {
      // Reload courses to get updated state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<CoursesBloc>().add(
            const LoadCoursesEvent(forceRefresh: false),
          );
        }
      });
      return const Center(
        child: CircularProgressIndicator(color: AppConstants.successColor),
      );
    }

    // Show green loader on initial state or loading state (first time load)
    if (state is CoursesInitial ||
        (state is CoursesLoading && state is! CoursesLoaded)) {
      // Show minimal loading indicator without full page reload
      // This allows the page structure to remain visible
      return RefreshIndicator(
        color: AppConstants.successColor,
        onRefresh: () async {
          context.read<CoursesBloc>().add(
            const LoadCoursesEvent(forceRefresh: false),
          );
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: AppConstants.successColor),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppConstants.successColor,
      onRefresh: () async {
        context.read<CoursesBloc>().add(
          const LoadCoursesEvent(forceRefresh: true),
        );
        // Wait for the API call to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: _buildCoursesContent(context, state),
    );
  }

  Widget _buildCoursesContent(BuildContext context, CoursesState state) {
    // Check if courses are empty and show empty state
    if (state is CoursesLoaded && state.filteredCourses.isEmpty) {
      final hasActiveFilters =
          state.searchQuery.isNotEmpty || state.hasActiveFilters();

      return RefreshIndicator(
        color: AppConstants.successColor,
        onRefresh: () async {
          context.read<CoursesBloc>().add(
            const LoadCoursesEvent(forceRefresh: true),
          );
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: EmptyStateWidget(
              icon: Icons.school_outlined,
              title: 'No courses found',
              subtitle: 'Try adjusting your search or filters',
              actionButton: hasActiveFilters
                  ? ElevatedButton(
                      onPressed: () {
                        final bloc = context.read<CoursesBloc>();
                        bloc.add(const ClearSearchEvent());
                        bloc.add(const ClearAllFiltersEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                      ),
                      child: const Text('Clear All'),
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    final filterPadding = (state is CoursesLoaded && state.showFilters)
        ? 92.0
        : 12.0;

    return CustomScrollView(
      slivers: [
        // Animated spacing at top (same as jobs section)
        SliverToBoxAdapter(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: filterPadding - 12,
          ),
        ),
        // Course list as SliverList
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.defaultPadding,
            12,
            AppConstants.defaultPadding,
            0,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (state is CoursesLoaded) {
                  final courses = state.filteredCourses;
                  if (index >= courses.length) return null;
                  final course = courses[index];
                  return RepaintBoundary(
                    child: Container(
                      margin: const EdgeInsets.only(
                        bottom: AppConstants.smallPadding,
                      ),
                      child: CourseCard(
                      course: course,
                      onTap: () {
                        // Pass course data with saved status to details page
                        final courseData = Map<String, dynamic>.from(course);
                        courseData['isSaved'] = state.savedCourseIds.contains(
                          course['id']?.toString() ?? '',
                        );
                        context.goNamed(
                          'courseDetails',
                          pathParameters: {'id': course['id']?.toString() ?? ''},
                          extra: courseData,
                        );
                      },
                      onSaveToggle: () {
                        final courseId = course['id']?.toString();
                        if (courseId != null) {
                          final isSaved = state.savedCourseIds.contains(
                            courseId,
                          );
                          if (isSaved) {
                            context.read<CoursesBloc>().add(
                              UnsaveCourseEvent(courseId: courseId),
                            );
                          } else {
                            context.read<CoursesBloc>().add(
                              SaveCourseEvent(courseId: courseId),
                            );
                          }
                        }
                      },
                    ),
                    ),
                  );
                }
                return null;
              },
              childCount: state is CoursesLoaded
                  ? state.filteredCourses.length
                  : 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context, CoursesState state) {
    if (state is! CoursesLoaded) return const SizedBox.shrink();

    final currentState = state;

    return GestureDetector(
      onHorizontalDragUpdate: (_) {
        // Consume horizontal drag gestures to prevent tab switching (same as jobs section)
      },
      child: Container(
        height: 80.0, // Same as jobs section
        decoration: const BoxDecoration(
          color: AppConstants.cardBackgroundColor,
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.5),
            bottom: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Container(
            height: 70.0, // Same as jobs section
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: AppConstants.defaultPadding),
                  // Category Chip
                  _buildFilterChip(
                    context: context,
                    label: 'Category',
                    icon: Icons.category_outlined,
                    isActive: currentState.selectedCategory != 'All',
                    onTap: () => _showFilterBottomSheet(
                      context,
                      'Category',
                      AppConstants.courseCategories,
                      currentState.selectedCategory,
                      (value) => context.read<CoursesBloc>().add(
                        FilterCoursesEvent(category: value),
                      ),
                    ),
                    onRemove: currentState.selectedCategory != 'All'
                        ? () => context.read<CoursesBloc>().add(
                            FilterCoursesEvent(category: 'All'),
                          )
                        : null,
                    activeValue: currentState.selectedCategory != 'All'
                        ? currentState.selectedCategory
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Level Chip
                  _buildFilterChip(
                    context: context,
                    label: 'Levels',
                    icon: Icons.trending_up_outlined,
                    isActive: currentState.selectedLevel != 'All',
                    onTap: () => _showFilterBottomSheet(
                      context,
                      'Levels',
                      AppConstants.courseLevels,
                      currentState.selectedLevel,
                      (value) => context.read<CoursesBloc>().add(
                        FilterCoursesEvent(level: value),
                      ),
                    ),
                    onRemove: currentState.selectedLevel != 'All'
                        ? () => context.read<CoursesBloc>().add(
                            FilterCoursesEvent(level: 'All'),
                          )
                        : null,
                    activeValue: currentState.selectedLevel != 'All'
                        ? currentState.selectedLevel
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Duration Chip
                  _buildFilterChip(
                    context: context,
                    label: 'Duration',
                    icon: Icons.schedule_outlined,
                    isActive: currentState.selectedDuration != 'All',
                    onTap: () => _showFilterBottomSheet(
                      context,
                      'Duration',
                      AppConstants.courseDurations,
                      currentState.selectedDuration,
                      (value) => context.read<CoursesBloc>().add(
                        FilterCoursesEvent(duration: value),
                      ),
                    ),
                    onRemove: currentState.selectedDuration != 'All'
                        ? () => context.read<CoursesBloc>().add(
                            FilterCoursesEvent(duration: 'All'),
                          )
                        : null,
                    activeValue: currentState.selectedDuration != 'All'
                        ? currentState.selectedDuration
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Institute Chip
                  _buildFilterChip(
                    context: context,
                    label: 'Institute',
                    icon: Icons.school_outlined,
                    isActive: currentState.selectedInstitute != 'All',
                    onTap: () => _showFilterBottomSheet(
                      context,
                      'Institute',
                      AppConstants.courseInstitutes,
                      currentState.selectedInstitute,
                      (value) => context.read<CoursesBloc>().add(
                        FilterCoursesEvent(institute: value),
                      ),
                    ),
                    onRemove: currentState.selectedInstitute != 'All'
                        ? () => context.read<CoursesBloc>().add(
                            FilterCoursesEvent(institute: 'All'),
                          )
                        : null,
                    activeValue: currentState.selectedInstitute != 'All'
                        ? currentState.selectedInstitute
                        : null,
                  ),
                  SizedBox(width: AppConstants.defaultPadding),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    VoidCallback? onRemove,
    String? activeValue,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        height: 48, // Same as jobs section
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 8 : 12, // Same as jobs section
          vertical: AppConstants.smallPadding,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppConstants.primaryColor : Colors.transparent,
          border: Border.all(
            color: isActive
                ? AppConstants.primaryColor
                : AppConstants.primaryColor.withOpacity(0.5),
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppConstants.primaryColor,
              size: 16, // Same as jobs section
            ),
            const SizedBox(width: 6),
            Text(
              _truncateText(activeValue ?? label, 15),
              style: TextStyle(
                color: isActive ? Colors.white : AppConstants.primaryColor,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isActive && onRemove != null) ...[
              const SizedBox(width: 6),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Truncate text to max length with ellipsis
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  void _showFilterBottomSheet(
    BuildContext context,
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppConstants.defaultPadding,
            24,
            AppConstants.defaultPadding,
            32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select $title',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = option == selectedValue;
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onSelect(option);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppConstants.primaryColor.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? AppConstants.primaryColor
                                  : AppConstants.textSecondaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected
                                      ? AppConstants.primaryColor
                                      : AppConstants.textPrimaryColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the Saved Courses tab
  /// Replica of All Courses tab - just filters by savedCourseIds
  Widget _buildSavedCoursesTab() {
    return BlocBuilder<CoursesBloc, CoursesState>(
      buildWhen: (previous, current) {
        // Rebuild only when saved courses or filters change
        if (previous is! CoursesLoaded || current is! CoursesLoaded) return true;
        return previous.savedCourseIds != current.savedCourseIds ||
               previous.searchQuery != current.searchQuery ||
               previous.selectedCategory != current.selectedCategory ||
               previous.selectedLevel != current.selectedLevel ||
               previous.selectedDuration != current.selectedDuration ||
               previous.selectedInstitute != current.selectedInstitute;
      },
      builder: (context, state) {
        if (state is CoursesLoaded) {
          // Filter courses by savedCourseIds - same as All Courses but filtered
          final savedCourses = state.allCourses.where((course) {
            final courseId = course['id'] is int
                ? course['id'].toString()
                : course['id']?.toString() ?? '';
            return state.savedCourseIds.contains(courseId);
          }).toList();

          // Apply search and filters if active (same as All Courses tab)
          var filteredSavedCourses = savedCourses;

          // Apply search query if exists
          if (state.searchQuery.isNotEmpty) {
            filteredSavedCourses = filteredSavedCourses.where((course) {
              final queryLower = state.searchQuery.toLowerCase();
              final title = course['title']?.toString().toLowerCase() ?? '';
              final description =
                  course['description']?.toString().toLowerCase() ?? '';
              final institute =
                  course['institute']?.toString().toLowerCase() ?? '';
              return title.contains(queryLower) ||
                  description.contains(queryLower) ||
                  institute.contains(queryLower);
            }).toList();
          }

          // Apply filters if active
          filteredSavedCourses = _applyCourseFilters(
            filteredSavedCourses,
            state.selectedCategory,
            state.selectedLevel,
            state.selectedDuration,
            state.selectedInstitute,
          );

          // Use the same courses content builder (replica of All Courses)
          return RefreshIndicator(
            color: AppConstants.successColor,
            onRefresh: () async {
              context.read<CoursesBloc>().add(
                const LoadCoursesEvent(forceRefresh: true),
              );
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: _buildCoursesContentWithList(
              context,
              state,
              filteredSavedCourses,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Apply filters to courses list (helper method for saved courses tab)
  List<Map<String, dynamic>> _applyCourseFilters(
    List<Map<String, dynamic>> courses,
    String category,
    String level,
    String duration,
    String institute,
  ) {
    var filteredCourses = courses;

    if (category != 'All' && category.isNotEmpty) {
      filteredCourses = filteredCourses.where((course) {
        final courseCategory =
            course['category']?.toString().toLowerCase() ?? '';
        return courseCategory.contains(category.toLowerCase());
      }).toList();
    }

    if (level != 'All' && level.isNotEmpty) {
      filteredCourses = filteredCourses.where((course) {
        final courseLevel = course['level']?.toString().toLowerCase() ?? '';
        return courseLevel.contains(level.toLowerCase());
      }).toList();
    }

    if (duration != 'All' && duration.isNotEmpty) {
      filteredCourses = filteredCourses.where((course) {
        final courseDuration =
            course['duration']?.toString().toLowerCase() ?? '';
        return courseDuration.contains(duration.toLowerCase());
      }).toList();
    }

    if (institute != 'All' && institute.isNotEmpty) {
      filteredCourses = filteredCourses.where((course) {
        final courseInstitute =
            course['institute']?.toString().toLowerCase() ?? '';
        return courseInstitute.contains(institute.toLowerCase());
      }).toList();
    }

    return filteredCourses;
  }

  /// Build courses content with custom list (for saved courses tab)
  Widget _buildCoursesContentWithList(
    BuildContext context,
    CoursesState state,
    List<Map<String, dynamic>> courses,
  ) {
    // Check if courses are empty and show empty state
    if (courses.isEmpty) {
      final hasActiveFilters =
          state is CoursesLoaded &&
          (state.searchQuery.isNotEmpty || state.hasActiveFilters());

      return RefreshIndicator(
        color: AppConstants.successColor,
        onRefresh: () async {
          context.read<CoursesBloc>().add(
            const LoadCoursesEvent(forceRefresh: true),
          );
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: EmptyStateWidget(
              icon: Icons.school_outlined,
              title: 'No saved courses found',
              subtitle: 'Try adjusting your search or filters',
              actionButton: hasActiveFilters
                  ? ElevatedButton(
                      onPressed: () {
                        final bloc = context.read<CoursesBloc>();
                        bloc.add(const ClearSearchEvent());
                        bloc.add(const ClearAllFiltersEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                      ),
                      child: const Text('Clear All'),
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    final filterPadding = (state is CoursesLoaded && state.showFilters)
        ? 92.0
        : 12.0;

    return CustomScrollView(
      slivers: [
        // Animated spacing at top
        SliverToBoxAdapter(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: filterPadding - 12,
          ),
        ),
        // Course list as SliverList
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.defaultPadding,
            12,
            AppConstants.defaultPadding,
            0,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= courses.length) return null;
              final course = courses[index];
              return RepaintBoundary(
                child: Container(
                  margin: const EdgeInsets.only(
                    bottom: AppConstants.smallPadding,
                  ),
                  child: CourseCard(
                  course: course,
                  onTap: () {
                    // Pass course data with saved status to details page
                    final courseData = Map<String, dynamic>.from(course);
                    if (state is CoursesLoaded) {
                      courseData['isSaved'] = state.savedCourseIds.contains(
                        course['id']?.toString() ?? '',
                      );
                    }
                    context.goNamed(
                      'courseDetails',
                      pathParameters: {'id': course['id']?.toString() ?? ''},
                      extra: courseData,
                    );
                  },
                  onSaveToggle: () {
                    final courseId = course['id']?.toString();
                    if (courseId != null && state is CoursesLoaded) {
                      final isSaved = state.savedCourseIds.contains(courseId);
                      if (isSaved) {
                        context.read<CoursesBloc>().add(
                          UnsaveCourseEvent(courseId: courseId),
                        );
                      } else {
                        context.read<CoursesBloc>().add(
                          SaveCourseEvent(courseId: courseId),
                        );
                      }
                    }
                  },
                  ),
                ),
              );
            }, childCount: courses.length),
          ),
        ),
      ],
    );
  }
}
