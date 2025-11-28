/// Mock data for jobs - This file contains all the job-related data

library;

import '../../../core/utils/app_constants.dart';

class JobData {
  /// List of recommended jobs displayed on the home screen
  /// This is fallback data - real data comes from API
  static const List<Map<String, dynamic>> recommendedJobs = [];

  /// List of saved jobs (for demonstration purposes)
  /// This is fallback data - real data comes from API
  static const List<Map<String, dynamic>> savedJobs = [];

  /// List of applied jobs (for demonstration purposes)
  /// This is fallback data - real data comes from API
  static const List<Map<String, dynamic>> appliedJobs = [];

  /// Job categories for filtering
  static List<String> get jobCategories => AppConstants.jobCategories;

  /// Experience levels
  static List<String> get experienceLevels => AppConstants.experienceLevels;

  /// Salary ranges
  static const List<String> salaryRanges = [
    "Below ₹1L",
    "₹1L - ₹2L",
    "₹2L - ₹3L",
    "₹3L - ₹5L",
    "Above ₹5L",
  ];

  /// Company data
  /// This is fallback data - real data comes from API
  static const Map<String, Map<String, dynamic>> companies = {};
}
