import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/data/job_data.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../../../shared/widgets/cards/job_card.dart';
import '../../../shared/widgets/cards/filter_chip.dart';

class SearchResultScreen extends StatefulWidget {
  /// Search query
  final String? searchQuery;

  const SearchResultScreen({super.key, this.searchQuery});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  /// Currently selected filter index
  int _selectedFilterIndex = 0;

  /// List of filtered jobs
  List<Map<String, dynamic>> _filteredJobs = [];

  @override
  void initState() {
    super.initState();
    _filterJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(title: 'Search Results', showBackButton: true),
      body: Column(
        children: [
          // Search info and filters
          _buildSearchInfoAndFilters(),

          // Results
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  /// Builds the search info and filters section
  Widget _buildSearchInfoAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search info
          _buildSearchInfo(),
          const SizedBox(height: AppConstants.defaultPadding),

          // Filter chips
          _buildFilterChips(),
        ],
      ),
    );
  }

  /// Builds the search info section
  Widget _buildSearchInfo() {
    return Row(
      children: [
        const Icon(Icons.search, color: AppConstants.textSecondaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Results for "${widget.searchQuery ?? "jobs"}"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ),
        Text(
          '${_filteredJobs.length} jobs found',
          style: const TextStyle(color: AppConstants.textSecondaryColor),
        ),
      ],
    );
  }

  /// Builds the filter chips section
  Widget _buildFilterChips() {
    return HorizontalFilterChips(
      filterOptions: JobData.filterOptions,
      selectedIndex: _selectedFilterIndex,
      onFilterSelected: (index) {
        setState(() {
          _selectedFilterIndex = index;
        });
        _filterJobs();
      },
    );
  }

  /// Builds the results section
  Widget _buildResults() {
    if (_filteredJobs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      itemCount: _filteredJobs.length,
      itemBuilder: (context, index) {
        final job = _filteredJobs[index];
        return JobCard(
          job: job,
          onTap: () {
            context.go(AppRoutes.jobDetailsWithId(job['id']));
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
            style: TextStyle(color: AppConstants.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding),
          ElevatedButton(
            onPressed: () {
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: const Text('Back to Search'),
          ),
        ],
      ),
    );
  }

  /// Filters jobs based on search query and selected filters
  void _filterJobs() {
    final query = widget.searchQuery?.toLowerCase() ?? '';

    setState(() {
      _filteredJobs = JobData.recommendedJobs.where((job) {
        // Filter by search query
        final matchesQuery =
            query.isEmpty ||
            job['title'].toString().toLowerCase().contains(query) ||
            job['company'].toString().toLowerCase().contains(query) ||
            job['location'].toString().toLowerCase().contains(query);

        return matchesQuery;
      }).toList();
    });
  }
}
