/// Learning Center Page
/// Main courses page with search, filters, and course listings

library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/data/course_data.dart';
import '../../../shared/widgets/cards/course_card.dart';
import '../../../core/utils/navigation_service.dart';

import 'course_details.dart';
import 'saved_courses.dart';

class LearningCenterPage extends StatefulWidget {
  const LearningCenterPage({super.key});

  @override
  State<LearningCenterPage> createState() => _LearningCenterPageState();
}

class _LearningCenterPageState extends State<LearningCenterPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Filter states
  String? _selectedCategory;
  String? _selectedLevel;
  bool _showFilters = false; // Toggle state for filter visibility

  // Course lists
  List<Map<String, dynamic>> _filteredCourses = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredCourses = CourseData.featuredCourses;
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
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _searchResults.clear();
      } else {
        _isSearching = true;
        _searchResults = CourseData.searchCourses(query);
      }
    });
  }

  void _applyFilters() {
    setState(() {
      if (_selectedCategory == null || _selectedCategory == 'All') {
        _filteredCourses = CourseData.featuredCourses;
      } else {
        _filteredCourses = CourseData.getCoursesByCategory(_selectedCategory!);
      }

      if (_selectedLevel != null && _selectedLevel != 'All') {
        _filteredCourses = _filteredCourses
            .where((course) => course['level'] == _selectedLevel)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppConstants.backgroundColor, // Changed to white background
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildLearningCenterTab(), const SavedCoursesPage()],
            ),
          ),
        ],
      ),
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

  Widget _buildLearningCenterTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      children: [
        if (!_isSearching) ...[
          _buildFeaturedSection(),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildFiltersSection(),
          const SizedBox(height: AppConstants.defaultPadding),
        ],
        _buildCoursesSection(),
      ],
    );
  }

  Widget _buildFeaturedSection() {
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
          height: 240, // Increased height to prevent overflow with CourseCard
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: CourseData.featuredCourses.length,
            itemBuilder: (context, index) {
              final course = CourseData.featuredCourses[index];
              return Container(
                width:
                    315, // Increased width from 288.8 to 350 for bigger cards
                margin: const EdgeInsets.only(right: AppConstants.smallPadding),
                child: CourseCard(
                  course: course,
                  onTap: () => _navigateToCourseDetails(course),
                  onSaveToggle: () => _toggleCourseSaved(course['id']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      children: [
        Row(
          children: [
            _buildFilterButton(),
            if (_showFilters) ...[
              const SizedBox(width: AppConstants.smallPadding),
              _buildCategoryFilter(),
              const SizedBox(width: AppConstants.smallPadding),
              _buildLevelFilter(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton() {
    return Container(
      height: 48, // Fixed height to match dropdowns
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: _showFilters ? AppConstants.primaryColor : Colors.transparent,
        border: Border.all(color: AppConstants.primaryColor),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _showFilters = !_showFilters;
            if (!_showFilters) {
              // Clear filters when hiding
              _selectedCategory = null;
              _selectedLevel = null;
              _filteredCourses = CourseData.featuredCourses;
            }
          });
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showFilters ? Icons.clear : Icons.tune,
              color: _showFilters ? Colors.white : AppConstants.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              _showFilters ? 'Clear' : 'Filter',
              style: TextStyle(
                color: _showFilters ? Colors.white : AppConstants.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Expanded(
      child: Container(
        height: 48, // Fixed height to match filter button
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppConstants.borderColor),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCategory,
            hint: const Text('Categories'),
            isExpanded: true,
            items: CourseData.categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
              _applyFilters();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLevelFilter() {
    return Expanded(
      child: Container(
        height: 48, // Fixed height to match filter button
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppConstants.borderColor),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedLevel,
            hint: const Text('Levels'),
            isExpanded: true,
            items: CourseData.levels.map((level) {
              return DropdownMenuItem<String>(value: level, child: Text(level));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLevel = value;
              });
              _applyFilters();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesSection() {
    final courses = _isSearching ? _searchResults : _filteredCourses;

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
            onSaveToggle: () => _toggleCourseSaved(course['id']),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToCourseDetails(Map<String, dynamic> course) {
    NavigationService.smartNavigate(
      destination: CourseDetailsPage(course: course),
    );
  }

  void _toggleCourseSaved(String courseId) {
    setState(() {
      CourseData.toggleCourseSaved(courseId);
    });
  }
}
