import 'package:flutter/material.dart';

class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  /// App Colors
  static const Color primaryColor = Color(0xFF144B75);
  static const Color secondaryColor = Color(0xFF58B248);
  static const Color accentColor = Colors.blue;
  static const Color locationAccentColor = Color(0xFF4A90E2);
  static const Color backgroundColor = Color(0xFFF5F9FC);
  static const Color cardBackgroundColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF144B75);
  static const Color textSecondaryColor = Colors.black54;
  static const Color borderColor = Colors.grey;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  static const Color errorColor = Colors.red;

  /// App Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  /// App Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 20.0;

  /// App Assets - Image paths organized in the assets/images/ folder
  static const String logoAsset = 'assets/images/logo/jobsahi_logo.png';
  static const String homeBannerAsset = 'assets/images/home/home.png';
  static const String defaultCompanyLogo = 'assets/images/company/group.png';
  static const String defaultProfileImage =
      'assets/images/profile/profile_img.png';
  static const String googleLogoAsset = 'assets/images/social/google.png';
  static const String linkedinLogoAsset = 'assets/images/social/linkedin.png';
  static const String locationIconAsset = 'assets/images/location_icon.png';

  /// App Strings
  static const String appName = 'Job Sahi';
  static const String appTagline = 'Find Your Perfect Job';

  /// Location Strings
  static const String yourLocationTitle = 'Your Location';
  static const String enterLocationTitle = 'What is your Location?';
  static const String searchAreaHint = 'क्षेत्र खोजें';
  static const String useCurrentLocation = 'Use current location';
  static const String selectButton = 'Select';
  static const String searchResultLabel = 'Search Result';
  static const String nextButton = 'NEXT';
  static const String locationDescription =
      'Start location to find jobs near you';
  static const String allowLocationAccess = 'Allow Location Access';
  static const String enterLocationManually = 'Enter location Manually';
  static const String currentLocationDescription =
      'अपने पास की नौकरियों को खोजने के लिए लोकेशन शुरू करें।';
  static const String allowLocationQuestion = 'Allow Location Access?';
  static const String searchPlaceholder = 'नौकरी खोजें';
  static const String savedJobsText = 'सेव की गई नौकरियाँ';
  static const String appliedJobsText = 'आवेदन की गई नौकरियाँ';
  static const String recommendedJobsText =
      'Recommended jobs (अनुशंसित नौकरियाँ)';
  static const String applyJobText = 'Apply This Job';
  static const String saveText = 'Save';
  static const String savedText = 'Saved';

  /// Navigation Labels
  static const String homeLabel = 'Home';
  static const String coursesLabel = 'Courses';
  static const String applicationsLabel = 'Applications';
  static const String messagesLabel = 'Messages';
  static const String profileLabel = 'Profile';

  /// Form Labels
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String phoneLabel = 'Phone Number';
  static const String otpLabel = 'OTP';
  static const String nameLabel = 'Full Name';
  static const String confirmPasswordLabel = 'Confirm Password';

  /// Button Texts
  static const String loginText = 'Login';
  static const String signupText = 'Sign Up';
  static const String forgotPasswordText = 'Forgot Password?';
  static const String resendOtpText = 'Resend OTP';
  static const String verifyText = 'Verify';
  static const String submitText = 'Submit';
  static const String cancelText = 'Cancel';
  static const String saveChangesText = 'Save Changes';

  /// Error Messages
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String phoneRequired = 'Phone number is required';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String otpRequired = 'OTP is required';
  static const String invalidOtp = 'Please enter a valid OTP';
  static const String nameRequired = 'Name is required';
  static const String passwordsDoNotMatch = 'Passwords do not match';

  /// Success Messages
  static const String loginSuccess = 'Login successful';
  static const String signupSuccess = 'Account created successfully';
  static const String otpSent = 'OTP sent successfully';
  static const String passwordReset = 'Password reset successfully';
  static const String jobSaved = 'Job saved successfully';
  static const String jobApplied = 'Job application submitted successfully';

  /// Loading Messages
  static const String loadingText = 'Loading...';
  static const String sendingOtp = 'Sending OTP...';
  static const String verifyingOtp = 'Verifying OTP...';
  static const String submittingApplication = 'Submitting application...';

  /// Time Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDuration = Duration(milliseconds: 500);

  /// API Endpoints (for future use)
  static const String baseUrl = 'https://api.jobsahi.com';
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String jobsEndpoint = '/jobs';
  static const String profileEndpoint = '/user/profile';

  /// Course Categories
  static const List<String> courseCategories = [
    'All',
    'Technology',
    'Business',
    'Design',
    'Marketing',
    'Value', // For your electrician courses
  ];

  /// Course Levels
  static const List<String> courseLevels = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  /// Job Categories
  static const List<String> jobCategories = [
    'All Jobs',
    'Electrician',
    'Fitter',
    'Welder',
    'Mechanic',
    'Plumber',
    'Carpenter',
  ];

  /// Job Filter Options
  static const List<String> jobFilterOptions = [
    'Filter',
    'Sort',
    'Job Title',
    'Experience',
    'Location',
    'Salary',
    'Company',
  ];

  /// Experience Levels
  static const List<String> experienceLevels = [
    'Fresher',
    '1-2 years',
    '2-5 years',
    '5+ years',
  ];

  /// Salary Ranges
  static const List<String> salaryRanges = [
    'Below ₹1L',
    '₹1L - ₹2L',
    '₹2L - ₹3L',
    '₹3L - ₹5L',
    'Above ₹5L',
  ];
}
