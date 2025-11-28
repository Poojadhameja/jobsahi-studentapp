/// App Routes Constants
/// Centralized route paths for deep linking and navigation
/// All routes are designed to be SEO-friendly and support deep linking
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // ==================== AUTHENTICATION ROUTES ====================
  /// Splash screen - initial loading screen
  static const String splash = '/splash';

  /// Onboarding screen - app introduction
  static const String onboarding = '/onboarding';

  /// Login with OTP email
  static const String loginOtpEmail = '/auth/login';

  /// Login with OTP code verification
  static const String loginOtpCode = '/auth/verify';

  /// Login verified success popup
  static const String loginVerifiedPopup = '/auth/verified';

  /// Create new account
  static const String createAccount = '/auth/create-account';

  /// Create account success popup
  static const String createAccountPopup = '/auth/create-account-popup';

  /// Forgot password
  static const String forgotPassword = '/auth/forgot-password';

  /// Set password code verification
  static const String setPasswordCode = '/auth/set-password-code';

  /// Set new password
  static const String setNewPassword = '/auth/set-new-password';

  /// Change password
  static const String changePassword = '/auth/change-password';

  // ==================== MAIN APP ROUTES ====================
  /// Home screen - main dashboard
  static const String home = '/home';

  /// Learning center - courses overview
  static const String learning = '/learning';

  /// Application tracker
  static const String applicationTracker = '/application-tracker';

  /// Messages inbox
  static const String messages = '/messages';

  /// Profile menu screen
  static const String profile = '/profile/menu';

  /// Profile details screen
  static const String profileDetails = '/profile/details';

  /// Personalize job feed
  static const String personalizeJobfeed = '/profile/personalize';

  /// Job status tracking
  static const String jobStatus = '/profile/job-status';

  /// User location setup
  static const String yourLocation = '/profile/location';

  /// Location permission screen
  static const String locationPermission = '/profile/location/permission';

  /// Profile builder step 1
  static const String profileBuilderStep1 = '/profile/builder/step1';

  /// Profile builder step 2
  static const String profileBuilderStep2 = '/profile/builder/step2';

  /// Profile builder step 3
  static const String profileBuilderStep3 = '/profile/builder/step3';

  // ==================== JOBS ROUTES ====================
  /// Job details screen with dynamic ID
  static const String jobDetails = '/jobs/details/:id';

  /// Saved jobs
  static const String savedJobs = '/jobs/saved';

  /// Calendar view for job applications
  static const String calendarView = '/jobs/applications/calendar';

  /// Write review for a job/company
  static const String writeReview = '/jobs/review/:id';

  /// About company page
  static const String aboutCompany = '/jobs/company/:id';

  /// Job application success
  static const String jobApplicationSuccess = '/jobs/application/success/:id';

  /// Job application step
  static const String jobStep = '/jobs/application/step/:id';

  /// Student application detail
  static const String studentApplicationDetail = '/application/details/:id';

  /// Interview detail
  static const String interviewDetail = '/interviews/details/:id';

  // ==================== COURSES ROUTES ====================

  /// Course details with dynamic ID
  static const String courseDetails = '/courses/:id';

  /// Saved courses
  static const String savedCourses = '/courses/saved';

  // ==================== MESSAGES ROUTES ====================

  /// Chat screen with dynamic ID
  static const String chat = '/messages/chat/:id';

  // ==================== SKILL TEST ROUTES ====================
  /// Skill test details with dynamic ID
  static const String skillTestDetails = '/skill-test/:id/details';

  /// Skill test instructions
  static const String skillTestInstructions = '/skill-test/:id/instructions';

  /// Skills test FAQ
  static const String skillsTestFAQ = '/skill-test/:id/faq';

  // ==================== SETTINGS ROUTES ====================
  /// Settings main page
  static const String settings = '/settings';

  /// About page
  static const String about = '/settings/about';
  static const String contactUs = '/settings/contact-us';

  /// Help center
  static const String helpCenter = '/settings/help';
  static const String feedback = '/settings/feedback';
  static const String faqs = '/settings/faqs';

  /// Privacy policy
  static const String privacyPolicy = '/settings/privacy';

  /// Terms and conditions
  static const String termsConditions = '/settings/terms';

  /// Notification settings (combined permission + preferences)
  static const String notificationSettings = '/settings/notifications';

  /// Notification permission (legacy - kept for backward compatibility)
  static const String notificationPermission =
      '/settings/notifications/permission';

  /// Notification preferences (legacy - kept for backward compatibility)
  static const String notificationPreferences =
      '/settings/notifications/preferences';

  /// Notification history
  static const String notificationHistory = '/settings/notifications/history';

  // ==================== FALLBACK/ERROR ROUTES ====================
  /// Not found route
  static const String notFound = '/404';

  // ==================== UTILITY METHODS ====================

  /// Generate job details route with ID
  static String jobDetailsWithId(String id) => '/jobs/details/$id';

  /// Generate course details route with ID
  static String courseDetailsWithId(String id) => '/courses/$id';

  /// Generate chat route with ID
  static String chatWithId(String id) => '/messages/chat/$id';

  /// Generate skill test details route with ID
  static String skillTestDetailsWithId(String id) => '/skill-test/$id/details';

  /// Generate skill test instructions route with ID
  static String skillTestInstructionsWithId(String id) =>
      '/skill-test/$id/instructions';

  /// Generate skill test FAQ route with ID
  static String skillTestFAQWithId(String id) => '/skill-test/$id/faq';

  /// Generate write review route with ID
  static String writeReviewWithId(String id) => '/jobs/review/$id';

  /// Generate about company route with ID
  static String aboutCompanyWithId(String id) => '/jobs/company/$id';

  /// Generate job step route with ID
  static String jobStepWithId(String id) => '/jobs/application/step/$id';

  /// Generate job application success route with ID
  static String jobApplicationSuccessWithId(String id) =>
      '/jobs/application/success/$id';

  /// Generate student application detail route with ID
  static String studentApplicationDetailWithId(String id) =>
      '/application/details/$id';

  /// Generate interview detail route with ID
  static String interviewDetailWithId(String id) => '/interviews/details/$id';
}
