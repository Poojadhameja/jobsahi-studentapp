import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/widgets/common/navigation_helper.dart';
import '../../../shared/widgets/common/empty_state_widget.dart';
import '../../../shared/widgets/cards/job_card.dart';
import '../../../shared/widgets/activity_tracker.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_event.dart' as courses;
import '../../jobs/bloc/jobs_bloc.dart';
import '../../jobs/bloc/jobs_event.dart' as jobs_events;
import '../../jobs/bloc/jobs_state.dart' as jobs_states;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load home data when screen initializes
    context.read<HomeBloc>().add(const LoadHomeDataEvent());

    // Preload courses in background for faster access
    _preloadCourses();
  }

  /// Preload courses in background
  void _preloadCourses() {
    // Add a small delay to not interfere with home loading
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<CoursesBloc>().add(const courses.LoadCoursesEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ActivityTracker(
      child: KeyboardDismissWrapper(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(const LoadHomeDataEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else {
              // Show HomePage content
              return const HomePage();
            }
          },
        ),
      ),
    );
  }
}

/// Home Page Widget
/// The main content of the home screen showing job listings
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 400),
    );

    // Removed auto-loading saved jobs on tab switch to avoid redundant API calls
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }


  TabController get tabController {
    _tabController ??= TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 400),
    );
    return _tabController!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeError) {
          return NoInternetErrorWidget(
            errorMessage: state.message,
            onRetry: () {
              context.read<HomeBloc>().add(const LoadHomeDataEvent());
            },
            showImage: true,
            enablePullToRefresh: true,
          );
        }

        if (state is HomeLoaded) {
          return SafeArea(
            child: Stack(
              children: [
                // Main content with NestedScrollView
                NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyTabBarDelegate(child: _buildTabBar()),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: tabController,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      _buildAllJobsTab(state),
                      _buildSavedJobsTab(state),
                    ],
                  ),
                ),
                // Filter chips overlay - positioned above everything with z-index
                Positioned(
                  top: 56, // Below the pinned tab bar (48 + 8 bottom padding)
                  left: 0,
                  right: 0,
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoaded) {
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
                          child: _buildFiltersSection(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  /// Handle save toggle for a job
  void _handleSaveToggle(Map<String, dynamic> job) {
    final jobId = job['id']?.toString();
    if (jobId == null) return;

    final currentState = context.read<HomeBloc>().state;
    if (currentState is HomeLoaded) {
      final isCurrentlySaved = currentState.savedJobIds.contains(jobId);

      if (isCurrentlySaved) {
        context.read<HomeBloc>().add(UnsaveJobEvent(jobId: jobId));
      } else {
        context.read<HomeBloc>().add(SaveJobEvent(jobId: jobId));
      }
    }
  }

  /// Builds the tab bar
  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: TabBar(
          controller: tabController,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: AppConstants.textSecondaryColor,
          indicatorColor: AppConstants.primaryColor,
          indicatorWeight: 3,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'All Jobs'),
            Tab(text: 'Saved Jobs'),
          ],
        ),
      ),
    );
  }

  /// Builds the All Jobs tab
  Widget _buildAllJobsTab(HomeLoaded state) {
    return _buildRecommendedJobsSection(state.filteredJobs);
  }

  /// Builds the Saved Jobs tab
  Widget _buildSavedJobsTab(HomeLoaded state) {
    final currentState = context.read<HomeBloc>().state;
    final filterPadding =
        (currentState is HomeLoaded && currentState.showFilters) ? 92.0 : 12.0;

    // Use BlocBuilder to listen to JobsBloc for saved jobs from API
    return BlocBuilder<JobsBloc, jobs_states.JobsState>(
      builder: (context, jobsState) {
        // Show loading state
        if (jobsState is jobs_states.JobsLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading saved jobs...',
                  style: TextStyle(color: AppConstants.textSecondaryColor),
                ),
              ],
            ),
          );
        }

        // Get saved jobs from API response
        List<Map<String, dynamic>> savedJobs = [];
        if (jobsState is jobs_states.SavedJobsLoaded) {
          savedJobs = jobsState.savedJobs;
        } else {
          // Fallback: use jobs from HomeBloc state filtered by savedJobIds
          savedJobs = state.allJobs
              .where((job) {
                final jobId = job['id'] is int
                    ? job['id'].toString()
                    : job['id']?.toString() ?? '';
                return state.savedJobIds.contains(jobId);
              })
              .toList();
        }

        // Show empty state
        if (savedJobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 80,
                  color: AppConstants.textSecondaryColor,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                const Text(
                  'No saved jobs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  'Save jobs to view them here',
                  style: TextStyle(color: AppConstants.textSecondaryColor),
                ),
              ],
            ),
          );
        }

        // Show saved jobs list
        return RefreshIndicator(
          onRefresh: () async {
            context.read<JobsBloc>().add(const jobs_events.LoadSavedJobsEvent());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            slivers: [
              // Animated spacing at top
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: filterPadding - 12,
                ),
              ),
              // Job list as SliverList
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.defaultPadding,
                  12,
                  AppConstants.defaultPadding,
                  0,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final job = savedJobs[index];
                    // Safely extract job ID
                    final jobId = job['id'] is int
                        ? job['id'].toString()
                        : job['id']?.toString() ?? '';
                    return JobCard(
                      job: job,
                      onTap: () {
                        if (jobId.isNotEmpty) {
                          NavigationHelper.navigateTo(
                            AppRoutes.jobDetailsWithId(jobId),
                          );
                        }
                      },
                      onSaveToggle: () {
                        _handleSaveToggle(job);
                        // Reload saved jobs after toggle
                        Future.delayed(const Duration(milliseconds: 300), () {
                          context.read<JobsBloc>().add(
                                const jobs_events.LoadSavedJobsEvent(),
                              );
                        });
                      },
                      isSaved: true,
                    );
                  }, childCount: savedJobs.length),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the recommended jobs section
  Widget _buildRecommendedJobsSection(List<Map<String, dynamic>> jobs) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Check if jobs are empty and show empty state
        if (jobs.isEmpty) {
          final hasActiveFilters =
              state is HomeLoaded &&
              (state.searchQuery.isNotEmpty || state.activeFilters.isNotEmpty);

          return EmptyStateWidget(
            icon: Icons.search_off,
            title: 'No jobs found',
            subtitle: 'Try adjusting your search or filters',
            actionButton: hasActiveFilters
                ? ElevatedButton(
                    onPressed: () {
                      final bloc = context.read<HomeBloc>();
                      bloc.add(const ClearSearchEvent());
                      bloc.add(const ClearAllFiltersEvent());
                      // Do not toggle filters visibility here; keep chips section open
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
          );
        }

        final filterPadding = (state is HomeLoaded && state.showFilters)
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
            // Job list as SliverList
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.defaultPadding,
                12,
                AppConstants.defaultPadding,
                0,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final job = jobs[index];
                  return JobCard(
                    job: job,
                    onTap: () {
                      // Safely extract job ID
                      final jobId = job['id'] is int
                          ? job['id'].toString()
                          : job['id']?.toString() ?? '';
                      if (jobId.isNotEmpty) {
                        NavigationHelper.navigateTo(
                          AppRoutes.jobDetailsWithId(jobId),
                        );
                      }
                    },
                    onSaveToggle: () {
                      _handleSaveToggle(job);
                    },
                    isSaved:
                        BlocProvider.of<HomeBloc>(context).state
                            is HomeLoaded &&
                        (BlocProvider.of<HomeBloc>(context).state as HomeLoaded)
                            .savedJobIds
                            .contains(job['id']?.toString()),
                  );
                }, childCount: jobs.length),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the filters section
  Widget _buildFiltersSection() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();

        return GestureDetector(
          onHorizontalDragUpdate: (_) {
            // Consume horizontal drag gestures to prevent tab switching
          },
          child: Container(
            height: 80.0, // Full height to capture all gestures
            decoration: const BoxDecoration(
              color: AppConstants.cardBackgroundColor,
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Container(
                height: 70.0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: AppConstants.defaultPadding),
                      _buildFilterChip(
                        context,
                        state,
                        'fields',
                        'Fields',
                        Icons.category_outlined,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        state,
                        'salary',
                        'Salary',
                        Icons.attach_money_outlined,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        state,
                        'location',
                        'Location',
                        Icons.location_on_outlined,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        state,
                        'job_type',
                        'Job Type',
                        Icons.work_outline,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        state,
                        'work_mode',
                        'Work Mode',
                        Icons.business,
                      ),
                      SizedBox(width: AppConstants.defaultPadding),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds a filter chip button
  Widget _buildFilterChip(
    BuildContext context,
    HomeLoaded state,
    String filterType,
    String label,
    IconData icon,
  ) {
    final isActive =
        state.activeFilters.containsKey(filterType) &&
        state.activeFilters[filterType] != null;
    final activeValue = state.activeFilters[filterType];

    return InkWell(
      onTap: () {
        // Show filter modal
        _showFilterModal(context, filterType, label);
      },
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 8 : 12,
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
            // Icon
            Icon(
              icon,
              color: isActive ? Colors.white : AppConstants.primaryColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            // Text - show active value if available, otherwise show label
            // Truncate to 15 characters with ellipsis
            Flexible(
              child: Text(
                _truncateText(activeValue ?? label, 15),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? Colors.white : AppConstants.primaryColor,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            // Right side: Cross icon (only when active)
            if (isActive) ...[
              const SizedBox(width: 6),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.read<HomeBloc>().add(
                      ClearFilterEvent(filterType: filterType),
                    );
                  },
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

  /// Shows filter modal for selecting filter value
  void _showFilterModal(BuildContext context, String filterType, String label) {
    final state = context.read<HomeBloc>().state;
    if (state is! HomeLoaded) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _FilterModalContent(
          filterType: filterType,
          label: label,
          currentValue: state.activeFilters[filterType],
          jobs: state.recommendedJobs,
        );
      },
    );
  }
}

/// Delegate for sticky tab bar
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 56.0; // 48 + 8 bottom padding

  @override
  double get maxExtent => 56.0; // 48 + 8 bottom padding

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

/// Job List Widget
/// Displays a list of job cards
class JobList extends StatelessWidget {
  /// List of jobs to display
  final List<Map<String, dynamic>> jobs;

  /// Callback when save button is toggled
  final Function(Map<String, dynamic>)? onSaveToggle;

  /// Function to check if a job is saved
  final bool Function(Map<String, dynamic>)? isSaved;

  const JobList({
    super.key,
    required this.jobs,
    this.onSaveToggle,
    this.isSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: jobs
          .map<Widget>(
            (job) => JobCard(
              job: job,
              onTap: () {
                // Navigate to job details screen using NavigationHelper
                final jobId = job['id'] is int
                    ? job['id'].toString()
                    : job['id']?.toString() ?? '';
                if (jobId.isNotEmpty) {
                  NavigationHelper.navigateTo(
                    AppRoutes.jobDetailsWithId(jobId),
                  );
                }
              },
              onSaveToggle: onSaveToggle != null
                  ? () => onSaveToggle!(job)
                  : null,
              isSaved: isSaved != null ? isSaved!(job) : false,
            ),
          )
          .toList(),
    );
  }
}

/// Filter Modal Content Widget
class _FilterModalContent extends StatefulWidget {
  final String filterType;
  final String label;
  final String? currentValue;
  final List<Map<String, dynamic>> jobs;

  const _FilterModalContent({
    required this.filterType,
    required this.label,
    this.currentValue,
    required this.jobs,
  });

  @override
  State<_FilterModalContent> createState() => _FilterModalContentState();
}

class _FilterModalContentState extends State<_FilterModalContent> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.currentValue;
  }

  List<String> getFilterOptions() {
    final Set<String> options = {};

    for (final job in widget.jobs) {
      switch (widget.filterType) {
        case 'fields':
          // Get unique job titles
          final title = job['title']?.toString();
          if (title != null && title.isNotEmpty) {
            options.add(title);
          }
          break;
        case 'salary':
          // Get unique salary ranges
          final salary = job['salary']?.toString();
          if (salary != null && salary.isNotEmpty) {
            options.add(salary);
          }
          break;
        case 'location':
          // Get unique locations
          final location = job['location']?.toString();
          if (location != null && location.isNotEmpty) {
            options.add(location);
          }
          break;
        case 'job_type':
          // Get unique job types (Full-Time, Part-Time, Internship)
          final jobType =
              job['job_type_display']?.toString() ??
              job['job_type']?.toString() ??
              '';
          if (jobType.isNotEmpty) {
            // Normalize job types
            final normalizedType = jobType.toLowerCase();
            if (normalizedType.contains('full')) {
              options.add('Full-Time');
            } else if (normalizedType.contains('part')) {
              options.add('Part-Time');
            } else if (normalizedType.contains('intern')) {
              options.add('Internship');
            }
          }
          break;
        case 'work_mode':
          // Get work mode (Remote, On-site)
          final isRemote = job['is_remote'] ?? false;
          if (isRemote) {
            options.add('Remote');
          } else {
            options.add('On-site');
          }
          break;
      }
    }

    return options.toList()..sort();
  }

  List<String> getPredefinedOptions() {
    // Return predefined options based on filter type (same as courses section pattern)
    switch (widget.filterType) {
      case 'job_type':
        return ['All', 'Full-Time', 'Part-Time', 'Internship'];
      case 'work_mode':
        return ['All', 'Remote', 'On-site'];
      default:
        // For dynamic filters (fields, salary, location), use getFilterOptions
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use predefined options if available, otherwise use dynamic options
    final predefinedOptions = getPredefinedOptions();
    final dynamicOptions = getFilterOptions();
    final options = predefinedOptions.isNotEmpty 
        ? predefinedOptions 
        : ['All', ...dynamicOptions];
    
    final currentSelectedValue = selectedValue ?? widget.currentValue;
    
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
            'Select ${widget.label}',
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
                final isSelected = option == currentSelectedValue || 
                    (option == 'All' && currentSelectedValue == null);
                
                return InkWell(
                  onTap: () {
                    final valueToApply = option == 'All' ? null : option;
                    context.read<HomeBloc>().add(
                      ApplyFilterEvent(
                        filterType: widget.filterType,
                        filterValue: valueToApply,
                      ),
                    );
                    Navigator.pop(context);
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
                          ? AppConstants.primaryColor.withOpacity(0.1)
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
  }
}

/// Bottom Navigation Screen Widgets
/// These are placeholder screens for the bottom navigation tabs
