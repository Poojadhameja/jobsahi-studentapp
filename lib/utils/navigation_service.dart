import 'package:flutter/material.dart';

// Import all screen classes
// Authentication screens (moved to auth folder)
import '../auth/splash_screen.dart';
import '../auth/onboarding.dart';
import '../auth/login_otp_email.dart';
import '../auth/login_otp_code.dart';
import '../auth/login_verified_popup.dart';
import '../auth/create_account.dart';
import '../auth/forgot_password.dart';
import '../auth/set_password_code.dart';
import '../auth/set_new_password.dart';
import '../pages/profile/job_status.dart';
import '../auth/change_password.dart';
// Main app screens (organized by feature in pages folder)
import '../pages/home/home.dart';
import '../pages/jobs/search_job.dart';
import '../pages/jobs/search_result.dart';
import '../pages/jobs/job_details.dart';
import '../pages/jobs/job_step.dart';
import '../pages/jobs/job_application_success.dart';
import '../pages/skill_test/skill_test_details.dart';
import '../pages/skill_test/skill_test_instructions.dart';
import '../pages/skill_test/skills_test_faq.dart';
import '../pages/jobs/application_tracker.dart';
import '../pages/jobs/calendar_view.dart';
import '../pages/jobs/write_review.dart';
import '../pages/jobs/saved_jobs.dart';
import '../pages/jobs/about_company.dart';
import '../pages/profile_builder/your_location.dart';
import '../pages/profile_builder/location_permission.dart';
import '../pages/profile_builder/profile_builder_steps.dart';
import '../pages/profile/profile.dart';
import '../pages/profile/user_profile.dart';
import '../pages/profile/profile_details.dart';
import '../pages/profile/job_status.dart';
import '../pages/setting/settings.dart'; // Course screens
import '../pages/courses/learning_center.dart';
import '../pages/courses/course_details.dart';
import '../pages/courses/saved_courses.dart';
import '../pages/setting/about_page.dart';
// Import data classes
import '../data/job_data.dart';

class NavigationService {
  // Private constructor to prevent instantiation
  NavigationService._();

  /// Global navigator key for accessing navigation from anywhere
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Get the current context
  static BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to a new screen
  static Future<T?> navigateTo<T>(Widget screen) async {
    if (navigatorKey.currentContext == null) {
      return null;
    }
    return await Navigator.of(
      navigatorKey.currentContext!,
    ).push<T>(MaterialPageRoute<T>(builder: (context) => screen));
  }

  /// Navigate to a new screen and replace the current screen
  static Future<T?> navigateToReplacement<T>(Widget screen) async {
    return await Navigator.of(
      navigatorKey.currentContext!,
    ).pushReplacement<T, void>(
      MaterialPageRoute<T>(builder: (context) => screen),
    );
  }

  /// Navigate to a new screen and clear the navigation stack
  static Future<T?> navigateToAndClear<T>(Widget screen) async {
    return await Navigator.of(
      navigatorKey.currentContext!,
    ).pushAndRemoveUntil<T>(
      MaterialPageRoute<T>(builder: (context) => screen),
      (route) => false,
    );
  }

  /// Go back to the previous screen
  static void goBack<T>([T? result]) {
    Navigator.of(navigatorKey.currentContext!).pop<T>(result);
  }

  /// Check if we can go back
  static bool canGoBack() {
    return Navigator.of(navigatorKey.currentContext!).canPop();
  }

  /// Navigate to a named route
  static Future<T?> navigateToNamed<T>(
    String routeName, {
    Object? arguments,
  }) async {
    return await Navigator.of(
      navigatorKey.currentContext!,
    ).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Navigate to a named route and replace the current screen
  static Future<T?> navigateToNamedReplacement<T>(
    String routeName, {
    Object? arguments,
  }) async {
    return await Navigator.of(
      navigatorKey.currentContext!,
    ).pushReplacementNamed<T, void>(routeName, arguments: arguments);
  }

  /// Navigate to a named route and clear the navigation stack
  static Future<T?> navigateToNamedAndClear<T>(
    String routeName, {
    Object? arguments,
  }) async {
    return await Navigator.of(
      navigatorKey.currentContext!,
    ).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Smart navigation
  static Future<T?> smartNavigate<T>({
    Widget? destination,
    String? routeName,
    Object? arguments,
  }) async {
    assert(
      destination != null || routeName != null,
      'Either destination widget or routeName must be provided',
    );

    final currentRoute = _getCurrentRouteName();
    final targetRoute = routeName ?? _getRouteNameFromWidget(destination!);
    final navigationAction = _determineNavigationAction(
      currentRoute,
      targetRoute,
    );

    return await _executeNavigation<T>(
      navigationAction: navigationAction,
      destination: destination,
      routeName: routeName,
      arguments: arguments,
    );
  }

  static String? _getCurrentRouteName() {
    final context = navigatorKey.currentContext;
    if (context == null) return null;

    final modalRoute = ModalRoute.of(context);
    return modalRoute?.settings.name;
  }

  static String _getRouteNameFromWidget(Widget widget) {
    final widgetType = widget.runtimeType.toString();

    switch (widgetType) {
      case 'SplashScreen':
        return RouteNames.splash;
      case 'OnboardingScreen':
        return RouteNames.onboarding;
      case 'LoginOtpEmailScreen':
        return RouteNames.loginOtpEmail;
      case 'LoginOtpCodeScreen':
        return RouteNames.loginOtpCode;
      case 'LoginVerifiedPopupScreen':
        return RouteNames.loginVerifiedPopup;
      case 'CreateAccountScreen':
        return RouteNames.createAccount;
      case 'ForgotPasswordScreen':
        return RouteNames.forgotPassword;
      case 'SetPasswordCodeScreen':
        return RouteNames.setPasswordCode;
      case 'SetNewPasswordScreen':
        return RouteNames.setNewPassword;
      case 'HomeScreen':
        return RouteNames.home;
      case 'SearchJobScreen':
        return RouteNames.searchJob;
      case 'SearchResultScreen':
        return RouteNames.searchResult;
      case 'JobDetailsScreen':
        return RouteNames.jobDetails;
      case 'SkillTestDetailsScreen':
        return RouteNames.skillTestDetails;
      case 'SkillTestInstructionsScreen':
        return RouteNames.skillTestInstructions;
      case 'SkillsTestFAQScreen':
        return RouteNames.skillsTestFAQ;

      case 'YourLocationScreen':
      case 'ApplicationTrackerScreen':
        return RouteNames.appTracker1;
      case 'CalendarViewScreen':
        return RouteNames.calendarView;
      case 'WriteReviewScreen':
        return RouteNames.writeReview;
      case 'AboutCompanyScreen':
        return RouteNames.aboutCompany;
      case 'SavedJobsScreen':
        return RouteNames.savedJobs;
      case 'JobStatusScreen':
        return RouteNames.jobStatus;
      case 'Location1Screen':
        return RouteNames.location1;
      case 'LocationPermissionScreen':
        return RouteNames.location2;
      case 'ProfileBuilderStep1Screen':
        return RouteNames.profileBuilderStep1;
      case 'ProfileBuilderStep2Screen':
        return RouteNames.profileBuilderStep2;
      case 'ProfileBuilderStep3Screen':
        return RouteNames.profileBuilderStep3;
      case 'ProfileScreen':
        return RouteNames.profile;
      case 'UserProfileScreen':
        return RouteNames.userProfile;
      case 'ProfileDetailsScreen':
        return RouteNames.profileDetails;
    
      case 'SettingsPage':
        return RouteNames.settings;
      case 'AboutPage':
        return RouteNames.about;
      case 'ChangePasswordPage':
        return RouteNames.changePassword;

      case 'LearningCenterPage':
        return RouteNames.learningCenter;
      case 'CourseDetailsPage':
        return RouteNames.courseDetails;
      case 'SavedCoursesPage':
        return RouteNames.savedCourses;
      default:
        return '/unknown';
    }
  }

  static _NavigationAction _determineNavigationAction(
    String? currentRoute,
    String targetRoute,
  ) {
    if (currentRoute == null) return _NavigationAction.push;

    if (_isAuthFlow(currentRoute, targetRoute)) {
      return _NavigationAction.replacement;
    }

    if (_isLocationCompletionFlow(currentRoute, targetRoute)) {
      return _NavigationAction.clearStack;
    }

    if (_isLocationFlow(currentRoute, targetRoute)) {
      return _NavigationAction.push;
    }

    if (_isProfileBuilderFlow(currentRoute, targetRoute)) {
      return _NavigationAction.push;
    }

    if (_isJobApplicationFlow(currentRoute, targetRoute)) {
      return _NavigationAction.push;
    }

    if (_isAuthToHomeFlow(currentRoute, targetRoute)) {
      return _NavigationAction.clearStack;
    }

    if (_isCourseFlow(currentRoute, targetRoute)) {
      return _NavigationAction.push;
    }

    return _NavigationAction.push;
  }

  static bool _isAuthFlow(String currentRoute, String targetRoute) {
    final authFlowSequences = [
      [RouteNames.splash, RouteNames.onboarding],
      [RouteNames.onboarding, RouteNames.loginOtpEmail],
      [RouteNames.loginOtpEmail, RouteNames.loginOtpCode],
      [RouteNames.loginOtpCode, RouteNames.loginVerifiedPopup],
      [RouteNames.forgotPassword, RouteNames.setPasswordCode],
      [RouteNames.setPasswordCode, RouteNames.setNewPassword],
    ];

    return authFlowSequences.any(
      (sequence) => sequence[0] == currentRoute && sequence[1] == targetRoute,
    );
  }

  static bool _isLocationCompletionFlow(
    String currentRoute,
    String targetRoute,
  ) {
    return currentRoute == RouteNames.location2 &&
        targetRoute == RouteNames.home;
  }

  static bool _isLocationFlow(String currentRoute, String targetRoute) {
    final locationFlowSequences = [
      [RouteNames.location1, RouteNames.location2],
      [RouteNames.location2, RouteNames.home],
    ];

    return locationFlowSequences.any(
      (sequence) => sequence[0] == currentRoute && sequence[1] == targetRoute,
    );
  }

  static bool _isProfileBuilderFlow(String currentRoute, String targetRoute) {
    final profileBuilderFlowSequences = [
      [RouteNames.profileBuilderStep1, RouteNames.profileBuilderStep2],
      [RouteNames.profileBuilderStep2, RouteNames.profileBuilderStep3],
      [RouteNames.profileBuilderStep3, RouteNames.location1],
    ];

    return profileBuilderFlowSequences.any(
      (sequence) => sequence[0] == currentRoute && sequence[1] == targetRoute,
    );
  }

  static bool _isJobApplicationFlow(String currentRoute, String targetRoute) {
    final jobFlowSequences = [
      [RouteNames.skillTestDetails, RouteNames.skillTestInstructions],
    ];

    return jobFlowSequences.any(
      (sequence) => sequence[0] == currentRoute && sequence[1] == targetRoute,
    );
  }

  static bool _isAuthToHomeFlow(String currentRoute, String targetRoute) {
    final authRoutes = [
      RouteNames.splash,
      RouteNames.onboarding,
      RouteNames.loginOtpEmail,
      RouteNames.loginOtpCode,
      RouteNames.loginVerifiedPopup,
      RouteNames.createAccount,
      RouteNames.forgotPassword,
      RouteNames.setPasswordCode,
      RouteNames.setNewPassword,
    ];

    final profileBuilderRoutes = [
      RouteNames.profileBuilderStep1,
      RouteNames.profileBuilderStep2,
      RouteNames.profileBuilderStep3,
    ];

    return (authRoutes.contains(currentRoute) ||
            profileBuilderRoutes.contains(currentRoute)) &&
        targetRoute == RouteNames.home;
  }

  static bool _isCourseFlow(String currentRoute, String targetRoute) {
    final courseFlowSequences = [
      [RouteNames.learningCenter, RouteNames.courseDetails],
      [RouteNames.courseDetails, RouteNames.savedCourses],
      [RouteNames.savedCourses, RouteNames.courseDetails],
    ];

    return courseFlowSequences.any(
      (sequence) => sequence[0] == currentRoute && sequence[1] == targetRoute,
    );
  }

  static Future<T?> _executeNavigation<T>({
    required _NavigationAction navigationAction,
    Widget? destination,
    String? routeName,
    Object? arguments,
  }) async {
    switch (navigationAction) {
      case _NavigationAction.push:
        if (destination != null) {
          return await navigateTo<T>(destination);
        } else {
          return await navigateToNamed<T>(routeName!, arguments: arguments);
        }
      case _NavigationAction.replacement:
        if (destination != null) {
          return await navigateToReplacement<T>(destination);
        } else {
          return await navigateToNamedReplacement<T>(
            routeName!,
            arguments: arguments,
          );
        }
      case _NavigationAction.clearStack:
        if (destination != null) {
          return await navigateToAndClear<T>(destination);
        } else {
          return await navigateToNamedAndClear<T>(
            routeName!,
            arguments: arguments,
          );
        }
    }
  }
}

enum _NavigationAction { push, replacement, clearStack }

/// Route Names
/// Centralized route names for the app
class RouteNames {
  // Private constructor to prevent instantiation
  RouteNames._();

  // App splash screen - initial loading screen
  static const String splash = '/splash';

  // Onboarding screen
  static const String onboarding = '/onboarding';

  // Authentication screens
  static const String loginOtpEmail = '/login-otp-email';
  static const String loginOtpCode = '/login-otp-code';
  static const String loginVerifiedPopup = '/login-verified-popup';
  static const String createAccount = '/create-account';
  static const String forgotPassword = '/forgot-password';
  static const String setPasswordCode = '/set-password-code';
  static const String setNewPassword = '/set-new-password';

  // Main app screens
  static const String home = '/home';
  static const String searchJob = '/search-job';
  static const String searchResult = '/search-result';
  static const String jobDetails = '/job-details';
  static const String skillTestDetails = '/skill-test-details';
  static const String skillTestInstructions = '/skill-test-instructions';
  static const String skillsTestFAQ = '/skills-test-faq';
  static const String appTracker1 = '/app-tracker1';
  static const String calendarView = '/calendar-view';
  static const String writeReview = '/write-review';
  static const String aboutCompany = '/about-company';
  static const String savedJobs = '/saved-jobs';
  static const String location1 = '/your-location';
  static const String location2 = '/enter-location';
  static const String profileBuilderStep1 = '/profile-builder-step1';
  static const String profileBuilderStep2 = '/profile-builder-step2';
  static const String profileBuilderStep3 = '/profile-builder-step3';
  static const String profile = '/profile';
  static const String userProfile = '/user-profile';
  static const String profileDetails = '/profile-details';
  // static const String resume = '/resume';
  static const String jobStatus = '/job-status';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String changePassword = '/change-password';

  // Course screens
  static const String learningCenter = '/learning-center';
  static const String courseDetails = '/course-details';
  static const String savedCourses = '/saved-courses';
}

/// Route Generator
/// Generates routes for the app based on route names
class RouteGenerator {
  /// Generate route based on route name and arguments
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Get arguments passed in while navigating to the route
    final args = settings.arguments;

    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case RouteNames.loginOtpEmail:
        return MaterialPageRoute(builder: (_) => const LoginOtpEmailScreen());
      case RouteNames.loginOtpCode:
        return MaterialPageRoute(builder: (_) => const LoginOtpCodeScreen());
      case RouteNames.loginVerifiedPopup:
        return MaterialPageRoute(
          builder: (_) => const LoginVerifiedPopupScreen(),
        );
      case RouteNames.createAccount:
        return MaterialPageRoute(builder: (_) => const CreateAccountScreen());
      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case RouteNames.setPasswordCode:
        return MaterialPageRoute(builder: (_) => const SetPasswordCodeScreen());
      case RouteNames.setNewPassword:
        return MaterialPageRoute(builder: (_) => const SetNewPasswordScreen());
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteNames.searchJob:
        return MaterialPageRoute(builder: (_) => const SearchJobScreen());
      case RouteNames.searchResult:
        return MaterialPageRoute(builder: (_) => const SearchResultScreen());
      case RouteNames.jobDetails:
        // Pass a default job object for now - in real app, this would come from arguments
        final job =
            args as Map<String, dynamic>? ?? JobData.recommendedJobs.first;
        return MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job));
      case RouteNames.skillTestDetails:
        final job =
            args as Map<String, dynamic>? ?? JobData.recommendedJobs.first;
        return MaterialPageRoute(
          builder: (_) => SkillTestDetailsScreen(job: job),
        );
      case RouteNames.skillTestInstructions:
        final skillTestArgs = args as Map<String, dynamic>? ?? {};
        final job = skillTestArgs['job'] ?? JobData.recommendedJobs.first;
        final test = skillTestArgs['test'] ?? {};
        return MaterialPageRoute(
          builder: (_) => SkillTestInstructionsScreen(job: job, test: test),
        );
      case RouteNames.skillsTestFAQ:
        final skillTestArgs = args as Map<String, dynamic>? ?? {};
        final job = skillTestArgs['job'] ?? JobData.recommendedJobs.first;
        final test = skillTestArgs['test'] ?? {};
        return MaterialPageRoute(
          builder: (_) => SkillsTestFAQScreen(job: job, test: test),
        );

      case RouteNames.appTracker1:
        return MaterialPageRoute(
          builder: (_) => const ApplicationTrackerScreen(),
        );
      case RouteNames.calendarView:
        return MaterialPageRoute(builder: (_) => const CalendarViewScreen());
      case RouteNames.writeReview:
        // Pass a job object for the review
        final job =
            args as Map<String, dynamic>? ?? JobData.recommendedJobs.first;
        return MaterialPageRoute(builder: (_) => WriteReviewScreen(job: job));
      case RouteNames.aboutCompany:
        // Pass a company object for the company details
        final company =
            args as Map<String, dynamic>? ?? JobData.companies.values.first;
        return MaterialPageRoute(
          builder: (_) => AboutCompanyScreen(company: company),
        );
      case RouteNames.savedJobs:
        return MaterialPageRoute(builder: (_) => const SavedJobsScreen());
      case RouteNames.location1:
        return MaterialPageRoute(builder: (_) => const YourLocationScreen());
      case RouteNames.location2:
        final locationArgs = args as Map<String, dynamic>? ?? {};
        final isFromCurrentLocation =
            locationArgs['isFromCurrentLocation'] ?? false;
        return MaterialPageRoute(
          builder: (_) => LocationPermissionScreen(
            isFromCurrentLocation: isFromCurrentLocation,
          ),
        );
      case RouteNames.profileBuilderStep1:
        return MaterialPageRoute(
          builder: (_) => const ProfileBuilderStep1Screen(),
        );
      case RouteNames.profileBuilderStep2:
        final stepArgs = args as Map<String, dynamic>? ?? {};
        final selectedJobType = stepArgs['selectedJobType'] ?? 'Full Time';
        return MaterialPageRoute(
          builder: (_) =>
              ProfileBuilderStep2Screen(selectedJobType: selectedJobType),
        );
      case RouteNames.profileBuilderStep3:
        final stepArgs = args as Map<String, dynamic>? ?? {};
        final selectedJobType = stepArgs['selectedJobType'] ?? 'Full Time';
        final selectedExperienceLevel =
            stepArgs['selectedExperienceLevel'] ?? 'Fresher';
        return MaterialPageRoute(
          builder: (_) => ProfileBuilderStep3Screen(
            selectedJobType: selectedJobType,
            selectedExperienceLevel: selectedExperienceLevel,
          ),
        );
      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case RouteNames.userProfile:
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());
      case RouteNames.profileDetails:
        return MaterialPageRoute(builder: (_) => const ProfileDetailsScreen());
      case RouteNames.jobStatus:
        return MaterialPageRoute(builder: (_) => const JobStatusScreen());
      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case RouteNames.about:
        return MaterialPageRoute(builder: (_) => const AboutPage());
      case RouteNames.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());

      case RouteNames.learningCenter:
        return MaterialPageRoute(builder: (_) => const LearningCenterPage());
      case RouteNames.courseDetails:
        final course = args as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => CourseDetailsPage(course: course),
        );
      case RouteNames.savedCourses:
        return MaterialPageRoute(builder: (_) => const SavedCoursesPage());
      default:
        // If there is no such named route, return an error page
        return _errorRoute();
    }
  }

  /// Error route for undefined routes
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('Route not found!')),
        );
      },
    );
  }
}
