class UserData {
  /// Current user profile information
  static const Map<String, dynamic> currentUser = {
    "id": "user_001",
    "name": "Rahul Kumar",
    "email": "rahul.kumar@email.com",
    "phone": "+91 98765 43210",
    "profileImage": "assets/images/profile/profile_img.png",
    "location": "Mumbai, Maharashtra",
    "experience": "2 years",
    "education": "12th Pass",
    "skills": ["Electrician", "Basic Electronics", "Safety Protocols"],
    "preferredJobTypes": ["Full-Time", "Apprenticeship"],
    "preferredLocation": "Mumbai, Pune, Nashik",
    "expectedSalary": "₹1.5L - ₹2.5L P.A.",
    "dateOfBirth": "1998-05-15",
    "gender": "Male",
    "address": "123, ABC Colony, Mumbai - 400001",
  };

  /// User's saved jobs (job IDs)
  static const List<String> savedJobIds = ["1", "4"];

  /// User's applied jobs with application status
  static const List<Map<String, dynamic>> appliedJobs = [
    {
      "jobId": "5",
      "applicationDate": "2024-01-15",
      "status": "Under Review",
      "company": "WaterWorks Ltd",
      "position": "प्लंबर अप्रेंटिस",
    },
    {
      "jobId": "2",
      "applicationDate": "2024-01-10",
      "status": "Shortlisted",
      "company": "TechMech Pvt Ltd",
      "position": "फिटर अप्रेंटिस",
    },
  ];

  /// User's notification preferences
  static const Map<String, bool> notificationPreferences = {
    "jobAlerts": true,
    "applicationUpdates": true,
    "messages": true,
    "promotional": false,
  };

  /// User's search history
  static const List<String> searchHistory = [
    "Electrician jobs",
    "Fitter apprenticeship",
    "Welder training",
    "Mechanic jobs in Mumbai",
  ];

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
  static const List<Map<String, dynamic>> enrolledCourses = [
    {
      "id": "course_001",
      "title": "Basic Electrical Safety",
      "progress": 75,
      "totalLessons": 12,
      "completedLessons": 9,
    },
    {
      "id": "course_002",
      "title": "Welding Fundamentals",
      "progress": 30,
      "totalLessons": 8,
      "completedLessons": 2,
    },
  ];

  /// User's messages (for future implementation)
  static const List<Map<String, dynamic>> messages = [
    {
      "id": "msg_001",
      "sender": "VoltX Energy",
      "subject": "Application Update",
      "message": "Your application has been shortlisted for the next round.",
      "timestamp": "2024-01-20T10:30:00Z",
      "isRead": false,
    },
    {
      "id": "msg_002",
      "sender": "TechMech Pvt Ltd",
      "subject": "Interview Schedule",
      "message":
          "Please confirm your availability for the interview on 25th January.",
      "timestamp": "2024-01-19T14:15:00Z",
      "isRead": true,
    },
  ];
}
