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
    return _buildResponsiveBanner();
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
