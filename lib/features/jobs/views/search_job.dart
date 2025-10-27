import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../../../shared/widgets/cards/job_card.dart';
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

            // Featured jobs section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFeaturedJobsSection(),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildJobResults(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the featured jobs section
  Widget _buildFeaturedJobsSection() {
    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        if (state is! JobsLoaded) return const SizedBox.shrink();

        // Use featured jobs from API if available, otherwise use first 4 regular jobs
        final featuredJobs = state.featuredJobs.isNotEmpty
            ? state.featuredJobs
            : state.allJobs.take(4).toList();

        if (featuredJobs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'Featured Jobs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
            SizedBox(
              height: 260, // Increased height to prevent overflow
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemCount: featuredJobs.length,
                itemBuilder: (context, index) {
                  final job = featuredJobs[index];
                  return Container(
                    width: 380, // Increased card width
                    margin: const EdgeInsets.only(
                      right: AppConstants.smallPadding,
                    ),
                    child: JobCard(
                      job: job,
                      onTap: () {
                        // Navigate to job details
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the search section
  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          const SizedBox(height: AppConstants.smallPadding),
          // Filters section
          _buildFiltersSection(),
        ],
      ),
    );
  }

  /// Builds the filters section
  Widget _buildFiltersSection() {
    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        if (state is! JobsLoaded) return const SizedBox.shrink();

        return Row(
          children: [
            _buildFilterButton(context, state),
            if (state.showFilters) ...[
              const SizedBox(width: AppConstants.smallPadding),
              _buildCategoryFilter(context, state),
            ],
          ],
        );
      },
    );
  }

  /// Builds the filter button
  Widget _buildFilterButton(BuildContext context, JobsLoaded state) {
    return InkWell(
      onTap: () {
        context.read<JobsBloc>().add(ToggleFiltersEvent());
      },
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        decoration: BoxDecoration(
          color: state.showFilters
              ? AppConstants.primaryColor
              : Colors.transparent,
          border: Border.all(color: AppConstants.primaryColor),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.showFilters ? Icons.clear : Icons.tune,
              color: state.showFilters
                  ? Colors.white
                  : AppConstants.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              state.showFilters ? 'Clear' : 'Filter',
              style: TextStyle(
                color: state.showFilters
                    ? Colors.white
                    : AppConstants.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the category filter dropdown
  Widget _buildCategoryFilter(BuildContext context, JobsLoaded state) {
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
            value: state.selectedCategory,
            hint: const Text('Categories'),
            isExpanded: true,
            items: _getJobCategories().map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              context.read<JobsBloc>().add(
                FilterJobsEvent(category: value ?? 'All'),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Get job categories for filtering
  List<String> _getJobCategories() {
    return AppConstants.jobCategories;
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

  /// Builds the job results section
  Widget _buildJobResults() {
    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        if (state is JobsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is JobsError) {
          return NoInternetErrorWidget(
            errorMessage: state.message,
            onRetry: () {
              context.read<JobsBloc>().add(const LoadJobsEvent());
            },
            showImage: true,
            enablePullToRefresh: true,
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
            'Try adjusting your search criteria',
            style: TextStyle(color: AppConstants.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
