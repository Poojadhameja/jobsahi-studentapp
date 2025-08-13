/// Navigation Service

library;

import 'package:flutter/material.dart';

// Import all screen classes
// Authentication screens (moved to auth folder)
import '../auth/splash_screen.dart';
import '../auth/onboarding.dart';
import '../auth/signin.dart';
import '../auth/signin1.dart';
import '../auth/signin2.dart';
import '../auth/create_account.dart';
import '../auth/forgot_password.dart';
import '../auth/enter_code.dart';
import '../auth/enter_new_password.dart';
// Main app screens (organized by feature in pages folder)
import '../pages/home/home.dart';
import '../pages/jobs/search_job.dart';
import '../pages/jobs/search_result.dart';
import '../pages/jobs/job_details.dart';
import '../pages/jobs/job_step1.dart';
import '../pages/jobs/job_step2.dart';
import '../pages/jobs/job_step3.dart';
import '../pages/location/location1.dart';
import '../pages/location/location2.dart';
import '../pages/profile/profile.dart';
import '../pages/profile/user_profile.dart';

// Import data classes
import '../data/job_data.dart';

class NavigationService {
  // Private constructor to prevent instantiation
  NavigationService._();

  /// Global navigator key for accessing navigation from anywhere
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get the current context
  static BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to a new screen
  static Future<T?> navigateTo<T>(Widget screen) async {
    return await Navigator.of(navigatorKey.currentContext!).push<T>(
      MaterialPageRoute<T>(builder: (context) => screen),
    );
  }

  /// Navigate to a new screen and replace the current screen
  static Future<T?> navigateToReplacement<T>(Widget screen) async {
    return await Navigator.of(navigatorKey.currentContext!).pushReplacement<T, void>(
      MaterialPageRoute<T>(builder: (context) => screen),
    );
  }

  /// Navigate to a new screen and clear the navigation stack
  static Future<T?> navigateToAndClear<T>(Widget screen) async {
    return await Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil<T>(
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
  static Future<T?> navigateToNamed<T>(String routeName, {Object? arguments}) async {
    return await Navigator.of(navigatorKey.currentContext!).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and replace the current screen
  static Future<T?> navigateToNamedReplacement<T>(String routeName, {Object? arguments}) async {
    return await Navigator.of(navigatorKey.currentContext!).pushReplacementNamed<T, void>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and clear the navigation stack
  static Future<T?> navigateToNamedAndClear<T>(String routeName, {Object? arguments}) async {
    return await Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}

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
  static const String signin = '/signin';
  static const String signin1 = '/signin1';
  static const String signin2 = '/signin2';
  static const String createAccount = '/create-account';
  static const String forgotPassword = '/forgot-password';
  static const String enterCode = '/enter-code';
  static const String enterNewPassword = '/enter-new-password';

  // Main app screens
  static const String home = '/home';
  static const String searchJob = '/search-job';
  static const String searchResult = '/search-result';
  static const String jobDetails = '/job-details';
  static const String jobStep1 = '/job-step1';
  static const String jobStep2 = '/job-step2';
  static const String jobStep3 = '/job-step3';
  static const String location1 = '/location1';
  static const String location2 = '/location2';
  static const String profile = '/profile';
  static const String userProfile = '/user-profile';
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
      case RouteNames.signin:
        return MaterialPageRoute(builder: (_) => const SigninScreen());
      case RouteNames.signin1:
        return MaterialPageRoute(builder: (_) => const Signin1Screen());
      case RouteNames.signin2:
        return MaterialPageRoute(builder: (_) => const Signin2Screen());
      case RouteNames.createAccount:
        return MaterialPageRoute(builder: (_) => const CreateAccountScreen());
      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case RouteNames.enterCode:
        return MaterialPageRoute(builder: (_) => const EnterCodeScreen());
      case RouteNames.enterNewPassword:
        return MaterialPageRoute(builder: (_) => const EnterNewPasswordScreen());
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteNames.searchJob:
        return MaterialPageRoute(builder: (_) => const SearchJobScreen());
      case RouteNames.searchResult:
        return MaterialPageRoute(builder: (_) => const SearchResultScreen());
      case RouteNames.jobDetails:
        // Pass a default job object for now - in real app, this would come from arguments
        final job = args as Map<String, dynamic>? ?? JobData.recommendedJobs.first;
        return MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job));
      case RouteNames.jobStep1:
        // Pass a default job object for now - in real app, this would come from arguments
        final job = args as Map<String, dynamic>? ?? JobData.recommendedJobs.first;
        return MaterialPageRoute(builder: (_) => JobStep1Screen(job: job));
      case RouteNames.jobStep2:
        // Pass a default job object for now - in real app, this would come from arguments
        final job = args as Map<String, dynamic>? ?? JobData.recommendedJobs.first;
        return MaterialPageRoute(builder: (_) => JobStep2Screen(job: job));
      case RouteNames.jobStep3:
        // Pass a default job object for now - in real app, this would come from arguments
        final job = args as Map<String, dynamic>? ?? JobData.recommendedJobs.first;
        return MaterialPageRoute(builder: (_) => JobStep3Screen(job: job));
      case RouteNames.location1:
        return MaterialPageRoute(builder: (_) => const Location1Screen());
      case RouteNames.location2:
        return MaterialPageRoute(builder: (_) => const Location2Screen());
      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case RouteNames.userProfile:
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());
      default:
        // If there is no such named route, return an error page
        return _errorRoute();
    }
  }

  /// Error route for undefined routes
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Route not found!'),
        ),
      );
    });
  }
}