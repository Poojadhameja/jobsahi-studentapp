import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/app_constants.dart';

/// Interview Card Widget
/// Displays interview information in a card format
class InterviewCard extends StatelessWidget {
  /// Capitalizes the first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  final Map<String, dynamic> interview;
  final VoidCallback? onTap;

  const InterviewCard({super.key, required this.interview, this.onTap});

  @override
  Widget build(BuildContext context) {
    final jobTitle =
        interview['job_title'] ?? interview['title'] ?? 'Job Title';
    final companyName =
        interview['company_name'] ?? interview['company'] ?? 'Company';
    final interviewDate = interview['interviewDate'] ?? '';
    final interviewTime = interview['interviewTime'] ?? '';
    final mode = interview['mode'] ?? 'online';
    final status = interview['status'] ?? 'scheduled';
    final location = interview['location'] ?? '';
    final platformName = interview['platform_name'] ?? '';
    final interviewLink = interview['interview_link'] ?? '';
    final interviewInfo = interview['interview_info'] ?? '';

    // Extract job_id from multiple possible keys
    String jobId = '';
    final jobIdRaw = interview['job_id'] ?? interview['jobId'];
    if (jobIdRaw != null) {
      if (jobIdRaw is int) {
        jobId = jobIdRaw.toString();
      } else if (jobIdRaw is String && jobIdRaw.isNotEmpty) {
        jobId = jobIdRaw;
      } else if (jobIdRaw is num) {
        jobId = jobIdRaw.toString();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with company logo and job info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company logo placeholder
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppConstants.smallBorderRadius,
                        ),
                        color: AppConstants.primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.business,
                        color: AppConstants.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    // Job details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job title
                          Text(
                            _capitalizeFirst(jobTitle),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textPrimaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Company name
                          Text(
                            _capitalizeFirst(companyName),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppConstants.successColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge and Job ID in column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Job ID badge in upper right corner
                        if (jobId.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.textSecondaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppConstants.textSecondaryColor
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Job ID: $jobId',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                          ),
                        // Status badge
                        _buildStatusBadge(status),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                // Interview details section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.smallBorderRadius,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Date and Time
                      if (interviewDate.isNotEmpty || interviewTime.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppConstants.textSecondaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                interviewDate.isNotEmpty &&
                                        interviewTime.isNotEmpty
                                    ? '$interviewDate at $interviewTime'
                                    : interviewDate.isNotEmpty
                                    ? interviewDate
                                    : interviewTime,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppConstants.textPrimaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (interviewDate.isNotEmpty || interviewTime.isNotEmpty)
                        const SizedBox(height: 8),
                      // Mode and Location/Platform
                      Row(
                        children: [
                          // Mode
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  mode.toLowerCase() == 'online'
                                      ? Icons.video_call
                                      : Icons.location_on,
                                  size: 16,
                                  color: AppConstants.textSecondaryColor,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    mode.toLowerCase() == 'online'
                                        ? 'Online'
                                        : 'On-site',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Location (if offline)
                          if (mode.toLowerCase() != 'online' &&
                              location.isNotEmpty)
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.pin_drop,
                                    size: 16,
                                    color: AppConstants.textSecondaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      location,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppConstants.textSecondaryColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      // Platform name for online interviews
                      if (mode.toLowerCase() == 'online' && platformName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.video_library,
                                size: 14,
                                color: AppConstants.textSecondaryColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  platformName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppConstants.textSecondaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Interview link for online interviews
                      if (mode.toLowerCase() == 'online' && interviewLink.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: GestureDetector(
                            onTap: () => _launchUrl(context, interviewLink),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.link,
                                  size: 14,
                                  color: AppConstants.primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Join Meeting',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppConstants.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.open_in_new,
                                  size: 14,
                                  color: AppConstants.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Interview info (if available)
                      if (interviewInfo.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppConstants.textSecondaryColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                interviewInfo,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppConstants.textSecondaryColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build status badge
  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    String displayStatus;

    switch (status.toLowerCase()) {
      case 'scheduled':
        backgroundColor = AppConstants.successColor;
        displayStatus = 'Scheduled';
        break;
      case 'completed':
        backgroundColor = AppConstants.primaryColor;
        displayStatus = 'Completed';
        break;
      case 'cancelled':
        backgroundColor = Colors.red;
        displayStatus = 'Cancelled';
        break;
      default:
        backgroundColor = AppConstants.textSecondaryColor;
        displayStatus = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        displayStatus,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    if (url.isEmpty) return;
    
    try {
      String urlToLaunch = url.trim();
      if (!urlToLaunch.startsWith('http://') &&
          !urlToLaunch.startsWith('https://')) {
        urlToLaunch = 'https://$urlToLaunch';
      }

      final uri = Uri.parse(urlToLaunch);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
