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

  /// Callback function when save button is toggled
  final VoidCallback? onSaveToggle;

  /// Whether this job is saved
  final bool isSaved;

  /// Whether this job is featured (shows golden shine effect)
  final bool isFeatured;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onSaveToggle,
    this.isSaved = false,
    this.isFeatured = false,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> with SingleTickerProviderStateMixin {
  AnimationController? _shineController;
  Animation<double>? _shineAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isFeatured) {
      _shineController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat();
      _shineAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
        CurvedAnimation(parent: _shineController!, curve: Curves.linear),
      );
    }
  }

  @override
  void dispose() {
    _shineController?.dispose();
    super.dispose();
  }

  /// Capitalizes the first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Safely extracts company name from job data
  /// Handles both string and nested map formats
  String _getCompanyName(Map<String, dynamic> job) {
    String companyName = '';

    // First try company_name (flat string from SavedJobItem.toMap())
    if (job['company_name'] != null) {
      final name = job['company_name'];
      if (name is String) {
        companyName = name;
      } else {
        companyName = name.toString();
      }
    } else {
      // Then try company as string
      final company = job['company'];
      if (company == null) return '';

      // If company is a Map/LinkedMap, extract company_name
      if (company is Map) {
        final name = company['company_name'];
        if (name != null) {
          if (name is String) {
            companyName = name;
          } else {
            companyName = name.toString();
          }
        }
      } else if (company is String) {
        companyName = company;
      } else {
        companyName = company.toString();
      }
    }

    // Capitalize first letter
    return _capitalizeFirst(companyName);
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    // Warm, earthy colors for featured jobs
    const featuredBgColor = Color(0xFFF5F0E8); // Light warm beige
    const featuredOliveTint = Color(0xFFE8F5E9); // Light olive green tint

    Widget cardContent = Card(
      elevation: widget.isFeatured ? 4 : 2,
      color: widget.isFeatured
          ? Color.lerp(featuredBgColor, featuredOliveTint, 0.3)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(color: Colors.grey, width: 0.5),
      ),
      margin: widget.isFeatured
          ? EdgeInsets.zero
          : const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon, title, company, and save button (matching applied cards style)
                _buildJobHeader(job),
                const SizedBox(height: 12),

                // Job type (Full-Time • Remote) - matching applied cards style
                _buildJobInfo(job),
                const SizedBox(height: 8),

                // Additional job details (salary, rating, tags, etc.)
                _buildJobDetails(job),
                const SizedBox(height: AppConstants.smallPadding),

                // View Details button (matching applied cards style) - only button clickable
                _buildActionButton(context),
              ],
            ),
          ),
          // Shine effect overlay for featured jobs - tilted diagonal
          if (widget.isFeatured)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true, // ensure overlay doesn't block taps
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  child: _shineAnimation != null
                      ? AnimatedBuilder(
                          animation: _shineAnimation!,
                          builder: (context, child) {
                            final animValue = _shineAnimation!.value;
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(
                                    animValue - 1.0,
                                    animValue - 1.0,
                                  ),
                                  end: Alignment(
                                    animValue + 1.0,
                                    animValue + 1.0,
                                  ),
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.2),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          // Featured badge with days left
          if (widget.isFeatured)
            Positioned(
              top: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Featured label - golden
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700), // Golden color
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Featured by JobSahi',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Days left badge (if deadline exists)
                  if (job['application_deadline'] != null &&
                      job['application_deadline'].toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildDeadlineBadge(job['application_deadline']),
                  ],
                ],
              ),
            ),
        ],
      ),
    );

    // Add normal shadow for featured jobs
    if (widget.isFeatured) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: cardContent,
      );
    }

    return cardContent;
  }

  /// Builds the job header section matching applied cards style (icon, title, company, deadline badge)
  Widget _buildJobHeader(Map<String, dynamic> job) {
    return Stack(
      children: [
        Row(
          children: [
            // Job icon - matching applied cards style
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppConstants.successColor,
                borderRadius: BorderRadius.circular(
                  AppConstants.smallBorderRadius,
                ),
              ),
              child: const Icon(Icons.work, color: Colors.white, size: 24),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            // Job title and company - matching applied cards style
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: widget.isFeatured
                      ? 150
                      : (job['application_deadline'] != null &&
                            job['application_deadline'].toString().isNotEmpty)
                      ? 100
                      : 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capitalizeFirst(job['title']?.toString() ?? 'Job Title'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCompanyName(job),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Deadline badge in top right corner (only for non-featured jobs)
        if (!widget.isFeatured &&
            job['application_deadline'] != null &&
            job['application_deadline'].toString().isNotEmpty)
          Positioned(
            top: 0,
            right: 0,
            child: _buildDeadlineBadge(job['application_deadline']),
          ),
      ],
    );
  }

  /// Builds job info section (Full-Time • Remote) - chips format
  Widget _buildJobInfo(Map<String, dynamic> job) {
    // Get job type display and remote status from the job data
    final jobTypeDisplay = job['job_type_display'] ?? job['job_type'] ?? '';
    final isRemote = job['is_remote'] ?? false;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (jobTypeDisplay.isNotEmpty)
          _buildDetailChip(
            Icons.access_time,
            '',
            jobTypeDisplay,
            AppConstants.textSecondaryColor,
          ),
        _buildDetailChip(
          isRemote ? Icons.wifi : Icons.business,
          '',
          isRemote ? 'Remote' : 'On-site',
          AppConstants.textSecondaryColor,
        ),
      ],
    );
  }

  /// Builds date info section (posted date and deadline) - chips format
  Widget _buildJobDateInfo(Map<String, dynamic> job) {
    final hasPostedDate =
        job['created_at'] != null && job['created_at'].toString().isNotEmpty;
    final hasDeadline =
        job['application_deadline'] != null &&
        job['application_deadline'].toString().isNotEmpty;

    if (!hasPostedDate && !hasDeadline) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (hasPostedDate)
          _buildDetailChip(
            Icons.calendar_today,
            'Posted',
            _formatDate(job['created_at']),
            AppConstants.textSecondaryColor,
          ),
        if (hasDeadline)
          _buildDetailChip(
            Icons.schedule,
            'Deadline',
            _formatDate(job['application_deadline']),
            AppConstants.textSecondaryColor,
          ),
      ],
    );
  }

  /// Formats date to a readable string
  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dateTime = DateTime.parse(date.toString());
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = _getMonthName(dateTime.month);
      final year = dateTime.year.toString();
      return '$day $month $year';
    } catch (e) {
      return date.toString();
    }
  }

  /// Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  /// Builds additional job details (salary, skills, etc.)
  Widget _buildJobDetails(Map<String, dynamic> job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Salary row
        _buildSalaryInfo(job),
        const SizedBox(height: 10),

        // Location and skills
        _buildLocationAndSkills(job),
      ],
    );
  }

  /// Builds the action button - matching applied cards style (only button clickable)
  Widget _buildActionButton(BuildContext context) {
    return Row(
      children: [
        // View Job Details button
        Expanded(
          child: ElevatedButton(
            onPressed: widget.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.smallBorderRadius,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'View Job Details',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        // Save button on the right side
        if (widget.onSaveToggle != null) ...[
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: widget.onSaveToggle,
              customBorder: const CircleBorder(),
              splashColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade200,
              radius: 20,
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: widget.isSaved
                          ? AppConstants.primaryColor
                          : Colors.grey.shade700,
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppConstants.saveText,
                      style: TextStyle(
                        fontSize: 10,
                        color: widget.isSaved
                            ? AppConstants.primaryColor
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    final salary = job['salary'];
    final salaryText = salary != null ? salary.toString() : '';
    return Text(
      salaryText,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppConstants.successColor, // Green color matching button
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
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

        // Posted date - directly above location
        if (job['created_at'] != null &&
            job['created_at'].toString().isNotEmpty) ...[
          _buildJobDateInfo(job),
          const SizedBox(height: 6),
        ],

        // Location chip
        if (job['location'] != null && job['location'].toString().isNotEmpty)
          _buildDetailChip(
            Icons.location_on,
            '',
            job['location'].toString(),
            AppConstants.textSecondaryColor,
          ),
      ],
    );
  }

  /// Builds the skills section
  Widget _buildSkillsSection(List<dynamic> skills) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...skills.take(3).map<Widget>((skill) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              skill.toString().trim(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          );
        }),
        if (skills.length > 3)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              '+${skills.length - 3} more',
              style: TextStyle(
                fontSize: 11,
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
          Icons.people_alt_outlined,
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
          Icons.info_outline_rounded,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_outlined,
            size: 10,
            color: AppConstants.textSecondaryColor,
          ),
          const SizedBox(width: 3),
          Text(
            views,
            style: const TextStyle(
              fontSize: 9,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppConstants.primaryColor),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label.isEmpty ? value : '$label: $value',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppConstants.textSecondaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

  /// Builds a deadline badge for top corner - color based on days left
  Widget _buildDeadlineBadge(dynamic deadline) {
    if (deadline == null) return const SizedBox.shrink();

    try {
      final date = DateTime.parse(deadline.toString());
      final now = DateTime.now();
      final difference = date.difference(now);

      String displayText;
      Color badgeColor;

      if (difference.isNegative) {
        // Expired - show "Closed" in grey
        displayText = 'Closed';
        badgeColor = Colors.grey;
      } else if (difference.inDays == 0) {
        // Today
        displayText = 'Today';
        badgeColor = Colors.red;
      } else if (difference.inDays <= 3) {
        // 1-3 days left - Red
        displayText = '${difference.inDays} days left';
        badgeColor = Colors.red;
      } else if (difference.inDays <= 7) {
        // 4-7 days left - Orange
        displayText = '${difference.inDays} days left';
        badgeColor = Colors.orange;
      } else {
        // More than 7 days left - Green
        displayText = '${difference.inDays} days left';
        badgeColor = AppConstants.successColor;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          displayText,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
    } catch (e) {
      // Fallback to green if parsing fails
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppConstants.successColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Deadline',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
    }
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
