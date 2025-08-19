/// Home Screen

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../data/job_data.dart';
import '../../data/user_data.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/custom_app_bar.dart';
import '../../widgets/global/bottom_navigation.dart';
import '../../widgets/feature_specific/job_card.dart';
import '../../widgets/feature_specific/filter_chip.dart';
import '../jobs/job_details.dart';
import '../jobs/search_job.dart';
import '../profile/profile.dart';
import '../courses/learning_center.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Currently selected tab index
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildCurrentScreen(),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }

  /// Builds the appropriate app bar based on selected tab
  PreferredSizeWidget? _buildAppBar() {
    switch (_selectedIndex) {
      case 0:
        // Home tab - show hamburger menu, search, and notification
        return const CustomAppBar(
          showSearchBar: true,
          showMenuButton: true,
          showNotificationIcon: true,
          onSearch: _onSearch,
        );
      case 1:
        // Courses tab - show heading with back icon
        return const TabAppBar(title: 'Learning Center');
      case 2:
        // Applications tab - show heading with back icon
        return const TabAppBar(title: 'My Applications');
      case 3:
        // Messages tab - show heading with back icon
        return const TabAppBar(title: 'Messages');
      case 4:
        // Profile tab - show heading with back icon
        return const TabAppBar(title: 'Profile');
      default:
        return null;
    }
  }

  /// Builds the current screen based on selected tab
  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const LearningCenterPage();
      case 2:
        return const ApplicationsPage();
      case 3:
        return const MessagesPage();
      case 4:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }

  /// Handles tab selection
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Handles search functionality
  static void _onSearch(String query) {
    // Navigate to search results screen
    NavigationService.navigateTo(SearchJobScreen(searchQuery: query));
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
  /// Currently selected filter index
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Greeting section
          _buildGreetingSection(),
          const SizedBox(height: AppConstants.smallPadding),

          // Action buttons
          _buildActionButtons(),
          const SizedBox(height: AppConstants.smallPadding),

          // Banner image
          _buildBannerImage(),
          const SizedBox(height: AppConstants.smallPadding),

          // Filter chips
          _buildFilterChips(),
          const SizedBox(height: AppConstants.smallPadding),

          // Recommended jobs section
          _buildRecommendedJobsSection(),
        ],
      ),
    );
  }

  /// Builds the greeting section
  Widget _buildGreetingSection() {
    final userName = UserData.currentUser['name'] as String? ?? 'User';

    return Text('Hi $userName,', style: AppConstants.headingStyle);
  }

  /// Builds the action buttons (saved jobs and applied jobs)
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Saved jobs button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Navigate to saved jobs screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.cardBackgroundColor,
              side: const BorderSide(color: AppConstants.accentColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Text(
              AppConstants.savedJobsText,
              style: const TextStyle(color: AppConstants.textPrimaryColor),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),

        // Applied jobs button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Navigate to applied jobs screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.cardBackgroundColor,
              side: const BorderSide(color: AppConstants.accentColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Text(
              AppConstants.appliedJobsText,
              style: const TextStyle(color: AppConstants.textPrimaryColor),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the banner image
  Widget _buildBannerImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Image.asset(AppConstants.homeBannerAsset),
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
        // TODO: Apply filter logic
      },
    );
  }

  /// Builds the recommended jobs section
  Widget _buildRecommendedJobsSection() {
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
        JobList(jobs: JobData.recommendedJobs),
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
                NavigationService.navigateTo(JobDetailsScreen(job: job));
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

class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Applications content
            const Text(
              'Your Job Applications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Placeholder content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: AppConstants.textSecondaryColor,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      'No applications yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      'Start applying to jobs to see them here',
                      style: TextStyle(color: AppConstants.textSecondaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Messages content
            const Text(
              'Your Messages',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            // Placeholder content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message_outlined,
                      size: 64,
                      color: AppConstants.textSecondaryColor,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      'No messages yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      'Messages from employers will appear here',
                      style: TextStyle(color: AppConstants.textSecondaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
