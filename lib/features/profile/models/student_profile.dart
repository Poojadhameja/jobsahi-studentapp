/// Student Profile Models
/// Models for the student profile API response

class StudentProfileResponse {
  final bool success;
  final String message;
  final StudentProfileData data;
  final StudentProfileMeta meta;

  StudentProfileResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory StudentProfileResponse.fromJson(Map<String, dynamic> json) {
    return StudentProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: StudentProfileData.fromJson(json['data'] ?? {}),
      meta: StudentProfileMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class StudentProfileData {
  final List<StudentProfile> profiles;
  final int totalCount;
  final String userRole;
  final Map<String, dynamic> filtersApplied;

  StudentProfileData({
    required this.profiles,
    required this.totalCount,
    required this.userRole,
    required this.filtersApplied,
  });

  factory StudentProfileData.fromJson(Map<String, dynamic> json) {
    return StudentProfileData(
      profiles:
          (json['profiles'] as List<dynamic>?)
              ?.map((profile) => StudentProfile.fromJson(profile))
              .toList() ??
          [],
      totalCount: json['total_count'] ?? 0,
      userRole: json['user_role'] ?? '',
      filtersApplied: json['filters_applied'] ?? {},
    );
  }
}

class StudentProfile {
  final int profileId;
  final int userId;
  final PersonalInfo personalInfo;
  final ProfessionalInfo professionalInfo;
  final Documents documents;
  final SocialLinks socialLinks;
  final AdditionalInfo additionalInfo;
  final ProfileStatus status;

  StudentProfile({
    required this.profileId,
    required this.userId,
    required this.personalInfo,
    required this.professionalInfo,
    required this.documents,
    required this.socialLinks,
    required this.additionalInfo,
    required this.status,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      profileId: json['profile_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      personalInfo: PersonalInfo.fromJson(json['personal_info'] ?? {}),
      professionalInfo: ProfessionalInfo.fromJson(
        json['professional_info'] ?? {},
      ),
      documents: Documents.fromJson(json['documents'] ?? {}),
      socialLinks: SocialLinks.fromJson(json['social_links'] ?? {}),
      additionalInfo: AdditionalInfo.fromJson(json['additional_info'] ?? {}),
      status: ProfileStatus.fromJson(json['status'] ?? {}),
    );
  }
}

class PersonalInfo {
  final String email;
  final String userName;
  final String phoneNumber;
  final String dateOfBirth;
  final String gender;
  final String location;
  final double latitude;
  final double longitude;

  PersonalInfo({
    required this.email,
    required this.userName,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      email: json['email'] ?? '',
      userName: json['user_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      gender: json['gender'] ?? '',
      location: json['location'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }
}

class ProfessionalInfo {
  final String skills;
  final String education;
  final List<Experience> experience;
  final List<Project> projects;
  final String jobType;
  final String trade;
  final String graduationYear;
  final String cgpa;
  final String languages;

  ProfessionalInfo({
    required this.skills,
    required this.education,
    required this.experience,
    required this.projects,
    required this.jobType,
    required this.trade,
    required this.graduationYear,
    required this.cgpa,
    required this.languages,
  });

  factory ProfessionalInfo.fromJson(Map<String, dynamic> json) {
    // Handle experience field - can be either List or Object
    List<Experience> experienceList = [];
    final experienceData = json['experience'];

    if (experienceData != null) {
      if (experienceData is List) {
        // If it's already a list, parse it directly
        experienceList = experienceData
            .map((exp) => Experience.fromJson(exp as Map<String, dynamic>))
            .toList();
      } else if (experienceData is Map<String, dynamic>) {
        // If it's an object with 'details' field, extract the details array
        final details = experienceData['details'];
        if (details is List && details.isNotEmpty) {
          experienceList = details
              .map((exp) => Experience.fromJson(exp as Map<String, dynamic>))
              .toList();
        }
      }
    }

    return ProfessionalInfo(
      skills: json['skills'] ?? '',
      education: json['education'] ?? '',
      experience: experienceList,
      projects:
          (json['projects'] as List<dynamic>?)
              ?.map((project) => Project.fromJson(project))
              .toList() ??
          [],
      jobType: json['job_type'] ?? '',
      trade: json['trade'] ?? '',
      graduationYear: json['graduation_year'] ?? '',
      cgpa: json['cgpa'] ?? '',
      languages: json['languages'] ?? '',
    );
  }
}

class Experience {
  final String company;
  final String role;
  final String duration;
  final String description;

  Experience({
    required this.company,
    required this.role,
    required this.duration,
    required this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      company: json['company'] ?? '',
      role: json['role'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class Project {
  final String name;
  final String link;

  Project({required this.name, required this.link});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(name: json['name'] ?? '', link: json['link'] ?? '');
  }
}

class Documents {
  final String resume;
  final String certificates;
  final String aadharNumber;

  Documents({
    required this.resume,
    required this.certificates,
    required this.aadharNumber,
  });

  factory Documents.fromJson(Map<String, dynamic> json) {
    return Documents(
      resume: json['resume'] ?? '',
      certificates: json['certificates'] ?? '',
      aadharNumber: json['aadhar_number'] ?? '',
    );
  }
}

class SocialLinks {
  final String portfolioLink;
  final String linkedinUrl;

  SocialLinks({required this.portfolioLink, required this.linkedinUrl});

  factory SocialLinks.fromJson(Map<String, dynamic> json) {
    return SocialLinks(
      portfolioLink: json['portfolio_link'] ?? '',
      linkedinUrl: json['linkedin_url'] ?? '',
    );
  }
}

class AdditionalInfo {
  final String bio;

  AdditionalInfo({required this.bio});

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) {
    return AdditionalInfo(bio: json['bio'] ?? '');
  }
}

class ProfileStatus {
  final String adminAction;
  final String createdAt;
  final String modifiedAt;

  ProfileStatus({
    required this.adminAction,
    required this.createdAt,
    required this.modifiedAt,
  });

  factory ProfileStatus.fromJson(Map<String, dynamic> json) {
    return ProfileStatus(
      adminAction: json['admin_action'] ?? '',
      createdAt: json['created_at'] ?? '',
      modifiedAt: json['modified_at'] ?? '',
    );
  }
}

class StudentProfileMeta {
  final String timestamp;
  final String apiVersion;
  final String responseFormat;

  StudentProfileMeta({
    required this.timestamp,
    required this.apiVersion,
    required this.responseFormat,
  });

  factory StudentProfileMeta.fromJson(Map<String, dynamic> json) {
    return StudentProfileMeta(
      timestamp: json['timestamp'] ?? '',
      apiVersion: json['api_version'] ?? '',
      responseFormat: json['response_format'] ?? '',
    );
  }
}
