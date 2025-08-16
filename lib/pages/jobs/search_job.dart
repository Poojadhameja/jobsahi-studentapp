/// Search Job Screen

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../data/job_data.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import '../../widgets/feature_specific/job_card.dart';
import '../../widgets/feature_specific/filter_chip.dart';
import 'job_details.dart';

class SearchJobScreen extends StatefulWidget {
  /// Initial search query
  final String? searchQuery;

  const SearchJobScreen({
    super.key,
    this.searchQuery,
  });

  @override
  State<SearchJobScreen> createState() => _SearchJobScreenState();
}

class _SearchJobScreenState extends State<SearchJobScreen> {
  /// Search controller
  final _searchController = TextEditingController();
  
  /// Currently selected filter index
  int _selectedFilterIndex = 0;
  
  /// Currently selected category index
  int _selectedCategoryIndex = 0;
  
  /// List of filtered jobs
  List<Map<String, dynamic>> _filteredJobs = [];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery ?? '';
    _filterJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(
        title: 'Search Jobs',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Search and filter section
          _buildSearchAndFilterSection(),
          
          // Job results
          Expanded(
            child: _buildJobResults(),
          ),
        ],
      ),
    );
  }

  /// Builds the search and filter section
  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Category filters
          _buildCategoryFilters(),
          const SizedBox(height: AppConstants.smallPadding),
          
          // Filter chips
          _buildFilterChips(),
        ],
      ),
    );
  }

  /// Builds the search bar
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: AppConstants.searchPlaceholder,
        prefixIcon: const Icon(Icons.search, color: AppConstants.textPrimaryColor),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            _filterJobs();
          },
        ),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        _filterJobs();
      },
    );
  }

  /// Builds the category filters
  Widget _buildCategoryFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        HorizontalFilterChips(
          filterOptions: JobData.jobCategories,
          selectedIndex: _selectedCategoryIndex,
          onFilterSelected: (index) {
            setState(() {
              _selectedCategoryIndex = index;
            });
            _filterJobs();
          },
        ),
      ],
    );
  }

  /// Builds the filter chips
  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filters',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        HorizontalFilterChips(
          filterOptions: JobData.filterOptions,
          selectedIndex: _selectedFilterIndex,
          onFilterSelected: (index) {
            setState(() {
              _selectedFilterIndex = index;
            });
            _filterJobs();
          },
        ),
      ],
    );
  }

  /// Builds the job results section
  Widget _buildJobResults() {
    if (_filteredJobs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      itemCount: _filteredJobs.length,
      itemBuilder: (context, index) {
        final job = _filteredJobs[index];
        return JobCard(
          job: job,
          onTap: () {
            NavigationService.smartNavigate(destination: JobDetailsScreen(job: job));
          },
        );
      },
    );
  }

  /// Builds the empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppConstants.textSecondaryColor,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text(
            'No jobs found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          const Text(
            'Try adjusting your search criteria or filters',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Filters jobs based on search query and selected filters
  void _filterJobs() {
    final query = _searchController.text.toLowerCase();
    final selectedCategory = JobData.jobCategories[_selectedCategoryIndex];
    
    setState(() {
      _filteredJobs = JobData.recommendedJobs.where((job) {
        // Filter by search query
        final matchesQuery = query.isEmpty ||
            job['title'].toString().toLowerCase().contains(query) ||
            job['company'].toString().toLowerCase().contains(query) ||
            job['location'].toString().toLowerCase().contains(query);
        
        // Filter by category
        final matchesCategory = selectedCategory == 'All Jobs' ||
            job['title'].toString().toLowerCase().contains(selectedCategory.toLowerCase());
        
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }
}
