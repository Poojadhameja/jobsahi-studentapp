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

  @override
  State<StudentApplicationDetailScreen> createState() =>
      _StudentApplicationDetailScreenState();
}

class _StudentApplicationDetailScreenState
    extends State<StudentApplicationDetailScreen> {
  late Future<Map<String, dynamic>> _detailFuture;
  Map<String, dynamic>? _initialData;

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
    _initialData =
        widget.initialData != null ? Map<String, dynamic>.from(widget.initialData!) : null;
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

    merged['formatted_applied_at'] =
        _formatDateTime(merged['applied_at']?.toString());
    merged['formatted_created_at'] =
        _formatDateTime(merged['created_at']?.toString());
    merged['formatted_updated_at'] =
        _formatDateTime(merged['modified_at']?.toString());
    merged['salary'] = merged['salary'] ??
        _formatSalaryRange(merged['salary_min'], merged['salary_max']);
    merged['status_label'] =
        _mapStatusLabel(merged['status']?.toString() ?? '');

    final skillOverviewRaw = merged['skill_test_overview'];
    if (skillOverviewRaw is Map<String, dynamic>) {
      merged['skill_test_overview'] =
          _normalizeSkillTestOverview(skillOverviewRaw, merged);
    } else {
      merged['skill_test_overview'] = null;
    }

    return merged;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(
        title: 'Application Detail',
        showBackButton: true,
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
                snapshot.error?.toString() ?? 'Failed to load application detail.',
              );
            }

    final data = snapshot.data ?? <String, dynamic>{};
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: _buildMainCard(data),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildMainCard(Map<String, dynamic> data) {
    final title = data['job_title']?.toString() ?? data['title']?.toString() ?? 'Job Title';
    final company = data['company_name']?.toString() ??
        data['company']?.toString() ??
        'Company';
    final location = data['location']?.toString() ?? 'Location';
    final statusLabel = data['status_label']?.toString() ?? 'Applied';
    final coverLetter = (data['cover_letter'] ?? data['cover_letter_text'])
            ?.toString()
            .trim() ??
        '';
    final skillOverview = data['skill_test_overview'];

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(title, company, statusLabel),
          _buildDivider(),
          _buildInfoRows(data, location),
          _buildDivider(),
          if (skillOverview is Map<String, dynamic> &&
              skillOverview.isNotEmpty) ...[
            _buildSkillTestSection(context, data, skillOverview),
            _buildDivider(),
          ],
          _buildTimelineSection(data),
          _buildDivider(),
          _buildCoverLetterSection(coverLetter),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(
    String title,
    String company,
    String statusLabel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.work_outline, color: AppConstants.primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
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
                ),
                const SizedBox(height: 6),
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppConstants.successColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: const TextStyle(
                color: AppConstants.successColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRows(Map<String, dynamic> data, String fallbackLocation) {
    final jobType = data['job_type']?.toString() ?? data['type']?.toString() ?? 'Job Type';
    final salary = data['salary']?.toString() ??
        _formatSalaryRange(data['salary_min'], data['salary_max']);
    final location = data['location']?.toString() ?? fallbackLocation;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
          const SizedBox(height: 12),
          _buildIconRow(Icons.location_on_outlined, location),
          const SizedBox(height: 8),
          _buildIconRow(Icons.schedule, jobType),
          const SizedBox(height: 8),
          _buildIconRow(Icons.payments_outlined, salary),
        ],
      ),
    );
  }

  Widget _buildSkillTestSection(
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
    final String buttonLabel = overview['ctaLabel']?.toString() ?? 'Take Skill Test';
    final String jobId = overview['jobId']?.toString() ?? '';
    final Map<String, dynamic>? jobPayload =
        overview['jobPayload'] as Map<String, dynamic>?;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
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
                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    color: AppConstants.primaryColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Skill Test',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: hasCompleted
                              ? AppConstants.successColor
                              : AppConstants.textSecondaryColor,
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
                  const Icon(
                    Icons.stacked_line_chart,
                    size: 18,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    scoreText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppConstants.textPrimaryColor,
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
                  const Icon(
                    Icons.list_alt_outlined,
                    size: 18,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    progressText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppConstants.textSecondaryColor,
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
                  const Icon(
                    Icons.event_available_outlined,
                    size: 18,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Completed on $completedLabel',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (!hasCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (canStart && jobId.isNotEmpty && jobPayload != null)
                      ? () {
                          context.pushNamed(
                            'skillTestDetails',
                            pathParameters: {'id': jobId},
                            extra: jobPayload,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
    );
  }

  Widget _buildTimelineSection(Map<String, dynamic> data) {
    final appliedAt =
        data['formatted_applied_at']?.toString() ?? 'Not available';

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildTimelineTile('Applied on', appliedAt, Icons.check_circle_outline),
        ],
      ),
    );
  }

  Widget _buildCoverLetterSection(String coverLetter) {
    final hasCoverLetter = coverLetter.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cover Letter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              hasCoverLetter
                  ? coverLetter
                  : 'Cover letter not provided.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppConstants.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineTile(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppConstants.secondaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.grey.shade200,
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
    final score = _toDouble(overview['score']);
    final maxScore = _toDouble(overview['max_score']);
    final hasCompleted =
        score != null && maxScore != null && maxScore > 0;
    final answered = overview['answered_questions'];
    final totalQuestions = overview['total_questions'];
    final completedAtRaw = overview['completed_at']?.toString();
    final statusRaw = overview['status']?.toString() ?? '';

    String? scoreText;
    if (hasCompleted) {
      final percent =
          maxScore > 0 ? ((score / maxScore) * 100).round() : null;
      scoreText = percent != null
          ? '${score.toInt()} / ${maxScore.toInt()}  (${percent}%)'
          : score.toStringAsFixed(1);
    }

    String? progressText;
    if (answered is num && totalQuestions is num && totalQuestions > 0) {
      progressText =
          '${answered.toInt()} of ${totalQuestions.toInt()} questions answered';
    }

    final completedLabel =
        completedAtRaw != null ? _formatDateTime(completedAtRaw) : '';

    final statusLabel =
        _mapSkillTestStatus(statusRaw, hasCompleted, available);

    final jobId = application['job_id']?.toString() ?? '';
    final jobTitle = application['job_title']?.toString() ??
        application['title']?.toString() ??
        'Skill Test';
    final jobCategory = application['job_type']?.toString() ??
        application['type']?.toString() ??
        'general';
    final companyName = application['company_name']?.toString() ??
        application['company']?.toString() ??
        '';

    final ctaEnabled = !hasCompleted && canStartNow && jobId.isNotEmpty;
    final ctaLabel = hasCompleted
        ? 'Skill Test Completed'
        : (ctaEnabled ? 'Take Skill Test' : 'Skill Test Unavailable');

    return <String, dynamic>{
      'available': available,
      'canStart': canStartNow,
      'hasCompleted': hasCompleted,
      'statusLabel': statusLabel,
      'scoreText': scoreText,
      'progressText': progressText,
      'completedLabel':
          completedLabel != 'Not available' ? completedLabel : '',
      'ctaEnabled': ctaEnabled,
      'ctaLabel': ctaLabel,
      'jobId': jobId,
      'jobPayload': {
        'id': jobId,
        'title': jobTitle,
        'category': jobCategory,
        'company': companyName,
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

  String _mapSkillTestStatus(
    String status,
    bool hasCompleted,
    bool available,
  ) {
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
}

