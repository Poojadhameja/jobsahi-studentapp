import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import route constants
import '../constants/app_routes.dart';

// Import all screen classes
// Authentication screens
import '../../features/auth/views/splash_screen.dart';
import '../../features/auth/views/onboarding.dart';
import '../../features/auth/views/login_otp_email.dart';
import '../../features/auth/views/login_otp_code.dart';
import '../../features/auth/views/login_verified_popup.dart';
import '../../features/auth/views/create_account.dart';
import '../../features/auth/views/forgot_password.dart';
import '../../features/auth/views/set_password_code.dart';
import '../../features/auth/views/set_new_password.dart';
import '../../features/auth/views/change_password.dart';

// Main app screens
import '../../features/home/views/home.dart';
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
import '../../features/profile/views/profile.dart';
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
        builder: (context, state) => const LoginOtpEmailScreen(),
      ),

      GoRoute(
        path: AppRoutes.loginOtpCode,
        name: 'loginOtpCode',
        builder: (context, state) => const LoginOtpCodeScreen(),
      ),

      GoRoute(
        path: AppRoutes.loginVerifiedPopup,
        name: 'loginVerifiedPopup',
        builder: (context, state) => const LoginVerifiedPopupScreen(),
      ),

      GoRoute(
        path: AppRoutes.createAccount,
        name: 'createAccount',
        builder: (context, state) => const CreateAccountScreen(),
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

      // ==================== MAIN APP ROUTES ====================
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // ==================== PROFILE ROUTES ====================
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
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
          final jobId = state.pathParameters['id'] ?? '';
          // In a real app, you would fetch job data by ID
          // For now, using default job data
          final job = JobData.recommendedJobs.first;
          return JobDetailsScreen(job: job);
        },
      ),

      GoRoute(
        path: AppRoutes.savedJobs,
        name: 'savedJobs',
        builder: (context, state) => const SavedJobsScreen(),
      ),

      GoRoute(
        path: AppRoutes.applicationTracker,
        name: 'applicationTracker',
        builder: (context, state) => const ApplicationTrackerScreen(),
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
          final jobId = state.pathParameters['id'] ?? '';
          // In a real app, you would fetch job data by ID
          final job = JobData.recommendedJobs.first;
          return WriteReviewScreen(job: job);
        },
      ),

      GoRoute(
        path: AppRoutes.aboutCompany,
        name: 'aboutCompany',
        builder: (context, state) {
          final companyId = state.pathParameters['id'] ?? '';
          // In a real app, you would fetch company data by ID
          final company = JobData.companies.values.first;
          return AboutCompanyScreen(company: company);
        },
      ),

      GoRoute(
        path: AppRoutes.jobApplicationSuccess,
        name: 'jobApplicationSuccess',
        builder: (context, state) {
          // In a real app, you would fetch job data by ID
          final job = JobData.recommendedJobs.first;
          return JobApplicationSuccessScreen(job: job);
        },
      ),

      GoRoute(
        path: AppRoutes.jobStep,
        name: 'jobStep',
        builder: (context, state) {
          final stepId = state.pathParameters['id'] ?? '';
          // In a real app, you would fetch job data by ID
          final job = JobData.recommendedJobs.first;
          return JobStepScreen(job: job);
        },
      ),

      // ==================== COURSES ROUTES ====================
      GoRoute(
        path: AppRoutes.learningCenter,
        name: 'learningCenter',
        builder: (context, state) => const LearningCenterPage(),
      ),

      GoRoute(
        path: AppRoutes.courseDetails,
        name: 'courseDetails',
        builder: (context, state) {
          final courseId = state.pathParameters['id'] ?? '';
          // In a real app, you would fetch course data by ID
          final course = <String, dynamic>{}; // Default empty course
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
        path: AppRoutes.inbox,
        name: 'inbox',
        builder: (context, state) => const InboxScreen(),
      ),

      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) {
          final chatId = state.pathParameters['id'] ?? '';
          // In a real app, you would fetch company data by ID
          final company = JobData.companies.values.first;
          return ChatScreen(company: company);
        },
      ),

      // ==================== SKILL TEST ROUTES ====================
      GoRoute(
        path: AppRoutes.skillTestDetails,
        name: 'skillTestDetails',
        builder: (context, state) {
          final testId = state.pathParameters['id'] ?? '';
          // In a real app, you would fetch test data by ID
          final job = JobData.recommendedJobs.first;
          return SkillTestDetailsScreen(job: job);
        },
      ),

      GoRoute(
        path: AppRoutes.skillTestInstructions,
        name: 'skillTestInstructions',
        builder: (context, state) {
          final testId = state.pathParameters['id'] ?? '';
          // In a real app, you would fetch test data by ID
          final job = JobData.recommendedJobs.first;
          final test = <String, dynamic>{}; // Default empty test
          return SkillTestInstructionsScreen(job: job, test: test);
        },
      ),

      GoRoute(
        path: AppRoutes.skillsTestFAQ,
        name: 'skillsTestFAQ',
        builder: (context, state) {
          final testId = state.pathParameters['id'] ?? '';
          // In a real app, you would fetch test data by ID
          final job = JobData.recommendedJobs.first;
          final test = <String, dynamic>{}; // Default empty test
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
