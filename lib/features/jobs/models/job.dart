/// Company information model
class CompanyInfo {
  final int recruiterId;
  final String companyName;
  final String companyLogo;
  final String industry;
  final String website;
  final String location;

  const CompanyInfo({
    required this.recruiterId,
    required this.companyName,
    required this.companyLogo,
    required this.industry,
    required this.website,
    required this.location,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      recruiterId: json['recruiter_id'] ?? 0,
      companyName: json['company_name']?.toString() ?? '',
      companyLogo: json['company_logo']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recruiter_id': recruiterId,
      'company_name': companyName,
      'company_logo': companyLogo,
      'industry': industry,
      'website': website,
      'location': location,
    };
  }
}

/// Job statistics model
class JobStatistics {
  final int totalViews;
  final int totalApplications;
  final int pendingApplications;
  final int shortlistedApplications;
  final int selectedApplications;
  final int timesSaved;

  const JobStatistics({
    required this.totalViews,
    required this.totalApplications,
    required this.pendingApplications,
    required this.shortlistedApplications,
    required this.selectedApplications,
    required this.timesSaved,
  });

  factory JobStatistics.fromJson(Map<String, dynamic> json) {
    return JobStatistics(
      totalViews: json['total_views'] ?? 0,
      totalApplications: json['total_applications'] ?? 0,
      pendingApplications: json['pending_applications'] ?? 0,
      shortlistedApplications: json['shortlisted_applications'] ?? 0,
      selectedApplications: json['selected_applications'] ?? 0,
      timesSaved: json['times_saved'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_views': totalViews,
      'total_applications': totalApplications,
      'pending_applications': pendingApplications,
      'shortlisted_applications': shortlistedApplications,
      'selected_applications': selectedApplications,
      'times_saved': timesSaved,
    };
  }
}

/// Job model representing a job posting from the API
class Job {
  final int id;
  final int? recruiterId;
  final String title;
  final String description;
  final String location;
  final List<String> skillsRequired;
  final String salaryMin;
  final String salaryMax;
  final String jobType;
  final String experienceRequired;
  final String applicationDeadline;
  final bool isRemote;
  final int noOfVacancies;
  final String status;
  final String adminAction;
  final String createdAt;
  final int views;
  final String? companyName; // New field for company name

  const Job({
    required this.id,
    this.recruiterId,
    required this.title,
    required this.description,
    required this.location,
    required this.skillsRequired,
    required this.salaryMin,
    required this.salaryMax,
    required this.jobType,
    required this.experienceRequired,
    required this.applicationDeadline,
    required this.isRemote,
    required this.noOfVacancies,
    required this.status,
    required this.adminAction,
    required this.createdAt,
    required this.views,
    this.companyName, // Optional company name
  });

  /// Create Job from JSON
  /// Helper method to parse skills from different formats
  static List<String> _parseSkills(dynamic skillsData) {
    if (skillsData == null) return [];

    if (skillsData is List) {
      return skillsData.map((skill) => skill.toString()).toList();
    } else if (skillsData is String) {
      // Handle comma-separated string
      return skillsData
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList();
    }

    return [];
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as int,
      recruiterId: json['recruiter_id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      skillsRequired: _parseSkills(json['skills_required']),
      salaryMin: json['salary_min'] as String? ?? '0',
      salaryMax: json['salary_max'] as String? ?? '0',
      jobType: json['job_type'] as String? ?? '',
      experienceRequired: json['experience_required'] as String? ?? '',
      applicationDeadline: json['application_deadline'] as String? ?? '',
      isRemote: (json['is_remote'] as int? ?? 0) == 1,
      noOfVacancies: json['no_of_vacancies'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      adminAction: json['admin_action'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      views: json['views'] as int? ?? 0,
      companyName:
          json['company_name'] as String?, // Parse company_name from API
    );
  }

  /// Convert Job to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recruiter_id': recruiterId,
      'title': title,
      'description': description,
      'location': location,
      'skills_required': skillsRequired,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'job_type': jobType,
      'experience_required': experienceRequired,
      'application_deadline': applicationDeadline,
      'is_remote': isRemote ? 1 : 0,
      'no_of_vacancies': noOfVacancies,
      'status': status,
      'admin_action': adminAction,
      'created_at': createdAt,
      'views': views,
      'company_name': companyName, // Include company_name in JSON output
    };
  }

  /// Get formatted salary range
  String get formattedSalary {
    final min = double.tryParse(salaryMin) ?? 0;
    final max = double.tryParse(salaryMax) ?? 0;

    if (min == 0 && max == 0) return 'Salary not specified';
    if (min == 0) return 'Up to ₹${_formatSalary(max)}';
    if (max == 0) return '₹${_formatSalary(min)}+';
    if (min == max) return '₹${_formatSalary(min)}';

    return '₹${_formatSalary(min)} - ₹${_formatSalary(max)}';
  }

  /// Format salary value
  String _formatSalary(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  /// Get skills as a list
  List<String> get skillsList {
    return skillsRequired;
  }

  /// Get time since creation
  String get timeAgo {
    try {
      final created = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(created);

      if (difference.inDays > 0) {
        return '${difference.inDays} दिन पहले';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} घंटे पहले';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} मिनट पहले';
      } else {
        return 'अभी';
      }
    } catch (e) {
      return 'अज्ञात';
    }
  }

  /// Check if job is active
  bool get isActive =>
      status.toLowerCase() == 'open' && adminAction.toLowerCase() == 'approved';

  /// Get job type display text
  String get jobTypeDisplay {
    switch (jobType.toLowerCase()) {
      case 'full_time':
        return 'Full-Time';
      case 'part_time':
        return 'Part-Time';
      case 'contract':
        return 'Contract';
      case 'internship':
        return 'Internship';
      default:
        return 'Full-Time';
    }
  }

  @override
  String toString() {
    return 'Job(id: $id, title: $title, location: $location, salary: $formattedSalary)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Job && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Job details API response model
class JobDetailsResponse {
  final bool status;
  final String message;
  final Job jobInfo;
  final CompanyInfo companyInfo;
  final JobStatistics statistics;
  final String timestamp;

  const JobDetailsResponse({
    required this.status,
    required this.message,
    required this.jobInfo,
    required this.companyInfo,
    required this.statistics,
    required this.timestamp,
  });

  factory JobDetailsResponse.fromJson(Map<String, dynamic> json) {
    return JobDetailsResponse(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      jobInfo: Job.fromJson(json['data']['job_info'] ?? {}),
      companyInfo: CompanyInfo.fromJson(json['data']['company_info'] ?? {}),
      statistics: JobStatistics.fromJson(json['data']['statistics'] ?? {}),
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': {
        'job_info': jobInfo.toJson(),
        'company_info': companyInfo.toJson(),
        'statistics': statistics.toJson(),
      },
      'timestamp': timestamp,
    };
  }
}
