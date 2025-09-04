import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/data/job_data.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../../../shared/widgets/cards/job_card.dart';
import '../../../shared/widgets/cards/filter_chip.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';

class SearchJobScreen extends StatefulWidget {
  /// Initial search query
  final String? searchQuery;

  const SearchJobScreen({super.key, this.searchQuery});

  @override
  State<SearchJobScreen> createState() => _SearchJobScreenState();
}

class _SearchJobScreenState extends State<SearchJobScreen> {
  /// Search controller
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery ?? '';

    // Load jobs when screen initializes
    context.read<JobsBloc>().add(const LoadJobsEvent());

    // If there's an initial search query, search for it
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      context.read<JobsBloc>().add(SearchJobsEvent(query: widget.searchQuery!));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobsBloc, JobsState>(
      listener: (context, state) {
        if (state is JobsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppConstants.cardBackgroundColor,
        appBar: const SimpleAppBar(title: 'Search Jobs', showBackButton: true),
        body: Column(
          children: [
            // Search and filter section
            _buildSearchAndFilterSection(),

            // Job results
            Expanded(child: _buildJobResults()),
          ],
        ),
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
        prefixIcon: const Icon(
          Icons.search,
          color: AppConstants.textPrimaryColor,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            context.read<JobsBloc>().add(const ClearSearchEvent());
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
        context.read<JobsBloc>().add(SearchJobsEvent(query: value));
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
        BlocBuilder<JobsBloc, JobsState>(
          builder: (context, state) {
            final selectedCategoryIndex = state is JobsLoaded
                ? state.selectedCategoryIndex
                : 0;

            return HorizontalFilterChips(
              filterOptions: JobData.jobCategories,
              selectedIndex: selectedCategoryIndex,
              onFilterSelected: (index) {
                final currentState = state as JobsLoaded;
                context.read<JobsBloc>().add(
                  FilterJobsEvent(
                    categoryIndex: index,
                    filterIndex: currentState.selectedFilterIndex,
                  ),
                );
              },
            );
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
        BlocBuilder<JobsBloc, JobsState>(
          builder: (context, state) {
            final selectedFilterIndex = state is JobsLoaded
                ? state.selectedFilterIndex
                : 0;

            return HorizontalFilterChips(
              filterOptions: JobData.filterOptions,
              selectedIndex: selectedFilterIndex,
              onFilterSelected: (index) {
                final currentState = state as JobsLoaded;
                context.read<JobsBloc>().add(
                  FilterJobsEvent(
                    categoryIndex: currentState.selectedCategoryIndex,
                    filterIndex: index,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// Builds the job results section
  Widget _buildJobResults() {
    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        if (state is JobsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is JobsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<JobsBloc>().add(const LoadJobsEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is JobsLoaded) {
          final filteredJobs = state.filteredJobs;

          if (filteredJobs.isEmpty) {
            return _buildEmptyState();
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
                isInitiallySaved: state.savedJobIds.contains(job['id']),
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
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
        ],
      ),
    );
  }
}
