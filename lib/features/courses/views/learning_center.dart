/// Learning Center Page
/// Main courses page with search, filters, and course listings

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/cards/course_card.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/courses_bloc.dart';
import '../bloc/courses_event.dart';
import '../bloc/courses_state.dart';
import '../../../core/di/injection_container.dart';

import 'saved_courses.dart';

class LearningCenterPage extends StatelessWidget {
  const LearningCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CoursesBloc>()..add(LoadCoursesEvent()),
      child: _LearningCenterPageView(),
    );
  }
}

class _LearningCenterPageView extends StatefulWidget {
  @override
  State<_LearningCenterPageView> createState() =>
      _LearningCenterPageViewState();
}

class _LearningCenterPageViewState extends State<_LearningCenterPageView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      context.read<CoursesBloc>().add(ClearSearchEvent());
    } else {
      context.read<CoursesBloc>().add(SearchCoursesEvent(query: query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        return KeyboardDismissWrapper(
          child: Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            appBar: _buildAppBar(context, state),
            body: Column(
              children: [
                _buildSearchBar(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLearningCenterTab(context, state),
                      const SavedCoursesPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CoursesState state) {
    return AppBar(
      backgroundColor: AppConstants.cardBackgroundColor,
      elevation: 0,
      title: const Text(
        'Learning Center',
        style: TextStyle(
          color: AppConstants.primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _refreshCourses(context),
          icon: const Icon(Icons.refresh, color: AppConstants.primaryColor),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
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
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Courses search kare',
          hintStyle: TextStyle(color: AppConstants.textSecondaryColor),
          prefixIcon: Icon(
            Icons.search,
            color: AppConstants.textSecondaryColor,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppConstants.cardBackgroundColor,
      child: TabBar(
        controller: _tabController,
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        indicatorColor: AppConstants.primaryColor,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Learning Center'),
          Tab(text: 'Saved Courses'),
        ],
      ),
    );
  }

  Widget _buildLearningCenterTab(BuildContext context, CoursesState state) {
    bool isSearching = false;
    if (state is CoursesLoaded) {
      isSearching = state.searchQuery.isNotEmpty;
    }

    // Handle error state
    if (state is CoursesError) {
      return NoInternetErrorWidget(
        errorMessage: state.message,
        onRetry: () {
          context.read<CoursesBloc>().add(LoadCoursesEvent());
        },
        showImage: true,
        enablePullToRefresh: true,
      );
    }

    // Show cached data immediately if available, even during loading
    if (state is CoursesLoading && state is! CoursesLoaded) {
      // Check if we have any cached courses to show
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading courses...',
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _refreshCourses(context);
        // Wait for the API call to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          if (!isSearching) ...[
            _buildFeaturedSection(context, state),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildFiltersSection(context, state),
            const SizedBox(height: AppConstants.defaultPadding),
          ],
          _buildCoursesSection(context, state),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context, CoursesState state) {
    List<Map<String, dynamic>> featuredCourses = [];
    if (state is CoursesLoaded) {
      featuredCourses = state.allCourses;
    } else {
      featuredCourses = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured By Top Institutes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredCourses.length,
            itemBuilder: (context, index) {
              final course = featuredCourses[index];
              return Container(
                width: 315,
                margin: const EdgeInsets.only(right: AppConstants.smallPadding),
                child: CourseCard(
                  course: course,
                  onTap: () => _navigateToCourseDetails(course),
                  onSaveToggle: () =>
                      _onSaveToggle(context, state, course['id']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection(BuildContext context, CoursesState state) {
    final bool showFilters = _showFilters;

    return Column(
      children: [
        Row(
          children: [
            _buildFilterButton(context),
            if (showFilters) ...[
              const SizedBox(width: AppConstants.smallPadding),
              _buildCategoryFilter(context, state),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    final showFilters = _showFilters;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: showFilters ? AppConstants.primaryColor : Colors.transparent,
        border: Border.all(color: AppConstants.primaryColor),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _showFilters = !_showFilters;
            if (!_showFilters) {
              _selectedCategory = 'All';
              context.read<CoursesBloc>().add(
                FilterCoursesEvent(category: 'All'),
              );
            }
          });
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              showFilters ? Icons.clear : Icons.tune,
              color: showFilters ? Colors.white : AppConstants.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              showFilters ? 'Clear' : 'Filter',
              style: TextStyle(
                color: showFilters ? Colors.white : AppConstants.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, CoursesState state) {
    String? selectedCategory = _selectedCategory;

    return Expanded(
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppConstants.borderColor),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCategory,
            hint: const Text('Categories'),
            isExpanded: true,
            items: _getCourseCategories().map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? 'All';
              });
              context.read<CoursesBloc>().add(
                FilterCoursesEvent(category: _selectedCategory ?? 'All'),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesSection(BuildContext context, CoursesState state) {
    List<Map<String, dynamic>> courses = [];
    if (state is CoursesLoaded) {
      courses = state.filteredCourses;
    } else {
      courses = [];
    }

    if (courses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.largePadding),
          child: Text(
            'No courses found',
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ),
      );
    }

    return Column(
      children: courses.map((course) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: CourseCard(
            course: course,
            onTap: () => _navigateToCourseDetails(course),
            onSaveToggle: () => _onSaveToggle(context, state, course['id']),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToCourseDetails(Map<String, dynamic> course) {
    context.go(AppRoutes.courseDetailsWithId(course['id']));
  }

  void _onSaveToggle(
    BuildContext context,
    CoursesState state,
    String courseId,
  ) {
    final bloc = context.read<CoursesBloc>();
    if (state is CoursesLoaded) {
      final isSaved = state.savedCourseIds.contains(courseId);
      if (isSaved) {
        bloc.add(UnsaveCourseEvent(courseId: courseId));
      } else {
        bloc.add(SaveCourseEvent(courseId: courseId));
      }
    }
  }

  /// Get course categories for filtering
  List<String> _getCourseCategories() {
    return [
      'All',
      'Electrical',
      'Mechanical',
      'Welding',
      'Machining',
      'Turning',
      'Woodwork',
      'Plumbing',
      'Drafting',
      'General',
    ];
  }

  /// Refresh courses by reloading from API
  void _refreshCourses(BuildContext context) {
    context.read<CoursesBloc>().add(const LoadCoursesEvent());
  }
}
