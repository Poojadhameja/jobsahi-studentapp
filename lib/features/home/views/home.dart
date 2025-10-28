import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/data/user_data.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/widgets/common/navigation_helper.dart';
import '../../../shared/widgets/cards/job_card.dart';
import '../../../shared/widgets/activity_tracker.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../courses/bloc/courses_bloc.dart';
import '../../courses/bloc/courses_event.dart';

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
        context.read<CoursesBloc>().add(const LoadCoursesEvent());
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
            child: Column(
              children: [
                // Greeting and Banner (fixed at top)
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    children: [
                      _buildGreetingSection(),
                      const SizedBox(height: AppConstants.smallPadding),
                      _buildBannerImage(),
                    ],
                  ),
                ),
                // Tab Bar (fixed)
                _buildTabBar(),
                // Tab Bar View
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      _buildAllJobsTab(state),
                      _buildSavedJobsTab(state),
                    ],
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

  /// Builds the greeting section
  Widget _buildGreetingSection() {
    final userName = UserData.currentUser['name'] as String? ?? 'User';

    return Align(
      alignment: Alignment.centerLeft,
      child: Text('Hi $userName,', style: AppConstants.headingStyle),
    );
  }

  /// Builds the banner image
  Widget _buildBannerImage() {
    return _buildResponsiveBanner();
  }

  /// Builds the tab bar
  Widget _buildTabBar() {
    return Container(
      color: AppConstants.cardBackgroundColor,
      child: TabBar(
        controller: tabController,
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        indicatorColor: AppConstants.primaryColor,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'All Jobs'),
          Tab(text: 'Saved Jobs'),
        ],
      ),
    );
  }

  /// Builds the All Jobs tab
  Widget _buildAllJobsTab(HomeLoaded state) {
    return _buildRecommendedJobsSection(state.filteredJobs);
  }

  /// Builds the Saved Jobs tab
  Widget _buildSavedJobsTab(HomeLoaded state) {
    if (state.savedJobIds.isEmpty) {
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
            Text(
              'No saved jobs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
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

    final savedJobs = state.allJobs
        .where((job) => state.savedJobIds.contains(job['id']?.toString()))
        .toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final job = savedJobs[index];
              return JobCard(
                job: job,
                onTap: () {
                  NavigationHelper.navigateTo(
                    AppRoutes.jobDetailsWithId(job['id']),
                  );
                },
                onSaveToggle: () {
                  _handleSaveToggle(job);
                },
                isSaved: true,
              );
            }, childCount: savedJobs.length),
          ),
        ),
      ],
    );
  }

  /// Builds a responsive banner that adapts to different screen sizes
  Widget _buildResponsiveBanner() {
    return Builder(
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;
        final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
        final orientation = MediaQuery.of(context).orientation;

        // Calculate responsive dimensions
        final bannerDimensions = _calculateBannerDimensions(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          devicePixelRatio: devicePixelRatio,
          orientation: orientation,
        );

        return Container(
          width: double.infinity,
          height: bannerDimensions.height,
          margin: EdgeInsets.symmetric(horizontal: bannerDimensions.margin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Image.asset(
              AppConstants.homeBannerAsset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: bannerDimensions.height,
              errorBuilder: (context, error, stackTrace) {
                return _buildBannerErrorWidget(bannerDimensions.height);
              },
            ),
          ),
        );
      },
    );
  }

  /// Calculates banner dimensions based on screen properties
  ({double height, double margin}) _calculateBannerDimensions({
    required double screenWidth,
    required double screenHeight,
    required double devicePixelRatio,
    required Orientation orientation,
  }) {
    double bannerHeight;
    double horizontalMargin;

    // Determine device type and orientation
    final isLandscape = orientation == Orientation.landscape;

    if (screenWidth < 400) {
      // Small phones (iPhone SE, etc.)
      bannerHeight = isLandscape ? screenHeight * 0.25 : screenHeight * 0.16;
      horizontalMargin = 0.0; // No margin for small phones
    } else if (screenWidth < 600) {
      // Medium phones and small tablets
      bannerHeight = isLandscape ? screenHeight * 0.30 : screenHeight * 0.18;
      horizontalMargin = 0.0; // No margin for medium phones
    } else if (screenWidth < 900) {
      // Tablets
      bannerHeight = isLandscape ? screenHeight * 0.35 : screenHeight * 0.20;
      horizontalMargin = 0.0; // No margin for tablets
    } else {
      // Desktop and large tablets
      bannerHeight = isLandscape ? screenHeight * 0.40 : screenHeight * 0.22;
      horizontalMargin = 0.5; // Almost no margin for desktop
    }

    // Adjust for high DPI screens
    if (devicePixelRatio > 2.0) {
      bannerHeight *= 1.05;
    }

    // Ensure reasonable bounds
    bannerHeight = bannerHeight.clamp(80.0, 320.0);

    return (height: bannerHeight, margin: horizontalMargin);
  }

  /// Builds error widget for banner when image fails to load
  Widget _buildBannerErrorWidget(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.1),
            AppConstants.secondaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 40,
              color: AppConstants.textSecondaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              'Banner Image',
              style: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the recommended jobs section
  Widget _buildRecommendedJobsSection(List<Map<String, dynamic>> jobs) {
    return CustomScrollView(
      slivers: [
        // Filter section as SliverToBoxAdapter
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: _buildFiltersSection(),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppConstants.smallPadding),
        ),
        // Job list as SliverList
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final job = jobs[index];
              return JobCard(
                job: job,
                onTap: () {
                  NavigationHelper.navigateTo(
                    AppRoutes.jobDetailsWithId(job['id']),
                  );
                },
                onSaveToggle: () {
                  _handleSaveToggle(job);
                },
                isSaved:
                    BlocProvider.of<HomeBloc>(context).state is HomeLoaded &&
                    (BlocProvider.of<HomeBloc>(context).state as HomeLoaded)
                        .savedJobIds
                        .contains(job['id']?.toString()),
              );
            }, childCount: jobs.length),
          ),
        ),
      ],
    );
  }

  /// Builds the filters section
  Widget _buildFiltersSection() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();

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
  Widget _buildFilterButton(BuildContext context, HomeLoaded state) {
    return InkWell(
      onTap: () {
        context.read<HomeBloc>().add(ToggleFiltersEvent());
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
  Widget _buildCategoryFilter(BuildContext context, HomeLoaded state) {
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
              context.read<HomeBloc>().add(
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
                NavigationHelper.navigateTo(
                  AppRoutes.jobDetailsWithId(job['id']),
                );
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

/// Bottom Navigation Screen Widgets
/// These are placeholder screens for the bottom navigation tabs
