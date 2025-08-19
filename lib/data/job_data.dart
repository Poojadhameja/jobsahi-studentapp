/// Mock data for jobs - This file contains all the job-related data

library;

import '../../utils/app_constants.dart';

class JobData {
  /// List of recommended jobs displayed on the home screen
  static const List<Map<String, dynamic>> recommendedJobs = [
    {
      "id": "1",
      "title": "इलेक्ट्रिशियन अप्रेंटिस",
      "company": "VoltX Energy",
      "rating": 4.7,
      "tags": ["Full-Time", "Apprenticeship"],
      "salary": "₹1.2L – ₹1.8L P.A.",
      "location": "Nashik, India",
      "time": "3 दिन पहले",
      "logo": "assets/images/company/group.png",
      "description":
          "We are looking for an enthusiastic Electrician Apprentice to join our team...",
      "requirements": [
        "10th or 12th pass",
        "Basic knowledge of electrical systems",
        "Willingness to learn",
        "Good communication skills",
      ],
      "benefits": [
        "On-the-job training",
        "Health insurance",
        "Performance bonuses",
        "Career growth opportunities",
      ],
    },
    {
      "id": "2",
      "title": "फिटर अप्रेंटिस",
      "company": "TechMech Pvt Ltd",
      "rating": 4.3,
      "tags": ["Full-Time", "Apprenticeship"],
      "salary": "₹1.5L – ₹2.0L P.A.",
      "location": "Pune, India",
      "time": "2 दिन पहले",
      "logo": "assets/images/company/group.png",
      "description":
          "Join our mechanical team as a Fitter Apprentice and learn from experienced professionals...",
      "requirements": [
        "ITI in Fitter trade",
        "Basic mechanical knowledge",
        "Team player",
        "Safety conscious",
      ],
      "benefits": [
        "Comprehensive training",
        "Competitive salary",
        "Transport allowance",
        "Professional development",
      ],
    },
    {
      "id": "3",
      "title": "वेल्डर अप्रेंटिस",
      "company": "SteelWorks Ltd",
      "rating": 4.6,
      "tags": ["Full-Time", "Training"],
      "salary": "₹1.0L – ₹1.5L P.A.",
      "location": "Mumbai, India",
      "time": "1 दिन पहले",
      "logo": "assets/images/company/group.png",
      "description":
          "Learn the art of welding with our expert team in a safe and professional environment...",
      "requirements": [
        "10th pass minimum",
        "Interest in welding",
        "Physical fitness",
        "Attention to detail",
      ],
      "benefits": [
        "Certified training program",
        "Safety equipment provided",
        "Overtime opportunities",
        "Skill certification",
      ],
    },
  ];

  /// List of saved jobs (for demonstration purposes)
  static const List<Map<String, dynamic>> savedJobs = [
    {
      "id": "4",
      "title": "मैकेनिक अप्रेंटिस",
      "company": "AutoCare Solutions",
      "rating": 4.5,
      "tags": ["Full-Time", "Training"],
      "salary": "₹1.3L – ₹1.7L P.A.",
      "location": "Delhi, India",
      "time": "5 दिन पहले",
      "logo": "assets/images/company/group.png",
    },
  ];

  /// List of applied jobs (for demonstration purposes)
  static const List<Map<String, dynamic>> appliedJobs = [
    {
      "id": "5",
      "title": "प्लंबर अप्रेंटिस",
      "company": "WaterWorks Ltd",
      "rating": 4.2,
      "tags": ["Full-Time", "Apprenticeship"],
      "salary": "₹1.1L – ₹1.6L P.A.",
      "location": "Bangalore, India",
      "time": "1 सप्ताह पहले",
      "logo": "assets/images/company/group.png",
      "status": "Under Review",
    },
  ];

  /// Filter options for job search
  static List<String> get filterOptions => AppConstants.jobFilterOptions;

  /// Job categories for filtering
  static List<String> get jobCategories => AppConstants.jobCategories;

  /// Experience levels
  static List<String> get experienceLevels => AppConstants.experienceLevels;

  /// Salary ranges
  static List<String> get salaryRanges => AppConstants.salaryRanges;
}
