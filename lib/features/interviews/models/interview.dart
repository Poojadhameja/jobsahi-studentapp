/// Interview model
class Interview {
  final int interviewId;
  final int jobId;
  final String jobTitle;
  final String companyName;
  final String scheduledAt;
  final String mode;
  final String status;
  final String? location; // null for online interviews
  final String? platformName; // for online interviews
  final String? interviewLink; // for online interviews
  final String? interviewInfo; // interview information/notes
  final double? salaryMin; // from job object
  final double? salaryMax; // from job object
  final String? appliedAt; // from job object

  const Interview({
    required this.interviewId,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.scheduledAt,
    required this.mode,
    required this.status,
    this.location,
    this.platformName,
    this.interviewLink,
    this.interviewInfo,
    this.salaryMin,
    this.salaryMax,
    this.appliedAt,
  });

  factory Interview.fromJson(Map<String, dynamic> json) {
    // Handle new nested structure: {interview: {...}, job: {...}, company_name: "...", job_id: ...}
    Map<String, dynamic> interviewData;
    Map<String, dynamic> jobData;
    String companyName;

    if (json.containsKey('interview') && json.containsKey('job')) {
      // New nested structure
      interviewData = json['interview'] as Map<String, dynamic>? ?? {};
      jobData = json['job'] as Map<String, dynamic>? ?? {};
      companyName = json['company_name'] as String? ?? '';
    } else {
      // Old flat structure (for backward compatibility)
      interviewData = json;
      jobData = {
        'id': json['job_id'] as int? ?? 0,
        'title': json['job_title'] as String? ?? '',
      };
      companyName = json['company_name'] as String? ?? '';
    }

    // Extract job_id from top level (new API structure) or from job/interview data
    final topLevelJobId = json['job_id'] as int?;
    final jobIdFromJob = jobData['id'] as int?;
    final jobIdFromInterview = interviewData['job_id'] as int?;
    final finalJobId = topLevelJobId ?? jobIdFromJob ?? jobIdFromInterview ?? 0;

    // Extract salary and applied_at from job data
    final salaryMinRaw = jobData['salary_min'];
    final salaryMaxRaw = jobData['salary_max'];
    final double? salaryMin = salaryMinRaw != null
        ? (salaryMinRaw is num
              ? salaryMinRaw.toDouble()
              : double.tryParse(salaryMinRaw.toString()))
        : null;
    final double? salaryMax = salaryMaxRaw != null
        ? (salaryMaxRaw is num
              ? salaryMaxRaw.toDouble()
              : double.tryParse(salaryMaxRaw.toString()))
        : null;
    final String? appliedAt = jobData['applied_at'] as String?;

    return Interview(
      interviewId:
          interviewData['id'] as int? ??
          interviewData['interview_id'] as int? ??
          0,
      jobId: finalJobId,
      jobTitle:
          jobData['title'] as String? ??
          interviewData['job_title'] as String? ??
          '',
      companyName: companyName,
      scheduledAt: interviewData['scheduled_at'] as String? ?? '',
      mode: interviewData['mode'] as String? ?? 'online',
      status: interviewData['status'] as String? ?? 'scheduled',
      location: interviewData['location'] as String?,
      platformName: interviewData['platform_name'] as String?,
      interviewLink: interviewData['interview_link'] as String?,
      interviewInfo: interviewData['interview_info'] as String?,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      appliedAt: appliedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interview_id': interviewId,
      'job_id': jobId,
      'job_title': jobTitle,
      'company_name': companyName,
      'scheduled_at': scheduledAt,
      'mode': mode,
      'status': status,
      'location': location,
      'platform_name': platformName,
      'interview_link': interviewLink,
      'interview_info': interviewInfo,
    };
  }

  /// Convert to Map format for UI compatibility
  Map<String, dynamic> toMap() {
    // For online: use platform_name (not link), for offline: use location
    final displayLocation = mode.toLowerCase() == 'online'
        ? (platformName ?? '')
        : (location ?? '');

    // Format salary range
    String salaryText = '';
    if (salaryMin != null && salaryMax != null) {
      salaryText = _formatSalaryRange(salaryMin!, salaryMax!);
    } else if (salaryMin != null) {
      salaryText = _formatSalaryValue(salaryMin!);
    } else if (salaryMax != null) {
      salaryText = _formatSalaryValue(salaryMax!);
    }

    // Format applied date and time
    String appliedDate = '';
    String appliedTime = '';
    if (appliedAt != null && appliedAt!.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(appliedAt!);
        final day = dateTime.day.toString().padLeft(2, '0');
        final month = _getMonthName(dateTime.month);
        final year = dateTime.year.toString();
        appliedDate = '$day $month $year';

        final hour = dateTime.hour;
        final minute = dateTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        appliedTime = '$displayHour:$minute $period';
      } catch (e) {
        appliedDate = appliedAt!;
      }
    }

    return {
      'interview_id': interviewId,
      'id': interviewId.toString(),
      'job_id': jobId, // Include as int
      'jobId': jobId.toString(), // Also include as string for compatibility
      'job_title': jobTitle,
      'title': jobTitle,
      'company_name': companyName,
      'company': companyName,
      'scheduled_at': scheduledAt,
      'scheduledAt': scheduledAt,
      'mode': mode,
      'status': status,
      'location': displayLocation,
      'platform_name': platformName,
      'interview_link': interviewLink,
      'interview_info': interviewInfo,
      'interviewDate': scheduledAt.isNotEmpty ? _formatDate(scheduledAt) : '',
      'interviewTime': scheduledAt.isNotEmpty ? _formatTime(scheduledAt) : '',
      'salary': salaryText,
      'salary_min': salaryMin?.toString() ?? '',
      'salary_max': salaryMax?.toString() ?? '',
      'applied_at': appliedAt ?? '',
      'appliedDate': appliedDate,
      'appliedTime': appliedTime,
    };
  }

  String _formatSalaryRange(double min, double max) {
    String formatValue(double value) {
      if (value >= 100000) {
        return '₹${(value / 100000).toStringAsFixed(1)}L';
      }
      if (value >= 1000) {
        return '₹${(value / 1000).toStringAsFixed(1)}K';
      }
      return '₹${value.toStringAsFixed(0)}';
    }

    return '${formatValue(min)} - ${formatValue(max)}';
  }

  String _formatSalaryValue(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    }
    if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  String _formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = _getMonthName(dateTime.month);
      final year = dateTime.year.toString();
      return '$day $month $year';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return dateTimeString;
    }
  }

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
    return months[month - 1];
  }
}

/// Interviews API response model
class InterviewsResponse {
  final String message;
  final bool status;
  final int count;
  final List<Interview> data;
  final String timestamp;

  const InterviewsResponse({
    required this.message,
    required this.status,
    required this.count,
    required this.data,
    required this.timestamp,
  });

  factory InterviewsResponse.fromJson(Map<String, dynamic> json) {
    return InterviewsResponse(
      message: json['message'] as String? ?? '',
      status: json['status'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (interviewJson) =>
                    Interview.fromJson(interviewJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}
