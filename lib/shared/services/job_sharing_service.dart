import 'package:share_plus/share_plus.dart';

/// Service for generating and sharing job links
class JobSharingService {
  // Private constructor to prevent instantiation
  JobSharingService._();

  /// Singleton instance
  static final JobSharingService instance = JobSharingService._();

  /// Base URL for shareable links
  /// Using jobsahi.com domain which matches Android App Links configuration
  /// Format: https://jobsahi.com/jobs/details/{jobId}
  /// This will open the app directly if installed (via App Links),
  /// or open in browser if app is not installed
  static const String _baseUrl = 'https://jobsahi.com/jobs/details';

  /// Generate a shareable link for a job
  ///
  /// The link format will be: https://jobsahi.com/jobs/details/{jobId}
  /// When clicked, it will open the app directly if installed (via Android App Links),
  /// or open in browser if the app is not installed
  String generateJobLink(String jobId) {
    return '$_baseUrl/$jobId';
  }

  /// Truncate description to maximum 3 lines
  String _truncateDescription(String description, {int maxLines = 3}) {
    final lines = description.split('\n');

    // If description has newlines, limit to maxLines
    if (lines.length > maxLines) {
      final truncated = lines.take(maxLines).join('\n');
      return '$truncated...';
    }

    // If single line but too long, truncate to ~200 characters (approx 3 lines)
    if (lines.length == 1 && description.length > 200) {
      return '${description.substring(0, 200)}...';
    }

    return description;
  }

  /// Share a job link
  ///
  /// Opens the native share dialog with the job link and title
  /// Uses web URL that works with Android App Links to open the app directly if installed
  Future<void> shareJob({
    required String jobId,
    required String jobTitle,
    String? companyName,
    String? salary,
    String? location,
    String? experienceRequired,
    String? jobType,
    String? vacancies,
    String? description,
  }) async {
    try {
      final link = generateJobLink(jobId);

      // Build professional and promotional message with formatting
      final buffer = StringBuffer();

      // Professional header
      // buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('💼 *EXCITING JOB OPPORTUNITY*\n');
      // buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // Job Title (prominent)
      buffer.writeln('*$jobTitle*');

      // Company Name (prominent)
      if (companyName != null && companyName.isNotEmpty) {
        buffer.writeln('🏢 *Company:* $companyName\n');
      } else {
        buffer.writeln('');
      }

      // Job Description (3 lines max)
      if (description != null && description.isNotEmpty) {
        final truncatedDesc = _truncateDescription(description.trim());
        buffer.writeln(truncatedDesc);
        buffer.writeln('');
      }

      // Key Highlights Section
      buffer.writeln('✨ *KEY HIGHLIGHTS:*\n');

      // Salary
      if (salary != null &&
          salary.isNotEmpty &&
          salary.toLowerCase() != 'not specified') {
        buffer.writeln('💰 *Competitive Salary:* $salary');
      }

      // Location
      if (location != null &&
          location.isNotEmpty &&
          location.toLowerCase() != 'location not specified') {
        buffer.writeln('*Location:* $location');
      }

      // Experience Required
      if (experienceRequired != null && experienceRequired.isNotEmpty) {
        buffer.writeln('*Experience Required:* $experienceRequired');
      }

      // Job Type
      if (jobType != null && jobType.isNotEmpty) {
        buffer.writeln('*Job Type:* $jobType');
      }

      // Vacancies
      if (vacancies != null && vacancies.isNotEmpty) {
        buffer.writeln('*Open Positions:* $vacancies');
      }

      buffer.writeln(''); // Empty line

      // Promotional call to action
      buffer.writeln('*Don\'t miss out on this opportunity!*\n');

      // Link section
      buffer.writeln('🚀 *Apply Now:*');
      buffer.writeln(link);
      buffer.writeln('');

      // Professional closing
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('_Powered by Satpuda group of education_');
      buffer.writeln('_Download the Jobsahi app for more opportunities_');
      // buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final result = await Share.share(
        buffer.toString(),
        subject: 'Job Opportunity: $jobTitle',
      );

      // Check if sharing was successful
      if (result.status == ShareResultStatus.dismissed) {
        // User dismissed the share dialog - this is fine, not an error
        return;
      }
    } catch (e) {
      // Re-throw with more context
      throw Exception('Failed to share job: ${e.toString()}');
    }
  }

  /// Generate deep link for app (custom URL scheme)
  /// This will be used for in-app deep linking
  String generateDeepLink(String jobId) {
    return 'jobsahi://job/$jobId';
  }

  /// Extract job ID from a shareable link
  ///
  /// Supports both web URLs and deep links
  String? extractJobIdFromLink(String link) {
    try {
      // Handle web URLs: https://jobsahi.com/jobs/details/{id}
      if (link.contains('/jobs/details/')) {
        final parts = link.split('/jobs/details/');
        if (parts.length > 1) {
          // Remove any query parameters or fragments
          final jobId = parts[1].split('?')[0].split('#')[0].trim();
          return jobId.isNotEmpty ? jobId : null;
        }
      }

      // Handle legacy format: https://jobsahi.app/job/{id} or /job/{id}
      if (link.contains('/job/')) {
        final parts = link.split('/job/');
        if (parts.length > 1) {
          // Remove any query parameters or fragments
          final jobId = parts[1].split('?')[0].split('#')[0].trim();
          return jobId.isNotEmpty ? jobId : null;
        }
      }

      // Handle deep links: jobsahi://job/{id}
      if (link.contains('jobsahi://job/')) {
        final parts = link.split('jobsahi://job/');
        if (parts.length > 1) {
          final jobId = parts[1].split('?')[0].split('#')[0].trim();
          return jobId.isNotEmpty ? jobId : null;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
