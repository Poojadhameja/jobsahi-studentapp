import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/data/job_data.dart';
import '../../../shared/data/user_data.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/widgets/common/navigation_helper.dart';
import '../../../shared/widgets/cards/job_card.dart';
import '../../../shared/widgets/cards/filter_chip.dart';
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

class _HomePageState extends State<HomePage> {
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
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                // Greeting section
                _buildGreetingSection(),
                const SizedBox(height: AppConstants.smallPadding),

                // Action buttons section removed

                // Banner image
                _buildBannerImage(),
                const SizedBox(height: AppConstants.smallPadding),

                // Filter chips
                _buildFilterChips(state.selectedFilterIndex),
                const SizedBox(height: AppConstants.smallPadding),

                // Recommended jobs section
                _buildRecommendedJobsSection(state.filteredJobs),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  /// Builds the greeting section
  Widget _buildGreetingSection() {
    final userName = UserData.currentUser['name'] as String? ?? 'User';

    return Text('Hi $userName,', style: AppConstants.headingStyle);
  }

  /// Builds the banner image
  Widget _buildBannerImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Image.asset(AppConstants.homeBannerAsset),
    );
  }

  /// Builds the filter chips section
  Widget _buildFilterChips(int selectedFilterIndex) {
    return HorizontalFilterChips(
      filterOptions: JobData.filterOptions,
      selectedIndex: selectedFilterIndex,
      onFilterSelected: (index) {
        context.read<HomeBloc>().add(FilterJobsEvent(filterIndex: index));
      },
    );
  }

  /// Builds the recommended jobs section
  Widget _buildRecommendedJobsSection(List<Map<String, dynamic>> jobs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          AppConstants.recommendedJobsText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.successColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),

        // Job list
        JobList(jobs: jobs),
      ],
    );
  }
}

/// Job List Widget
/// Displays a list of job cards
class JobList extends StatelessWidget {
  /// List of jobs to display
  final List<Map<String, dynamic>> jobs;

  const JobList({super.key, required this.jobs});

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
            ),
          )
          .toList(),
    );
  }
}

/// Bottom Navigation Screen Widgets
/// These are placeholder screens for the bottom navigation tabs
