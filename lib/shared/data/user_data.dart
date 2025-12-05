class UserData {
  /// Current user profile information
  /// This is fallback data - real data comes from API
  static const Map<String, dynamic> currentUser = {
    "id": null,
    "name": null,
    "email": null,
    "phone": null,
    "profileImage": null,
    "location": null,
    "experience": null,
    "education": null,
    "skills": [],
    "preferredJobTypes": [],
    "preferredLocation": null,
    "expectedSalary": null,
    "dateOfBirth": null,
    "gender": null,
    "address": null,
  };

  /// User's saved jobs (job IDs)
  static const List<String> savedJobIds = [];

  /// User's applied jobs with application status
  static const List<Map<String, dynamic>> appliedJobs = [];

  /// User's notification preferences
  static const Map<String, bool> notificationPreferences = {
    "jobAlerts": true,
    "applicationUpdates": true,
    "messages": true,
    "promotional": false,
  };

  /// User's search history
  static const List<String> searchHistory = [];

  /// Demo login credentials (for testing purposes)
  static const Map<String, String> demoCredentials = {
    "email": "demo@jobsahi.com",
    "password": "demo123",
    "otp": "123456",
  };

  /// Available login methods
  static const List<String> loginMethods = [
    "OTP",
    "Email",
    "Google",
    "LinkedIn",
  ];

  /// User's course enrollments (for future implementation)
  static const List<Map<String, dynamic>> enrolledCourses = [];

  /// User's messages (for future implementation)
  static const List<Map<String, dynamic>> messages = [];

  /// Available skill tests
  static const List<Map<String, dynamic>> availableSkillTests = [];

  /// User's test history
  static const List<Map<String, dynamic>> userTestHistory = [];
}
