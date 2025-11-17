import 'job.dart';

/// Job Detail API Response Model
class JobDetailResponse {
  final String message;
  final bool status;
  final JobDetailData data;
  final String timestamp;

  const JobDetailResponse({
    required this.message,
    required this.status,
    required this.data,
    required this.timestamp,
  });

  factory JobDetailResponse.fromJson(Map<String, dynamic> json) {
    return JobDetailResponse(
      message: json['message'] as String? ?? '',
      status: json['status'] as bool? ?? false,
      data: JobDetailData.fromJson(json['data'] as Map<String, dynamic>),
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'data': data.toJson(),
      'timestamp': timestamp,
    };
  }
}

/// Job Detail Data Model containing job info, company info, and statistics
class JobDetailData {
  final JobInfo jobInfo;
  final CompanyInfo companyInfo;
  final JobStatistics statistics;

  const JobDetailData({
    required this.jobInfo,
    required this.companyInfo,
    required this.statistics,
  });

  factory JobDetailData.fromJson(Map<String, dynamic> json) {
    return JobDetailData(
      jobInfo: JobInfo.fromJson(json['job_info'] as Map<String, dynamic>),
      companyInfo: CompanyInfo.fromJson(
        json['company_info'] as Map<String, dynamic>,
      ),
      statistics: JobStatistics.fromJson(
        json['statistics'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_info': jobInfo.toJson(),
      'company_info': companyInfo.toJson(),
      'statistics': statistics.toJson(),
    };
  }
}

/// Job Information Model
class JobInfo {
  final int id;
  final String title;
  final String description;
  final String location;
  final List<String> skillsRequired;
  final double salaryMin;
  final double salaryMax;
  final String jobType;
  final String experienceRequired;
  final String applicationDeadline;
  final bool isRemote;
  final int noOfVacancies;
  final String status;
  final String adminAction;
  final String createdAt;
  final bool isSaved;
  final bool isApplied;

  const JobInfo({
    required this.id,
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
    this.isSaved = false,
    this.isApplied = false,
  });

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

  factory JobInfo.fromJson(Map<String, dynamic> json) {
    return JobInfo(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      skillsRequired: _parseSkills(json['skills_required']),
      salaryMin: (json['salary_min'] as num?)?.toDouble() ?? 0.0,
      salaryMax: (json['salary_max'] as num?)?.toDouble() ?? 0.0,
      jobType: json['job_type'] as String? ?? '',
      experienceRequired: json['experience_required'] as String? ?? '',
      applicationDeadline: json['application_deadline'] as String? ?? '',
      isRemote: json['is_remote'] as bool? ?? false,
      noOfVacancies: json['no_of_vacancies'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      adminAction: json['admin_action'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'skills_required': skillsRequired,
      'requirements': skillsRequired, // For backward compatibility with UI
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'job_type': jobType,
      'experience_required': experienceRequired,
      'application_deadline': applicationDeadline,
      'is_remote': isRemote,
      'no_of_vacancies': noOfVacancies,
      'status': status,
      'admin_action': adminAction,
      'created_at': createdAt,
    };
  }

  /// Get formatted salary range
  String get formattedSalary {
    if (salaryMin == 0 && salaryMax == 0) return 'Salary not specified';
    if (salaryMin == 0) return 'Up to ₹${_formatSalary(salaryMax)}';
    if (salaryMax == 0) return '₹${_formatSalary(salaryMin)}+';
    if (salaryMin == salaryMax) return '₹${_formatSalary(salaryMin)}';

    return '₹${_formatSalary(salaryMin)} - ₹${_formatSalary(salaryMax)}';
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

  /// Check if job is active
  bool get isActive =>
      status.toLowerCase() == 'open' && adminAction.toLowerCase() == 'approved';

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

  /// Convert to legacy Job model for compatibility
  Job toJob() {
    return Job(
      id: id,
      title: title,
      description: description,
      location: location,
      skillsRequired: skillsRequired,
      salaryMin: salaryMin.toString(),
      salaryMax: salaryMax.toString(),
      jobType: jobType,
      experienceRequired: experienceRequired,
      applicationDeadline: applicationDeadline,
      isRemote: isRemote,
      noOfVacancies: noOfVacancies,
      status: status,
      adminAction: adminAction,
      createdAt: createdAt,
      views: 0, // This will be populated from statistics
      companyName: null, // Will be populated from API response
    );
  }
}

/// Company Information Model
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
      recruiterId: json['recruiter_id'] as int? ?? 0,
      companyName: json['company_name'] as String? ?? '',
      companyLogo: json['company_logo'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      website: json['website'] as String? ?? '',
      location: json['location'] as String? ?? '',
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

/// Job Statistics Model
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
      totalViews: json['total_views'] as int? ?? 0,
      totalApplications: json['total_applications'] as int? ?? 0,
      pendingApplications: json['pending_applications'] as int? ?? 0,
      shortlistedApplications: json['shortlisted_applications'] as int? ?? 0,
      selectedApplications: json['selected_applications'] as int? ?? 0,
      timesSaved: json['times_saved'] as int? ?? 0,
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
