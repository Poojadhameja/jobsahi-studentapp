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
  final bool isSaved;
  final bool isApplied;

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
    this.isSaved = false,
    this.isApplied = false,
  });

  factory JobInfoApi.fromJson(Map<String, dynamic> json) {
    // Parse is_saved and is_applied (can be int 0/1 or bool)
    final isSavedValue = json['is_saved'];
    final isAppliedValue = json['is_applied'];
    
    final isSaved = isSavedValue is bool 
        ? isSavedValue 
        : (isSavedValue is int ? isSavedValue == 1 : false);
    
    final isApplied = isAppliedValue is bool 
        ? isAppliedValue 
        : (isAppliedValue is int ? isAppliedValue == 1 : false);
    
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
      isSaved: isSaved,
      isApplied: isApplied,
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
      'is_saved': isSaved ? 1 : 0,
      'is_applied': isApplied ? 1 : 0,
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

/// Saved Job Data Model
class SavedJobData {
  final int savedJobId;
  final int jobId;
  final String jobTitle;
  final int studentId;
  final String savedAt;

  const SavedJobData({
    required this.savedJobId,
    required this.jobId,
    required this.jobTitle,
    required this.studentId,
    required this.savedAt,
  });

  factory SavedJobData.fromJson(Map<String, dynamic> json) {
    return SavedJobData(
      savedJobId: json['saved_job_id'] ?? 0,
      jobId: json['job_id'] ?? 0,
      jobTitle: json['job_title']?.toString() ?? '',
      studentId: json['student_id'] ?? 0,
      savedAt: json['saved_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saved_job_id': savedJobId,
      'job_id': jobId,
      'job_title': jobTitle,
      'student_id': studentId,
      'saved_at': savedAt,
    };
  }
}

/// Save Job API Response Model
/// Handles all response scenarios: success, already saved, job not found, invalid token
class SaveJobResponse {
  final bool status;
  final String message;
  final SavedJobData? data;
  final bool? alreadySaved;
  final String? timestamp;

  const SaveJobResponse({
    required this.status,
    required this.message,
    this.data,
    this.alreadySaved,
    this.timestamp,
  });

  factory SaveJobResponse.fromJson(Map<String, dynamic> json) {
    return SaveJobResponse(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? SavedJobData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      alreadySaved: json['already_saved'] as bool?,
      timestamp: json['timestamp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
      if (alreadySaved != null) 'already_saved': alreadySaved,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }

  /// Check if job was successfully saved
  bool get isSuccess => status && data != null;

  /// Check if job is already saved
  bool get isAlreadySaved => alreadySaved == true;

  /// Check if job was not found
  bool get isJobNotFound =>
      !status && message.toLowerCase().contains('not found');

  /// Check if token is invalid
  bool get isInvalidToken =>
      !status && message.toLowerCase().contains('invalid token');
}

/// Unsave Job Data Model
class UnsaveJobData {
  final int jobId;
  final String jobTitle;
  final int studentId;

  const UnsaveJobData({
    required this.jobId,
    required this.jobTitle,
    required this.studentId,
  });

  factory UnsaveJobData.fromJson(Map<String, dynamic> json) {
    return UnsaveJobData(
      jobId: json['job_id'] ?? 0,
      jobTitle: json['job_title']?.toString() ?? '',
      studentId: json['student_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'job_title': jobTitle,
      'student_id': studentId,
    };
  }
}

/// Unsave Job API Response Model
class UnsaveJobResponse {
  final bool status;
  final String message;
  final UnsaveJobData? data;
  final String? timestamp;

  const UnsaveJobResponse({
    required this.status,
    required this.message,
    this.data,
    this.timestamp,
  });

  factory UnsaveJobResponse.fromJson(Map<String, dynamic> json) {
    return UnsaveJobResponse(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? UnsaveJobData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      timestamp: json['timestamp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
      if (timestamp != null) 'timestamp': timestamp,
    };
  }

  bool get isSuccess => status && data != null;
  bool get isJobNotSaved =>
      !status &&
      (message.toLowerCase().contains('not saved') ||
          message.toLowerCase().contains("doesn't exist"));
}

/// Saved Job Company Information
class SavedJobCompany {
  final String companyName;
  final String companyLogo;
  final String industry;
  final String website;

  const SavedJobCompany({
    required this.companyName,
    required this.companyLogo,
    required this.industry,
    required this.website,
  });

  factory SavedJobCompany.fromJson(Map<String, dynamic> json) {
    return SavedJobCompany(
      companyName: json['company_name']?.toString() ?? '',
      companyLogo: json['company_logo']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'company_logo': companyLogo,
      'industry': industry,
      'website': website,
    };
  }
}

/// Saved Job Data from API
class SavedJobItem {
  final int savedJobId;
  final int jobId;
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
  final String jobCreatedAt;
  final String savedAt;
  final SavedJobCompany company;

  const SavedJobItem({
    required this.savedJobId,
    required this.jobId,
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
    required this.jobCreatedAt,
    required this.savedAt,
    required this.company,
  });

  factory SavedJobItem.fromJson(Map<String, dynamic> json) {
    return SavedJobItem(
      savedJobId: json['saved_job_id'] ?? 0,
      jobId: json['job_id'] ?? 0,
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
      jobCreatedAt: json['job_created_at']?.toString() ?? '',
      savedAt: json['saved_at']?.toString() ?? '',
      company: SavedJobCompany.fromJson(
        json['company'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  static List<String> _parseSkills(dynamic skillsData) {
    if (skillsData == null) return [];
    if (skillsData is List) {
      return skillsData.map((skill) => skill.toString()).toList();
    } else if (skillsData is String) {
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
      'saved_job_id': savedJobId,
      'job_id': jobId,
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
      'job_created_at': jobCreatedAt,
      'saved_at': savedAt,
      'company': company.toJson(),
    };
  }

  /// Convert to Map format with deep conversion to avoid LinkedMap/IdentityMap issues
  Map<String, dynamic> toMap() {
    dynamic _deepConvert(dynamic value) {
      if (value is Map) {
        return Map<String, dynamic>.from(
          value.map((k, v) => MapEntry(k.toString(), _deepConvert(v)))
        );
      } else if (value is List) {
        return value.map((e) => _deepConvert(e)).toList();
      }
      return value;
    }

    final baseMap = {
      'id': jobId.toString(),
      'saved_job_id': savedJobId.toString(),
      'title': title,
      'description': description,
      'location': location,
      'skills_required': skillsRequired,
      'skillsList': skillsRequired,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'salaryMin': salaryMin.toString(),
      'salaryMax': salaryMax.toString(),
      'job_type': jobType,
      'jobType': jobType,
      'experience_required': experienceRequired,
      'experienceRequired': experienceRequired,
      'application_deadline': applicationDeadline,
      'applicationDeadline': applicationDeadline,
      'is_remote': isRemote,
      'isRemote': isRemote,
      'no_of_vacancies': noOfVacancies,
      'noOfVacancies': noOfVacancies,
      'status': status,
      'created_at': jobCreatedAt,
      'saved_at': savedAt,
      'company_name': company.companyName,
      'company_logo': company.companyLogo,
      'company': {
        'company_name': company.companyName,
        'company_logo': company.companyLogo,
        'industry': company.industry,
        'website': company.website,
      },
      'is_saved': true,
    };

    return _deepConvert(baseMap) as Map<String, dynamic>;
  }
}

/// Pagination Information
class PaginationInfo {
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  const PaginationInfo({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 20,
      offset: json['offset'] ?? 0,
      hasMore: json['has_more'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'limit': limit,
      'offset': offset,
      'has_more': hasMore,
    };
  }
}

/// Get Saved Jobs API Response Model
class SavedJobsResponse {
  final bool status;
  final String message;
  final List<SavedJobItem> data;
  final PaginationInfo? pagination;
  final String? timestamp;

  const SavedJobsResponse({
    required this.status,
    required this.message,
    required this.data,
    this.pagination,
    this.timestamp,
  });

  factory SavedJobsResponse.fromJson(Map<String, dynamic> json) {
    return SavedJobsResponse(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((item) =>
                  SavedJobItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? PaginationInfo.fromJson(
              json['pagination'] as Map<String, dynamic>)
          : null,
      timestamp: json['timestamp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
      if (pagination != null) 'pagination': pagination!.toJson(),
      if (timestamp != null) 'timestamp': timestamp,
    };
  }
}
