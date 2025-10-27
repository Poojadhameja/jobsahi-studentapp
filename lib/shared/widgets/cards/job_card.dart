import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

/// Helper class for deadline information
class DeadlineInfo {
  final String text;
  final IconData icon;
  final Color color;

  DeadlineInfo(this.text, this.icon, this.color);
}

class JobCard extends StatefulWidget {
  /// Job data to be displayed
  final Map<String, dynamic> job;

  /// Callback function when the card is tapped
  final VoidCallback? onTap;

  const JobCard({super.key, required this.job, this.onTap});

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.cardBackgroundColor,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job header with company logo, title, company name, rating, and save button
            _buildJobHeader(job),
            const SizedBox(height: 8),

            // Job tags
            _buildJobTags(job),
            const SizedBox(height: 6),

            // Salary and rating
            Row(
              children: [
                _buildSalaryInfo(job),
                const SizedBox(width: 8),
                _buildRatingInfo(job),
              ],
            ),
            const SizedBox(height: 6),

            // Location and skills
            _buildLocationAndSkills(job),
          ],
        ),
      ),
    );
  }

  /// Builds the job header section with logo, title, company, rating, and save button
  Widget _buildJobHeader(Map<String, dynamic> job) {
    return Row(
      children: [
        // Company logo
        Image.asset(
          job['logo'] ?? AppConstants.defaultCompanyLogo,
          width: 40,
          height: 40,
        ),
        const SizedBox(width: 10),

        // Job title and company name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                job['company'] ?? '',
                style: const TextStyle(color: AppConstants.accentColor),
              ),
            ],
          ),
        ),

        // Posted Date and Deadline in column layout
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Deadline (top)
            if (job['application_deadline'] != null &&
                job['application_deadline'].toString().isNotEmpty)
              _buildDeadlineBadge(job['application_deadline']),

            // Posted Date (bottom)
            if (job['created_at'] != null &&
                job['created_at'].toString().isNotEmpty) ...[
              if (job['application_deadline'] != null &&
                  job['application_deadline'].toString().isNotEmpty)
                const SizedBox(height: 4),
              _buildPostedDateBadge(job['created_at']),
            ],
          ],
        ),
      ],
    );
  }

  /// Builds the job type status section
  Widget _buildJobTags(Map<String, dynamic> job) {
    // Get job type display and remote status from the job data
    final jobTypeDisplay = job['job_type_display'] ?? job['job_type'] ?? '';
    final isRemote = job['is_remote'] ?? false;

    // Create a single status badge showing job type and work arrangement
    String statusText = jobTypeDisplay;
    if (isRemote) {
      statusText += ' • Remote';
    } else {
      statusText += ' • On-site';
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppConstants.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppConstants.accentColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppConstants.accentColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the salary information section
  Widget _buildSalaryInfo(Map<String, dynamic> job) {
    return Text(
      job['salary'] ?? '',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF10B981), // Primary green color
      ),
    );
  }

  /// Builds the rating information section
  Widget _buildRatingInfo(Map<String, dynamic> job) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: Colors.orange, size: 14),
        const SizedBox(width: 4),
        Text(
          job['rating']?.toString() ?? '0',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  /// Builds the skills section
  Widget _buildLocationAndSkills(Map<String, dynamic> job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skills Section
        if (job['requirements'] != null &&
            (job['requirements'] as List).isNotEmpty) ...[
          _buildSkillsSection(job['requirements'] as List),
          const SizedBox(height: 8),
        ],

        // Job Details Grid
        _buildJobDetailsGrid(job),

        const SizedBox(height: 8),

        // Location and Views row
        Row(
          children: [
            // Location
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppConstants.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job['location'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.textPrimaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            // Views
            if (job['views'] != null && job['views'] > 0) ...[
              const SizedBox(width: 8),
              _buildViewsChip(job['views'].toString()),
            ],
          ],
        ),
      ],
    );
  }

  /// Builds the skills section
  Widget _buildSkillsSection(List<dynamic> skills) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...skills.take(3).map<Widget>((skill) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              skill.toString().trim(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          );
        }),
        if (skills.length > 3)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              '+${skills.length - 3} more',
              style: TextStyle(
                fontSize: 10,
                color: AppConstants.textSecondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  /// Builds a grid layout for job details
  Widget _buildJobDetailsGrid(Map<String, dynamic> job) {
    final List<Widget> detailWidgets = [];

    // Experience Required
    if (job['experience_required'] != null &&
        job['experience_required'].toString().isNotEmpty) {
      detailWidgets.add(
        _buildDetailChip(
          Icons.work_outline,
          'Experience',
          job['experience_required'].toString(),
          AppConstants.textSecondaryColor,
        ),
      );
    }

    // Vacancies
    if (job['no_of_vacancies'] != null && job['no_of_vacancies'] > 0) {
      detailWidgets.add(
        _buildDetailChip(
          Icons.people_outline,
          'Vacancies',
          job['no_of_vacancies'].toString(),
          AppConstants.textSecondaryColor,
        ),
      );
    }

    // Status
    if (job['status'] != null && job['status'].toString().isNotEmpty) {
      detailWidgets.add(
        _buildDetailChip(
          Icons.info_outline,
          'Status',
          job['status'].toString(),
          _getStatusColor(job['status'].toString()),
        ),
      );
    }

    if (detailWidgets.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 6, runSpacing: 6, children: detailWidgets);
  }

  /// Builds a views chip with icon and text
  Widget _buildViewsChip(String views) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_outlined,
            size: 12,
            color: AppConstants.textSecondaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            views,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a detail chip with icon and text
  Widget _buildDetailChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppConstants.textSecondaryColor),
          const SizedBox(width: 4),
          Text(
            label.isEmpty ? value : '$label: $value',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a posted date badge for top corner
  Widget _buildPostedDateBadge(dynamic postedDate) {
    final postedInfo = _getPostedDateInfo(postedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: postedInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: postedInfo.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(postedInfo.icon, size: 12, color: postedInfo.color),
          const SizedBox(width: 4),
          Text(
            postedInfo.text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: postedInfo.color,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a deadline badge for top corner
  Widget _buildDeadlineBadge(dynamic deadline) {
    final deadlineInfo = _getDeadlineInfo(deadline);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: deadlineInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: deadlineInfo.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(deadlineInfo.icon, size: 12, color: deadlineInfo.color),
          const SizedBox(width: 4),
          Text(
            deadlineInfo.text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: deadlineInfo.color,
            ),
          ),
        ],
      ),
    );
  }

  /// Gets posted date information with styling
  DeadlineInfo _getPostedDateInfo(dynamic postedDate) {
    if (postedDate == null) {
      return DeadlineInfo(
        'No date',
        Icons.calendar_today,
        const Color(0xFF6B7280),
      );
    }

    try {
      final date = DateTime.parse(postedDate.toString());
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return DeadlineInfo(
          'Today',
          Icons.calendar_today,
          const Color(0xFF10B981), // Green
        );
      } else if (difference.inDays == 1) {
        return DeadlineInfo(
          'Yesterday',
          Icons.calendar_today,
          const Color(0xFF10B981), // Green
        );
      } else if (difference.inDays <= 7) {
        return DeadlineInfo(
          '${difference.inDays} days ago',
          Icons.calendar_today,
          const Color(0xFF3B82F6), // Blue
        );
      } else if (difference.inDays <= 30) {
        return DeadlineInfo(
          '${(difference.inDays / 7).floor()} weeks ago',
          Icons.calendar_today,
          const Color(0xFF6B7280), // Gray
        );
      } else {
        return DeadlineInfo(
          '${(difference.inDays / 30).floor()} months ago',
          Icons.calendar_today,
          const Color(0xFF6B7280), // Gray
        );
      }
    } catch (e) {
      return DeadlineInfo(
        'Invalid date',
        Icons.calendar_today,
        const Color(0xFF6B7280),
      );
    }
  }

  /// Gets deadline information with styling
  DeadlineInfo _getDeadlineInfo(dynamic deadline) {
    if (deadline == null) {
      return DeadlineInfo(
        'No deadline',
        Icons.schedule,
        const Color(0xFF6B7280),
      );
    }

    try {
      final date = DateTime.parse(deadline.toString());
      final now = DateTime.now();
      final difference = date.difference(now);

      if (difference.isNegative) {
        return DeadlineInfo(
          'Expired ${date.day}/${date.month}/${date.year}',
          Icons.schedule,
          const Color(0xFFEF4444), // Red
        );
      } else if (difference.inDays == 0) {
        return DeadlineInfo(
          'Today ${date.day}/${date.month}/${date.year}',
          Icons.warning,
          const Color(0xFFF59E0B), // Orange
        );
      } else if (difference.inDays <= 3) {
        return DeadlineInfo(
          '${difference.inDays} days left',
          Icons.schedule,
          const Color(0xFFF59E0B), // Orange
        );
      } else {
        return DeadlineInfo(
          '${difference.inDays} days left',
          Icons.schedule,
          const Color(0xFF10B981), // Green
        );
      }
    } catch (e) {
      return DeadlineInfo(
        deadline.toString(),
        Icons.schedule,
        const Color(0xFF6B7280),
      );
    }
  }

  /// Gets color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'active':
        return const Color(0xFF10B981); // Green
      case 'closed':
      case 'expired':
        return const Color(0xFFEF4444); // Red
      case 'pending':
        return const Color(0xFFF59E0B); // Orange
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}

/// Job Tag Widget
/// Displays individual job tags like "Full-Time", "Apprenticeship", etc.
class JobTag extends StatelessWidget {
  /// Text to be displayed in the tag
  final String text;

  const JobTag({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppConstants.accentColor),
      ),
    );
  }
}
