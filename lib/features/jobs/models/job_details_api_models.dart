/// Job Details API Models
/// Comprehensive models for the job details API response structure

/// Import the Job model for compatibility
import 'job.dart';

/// Job Information from API
class JobInfoApi {
  final int id;
  final String title;
  final String description;
  final String location;
  final List<String> skillsRequired;
  final int salaryMin;
  final int salaryMax;
  final String jobType;
  final String experienceRequired;
  final String applicationDeadline;
  final bool isRemote;
  final int noOfVacancies;
  final String status;
  final String adminAction;
  final String createdAt;

  const JobInfoApi({
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
  });

  factory JobInfoApi.fromJson(Map<String, dynamic> json) {
    return JobInfoApi(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      skillsRequired: _parseSkills(json['skills_required']),
      salaryMin: json['salary_min'] ?? 0,
      salaryMax: json['salary_max'] ?? 0,
      jobType: json['job_type']?.toString() ?? '',
      experienceRequired: json['experience_required']?.toString() ?? '',
      applicationDeadline: json['application_deadline']?.toString() ?? '',
      isRemote: json['is_remote'] ?? false,
      noOfVacancies: json['no_of_vacancies'] ?? 0,
      status: json['status']?.toString() ?? '',
      adminAction: json['admin_action']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'skills_required': skillsRequired,
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
      views: 0, // Will be populated from statistics
      companyName: null, // Will be populated from company info
    );
  }
}

/// Company Information from API
class CompanyInfoApi {
  final int recruiterId;
  final String companyName;
  final String companyLogo;
  final String industry;
  final String website;
  final String location;

  const CompanyInfoApi({
    required this.recruiterId,
    required this.companyName,
    required this.companyLogo,
    required this.industry,
    required this.website,
    required this.location,
  });

  factory CompanyInfoApi.fromJson(Map<String, dynamic> json) {
    return CompanyInfoApi(
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

/// Job Statistics from API
class JobStatisticsApi {
  final int totalViews;
  final int totalApplications;
  final int pendingApplications;
  final int shortlistedApplications;
  final int selectedApplications;
  final int timesSaved;

  const JobStatisticsApi({
    required this.totalViews,
    required this.totalApplications,
    required this.pendingApplications,
    required this.shortlistedApplications,
    required this.selectedApplications,
    required this.timesSaved,
  });

  factory JobStatisticsApi.fromJson(Map<String, dynamic> json) {
    return JobStatisticsApi(
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

/// Complete Job Details API Response
class JobDetailsApiResponse {
  final bool status;
  final String message;
  final JobInfoApi jobInfo;
  final CompanyInfoApi companyInfo;
  final JobStatisticsApi statistics;
  final String timestamp;

  const JobDetailsApiResponse({
    required this.status,
    required this.message,
    required this.jobInfo,
    required this.companyInfo,
    required this.statistics,
    required this.timestamp,
  });

  factory JobDetailsApiResponse.fromJson(Map<String, dynamic> json) {
    // Check if data field exists
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid response format: missing data field');
    }

    return JobDetailsApiResponse(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      jobInfo: JobInfoApi.fromJson(data['job_info'] ?? {}),
      companyInfo: CompanyInfoApi.fromJson(data['company_info'] ?? {}),
      statistics: JobStatisticsApi.fromJson(data['statistics'] ?? {}),
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
