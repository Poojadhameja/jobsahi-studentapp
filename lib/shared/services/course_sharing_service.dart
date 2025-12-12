import 'package:share_plus/share_plus.dart';

/// Service for generating and sharing course links
class CourseSharingService {
  // Private constructor to prevent instantiation
  CourseSharingService._();

  /// Singleton instance
  static final CourseSharingService instance = CourseSharingService._();

  /// Base URL for shareable links
  /// Using jobsahi.com domain which matches Android App Links configuration
  /// Format: https://jobsahi.com/courses/{courseId}
  /// This will open the app directly if installed (via App Links),
  /// or open in browser if app is not installed
  static const String _baseUrl = 'https://jobsahi.com/courses';

  /// Generate a shareable link for a course
  ///
  /// The link format will be: https://jobsahi.com/courses/{courseId}
  /// When clicked, it will open the app directly if installed (via Android App Links),
  /// or open in browser if the app is not installed
  String generateCourseLink(String courseId) {
    return '$_baseUrl/$courseId';
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

  /// Share a course link
  ///
  /// Opens the native share dialog with the course link and title
  /// Uses web URL that works with Android App Links to open the app directly if installed
  Future<void> shareCourse({
    required String courseId,
    required String courseTitle,
    String? instituteName,
    String? fees,
    String? duration,
    String? category,
    String? description,
  }) async {
    try {
      final link = generateCourseLink(courseId);

      // Build professional and promotional message with formatting
      final buffer = StringBuffer();

      // Professional header
      buffer.writeln('📚 *EXCITING COURSE OPPORTUNITY*\n');

      // Course Title (prominent)
      buffer.writeln('*$courseTitle*');

      // Institute Name (prominent)
      if (instituteName != null && instituteName.isNotEmpty) {
        buffer.writeln('🏫 *Institute:* $instituteName\n');
      } else {
        buffer.writeln('');
      }

      // Course Description (3 lines max)
      if (description != null && description.isNotEmpty) {
        final truncatedDesc = _truncateDescription(description.trim());
        buffer.writeln(truncatedDesc);
        buffer.writeln('');
      }

      // Key Highlights Section
      buffer.writeln('✨ *KEY HIGHLIGHTS:*\n');

      // Fees
      if (fees != null &&
          fees.isNotEmpty &&
          fees.toLowerCase() != 'not specified') {
        buffer.writeln('💰 *Course Fees:* $fees');
      }

      // Duration
      if (duration != null &&
          duration.isNotEmpty &&
          duration.toLowerCase() != 'duration not specified') {
        buffer.writeln('⏰ *Duration:* $duration');
      }

      // Category
      if (category != null &&
          category.isNotEmpty &&
          category.toLowerCase() != 'category not specified') {
        buffer.writeln('*Category:* $category');
      }

      buffer.writeln(''); // Empty line

      // Promotional call to action
      buffer.writeln('*Don\'t miss out on this opportunity!*\n');

      // Link section
      buffer.writeln('🚀 *Enroll Now:*');
      buffer.writeln(link);
      buffer.writeln('');

      // Professional closing
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('_Powered by Satpuda group of education_');
      buffer.writeln('_Download the Jobsahi app for more courses_');

      final result = await Share.share(
        buffer.toString(),
        subject: 'Course Opportunity: $courseTitle',
      );

      // Check if sharing was successful
      if (result.status == ShareResultStatus.dismissed) {
        // User dismissed the share dialog - this is fine, not an error
        return;
      }
    } catch (e) {
      // Re-throw with more context
      throw Exception('Failed to share course: ${e.toString()}');
    }
  }

  /// Generate deep link for app (custom URL scheme)
  /// This will be used for in-app deep linking
  String generateDeepLink(String courseId) {
    return 'jobsahi://course/$courseId';
  }

  /// Extract course ID from a shareable link
  ///
  /// Supports both web URLs and deep links
  String? extractCourseIdFromLink(String link) {
    try {
      // Handle web URLs: https://jobsahi.com/courses/{id}
      if (link.contains('/courses/')) {
        final parts = link.split('/courses/');
        if (parts.length > 1) {
          // Remove any query parameters or fragments
          final courseId = parts[1].split('?')[0].split('#')[0].trim();
          return courseId.isNotEmpty ? courseId : null;
        }
      }

      // Handle deep links: jobsahi://course/{id}
      if (link.contains('jobsahi://course/')) {
        final parts = link.split('jobsahi://course/');
        if (parts.length > 1) {
          final courseId = parts[1].split('?')[0].split('#')[0].trim();
          return courseId.isNotEmpty ? courseId : null;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
