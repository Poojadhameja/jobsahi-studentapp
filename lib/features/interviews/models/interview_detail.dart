/// Interview Detail model
/// Represents the full interview details from the API
class InterviewDetail {
  final int interviewId;
  final int applicationId;
  final String scheduledAt;
  final String mode;
  final String? interviewLocation; // null for online interviews
  final String interviewStatus;
  final String? interviewInfo; // renamed from feedback
  final String? platformName; // for online interviews
  final String? interviewLink; // for online interviews
  final String interviewCreatedAt;
  final String adminAction;
  final List<Panelist> panel;
  final ApplicationInfo application;
  final JobInfo job;
  final CompanyInfo company;

  const InterviewDetail({
    required this.interviewId,
    required this.applicationId,
    required this.scheduledAt,
    required this.mode,
    this.interviewLocation,
    required this.interviewStatus,
    this.interviewInfo,
    this.platformName,
    this.interviewLink,
    required this.interviewCreatedAt,
    required this.adminAction,
    required this.panel,
    required this.application,
    required this.job,
    required this.company,
  });

  factory InterviewDetail.fromJson(Map<String, dynamic> json) {
    // Handle new nested structure: {interview: {...}, application: {...}, job: {...}, company: {...}}
    Map<String, dynamic> interviewData;
    Map<String, dynamic> applicationData;
    Map<String, dynamic> jobData;
    Map<String, dynamic> companyData;
    
    if (json.containsKey('interview') && 
        json.containsKey('application') && 
        json.containsKey('job') && 
        json.containsKey('company')) {
      // New nested structure
      interviewData = json['interview'] as Map<String, dynamic>? ?? {};
      applicationData = json['application'] as Map<String, dynamic>? ?? {};
      jobData = json['job'] as Map<String, dynamic>? ?? {};
      companyData = json['company'] as Map<String, dynamic>? ?? {};
    } else {
      // Old flat structure (for backward compatibility)
      interviewData = json;
      applicationData = json['application'] as Map<String, dynamic>? ?? {};
      jobData = json['job'] as Map<String, dynamic>? ?? {};
      companyData = json['company'] as Map<String, dynamic>? ?? {};
    }
    
    return InterviewDetail(
      interviewId: interviewData['id'] as int? ?? 
                  interviewData['interview_id'] as int? ?? 0,
      applicationId: interviewData['application_id'] as int? ?? 
                    applicationData['id'] as int? ?? 0,
      scheduledAt: interviewData['scheduled_at'] as String? ?? '',
      mode: interviewData['mode'] as String? ?? 'online',
      interviewLocation: interviewData['location'] as String?,
      interviewStatus: interviewData['status'] as String? ?? 
                      interviewData['interview_status'] as String? ?? 'scheduled',
      interviewInfo: interviewData['interview_info'] as String? ?? 
                    interviewData['feedback'] as String?,
      platformName: interviewData['platform_name'] as String?,
      interviewLink: interviewData['interview_link'] as String?,
      interviewCreatedAt: interviewData['created_at'] as String? ?? 
                         interviewData['interview_created_at'] as String? ?? '',
      adminAction: interviewData['admin_action'] as String? ?? '',
      panel: (interviewData['panel'] as List<dynamic>?)
              ?.map((panelJson) =>
                  Panelist.fromJson(panelJson as Map<String, dynamic>))
              .toList() ??
          [],
      application: ApplicationInfo.fromJson(applicationData),
      job: JobInfo.fromJson(jobData),
      company: CompanyInfo.fromJson(companyData),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interview_id': interviewId,
      'application_id': applicationId,
      'scheduled_at': scheduledAt,
      'mode': mode,
      'interview_location': interviewLocation,
      'interview_status': interviewStatus,
      'interview_info': interviewInfo,
      'platform_name': platformName,
      'interview_link': interviewLink,
      'interview_created_at': interviewCreatedAt,
      'admin_action': adminAction,
      'panel': panel.map((p) => p.toJson()).toList(),
      'application': application.toJson(),
      'job': job.toJson(),
      'company': company.toJson(),
    };
  }
  
  /// Get display location based on mode
  String get displayLocation {
    if (mode.toLowerCase() == 'online') {
      return interviewLink ?? platformName ?? '';
    } else {
      return interviewLocation ?? '';
    }
  }
  
  /// Check if interview is online
  bool get isOnline => mode.toLowerCase() == 'online';

  /// Format date for display
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(scheduledAt);
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = _getMonthName(dateTime.month);
      final year = dateTime.year.toString();
      return '$day $month $year';
    } catch (e) {
      return scheduledAt;
    }
  }

  /// Format time for display
  String get formattedTime {
    try {
      final dateTime = DateTime.parse(scheduledAt);
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return scheduledAt;
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

/// Panelist model
class Panelist {
  final int id;
  final String panelistName;
  final String? feedback;
  final int? rating;

  const Panelist({
    required this.id,
    required this.panelistName,
    this.feedback,
    this.rating,
  });

  factory Panelist.fromJson(Map<String, dynamic> json) {
    return Panelist(
      id: json['id'] as int? ?? 0,
      panelistName: json['panelist_name'] as String? ?? '',
      feedback: json['feedback'] as String?,
      rating: json['rating'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'panelist_name': panelistName,
      'feedback': feedback,
      'rating': rating,
    };
  }
}

/// Application Info model
class ApplicationInfo {
  final int id;
  final int studentId;
  final String status;
  final String appliedAt;
  final String? coverLetter;

  const ApplicationInfo({
    required this.id,
    required this.studentId,
    required this.status,
    required this.appliedAt,
    this.coverLetter,
  });

  factory ApplicationInfo.fromJson(Map<String, dynamic> json) {
    return ApplicationInfo(
      id: json['id'] as int? ?? 0,
      studentId: json['student_id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      appliedAt: json['applied_at'] as String? ?? '',
      coverLetter: json['cover_letter'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'status': status,
      'applied_at': appliedAt,
      'cover_letter': coverLetter,
    };
  }
}

/// Job Info model
class JobInfo {
  final int id;
  final String title;
  final String description;
  final String location;
  final String jobType;
  final double salaryMin;
  final double salaryMax;
  final String experienceRequired;
  final String skillsRequired;
  final String applicationDeadline;
  final bool isRemote;
  final int noOfVacancies;

  const JobInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.jobType,
    required this.salaryMin,
    required this.salaryMax,
    required this.experienceRequired,
    required this.skillsRequired,
    required this.applicationDeadline,
    required this.isRemote,
    required this.noOfVacancies,
  });

  factory JobInfo.fromJson(Map<String, dynamic> json) {
    return JobInfo(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      jobType: json['job_type'] as String? ?? '',
      salaryMin: (json['salary_min'] as num?)?.toDouble() ?? 0.0,
      salaryMax: (json['salary_max'] as num?)?.toDouble() ?? 0.0,
      experienceRequired: json['experience_required'] as String? ?? '',
      skillsRequired: json['skills_required'] as String? ?? '',
      applicationDeadline: json['application_deadline'] as String? ?? '',
      isRemote: json['is_remote'] as bool? ?? false,
      noOfVacancies: json['no_of_vacancies'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'job_type': jobType,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'experience_required': experienceRequired,
      'skills_required': skillsRequired,
      'application_deadline': applicationDeadline,
      'is_remote': isRemote,
      'no_of_vacancies': noOfVacancies,
    };
  }
}

/// Company Info model
class CompanyInfo {
  final int id;
  final String companyName;
  final String companyAddress;

  const CompanyInfo({
    required this.id,
    required this.companyName,
    required this.companyAddress,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      id: json['id'] as int? ?? 0,
      companyName: json['company_name'] as String? ?? '',
      companyAddress: json['company_address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'company_address': companyAddress,
    };
  }
}

/// Interview Detail API response model
class InterviewDetailResponse {
  final String message;
  final bool status;
  final String role;
  final InterviewDetail data;
  final String timestamp;

  const InterviewDetailResponse({
    required this.message,
    required this.status,
    required this.role,
    required this.data,
    required this.timestamp,
  });

  factory InterviewDetailResponse.fromJson(Map<String, dynamic> json) {
    // Extract data object which contains nested interview, application, job, company
    final dataJson = json['data'] as Map<String, dynamic>? ?? {};
    
    return InterviewDetailResponse(
      message: json['message'] as String? ?? '',
      status: json['status'] as bool? ?? false,
      role: json['role'] as String? ?? '',
      data: InterviewDetail.fromJson(dataJson), // Pass nested structure to InterviewDetail
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}

