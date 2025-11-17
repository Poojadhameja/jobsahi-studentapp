import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_constants.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';

class StudentApplicationDetailScreen extends StatefulWidget {
  final String applicationId;
  final Map<String, dynamic>? initialData;

  const StudentApplicationDetailScreen({
    super.key,
    required this.applicationId,
    this.initialData,
  });

  /// Get navigation source from initial data
  String? get navigationSource => initialData?['_navigation_source']?.toString();

  @override
  State<StudentApplicationDetailScreen> createState() =>
      _StudentApplicationDetailScreenState();
}

class _StudentApplicationDetailScreenState
    extends State<StudentApplicationDetailScreen> {
  late Future<Map<String, dynamic>> _detailFuture;
  Map<String, dynamic>? _initialData;
  bool _isStartingSkillTest = false;

  static const List<String> _monthNames = <String>[
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

  @override
  void initState() {
    super.initState();
    _initialData = widget.initialData != null
        ? Map<String, dynamic>.from(widget.initialData!)
        : null;
    _detailFuture = _loadApplicationDetail();
  }

  Future<Map<String, dynamic>> _loadApplicationDetail() async {
    final applicationId = int.tryParse(widget.applicationId);
    if (applicationId == null) {
      throw Exception('Invalid application ID');
    }

    final api = ApiService();
    final detail = await api.getStudentApplicationDetail(applicationId);
    final merged = Map<String, dynamic>.from(detail);

    if (_initialData != null) {
      merged.addAll(_initialData!);
    }

    merged['formatted_applied_at'] = _formatDateTime(
      merged['applied_at']?.toString(),
    );
    merged['formatted_created_at'] = _formatDateTime(
      merged['created_at']?.toString(),
    );
    merged['formatted_updated_at'] = _formatDateTime(
      merged['modified_at']?.toString(),
    );
    merged['salary'] =
        merged['salary'] ??
        _formatSalaryRange(merged['salary_min'], merged['salary_max']);
    // Map status - if status is "open" or empty, default to "Applied" since user has an application
    final rawStatus = merged['status']?.toString() ?? '';
    final applicationStatus = merged['application_status']?.toString() ?? rawStatus;
    merged['status_label'] = _mapStatusLabel(applicationStatus.isNotEmpty ? applicationStatus : 'applied');

    final skillOverviewRaw = merged['skill_test_overview'];
    if (skillOverviewRaw is Map<String, dynamic>) {
      merged['skill_test_overview'] = _normalizeSkillTestOverview(
        skillOverviewRaw,
        merged,
      );
    } else {
      merged['skill_test_overview'] = null;
    }

    return merged;
  }

  @override
  Widget build(BuildContext context) {
    final navigationSource = widget.navigationSource;
    
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: SimpleAppBar(
        title: 'Application Detail',
        showBackButton: true,
        onBack: () => _handleBackNavigation(context, navigationSource),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState(
                context,
                snapshot.error?.toString() ??
                    'Failed to load application detail.',
              );
            }

            final data = snapshot.data ?? <String, dynamic>{};
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: _buildApplicationDetailContent(context, data),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _detailFuture = _loadApplicationDetail();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Capitalizes the first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Build application detail content with separate cards (matching interview details structure)
  Widget _buildApplicationDetailContent(BuildContext context, Map<String, dynamic> data) {
    final title =
        data['job_title']?.toString() ??
        data['title']?.toString() ??
        'Job Title';
    final company =
        data['company_name']?.toString() ??
        data['company']?.toString() ??
        'Company';
    final statusLabel = data['status_label']?.toString() ?? 'Applied';
    final skillOverview = data['skill_test_overview'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Card
        _buildHeaderCard(_capitalizeFirst(title), _capitalizeFirst(company), statusLabel),
        const SizedBox(height: AppConstants.defaultPadding),

        // Job Information Card
        _buildJobInfoCard(data),
        const SizedBox(height: AppConstants.defaultPadding),

        // Application Information Card
        _buildApplicationInfoCard(data),
        const SizedBox(height: AppConstants.defaultPadding),

        // Skill Test Card
        if (skillOverview is Map<String, dynamic> &&
            skillOverview.isNotEmpty) ...[
          _buildSkillTestCard(context, data, skillOverview),
        ],
      ],
    );
  }

  /// Builds the header card (matching interview details structure)
  Widget _buildHeaderCard(String title, String company, String statusLabel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppConstants.successColor,
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                ),
                child: const Icon(Icons.work, color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppConstants.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(statusLabel),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'shortlisted':
        return AppConstants.successColor; // Green
      case 'applied':
        return AppConstants.primaryColor; // Blue
      default:
        return AppConstants.textSecondaryColor;
    }
  }

  /// Builds the job information card (matching interview details structure)
  Widget _buildJobInfoCard(Map<String, dynamic> data) {
    final jobType =
        data['job_type']?.toString() ?? data['type']?.toString() ?? 'Job Type';
    final salary =
        data['salary']?.toString() ??
        _formatSalaryRange(data['salary_min'], data['salary_max']);
    final location = data['location']?.toString() ?? 'Location';
    final description = data['description']?.toString() ?? '';
    final experience = data['experience_required']?.toString() ?? '';
    final skills = data['skills_required']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          if (description.isNotEmpty) ...[
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            const Divider(),
            const SizedBox(height: AppConstants.defaultPadding),
          ],
          _buildInfoRow(Icons.location_on, 'Location', location),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.work, 'Job Type', jobType),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.currency_rupee, 'Salary', salary),
          if (experience.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.trending_up, 'Experience', experience),
          ],
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.code, 'Skills Required', skills),
          ],
        ],
      ),
    );
  }

  /// Builds the application information card
  Widget _buildApplicationInfoCard(Map<String, dynamic> data) {
    final statusLabel = data['status_label']?.toString() ?? 'Applied';
    final appliedAt = data['formatted_applied_at']?.toString() ?? 
                     data['applied_at']?.toString() ?? 'Not available';
    final coverLetter =
        (data['cover_letter'] ?? data['cover_letter_text'])
            ?.toString()
            .trim() ??
        '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildInfoRow(
            Icons.description,
            'Application Status',
            statusLabel,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Applied On',
            appliedAt,
          ),
          if (coverLetter.isNotEmpty) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            const Divider(),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              'Your Cover Letter',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              coverLetter,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the skill test card (matching interview details structure)
  Widget _buildSkillTestCard(
    BuildContext context,
    Map<String, dynamic> application,
    Map<String, dynamic> overview,
  ) {
    final statusLabel = overview['statusLabel']?.toString() ?? 'Not started';
    final scoreText = overview['scoreText']?.toString();
    final progressText = overview['progressText']?.toString();
    final completedLabel = overview['completedLabel']?.toString();
    final bool hasCompleted = overview['hasCompleted'] == true;
    final bool canStart = overview['ctaEnabled'] == true;
    final bool available = overview['available'] == true;
    final String buttonLabel =
        overview['ctaLabel']?.toString() ?? 'Take Skill Test';
    final String jobId = overview['jobId']?.toString() ?? '';
    final String testId = overview['testId']?.toString() ?? '';
    final Map<String, dynamic>? jobPayload =
        overview['jobPayload'] as Map<String, dynamic>?;
    final String routeId = jobId.isNotEmpty ? jobId : testId;
    final bool canNavigate = routeId.isNotEmpty && jobPayload != null;
    final bool isLoading = _isStartingSkillTest;
    
    // Check if skill test is not available/required
    final bool hasSkillTest = available && (canStart || testId.isNotEmpty);
    
    // Get score and maxScore from overview
    final scoreValue = _toDouble(overview['score']);
    final maxScoreValue = _toDouble(overview['maxScore']);
    
    // Calculate score percentage and determine color
    double? scorePercentage;
    if (scoreValue != null && maxScoreValue != null && maxScoreValue > 0 && hasCompleted) {
      scorePercentage = (scoreValue / maxScoreValue * 100);
    } else if (scoreText != null && hasCompleted) {
      // Fallback: Extract percentage from scoreText (format: "X / Y (Z%)")
      final percentMatch = RegExp(r'\((\d+)%\)').firstMatch(scoreText);
      if (percentMatch != null) {
        scorePercentage = double.tryParse(percentMatch.group(1) ?? '');
      } else {
        // Try to extract from score/maxScore if available
        final scoreMatch = RegExp(r'(\d+)\s*/\s*(\d+)').firstMatch(scoreText);
        if (scoreMatch != null) {
          final score = double.tryParse(scoreMatch.group(1) ?? '');
          final maxScore = double.tryParse(scoreMatch.group(2) ?? '');
          if (score != null && maxScore != null && maxScore > 0) {
            scorePercentage = (score / maxScore * 100);
          }
        }
      }
    }
    
    // Determine color based on score or availability (subtle approach)
    Color iconColor;
    Color borderColor;
    
    // Keep background neutral, only change icon and border colors
    const Color sectionColor = Color(0xFFF5F7FB);
    
    if (!hasSkillTest) {
      // Not available - Blue
      iconColor = AppConstants.primaryColor;
      borderColor = AppConstants.primaryColor.withValues(alpha: 0.2);
    } else if (scorePercentage != null) {
      if (scorePercentage < 50) {
        // Below average - Red (subtle)
        iconColor = Colors.red.shade600;
        borderColor = Colors.red.withValues(alpha: 0.15);
      } else if (scorePercentage >= 50 && scorePercentage <= 70) {
        // Average - Orange (subtle)
        iconColor = Colors.orange.shade600;
        borderColor = Colors.orange.withValues(alpha: 0.15);
      } else {
        // Above average - Green (subtle)
        iconColor = AppConstants.successColor;
        borderColor = AppConstants.successColor.withValues(alpha: 0.15);
      }
    } else {
      // Default - Light grey (not started/in progress)
      iconColor = AppConstants.primaryColor;
      borderColor = Colors.grey.shade200;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skill Test',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: sectionColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.quiz_outlined,
                    color: hasCompleted && scorePercentage != null 
                        ? iconColor.withValues(alpha: 0.9) 
                        : iconColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skill Test',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: hasCompleted && scorePercentage != null
                              ? iconColor.withValues(alpha: 0.9)
                              : AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: hasCompleted && scorePercentage != null
                              ? iconColor.withValues(alpha: 0.9)
                              : (!hasSkillTest 
                                  ? AppConstants.primaryColor 
                                  : AppConstants.textSecondaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (scoreText != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.stacked_line_chart,
                    size: 18,
                    color: hasCompleted && scorePercentage != null 
                        ? iconColor.withValues(alpha: 0.9) 
                        : AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    scoreText,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasCompleted && scorePercentage != null 
                          ? iconColor.withValues(alpha: 0.9) 
                          : AppConstants.textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (progressText != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.list_alt_outlined,
                    size: 18,
                    color: hasCompleted && scorePercentage != null 
                        ? iconColor.withValues(alpha: 0.9) 
                        : AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    progressText,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasCompleted && scorePercentage != null 
                          ? iconColor.withValues(alpha: 0.9) 
                          : AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (completedLabel != null &&
                completedLabel.isNotEmpty &&
                hasCompleted) ...[
              Row(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 18,
                    color: hasCompleted && scorePercentage != null 
                        ? iconColor.withValues(alpha: 0.9) 
                        : AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Completed on $completedLabel',
                    style: TextStyle(
                      fontSize: 13,
                      color: hasCompleted && scorePercentage != null 
                          ? iconColor.withValues(alpha: 0.9) 
                          : AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Only show button if skill test is required and not completed
            if (!hasCompleted && canStart)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (!isLoading && canNavigate)
                      ? () => _startSkillTest(application, overview)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          buttonLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            // Show message if skill test is not available/required
            if (!hasCompleted && !hasSkillTest)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppConstants.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'The skill test is not available or required. Once available, it will appear here.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (hasCompleted && scoreText == null)
              const Text(
                'Skill test completed.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
          ],
        ),
          ),
        ],
      ),
    );
  }


  /// Builds an info row with icon and text (matching interview details structure)
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppConstants.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppConstants.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isLink
                      ? AppConstants.primaryColor
                      : AppConstants.textPrimaryColor,
                  decoration: isLink ? TextDecoration.underline : null,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'Not available';

    try {
      final dateTime = DateTime.parse(raw);
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = _monthNames[dateTime.month - 1];
      final year = dateTime.year.toString();
      var hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      final hourLabel = hour.toString().padLeft(2, '0');
      return '$day $month $year • $hourLabel:$minute $period';
    } catch (_) {
      return raw;
    }
  }

  String _formatSalaryRange(dynamic min, dynamic max) {
    final double? minValue = _toDouble(min);
    final double? maxValue = _toDouble(max);

    if (minValue == null && maxValue == null) {
      return 'Salary not disclosed';
    }

    String format(double value) {
      if (value >= 100000) {
        return '₹${(value / 100000).toStringAsFixed(1)}L';
      }
      if (value >= 1000) {
        return '₹${(value / 1000).toStringAsFixed(1)}K';
      }
      return '₹${value.toStringAsFixed(0)}';
    }

    if (minValue != null && maxValue != null) {
      return '${format(minValue)} - ${format(maxValue)}';
    }

    final single = minValue ?? maxValue!;
    return format(single);
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String _mapStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return 'Applied';
      case 'open':
        // If status is "open" but user has applied, show "Applied"
        return 'Applied';
      case 'shortlisted':
        return 'Shortlisted';
      case 'interview':
      case 'interview_scheduled':
        return 'Interview Scheduled';
      case 'offer':
      case 'offer_received':
        return 'Offer Received';
      case 'offer accepted':
      case 'hired':
      case 'selected':
        return 'Offer Accepted';
      default:
        if (status.isEmpty) return 'Applied';
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  Map<String, dynamic> _normalizeSkillTestOverview(
    Map<String, dynamic> overview,
    Map<String, dynamic> application,
  ) {
    final available = _toBool(overview['available']);
    final canStartNow =
        _toBool(overview['can_start_now']) || _toBool(overview['can_start']);
    final alreadyExists = _toBool(overview['already_exists']);
    final score = _toDouble(overview['score']);
    final maxScore = _toDouble(overview['max_score']);
    final hasCompleted = score != null && maxScore != null && maxScore > 0;
    final answered = overview['answered_questions'];
    final totalQuestions = overview['total_questions'];
    final completedAtRaw = overview['completed_at']?.toString();
    final statusRaw = overview['status']?.toString() ?? '';

    String? scoreText;
    if (score != null && maxScore != null) {
      final double scoreValue = score;
      final double maxScoreValue = maxScore;
      final percent = maxScoreValue > 0
          ? ((scoreValue / maxScoreValue) * 100).round()
          : null;
      scoreText = percent != null
          ? '${scoreValue.toInt()} / ${maxScoreValue.toInt()}  (${percent}%)'
          : scoreValue.toStringAsFixed(1);
    }

    String? progressText;
    if (answered is num && totalQuestions is num && totalQuestions > 0) {
      progressText =
          '${answered.toInt()} of ${totalQuestions.toInt()} questions answered';
    }

    final completedLabel = completedAtRaw != null
        ? _formatDateTime(completedAtRaw)
        : '';

    final statusLabel = _mapSkillTestStatus(statusRaw, hasCompleted, available);

    final jobId = application['job_id']?.toString() ?? '';
    final jobTitle =
        application['job_title']?.toString() ??
        application['title']?.toString() ??
        'Skill Test';
    final jobCategory =
        application['job_type']?.toString() ??
        application['type']?.toString() ??
        'general';
    final companyName =
        application['company_name']?.toString() ??
        application['company']?.toString() ??
        '';
    final testId = overview['test_id']?.toString() ?? '';

    // Check if skill test is available (has questions)
    final bool hasSkillTest = available && (canStartNow || alreadyExists || testId.isNotEmpty);
    
    // Update status label if skill test is not available
    final String finalStatusLabel = !hasSkillTest && !hasCompleted
        ? 'Not available'
        : statusLabel;
    
    final ctaEnabled =
        !hasCompleted && hasSkillTest && jobId.isNotEmpty;
    final ctaLabel = hasCompleted
        ? 'Skill Test Completed'
        : !hasSkillTest
        ? 'Skill Test Not Required'
        : alreadyExists
        ? 'Resume Skill Test'
        : (canStartNow ? 'Take Skill Test' : 'Skill Test Unavailable');

    return <String, dynamic>{
      'available': available,
      'canStart': canStartNow,
      'alreadyExists': alreadyExists,
      'hasCompleted': hasCompleted,
      'statusLabel': finalStatusLabel,
      'scoreText': scoreText,
      'score': score,
      'maxScore': maxScore,
      'progressText': progressText,
      'completedLabel': completedLabel != 'Not available' ? completedLabel : '',
      'ctaEnabled': ctaEnabled,
      'ctaLabel': ctaLabel,
      'jobId': jobId,
      'testId': testId,
      'jobPayload': {
        'id': jobId.isNotEmpty ? jobId : testId,
        'job_id': jobId.isNotEmpty ? jobId : testId,
        'title': jobTitle,
        'category': jobCategory,
        'company': companyName,
        'test_id': testId,
      },
    };
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return false;
  }

  String _mapSkillTestStatus(String status, bool hasCompleted, bool available) {
    final normalized = status.toLowerCase();
    if (hasCompleted) return 'Completed';
    switch (normalized) {
      case 'in_progress':
      case 'in-progress':
        return 'In progress';
      case 'pending':
      case 'not_started':
      case 'ready':
        return available ? 'Ready to start' : 'Not started';
      case 'expired':
        return 'Expired';
      default:
        if (status.isEmpty) {
          return available ? 'Ready to start' : 'Not available';
        }
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppConstants.primaryColor,
      ),
    );
  }

  Future<void> _startSkillTest(
    Map<String, dynamic> application,
    Map<String, dynamic> overview,
  ) async {
    final appIdStr =
        application['application_id']?.toString() ?? widget.applicationId;
    final applicationId = int.tryParse(appIdStr);
    if (applicationId == null) {
      _showSnackBar('Invalid application ID.');
      return;
    }

    final Map<String, dynamic> jobPayload = Map<String, dynamic>.from(
      overview['jobPayload'] as Map<String, dynamic>? ??
          {
            'id': application['job_id']?.toString() ?? '',
            'job_id': application['job_id']?.toString() ?? '',
            'title':
                application['job_title']?.toString() ??
                application['title']?.toString() ??
                'Skill Test',
            'category':
                application['job_type']?.toString() ??
                application['type']?.toString() ??
                'general',
            'company':
                application['company_name']?.toString() ??
                application['company']?.toString() ??
                '',
          },
    );

    final jobId = jobPayload['id']?.toString() ?? '';

    setState(() {
      _isStartingSkillTest = true;
    });

    try {
      final result = await ApiService().startSkillTest(
        applicationId: applicationId,
      );

      if (!mounted) return;

      final message = result['message']?.toString();
      if (message != null && message.isNotEmpty) {
        _showSnackBar(message, isError: result['status'] != true);
      }

      final testId =
          result['test_id']?.toString() ?? overview['testId']?.toString() ?? '';
      final routeId = jobId.isNotEmpty
          ? jobId
          : (testId.isNotEmpty ? testId : '');

      setState(() {
        _detailFuture = _loadApplicationDetail();
      });

      if (routeId.isNotEmpty) {
        final payload = Map<String, dynamic>.from(jobPayload);
        payload['skill_test_response'] = result;
        payload['test_id'] = testId;

        context.pushNamed(
          'skillTestDetails',
          pathParameters: {'id': routeId},
          extra: payload,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      _showSnackBar(
        msg.startsWith('Exception: ')
            ? msg.substring('Exception: '.length)
            : msg,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isStartingSkillTest = false;
      });
    }
  }

  /// Handle back navigation based on source
  void _handleBackNavigation(BuildContext context, String? navigationSource) {
    if (navigationSource == 'job_details') {
      // Navigate back to job details page
      final jobId = widget.initialData?['id']?.toString() ??
          widget.initialData?['job_id']?.toString();
      
      if (jobId != null && jobId.isNotEmpty) {
        final jobPayload = Map<String, dynamic>.from(widget.initialData ?? {});
        jobPayload['id'] = jobId;
        jobPayload['job_id'] = jobId;
        
        context.goNamed(
          'jobDetails',
          pathParameters: {'id': jobId},
          extra: jobPayload,
        );
        return;
      }
    } else if (navigationSource == 'applied_jobs') {
      // Navigate back to applied jobs page (Application Tracker)
      context.goNamed('application-tracker');
      return;
    } else if (navigationSource == 'job_application_success') {
      // Navigate back to job application success page
      final jobId = widget.initialData?['id']?.toString() ??
          widget.initialData?['job_id']?.toString();
      
      if (jobId != null && jobId.isNotEmpty) {
        final jobPayload = Map<String, dynamic>.from(widget.initialData ?? {});
        jobPayload['id'] = jobId;
        jobPayload['job_id'] = jobId;
        
        context.goNamed(
          'jobApplicationSuccess',
          pathParameters: {'id': jobId},
          extra: jobPayload,
        );
        return;
      }
    }
    
    // Default: pop if possible, otherwise go to home
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.goNamed('home');
    }
  }
}
