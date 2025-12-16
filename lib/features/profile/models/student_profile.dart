import 'dart:convert';

/// Student Profile Models
/// Models for the student profile API response

class StudentProfileResponse {
  final bool success;
  final String message;
  final StudentProfileData data;
  final StudentProfileMeta? meta;

  StudentProfileResponse({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });

  factory StudentProfileResponse.fromJson(Map<String, dynamic> json) {
    return StudentProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: StudentProfileData.fromJson(json['data'] ?? {}),
      meta: json['meta'] != null
          ? StudentProfileMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}

class StudentProfileData {
  final List<StudentProfile> profiles;

  StudentProfileData({required this.profiles});

  factory StudentProfileData.fromJson(Map<String, dynamic> json) {
    return StudentProfileData(
      profiles:
          (json['profiles'] as List<dynamic>?)
              ?.map((profile) => StudentProfile.fromJson(profile))
              .toList() ??
          [],
    );
  }
}

class StudentProfile {
  final int profileId;
  final int userId;
  final PersonalInfo personalInfo;
  final ContactInfo? contactInfo;
  final ProfessionalInfo professionalInfo;
  final Documents documents;
  final List<SocialLink> socialLinks; // ✅ Array of objects
  final AdditionalInfo additionalInfo;

  StudentProfile({
    required this.profileId,
    required this.userId,
    required this.personalInfo,
    this.contactInfo,
    required this.professionalInfo,
    required this.documents,
    required this.socialLinks,
    required this.additionalInfo,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      profileId: json['profile_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      personalInfo: PersonalInfo.fromJson(json['personal_info'] ?? {}),
      contactInfo: json['contact_info'] != null
          ? ContactInfo.fromJson(json['contact_info'] as Map<String, dynamic>)
          : null,
      professionalInfo: ProfessionalInfo.fromJson(
        json['professional_info'] ?? {},
      ),
      documents: Documents.fromJson(json['documents'] ?? {}),
      socialLinks:
          (json['social_links'] as List<dynamic>?)
              ?.map((link) => SocialLink.fromJson(link as Map<String, dynamic>))
              .toList() ??
          [],
      additionalInfo: AdditionalInfo.fromJson(json['additional_info'] ?? {}),
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
  final String? profileImage;

  PersonalInfo({
    required this.email,
    required this.userName,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.profileImage,
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
      profileImage: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'user_name': userName,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'profile_image': profileImage,
    };
  }
}

class ContactInfo {
  final String contactEmail;
  final String contactPhone;

  ContactInfo({required this.contactEmail, required this.contactPhone});

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      contactEmail: json['contact_email'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'contact_email': contactEmail, 'contact_phone': contactPhone};
  }
}

class ProfessionalInfo {
  final List<String> skills; // ✅ Array of strings
  final List<Education> education; // ✅ Array of objects
  final List<Experience> experience; // ✅ Array of objects
  final List<Project> projects; // ✅ Array of objects
  final String jobType;
  final String trade;
  final List<String> languages; // ✅ Array of strings

  ProfessionalInfo({
    required this.skills,
    required this.education,
    required this.experience,
    required this.projects,
    required this.jobType,
    required this.trade,
    required this.languages,
  });

  factory ProfessionalInfo.fromJson(Map<String, dynamic> json) {
    // Parse skills - can be List or comma-separated string
    List<String> skillsList = [];
    final skillsData = json['skills'];
    if (skillsData != null) {
      if (skillsData is List) {
        skillsList = skillsData.map((s) => s.toString()).toList();
      } else if (skillsData is String) {
        skillsList = skillsData
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }

    // Parse education - should be a List
    List<Education> educationList = [];
    final educationData = json['education'];
    if (educationData != null && educationData is List) {
      educationList = educationData
          .map((edu) => Education.fromJson(edu as Map<String, dynamic>))
          .toList();
    }

    // Parse experience - should be a List
    List<Experience> experienceList = [];
    final experienceData = json['experience'];
    if (experienceData != null && experienceData is List) {
      experienceList = experienceData
          .map((exp) => Experience.fromJson(exp as Map<String, dynamic>))
          .toList();
    }

    // Parse languages - can be List or comma-separated string
    List<String> languagesList = [];
    final languagesData = json['languages'];
    if (languagesData != null) {
      if (languagesData is List) {
        languagesList = languagesData.map((l) => l.toString()).toList();
      } else if (languagesData is String) {
        languagesList = languagesData
            .split(',')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();
      }
    }

    return ProfessionalInfo(
      skills: skillsList,
      education: educationList,
      experience: experienceList,
      projects:
          (json['projects'] as List<dynamic>?)
              ?.map(
                (project) => Project.fromJson(project as Map<String, dynamic>),
              )
              .toList() ??
          [],
      jobType: json['job_type'] ?? '',
      trade: json['trade'] ?? '',
      languages: languagesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skills': skills,
      'education': education.map((e) => e.toJson()).toList(),
      'experience': experience.map((e) => e.toJson()).toList(),
      'projects': projects.map((p) => p.toJson()).toList(),
      'job_type': jobType,
      'trade': trade,
      'languages': languages,
    };
  }
}

class Education {
  final String qualification;
  final String institute;
  final String startYear;
  final String endYear;
  final bool isPursuing;
  final int? pursuingYear;
  final double? cgpa;

  Education({
    required this.qualification,
    required this.institute,
    required this.startYear,
    required this.endYear,
    required this.isPursuing,
    this.pursuingYear,
    this.cgpa,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      qualification: json['qualification'] ?? '',
      institute: json['institute'] ?? '',
      startYear: json['start_year']?.toString() ?? '',
      endYear: json['end_year']?.toString() ?? '',
      isPursuing:
          json['is_pursuing'] == true ||
          json['is_pursuing'] == 1 ||
          json['is_pursuing'] == '1',
      pursuingYear: json['pursuing_year'] != null
          ? (json['pursuing_year'] is int
                ? json['pursuing_year'] as int
                : int.tryParse(json['pursuing_year'].toString()))
          : null,
      cgpa: json['cgpa'] != null
          ? (json['cgpa'] is double
                ? json['cgpa'] as double
                : double.tryParse(json['cgpa'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qualification': qualification,
      'institute': institute,
      'start_year': startYear,
      'end_year': endYear,
      'is_pursuing': isPursuing,
      'pursuing_year': pursuingYear,
      'cgpa': cgpa,
    };
  }
}

class Experience {
  final String companyName;
  final String position;
  final String startDate;
  final String endDate;
  final String? companyLocation;
  final String? description;

  Experience({
    required this.companyName,
    required this.position,
    required this.startDate,
    required this.endDate,
    this.companyLocation,
    this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      companyName: json['company_name'] ?? '',
      position: json['position'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      companyLocation: json['company_location'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'position': position,
      'start_date': startDate,
      'end_date': endDate,
      'company_location': companyLocation,
      'description': description,
    };
  }
}

class Project {
  final String name;
  final String link;

  Project({required this.name, required this.link});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(name: json['name'] ?? '', link: json['link'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'link': link};
  }
}

class Certificate {
  final String url;
  final String name;
  final String? uploadedAt;

  Certificate({required this.url, required this.name, this.uploadedAt});

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      url: json['url'] ?? '',
      name: json['name'] ?? '',
      uploadedAt: json['uploaded_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'name': name, 'uploaded_at': uploadedAt};
  }
}

class Documents {
  final String? resume;
  final List<Certificate> certificates; // ✅ Changed to List
  final String? profileImage;
  final String aadharNumber;

  Documents({
    this.resume,
    required this.certificates,
    this.profileImage,
    required this.aadharNumber,
  });

  factory Documents.fromJson(Map<String, dynamic> json) {
    // Handle certificates - can be array or string (backward compatibility)
    List<Certificate> certificatesList = [];
    final certificatesData = json['certificates'];

    if (certificatesData != null) {
      if (certificatesData is List) {
        // New format: Array of certificate objects
        certificatesList = certificatesData
            .map((cert) => Certificate.fromJson(cert as Map<String, dynamic>))
            .toList();
      } else if (certificatesData is String && certificatesData.isNotEmpty) {
        // Old format: Single URL string - convert to array
        try {
          // Try to parse as JSON string first
          final decoded = jsonDecode(certificatesData);
          if (decoded is List) {
            certificatesList = decoded
                .map(
                  (cert) => Certificate.fromJson(cert as Map<String, dynamic>),
                )
                .toList();
          } else {
            // Single URL string
            certificatesList = [
              Certificate(
                url: certificatesData,
                name: certificatesData.split('/').last,
              ),
            ];
          }
        } catch (e) {
          // Not JSON, treat as single URL string
          certificatesList = [
            Certificate(
              url: certificatesData,
              name: certificatesData.split('/').last,
            ),
          ];
        }
      }
    }

    return Documents(
      resume: json['resume']?.toString(),
      certificates: certificatesList,
      profileImage: json['profile_image']?.toString(),
      aadharNumber: json['aadhar_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resume': resume,
      'certificates': certificates.map((c) => c.toJson()).toList(),
      'profile_image': profileImage,
      'aadhar_number': aadharNumber,
    };
  }
}

class SocialLink {
  final String title;
  final String profileUrl;

  SocialLink({required this.title, required this.profileUrl});

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      title: json['title'] ?? '',
      profileUrl: json['profile_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'profile_url': profileUrl};
  }
}

class AdditionalInfo {
  final String bio;

  AdditionalInfo({required this.bio});

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) {
    return AdditionalInfo(bio: json['bio'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'bio': bio};
  }
}

class StudentProfileMeta {
  final String? timestamp;
  final String? apiVersion;

  StudentProfileMeta({this.timestamp, this.apiVersion});

  factory StudentProfileMeta.fromJson(Map<String, dynamic> json) {
    return StudentProfileMeta(
      timestamp: json['timestamp']?.toString(),
      apiVersion: json['api_version']?.toString(),
    );
  }
}
