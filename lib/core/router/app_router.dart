import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import route constants
import '../constants/app_routes.dart';

// Import services for authentication check
import '../../shared/services/token_storage.dart';
import '../../shared/services/inactivity_service.dart';
import '../di/injection_container.dart';

// Import all screen classes
// Authentication screens
import '../../features/auth/views/splash_screen.dart';
import '../../features/auth/views/onboarding.dart';
import '../../features/auth/views/login_otp_email.dart';
import '../../features/auth/views/login_otp_code.dart';
import '../../features/auth/views/create_account.dart';
import '../../features/auth/views/success_popup.dart';
import '../../features/auth/views/forgot_password.dart';
import '../../features/auth/views/set_password_code.dart';
import '../../features/auth/views/set_new_password.dart';
import '../../features/auth/views/change_password.dart';

// Main app screens
import '../../features/home/views/home.dart';

// Import MainScaffold for ShellRoute
import '../../shared/widgets/common/main_scaffold.dart';
import '../../features/jobs/views/search_job.dart';
import '../../features/jobs/views/search_result.dart';
import '../../features/jobs/views/job_details.dart';
import '../../features/jobs/views/saved_jobs.dart';
import '../../features/jobs/views/application_tracker.dart';
import '../../features/jobs/views/calendar_view.dart';
import '../../features/jobs/views/write_review.dart';
import '../../features/jobs/views/about_company.dart';
import '../../features/jobs/views/job_application_success.dart';
import '../../features/jobs/views/job_step.dart';

// Profile screens
import '../../features/profile/views/your_location.dart';
import '../../features/profile/views/location_permission.dart';
import '../../features/profile/views/profile_builder_steps.dart';
import '../../features/profile/views/menu.dart';
import '../../features/profile/views/profile_details.dart';
import '../../features/profile/views/job_status.dart';
import '../../features/profile/views/personalize_jobfeed.dart';
import '../../features/profile/views/profile_details/profile_edit.dart';
import '../../features/profile/views/profile_details/experience_edit.dart';
import '../../features/profile/views/profile_details/education_edit.dart';
import '../../features/profile/views/profile_details/skills_edit.dart';
import '../../features/profile/views/profile_details/certificates_edit.dart';
import '../../features/profile/views/profile_details/resume_edit.dart';
import '../../features/profile/views/profile_details/profile_summary_edit.dart';

// Settings screens
import '../../features/settings/views/settings.dart';
import '../../features/settings/views/about_page.dart';
import '../../features/settings/views/help_center.dart';
import '../../features/settings/views/privacy_policy.dart';
import '../../features/settings/views/terms_conditions.dart';
import '../../features/settings/views/notification_permission.dart';

// Course screens
import '../../features/courses/views/learning_center.dart';
import '../../features/courses/views/course_details.dart';
import '../../features/courses/views/saved_courses.dart';

// Messages screens
import '../../features/messages/views/inbox_screen.dart';
import '../../features/messages/views/chat_screen.dart';

// Skill test screens
import '../../features/skill_test/views/skill_test_details.dart';
import '../../features/skill_test/views/skill_test_instructions.dart';
import '../../features/skill_test/views/skills_test_faq.dart';

// Import data classes
import '../../shared/data/job_data.dart';

/// App Router Configuration
/// Handles all navigation and deep linking for the app
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  /// Global router instance
  static final GoRouter _router = GoRouter(
    // Initial location when app starts
    initialLocation: AppRoutes.splash,

    // Debug logging for development
    debugLogDiagnostics: true,

    // Refresh listenable - will rebuild router when auth state changes
    refreshListenable: AuthStateNotifier.instance,

    // Central redirect to validate authentication and deep-link params
    redirect: (context, state) async {
      final path = state.uri.path;

      // Public routes that don't require authentication
      const publicPaths = {
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.loginOtpEmail,
        AppRoutes.loginOtpCode,
        AppRoutes.loginVerifiedPopup,
        AppRoutes.createAccount,
        AppRoutes.createAccountPopup,
        AppRoutes.forgotPassword,
        AppRoutes.setPasswordCode,
        AppRoutes.setNewPassword,
        AppRoutes.changePassword,
      };

      // Check if current path is a public route
      final isPublicRoute = publicPaths.contains(path);

      // Get authentication status
      final tokenStorage = sl<TokenStorage>();
      final isLoggedIn = await tokenStorage.isLoggedIn();
      final hasToken = await tokenStorage.hasToken();

      // If user is logged in, check for inactivity
      if (isLoggedIn && hasToken) {
        final inactivityService = InactivityService.instance;
        final isTokenExpired = await inactivityService.isTokenExpired();

        if (isTokenExpired) {
          // Token expired due to inactivity
          await inactivityService.handleTokenExpiry(context);
          return AppRoutes.loginOtpEmail;
        } else {
          // Update last active timestamp for current activity
          await inactivityService.updateLastActive();
        }
      }

      // If user is not logged in and trying to access protected route
      if (!isLoggedIn || !hasToken) {
        // Clear invalid session data
        if (!hasToken && isLoggedIn) {
          await tokenStorage.clearAll();
        }

        // If trying to access a protected route, redirect to login
        if (!isPublicRoute) {
          debugPrint(
            '🔒 Access denied: User not authenticated. Redirecting to login.',
          );
          return AppRoutes.loginOtpEmail;
        }
      }

      // If user is logged in and trying to access auth routes, redirect to appropriate screen
      if (isLoggedIn && hasToken && isPublicRoute && path != AppRoutes.splash) {
        // Check if trying to access auth routes (including success popups)
        const authRoutes = {
          AppRoutes.loginOtpEmail,
          AppRoutes.loginOtpCode,
          AppRoutes.loginVerifiedPopup,
          AppRoutes.createAccount,
          AppRoutes.createAccountPopup,
          AppRoutes.forgotPassword,
          AppRoutes.setPasswordCode,
          AppRoutes.setNewPassword,
          AppRoutes.changePassword,
        };

        if (authRoutes.contains(path)) {
          debugPrint(
            '🔒 Logged-in user trying to access auth route. Redirecting to location permission page.',
          );

          // Always redirect to location permission page first after login
          // This ensures all users go through location permission flow
          debugPrint(
            '🔒 Redirecting logged-in user to location permission page',
          );
          return AppRoutes.locationPermission;
        }

        return null;
      }

      // If on public route, allow access
      if (isPublicRoute) return null;

      // Validate dynamic id segments for known patterns
      if (path.startsWith('/jobs/details/')) {
        final id = state.pathParameters['id'];
        if (id == null || !_isValidId(id)) return AppRoutes.notFound;
      }
      if (path.startsWith('/jobs/review/')) {
        final id = state.pathParameters['id'];
        if (id == null || !_isValidId(id)) return AppRoutes.notFound;
      }
      if (path.startsWith('/jobs/company/')) {
        final id = state.pathParameters['id'];
        if (id == null || !_isValidId(id)) return AppRoutes.notFound;
      }
      if (path.startsWith('/jobs/application/step/')) {
        final id = state.pathParameters['id'];
        if (id == null || !_isValidId(id)) return AppRoutes.notFound;
      }
      if (path.startsWith('/courses/')) {
        final id = state.pathParameters['id'];
        if (id == null || !_isValidId(id)) return AppRoutes.notFound;
      }
      if (path.startsWith('/skill-test/')) {
        final id = state.pathParameters['id'];
        if (id == null || !_isValidId(id)) return AppRoutes.notFound;
      }

      return null;
    },

    // Error handling for unknown routes
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),

    // Route configuration
    routes: [
      // ==================== AUTHENTICATION ROUTES ====================
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      GoRoute(
        path: AppRoutes.loginOtpEmail,
        name: 'loginOtpEmail',
        builder: (context, state) {
          // Check if user came from splash (returning user) or onboarding (new user)
          final fromSplash = state.uri.queryParameters['fromSplash'] == 'true';
          return LoginOtpEmailScreen(showBackButton: !fromSplash);
        },
      ),

      GoRoute(
        path: AppRoutes.loginOtpCode,
        name: 'loginOtpCode',
        builder: (context, state) => const LoginOtpCodeScreen(),
      ),

      GoRoute(
        path: AppRoutes.loginVerifiedPopup,
        name: 'loginVerifiedPopup',
        builder: (context, state) => SuccessPopupScreen(
          title: 'Login Successful!',
          description:
              'Welcome back! You have successfully logged in. Let\'s continue your job search journey.',
          buttonText: 'Continue to App',
          navigationRoute:
              AppRoutes.home, // Will be overridden by redirect logic
        ),
      ),

      GoRoute(
        path: AppRoutes.createAccount,
        name: 'createAccount',
        builder: (context, state) => const CreateAccountScreen(),
      ),

      GoRoute(
        path: AppRoutes.createAccountPopup,
        name: 'createAccountPopup',
        builder: (context, state) => const SuccessPopupScreen(
          title: 'Account Created Successfully!',
          description:
              'Your account has been created successfully. You can now log in to access all features and start your job search journey.',
          buttonText: 'Continue',
          navigationRoute: AppRoutes.loginOtpEmail,
        ),
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: AppRoutes.setPasswordCode,
        name: 'setPasswordCode',
        builder: (context, state) => const SetPasswordCodeScreen(),
      ),

      GoRoute(
        path: AppRoutes.setNewPassword,
        name: 'setNewPassword',
        builder: (context, state) => const SetNewPasswordScreen(),
      ),

      GoRoute(
        path: AppRoutes.changePassword,
        name: 'changePassword',
        builder: (context, state) => const ChangePasswordPage(),
      ),

      // ==================== MAIN APP ROUTES WITH SHELL ROUTE ====================
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/learning',
            name: 'learning',
            builder: (context, state) => const LearningCenterPage(),
          ),
          GoRoute(
            path: '/application-tracker',
            name: 'application-tracker',
            builder: (context, state) =>
                const ApplicationTrackerScreen(isFromProfile: false),
          ),
          GoRoute(
            path: '/messages',
            name: 'messages',
            builder: (context, state) =>
                const InboxScreen(isFromProfile: false),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) =>
                const ProfileDetailsScreen(isFromBottomNavigation: true),
          ),
        ],
      ),

      // ==================== PROFILE ROUTES ====================
      GoRoute(
        path: AppRoutes.profile,
        name: 'profileMenu',
        builder: (context, state) => const MenuScreen(),
      ),

      GoRoute(
        path: AppRoutes.profileDetails,
        name: 'profileDetails',
        builder: (context, state) =>
            const ProfileDetailsScreen(isFromBottomNavigation: false),
      ),

      GoRoute(
        path: AppRoutes.profileEdit,
        name: 'profileEdit',
        builder: (context, state) => const ProfileEditScreen(),
      ),

      GoRoute(
        path: AppRoutes.profileExperienceEdit,
        name: 'profileExperienceEdit',
        builder: (context, state) => const ExperienceEditScreen(),
      ),

      GoRoute(
        path: AppRoutes.profileEducationEdit,
        name: 'profileEducationEdit',
        builder: (context, state) => const EducationEditScreen(),
      ),

      GoRoute(
        path: AppRoutes.profileSkillsEdit,
        name: 'profileSkillsEdit',
        builder: (context, state) => const SkillsEditScreen(),
      ),

      GoRoute(
        path: AppRoutes.profileCertificatesEdit,
        name: 'profileCertificatesEdit',
        builder: (context, state) => const CertificatesEditScreen(),
      ),

      GoRoute(
        path: AppRoutes.profileResumeEdit,
        name: 'profileResumeEdit',
        builder: (context, state) => const ResumeEditScreen(),
      ),

      GoRoute(
        path: AppRoutes.profileSummaryEdit,
        name: 'profileSummaryEdit',
        builder: (context, state) => const ProfileSummaryEditScreen(),
      ),

      GoRoute(
        path: AppRoutes.personalizeJobfeed,
        name: 'personalizeJobfeed',
        builder: (context, state) => const PersonalizeJobfeedScreen(),
      ),

      GoRoute(
        path: AppRoutes.jobStatus,
        name: 'jobStatus',
        builder: (context, state) => const JobStatusScreen(),
      ),

      GoRoute(
        path: AppRoutes.yourLocation,
        name: 'yourLocation',
        builder: (context, state) => const YourLocationScreen(),
      ),

      GoRoute(
        path: AppRoutes.locationPermission,
        name: 'locationPermission',
        builder: (context, state) {
          final isFromCurrentLocation =
              state.uri.queryParameters['isFromCurrentLocation'] == 'true';
          return LocationPermissionScreen(
            isFromCurrentLocation: isFromCurrentLocation,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.profileBuilderStep1,
        name: 'profileBuilderStep1',
        builder: (context, state) => const ProfileBuilderStep1Screen(),
      ),

      GoRoute(
        path: AppRoutes.profileBuilderStep2,
        name: 'profileBuilderStep2',
        builder: (context, state) {
          final selectedJobType =
              state.uri.queryParameters['selectedJobType'] ?? 'Full Time';
          return ProfileBuilderStep2Screen(selectedJobType: selectedJobType);
        },
      ),

      GoRoute(
        path: AppRoutes.profileBuilderStep3,
        name: 'profileBuilderStep3',
        builder: (context, state) {
          final selectedJobType =
              state.uri.queryParameters['selectedJobType'] ?? 'Full Time';
          final selectedExperienceLevel =
              state.uri.queryParameters['selectedExperienceLevel'] ?? 'Fresher';
          return ProfileBuilderStep3Screen(
            selectedJobType: selectedJobType,
            selectedExperienceLevel: selectedExperienceLevel,
          );
        },
      ),

      // ==================== JOBS ROUTES ====================
      GoRoute(
        path: AppRoutes.searchJob,
        name: 'searchJob',
        builder: (context, state) => const SearchJobScreen(),
      ),

      GoRoute(
        path: AppRoutes.searchResult,
        name: 'searchResult',
        builder: (context, state) => const SearchResultScreen(),
      ),

      GoRoute(
        path: AppRoutes.jobDetails,
        name: 'jobDetails',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          debugPrint('🔵 [Router] Job details route - ID from URL: $id');
          debugPrint('🔵 [Router] Full path: ${state.uri}');
          debugPrint('🔵 [Router] Path parameters: ${state.pathParameters}');
          // Create a job object with the correct ID from URL
          final job = {
            'id': id,
            'title': 'Loading...',
            'company': 'Loading...',
            'location': 'Loading...',
            'salary': 'Loading...',
            'description': 'Loading job details...',
          };
          debugPrint('🔵 [Router] Created job object: $job');
          return JobDetailsScreen(job: job);
        },
      ),

      GoRoute(
        path: AppRoutes.savedJobs,
        name: 'savedJobs',
        builder: (context, state) => const SavedJobsScreen(),
      ),

      GoRoute(
        path: AppRoutes.calendarView,
        name: 'calendarView',
        builder: (context, state) => const CalendarViewScreen(),
      ),

      GoRoute(
        path: AppRoutes.writeReview,
        name: 'writeReview',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final job = _findJobByIdOrDefault(id);
          return WriteReviewScreen(job: job);
        },
      ),

      GoRoute(
        path: AppRoutes.aboutCompany,
        name: 'aboutCompany',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final company = _findCompanyByIdOrDefault(id);
          return AboutCompanyScreen(company: company);
        },
      ),

      GoRoute(
        path: AppRoutes.jobApplicationSuccess,
        name: 'jobApplicationSuccess',
        builder: (context, state) {
          final job = JobData.recommendedJobs.first;
          return JobApplicationSuccessScreen(job: job);
        },
      ),

      GoRoute(
        path: AppRoutes.jobStep,
        name: 'jobStep',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final job = _findJobByIdOrDefault(id);
          return JobStepScreen(job: job);
        },
      ),

      // ==================== COURSES ROUTES ====================
      GoRoute(
        path: AppRoutes.courseDetails,
        name: 'courseDetails',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final course = _generateCourseById(id);
          return CourseDetailsPage(course: course);
        },
      ),

      GoRoute(
        path: AppRoutes.savedCourses,
        name: 'savedCourses',
        builder: (context, state) => const SavedCoursesPage(),
      ),

      // ==================== MESSAGES ROUTES ====================
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final company = _findCompanyByIdOrDefault(id);
          return ChatScreen(company: company);
        },
      ),

      // ==================== SKILL TEST ROUTES ====================
      GoRoute(
        path: AppRoutes.skillTestDetails,
        name: 'skillTestDetails',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final job = _findJobByIdOrDefault(id);
          return SkillTestDetailsScreen(job: job);
        },
      ),

      GoRoute(
        path: AppRoutes.skillTestInstructions,
        name: 'skillTestInstructions',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final job = _findJobByIdOrDefault(id);
          final test = <String, dynamic>{};
          return SkillTestInstructionsScreen(job: job, test: test);
        },
      ),

      GoRoute(
        path: AppRoutes.skillsTestFAQ,
        name: 'skillsTestFAQ',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final job = _findJobByIdOrDefault(id);
          final test = <String, dynamic>{};
          return SkillsTestFAQScreen(job: job, test: test);
        },
      ),

      // ==================== SETTINGS ROUTES ====================
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),

      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),

      GoRoute(
        path: AppRoutes.helpCenter,
        name: 'helpCenter',
        builder: (context, state) => const HelpCenterPage(),
      ),

      GoRoute(
        path: AppRoutes.privacyPolicy,
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),

      GoRoute(
        path: AppRoutes.termsConditions,
        name: 'termsConditions',
        builder: (context, state) => const TermsConditionsPage(),
      ),

      GoRoute(
        path: AppRoutes.notificationPermission,
        name: 'notificationPermission',
        builder: (context, state) => const NotificationPermissionPage(),
      ),

      // ==================== NOT FOUND ROUTE ====================
      GoRoute(
        path: AppRoutes.notFound,
        name: 'notFound',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'The page you are looking for does not exist.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  /// Get the router instance
  static GoRouter get router => _router;

  /// Navigate to a route with optional query parameters
  static void go(String route, {Map<String, String>? queryParameters}) {
    final uri = Uri(path: route, queryParameters: queryParameters);
    _router.go(uri.toString());
  }

  /// Push a new route onto the stack
  static void push(String route, {Map<String, String>? queryParameters}) {
    final uri = Uri(path: route, queryParameters: queryParameters);
    _router.push(uri.toString());
  }

  /// Replace the current route
  static void pushReplacement(
    String route, {
    Map<String, String>? queryParameters,
  }) {
    final uri = Uri(path: route, queryParameters: queryParameters);
    _router.pushReplacement(uri.toString());
  }

  /// Go back to the previous route
  static void pop() {
    _router.pop();
  }

  /// Check if we can go back
  static bool canPop() {
    return _router.canPop();
  }
}

// ==================== ROUTER HELPERS ====================
Map<String, dynamic> _findJobByIdOrDefault(String? id) {
  if (id == null || id.isEmpty) {
    return JobData.recommendedJobs.first;
  }

  final allJobs = <Map<String, dynamic>>[
    ...JobData.recommendedJobs,
    ...JobData.savedJobs,
    ...JobData.appliedJobs,
  ];

  final match = allJobs.cast<Map<String, dynamic>?>().firstWhere(
    (job) => job?['id']?.toString() == id,
    orElse: () => null,
  );
  return match ?? JobData.recommendedJobs.first;
}

Map<String, dynamic> _findCompanyByIdOrDefault(String? id) {
  // Try to resolve by job id to its company
  if (id != null && id.isNotEmpty) {
    final job = _findJobByIdOrDefault(id);
    final companyName = job['company']?.toString();
    if (companyName != null && JobData.companies.containsKey(companyName)) {
      return JobData.companies[companyName]!;
    }

    // Try direct company name key
    if (JobData.companies.containsKey(id)) {
      return JobData.companies[id]!;
    }

    // Try numeric index on companies list
    final index = int.tryParse(id);
    if (index != null && index >= 0 && index < JobData.companies.length) {
      return JobData.companies.values.elementAt(index);
    }
  }

  return JobData.companies.values.first;
}

Map<String, dynamic> _generateCourseById(String? id) {
  final safeId = id ?? 'unknown';
  return {
    'id': safeId,
    'title': 'Course $safeId',
    'category': 'General',
    'duration': '4 weeks',
    'fees': 0,
    'rating': 4,
    'totalRatings': 0,
    'description': 'Details for course $safeId will be loaded here.',
    'benefits': <String>[
      'Hands-on practice',
      'Mentor support',
      'Certificate of completion',
    ],
  };
}

// ==================== VALIDATION HELPERS ====================
bool _isValidId(String id) {
  // Allow URL-safe ids (letters, digits, dash, underscore), up to 64 chars
  return RegExp(r'^[A-Za-z0-9_-]{1,64}$').hasMatch(id);
}

// ==================== AUTH STATE NOTIFIER ====================
/// Notifier that triggers router refresh when authentication state changes
class AuthStateNotifier extends ChangeNotifier {
  static final AuthStateNotifier _instance = AuthStateNotifier._internal();
  static AuthStateNotifier get instance => _instance;

  AuthStateNotifier._internal();

  /// Notify listeners when auth state changes (login/logout)
  void notify() {
    notifyListeners();
  }
}
