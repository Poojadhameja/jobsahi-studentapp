import 'package:flutter/material.dart';

class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  /// App Colors
  static const Color primaryColor = Color(0xFF0B537D);
  static const Color secondaryColor = Color(0xFF5C9A24);
  static const Color accentColor = Color(0xFF0B537D);
  static const Color locationAccentColor = Color(0xFF0B537D);
  static const Color backgroundColor = Color(0xFFF5F9FC);
  static const Color cardBackgroundColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF0B537D);
  static const Color textSecondaryColor = Colors.black54;
  static const Color borderColor = Color.fromARGB(44, 11, 83, 125);
  static const Color successColor = Color(0xFF5C9A24);
  static const Color warningColor = Colors.orange;
  static const Color errorColor = Colors.red;

  /// Bottom Navigation Colors
  static const Color bottomNavActiveColor = Color(
    0xFF0B537D,
  ); // Dark blue for active tab
  static const Color bottomNavInactiveColor = Color(
    0xFF6680B5,
  ); // Light blue-grey for inactive tab

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
  static const String appName = 'Jobsahi';
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
  static const String recommendedJobsText = 'Jobs (नौकरियाँ)';
  static const String applyJobText = 'Apply This Job';
  static const String saveText = 'Save';
  static const String savedText = 'Saved';

  /// Navigation Labels
  static const String homeLabel = 'Home';
  static const String coursesLabel = 'Courses';
  static const String applicationsLabel = 'Application Tracker';
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
  static const String saveChangesText = 'Save';

  /// Error Messages
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String phoneRequired = 'Phone number is required';
  static const String invalidPhone =
      'Please enter a valid 10-digit phone number';
  static const String phoneLengthError =
      'Phone number must be exactly 10 digits';
  static const String phoneNumbersOnly =
      'Phone number must contain only numbers';
  static const String phoneAlreadyExists =
      'Phone number already exists. Please use a different number';
  static const String emailAlreadyExists =
      'Email already exists. Please use a different email';
  static const String emailAlreadyExistsComprehensive =
      'Email already exists. Please check if both email and phone number are already registered and use different values';
  static const String bothAlreadyExists =
      'Email and phone number both are already registered. Please use different email and phone number';
  static const String otpRequired = 'OTP is required';
  static const String invalidOtp = 'Please enter a valid OTP';
  static const String nameRequired = 'Name is required';
  static const String nameTooShort = 'Name must be at least 3 characters';
  static const String lastNameRequired = 'Last name is required';
  static const String nameLettersOnly =
      'Name must contain only letters and spaces';
  static const String passwordsDoNotMatch = 'Passwords do not match';

  /// Role-based Access Control Messages
  static const String accessDeniedNonStudent =
      'Access denied. This app is only for students.';
  static const String invalidUserRole =
      'Invalid user role. Only students can access this app.';
  static const String roleVerificationFailed =
      'Unable to verify user role. Please contact support.';
  static const String userDoesNotExist =
      'User does not exist, please sign up first';

  /// Success Messages
  static const String loginSuccess = 'Login successful';
  static const String signupSuccess =
      'Account created successfully! Welcome to Jobsahi! 🎉';
  static const String otpSent = 'OTP sent successfully';
  static const String passwordReset = 'Password reset successfully';
  static const String jobSaved = 'Job saved successfully';
  static const String jobApplied = 'Job application submitted successfully';
  static const String preferencesSaved = 'Preferences saved successfully!';
  static const String preferencesSavedHindi =
      'प्राथमिकताएं सफलतापूर्वक सहेजी गईं!';

  /// Personalize Jobfeed Section Titles
  static const String selectTradeTitle = 'Select your trade:';
  static const String selectTradeTitleHindi = 'अपना व्यापार चुनें:';
  static const String preferredLocationTitle = 'Preferred Job location:';
  static const String preferredLocationTitleHindi = 'पसंदीदा नौकरी का स्थान:';
  static const String jobSectorTitle = 'Preferred job sector:';
  static const String jobSectorTitleHindi = 'पसंदीदा नौकरी क्षेत्र:';
  static const String jobTypeTitle = 'Job type:';
  static const String jobTypeTitleHindi = 'नौकरी का प्रकार:';
  static const String availabilityTitle = 'Availability:';
  static const String availabilityTitleHindi = 'उपलब्धता:';
  static const String skillsTitle = 'Skills keyword:';
  static const String skillsTitleHindi = 'कौशल कीवर्ड:';
  static const String salaryRangeTitle = 'Expected salary range:';
  static const String salaryRangeTitleHindi = 'अपेक्षित वेतन सीमा:';
  static const String addSkillsHint = 'Add skills...';
  static const String addSkillsHintHindi = 'कौशल जोड़ें...';

  /// Availability Options
  static const String immediatelyAvailable = 'Immediately available';
  static const String withinOneMonth = 'Within 1 month';

  /// Loading Messages
  static const String loadingText = 'Loading...';
  static const String sendingOtp = 'Sending OTP...';
  static const String verifyingOtp = 'Verifying OTP...';
  static const String submittingApplication = 'Submitting application...';

  /// Time Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDuration = Duration(milliseconds: 500);

  /// Inactivity timeout - 30 days for production
  static const Duration inactivityTimeout = Duration(days: 30);

  /// User Roles
  static const String studentRole = 'student';

  /// API Endpoints
  /// Local development base URL
  // static const String baseUrl = 'http://localhost/jobsahi-API/api/';

  /// Production server base URL
  static const String baseUrl = 'https://beige-jaguar-560051.hostingersite.com/api';

  /// Use device-to-PC LAN IP if testing on a real device
  // static const String lanBaseUrl = 'http://10.167.188.31:8000/api';

  // Auth
  static const String createUserEndpoint = '/user/create_user.php';
  static const String loginEndpoint = '/auth/login.php';

  // Location
  static const String updateLocationEndpoint =
      '/student/set_current_location.php';

  // Student Profile
  static const String studentProfileEndpoint = '/student/profile.php';

  // Other (placeholders)
  static const String signupEndpoint = '/auth/signup';
  static const String jobsEndpoint = '/jobs';
  static const String profileEndpoint = '/user/profile';

  /// Course Categories
  static const List<String> courseCategories = [
    'All',
    'Electrical',
    'Mechanical',
    'Welding',
    'Machining',
    'Turning',
    'Woodwork',
    'Plumbing',
    'Drafting',
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
    'All',
    'Engineering',
    'Mechanical Engineering',
    'Electrical Engineering',
    'Civil Engineering',
    'Computer Science',
    'Electronics Engineering',
    'Chemical Engineering',
    'Aerospace Engineering',
    'Automobile Engineering',
    'IT/Software',
    'Software Development',
    'Web Development',
    'Mobile Development',
    'Data Science',
    'AI/ML',
    'Cybersecurity',
    'Cloud Computing',
    'DevOps',
    'Manufacturing',
    'Production',
    'Quality Control',
    'Quality Assurance',
    'Maintenance',
    'Welding',
    'Machining',
    'CNC',
    'Tool Making',
    'Fabrication',
    'Assembly',
    'Design',
    'CAD/CAM',
    'Project Management',
    'Supply Chain',
    'Logistics',
    'Healthcare',
    'Education',
    'Finance',
    'Banking',
    'Insurance',
    'Marketing',
    'Digital Marketing',
    'Sales',
    'Business Development',
    'HR',
    'Administration',
    'General',
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
