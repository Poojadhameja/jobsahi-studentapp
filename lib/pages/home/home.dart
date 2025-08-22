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
import '../jobs/saved_jobs.dart';
import '../profile/profile.dart';

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
      appBar: CustomAppBar(
        showSearchBar: true,
        showMenuButton: true,
        showNotificationIcon: true,
        onSearch: _onSearch,
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }

  /// Builds the current screen based on selected tab
  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const CoursesPage();
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
    NavigationService.smartNavigate(
      destination: SearchJobScreen(searchQuery: query),
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
              NavigationService.smartNavigate(
                destination: const SavedJobsScreen(),
              );
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
                NavigationService.smartNavigate(
                  destination: JobDetailsScreen(job: job),
                );
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

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Courses Page (Connect with Courses)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Applications Page (Jobs you applied)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Messages Page (Inbox)', style: TextStyle(fontSize: 20)),
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
