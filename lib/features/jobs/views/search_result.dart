import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/data/job_data.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../../../shared/widgets/cards/job_card.dart';
import '../../../shared/widgets/cards/filter_chip.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';

class SearchResultScreen extends StatelessWidget {
  /// Search query
  final String? searchQuery;

  const SearchResultScreen({super.key, this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          JobsBloc()
            ..add(LoadSearchResultsEvent(searchQuery: searchQuery ?? '')),
      child: const _SearchResultScreenView(),
    );
  }
}

class _SearchResultScreenView extends StatelessWidget {
  const _SearchResultScreenView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        String searchQuery = '';
        List<Map<String, dynamic>> filteredJobs = [];
        int selectedFilterIndex = 0;

        if (state is SearchResultsLoaded) {
          searchQuery = state.searchQuery;
          filteredJobs = state.filteredJobs;
          selectedFilterIndex = state.selectedFilterIndex;
        }

        return Scaffold(
          backgroundColor: AppConstants.cardBackgroundColor,
          appBar: const SimpleAppBar(
            title: 'Search Results',
            showBackButton: true,
          ),
          body: Column(
            children: [
              // Search info and filters
              _buildSearchInfoAndFilters(
                context,
                searchQuery,
                filteredJobs,
                selectedFilterIndex,
              ),

              // Results
              Expanded(child: _buildResults(context, filteredJobs)),
            ],
          ),
        );
      },
    );
  }

  /// Builds the search info and filters section
  Widget _buildSearchInfoAndFilters(
    BuildContext context,
    String searchQuery,
    List<Map<String, dynamic>> filteredJobs,
    int selectedFilterIndex,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search info
          _buildSearchInfo(searchQuery, filteredJobs),
          const SizedBox(height: AppConstants.defaultPadding),

          // Filter chips
          _buildFilterChips(context, selectedFilterIndex),
        ],
      ),
    );
  }

  /// Builds the search info section
  Widget _buildSearchInfo(
    String searchQuery,
    List<Map<String, dynamic>> filteredJobs,
  ) {
    return Row(
      children: [
        const Icon(Icons.search, color: AppConstants.textSecondaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Results for "${searchQuery.isEmpty ? "jobs" : searchQuery}"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ),
        Text(
          '${filteredJobs.length} jobs found',
          style: const TextStyle(color: AppConstants.textSecondaryColor),
        ),
      ],
    );
  }

  /// Builds the filter chips section
  Widget _buildFilterChips(BuildContext context, int selectedFilterIndex) {
    return HorizontalFilterChips(
      filterOptions: JobData.filterOptions,
      selectedIndex: selectedFilterIndex,
      onFilterSelected: (index) {
        context.read<JobsBloc>().add(
          UpdateSearchResultsFilterEvent(filterIndex: index),
        );
      },
    );
  }

  /// Builds the results section
  Widget _buildResults(
    BuildContext context,
    List<Map<String, dynamic>> filteredJobs,
  ) {
    if (filteredJobs.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        final job = filteredJobs[index];
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
  Widget _buildEmptyState(BuildContext context) {
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
}
