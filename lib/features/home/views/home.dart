import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/data/job_data.dart';
import '../../../shared/data/user_data.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/common/custom_app_bar.dart';
import '../../../shared/widgets/common/bottom_navigation.dart';
import '../../../shared/widgets/cards/job_card.dart';
import '../../../shared/widgets/cards/filter_chip.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

import '../../jobs/views/application_tracker.dart';
import '../../profile/views/profile_details.dart';
import '../../courses/views/learning_center.dart';
import '../../messages/views/inbox_screen.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final selectedIndex = state is HomeLoaded ? state.selectedTabIndex : 0;

        return PopScope(
          canPop: false, // Intercept back to avoid accidental app exit
          onPopInvokedWithResult: (didPop, result) {
            if (selectedIndex != 0) {
              // If not on home tab, navigate to home tab instead of exiting
              _navigateToHomeTab();
            } else {
              // On home tab: ignore back to prevent exiting the app
            }
          },
          child: Scaffold(
            backgroundColor: AppConstants.cardBackgroundColor,
            appBar: _buildAppBar(selectedIndex),
            body: _buildCurrentScreen(selectedIndex),
            bottomNavigationBar: CustomBottomNavigation(
              currentIndex: selectedIndex,
              onTap: _onTabSelected,
            ),
          ),
        );
      },
    );
  }

  /// Navigates back to home tab
  void _navigateToHomeTab() {
    context.read<HomeBloc>().add(const ChangeTabEvent(tabIndex: 0));
  }

  /// Builds the appropriate app bar based on selected tab
  PreferredSizeWidget? _buildAppBar(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        // Home tab - show hamburger menu, search, and notification
        return CustomAppBar(
          showSearchBar: true,
          showMenuButton: true,
          showNotificationIcon: true,
          onSearch: _onSearch,
          onNotificationPressed: _onNotificationPressed,
        );
      case 1:
        // Courses tab - show heading with back icon
        return TabAppBar(
          title: 'Learning Center',
          onBackPressed: _navigateToHomeTab, // Navigate to home tab
        );
      case 2:
        // Application Tracker tab - show heading with back icon
        return TabAppBar(
          title: 'Application Tracker',
          onBackPressed: _navigateToHomeTab, // Navigate to home tab
        );
      case 3:
        // Messages tab - show heading with back icon
        return TabAppBar(
          title: 'Messages',
          onBackPressed: _navigateToHomeTab, // Navigate to home tab
        );
      case 4:
        // Profile tab - show heading with back icon
        return TabAppBar(
          title: 'Profile Details',
          onBackPressed: _navigateToHomeTab, // Navigate to home tab
        );
      default:
        return null;
    }
  }

  /// Builds the current screen based on selected tab
  Widget _buildCurrentScreen(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const LearningCenterPage();
      case 2:
        return const ApplicationTrackerScreen(isFromProfile: false);
      case 3:
        return InboxScreen(isFromProfile: false);
      case 4:
        // Profile tab - navigate directly to profile details
        return const ProfileDetailsScreen(isFromBottomNavigation: true);
      default:
        return const HomePage();
    }
  }

  /// Handles tab selection
  void _onTabSelected(int index) {
    context.read<HomeBloc>().add(ChangeTabEvent(tabIndex: index));
  }

  /// Handles search functionality
  static void _onSearch(String query) {
    // Navigate to search results screen
    // Note: This is a static method, so we need to use a different approach
    // In a real app, you might want to pass the context or use a different pattern
    // For now, we'll use the global router
    AppRouter.go('${AppRoutes.searchJob}?query=${Uri.encodeComponent(query)}');
  }

  /// Handles notification icon tap
  void _onNotificationPressed() {
    // Navigate to notification permission page
    context.go(AppRoutes.notificationPermission);
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
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
          .map(
            (job) => JobCard(
              job: job,
              onTap: () {
                // Navigate to job details screen
                context.go(AppRoutes.jobDetailsWithId(job['id']));
              },
              isInitiallySaved: UserData.savedJobIds.contains(job['id']),
            ),
          )
          .toList(),
    );
  }
}

/// Bottom Navigation Screen Widgets
/// These are placeholder screens for the bottom navigation tabs
