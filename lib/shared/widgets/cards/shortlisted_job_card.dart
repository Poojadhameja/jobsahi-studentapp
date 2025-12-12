/// Shortlisted Job Card Widget
/// Displays shortlisted/interview scheduled job information in a card format

library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/top_snackbar.dart';

class ShortlistedJobCard extends StatelessWidget {
  /// Capitalizes the first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  final String jobTitle;
  final String companyName;
  final String location;
  final String interviewDate;
  final String interviewTime;
  final String mode;
  final String status;
  final String salary;
  final String appliedDate;
  final String appliedTime;
  final Map<String, dynamic> jobData;
  final VoidCallback? onInterviewDetailsTap;

  const ShortlistedJobCard({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.interviewDate,
    required this.interviewTime,
    required this.mode,
    required this.status,
    this.salary = '',
    this.appliedDate = '',
    this.appliedTime = '',
    required this.jobData,
    this.onInterviewDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = mode.toLowerCase() == 'online';

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, title, company, and status badge
            _buildHeader(),
            const SizedBox(height: AppConstants.smallPadding),
            // Interview mode and location (moved up)
            _buildInterviewModeLocationInfo(isOnline),
            const SizedBox(height: AppConstants.smallPadding),
            // Salary info
            if (salary.isNotEmpty) ...[
              _buildSalaryInfo(),
              const SizedBox(height: AppConstants.smallPadding),
            ],
            // Applied date and time (above interview date/time)
            if (appliedDate.isNotEmpty || appliedTime.isNotEmpty) ...[
              _buildAppliedDateTimeInfo(),
              const SizedBox(height: AppConstants.smallPadding),
            ],
            // Interview date and time
            _buildInterviewDateTimeInfo(),
            const SizedBox(height: AppConstants.smallPadding),
            // Interview Details button
            _buildInterviewActionButton(context),
          ],
        ),
      ),
    );
  }

  /// Returns icon based on job application status
  IconData _getStatusIcon(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower == 'hired' || statusLower == 'selected') {
      return Icons.celebration; // Celebration icon for hired
    } else if (statusLower == 'shortlisted') {
      return Icons.check_circle; // Check circle for shortlisted
    } else {
      return Icons.work; // Work/bag icon for applied
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Job icon - based on status
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppConstants.successColor,
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          child: Icon(_getStatusIcon(status), color: Colors.white, size: 24),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        // Job title and company - matching applied cards style
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _capitalizeFirst(jobTitle),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _capitalizeFirst(companyName),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Status badge - matching applied cards style
        // Show for both Shortlisted and Hired status
        if (status.toLowerCase() == 'shortlisted' ||
            status.toLowerCase() == 'hired' ||
            status.toLowerCase() == 'selected')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              // Shortlisted: orange, Hired: green
              color: status.toLowerCase() == 'shortlisted'
                  ? AppConstants
                        .warningColor // Orange for shortlisted
                  : AppConstants.successColor, // Green for hired
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status.toLowerCase() == 'selected' ? 'Hired' : status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInterviewDateTimeInfo() {
    // Extract job_id from jobData
    String jobId = '';
    final jobIdRaw =
        jobData['job_id'] ?? jobData['jobId'] ?? jobData['job']?['id'];
    if (jobIdRaw != null) {
      if (jobIdRaw is int) {
        jobId = jobIdRaw.toString();
      } else if (jobIdRaw is String && jobIdRaw.isNotEmpty) {
        jobId = jobIdRaw;
      } else if (jobIdRaw is num) {
        jobId = jobIdRaw.toString();
      }
    }

    // Match applied cards style - show interview date/time
    final interviewText = interviewTime.isNotEmpty
        ? 'Interview: $interviewDate at $interviewTime'
        : 'Interview: $interviewDate';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Interview date on the left
        Expanded(
          child: Text(
            interviewText,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Job ID on the right
        if (jobId.isNotEmpty)
          Text(
            'Job ID: $jobId',
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }

  /// Builds applied date/time info (similar format to interview date/time)
  Widget _buildAppliedDateTimeInfo() {
    String appliedText = '';
    if (appliedDate.isNotEmpty && appliedTime.isNotEmpty) {
      appliedText = 'Applied: $appliedDate at $appliedTime';
    } else if (appliedDate.isNotEmpty) {
      appliedText = 'Applied: $appliedDate';
    } else if (appliedTime.isNotEmpty) {
      appliedText = 'Applied: $appliedTime';
    }

    if (appliedText.isEmpty) return const SizedBox.shrink();

    return Text(
      appliedText,
      style: const TextStyle(
        fontSize: 14,
        color: AppConstants.textPrimaryColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInterviewModeLocationInfo(bool isOnline) {
    // Match applied cards style - show mode and location in one line with bullet
    final modeText = isOnline ? 'Online Interview' : 'On-site Interview';
    final locationText = location.isNotEmpty ? location : '';

    if (locationText.isEmpty) {
      return Text(
        modeText,
        style: const TextStyle(
          fontSize: 14,
          color: AppConstants.textSecondaryColor,
          height: 1.4,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Row(
      children: [
        Flexible(
          child: Text(
            modeText,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Text(
          ' • ',
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
            height: 1.4,
          ),
        ),
        Flexible(
          child: Text(
            locationText,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds salary information section
  Widget _buildSalaryInfo() {
    return Text(
      salary,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppConstants.successColor, // Green color matching button
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _buildInterviewActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (onInterviewDetailsTap != null) {
            onInterviewDetailsTap!();
            return;
          }

          // Default navigation logic
          dynamic interviewIdRaw =
              jobData['interview_id'] ??
              jobData['interviewId'] ??
              jobData['id'];

          String interviewId = '';
          if (interviewIdRaw != null) {
            if (interviewIdRaw is int) {
              interviewId = interviewIdRaw.toString();
            } else {
              interviewId = interviewIdRaw.toString();
            }
          }

          debugPrint('🔵 [ShortlistedCard] Checking interview_id...');
          debugPrint(
            '🔵 [ShortlistedCard] jobData keys: ${jobData.keys.toList()}',
          );
          debugPrint('🔵 [ShortlistedCard] interview_id: $interviewId');

          // Navigate to interview detail if interview_id is available
          if (interviewId.isNotEmpty) {
            final interviewIdInt = int.tryParse(interviewId);
            if (interviewIdInt != null && interviewIdInt > 0) {
              debugPrint(
                '🔵 [ShortlistedCard] ✅ Navigating to interview detail with ID: $interviewIdInt',
              );
              context.push(AppRoutes.interviewDetailWithId(interviewId));
              return;
            }
          }

          // Show error if no interview_id
          debugPrint('🔵 [ShortlistedCard] ❌ No valid interview_id');
          TopSnackBar.showInfo(
            context,
            message: 'Interview ID not available. Please try again later.',
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.successColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          'Interview Details',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
