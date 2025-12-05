/// Course model for API responses
class Course {
  final int id;
  final int instituteId;
  final String title;
  final String description;
  final String duration;
  final String fee;
  final String adminAction;
  final String? createdAt;
  // New fields from updated API
  final int? categoryId;
  final String? categoryName;
  final String? taggedSkills;
  final int? batchLimit;
  final String? status;
  final String? instructorName;
  final String? mode; // online/offline
  final bool? certificationAllowed;
  final String? moduleTitle;
  final String? moduleDescription;
  final String? media; // Course banner/image URL
  final String? updatedAt;

  Course({
    required this.id,
    required this.instituteId,
    required this.title,
    required this.description,
    required this.duration,
    required this.fee,
    required this.adminAction,
    this.createdAt,
    this.categoryId,
    this.categoryName,
    this.taggedSkills,
    this.batchLimit,
    this.status,
    this.instructorName,
    this.mode,
    this.certificationAllowed,
    this.moduleTitle,
    this.moduleDescription,
    this.media,
    this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      instituteId: json['institute_id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      fee: json['fee']?.toString() ?? '0.00',
      adminAction: json['admin_action']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? json['course_created_at']?.toString(),
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name']?.toString(),
      taggedSkills: json['tagged_skills']?.toString(),
      batchLimit: json['batch_limit'] as int?,
      status: json['status']?.toString(),
      instructorName: json['instructor_name']?.toString(),
      mode: json['mode']?.toString(),
      certificationAllowed: json['certification_allowed'] as bool?,
      moduleTitle: json['module_title']?.toString(),
      moduleDescription: json['module_description']?.toString(),
      media: json['media']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institute_id': instituteId,
      'title': title,
      'description': description,
      'duration': duration,
      'fee': fee,
      'admin_action': adminAction,
      if (createdAt != null) 'created_at': createdAt,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryName != null) 'category_name': categoryName,
      if (taggedSkills != null) 'tagged_skills': taggedSkills,
      if (batchLimit != null) 'batch_limit': batchLimit,
      if (status != null) 'status': status,
      if (instructorName != null) 'instructor_name': instructorName,
      if (mode != null) 'mode': mode,
      if (certificationAllowed != null) 'certification_allowed': certificationAllowed,
      if (moduleTitle != null) 'module_title': moduleTitle,
      if (moduleDescription != null) 'module_description': moduleDescription,
      if (media != null) 'media': media,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  // Convert to the format expected by the UI
  Map<String, dynamic> toUIMap() {
    // Parse tagged skills into a list
    final List<String> skillsList = [];
    if (taggedSkills != null && taggedSkills!.isNotEmpty) {
      skillsList.addAll(
        taggedSkills!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
      );
    }

    return {
      'id': id.toString(),
      'title': title,
      'titleEnglish': title, // For compatibility with existing UI
      'description': description,
      'duration': duration,
      'fees': double.tryParse(fee) ?? 0.0,
      'category': categoryName ?? 'General',
      'category_id': categoryId,
      'rating': 4.0, // Default rating
      'totalRatings': 0, // Default ratings count
      'institute': 'Institute $instituteId', // Default institute name
      'institute_id': instituteId,
      'level': 'Beginner', // Default level
      'isSaved': false, // Default saved status
      'imageUrl': media ?? 'assets/images/courses/default.png',
      'media': media,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'status': status,
      'instructor_name': instructorName,
      'mode': mode,
      'certification_allowed': certificationAllowed ?? false,
      'module_title': moduleTitle,
      'module_description': moduleDescription,
      'batch_limit': batchLimit,
      'tagged_skills': taggedSkills,
      'skills_list': skillsList,
      'benefits': [
        if (certificationAllowed == true) 'Industry certification',
        'Professional training',
        'Practical hands-on experience',
        'Career guidance',
      ],
    };
  }

  Course copyWith({
    int? id,
    int? instituteId,
    String? title,
    String? description,
    String? duration,
    String? fee,
    String? adminAction,
    String? createdAt,
    int? categoryId,
    String? categoryName,
    String? taggedSkills,
    int? batchLimit,
    String? status,
    String? instructorName,
    String? mode,
    bool? certificationAllowed,
    String? moduleTitle,
    String? moduleDescription,
    String? media,
    String? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      instituteId: instituteId ?? this.instituteId,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      fee: fee ?? this.fee,
      adminAction: adminAction ?? this.adminAction,
      createdAt: createdAt ?? this.createdAt,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      taggedSkills: taggedSkills ?? this.taggedSkills,
      batchLimit: batchLimit ?? this.batchLimit,
      status: status ?? this.status,
      instructorName: instructorName ?? this.instructorName,
      mode: mode ?? this.mode,
      certificationAllowed: certificationAllowed ?? this.certificationAllowed,
      moduleTitle: moduleTitle ?? this.moduleTitle,
      moduleDescription: moduleDescription ?? this.moduleDescription,
      media: media ?? this.media,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Course &&
        other.id == id &&
        other.instituteId == instituteId &&
        other.title == title &&
        other.description == description &&
        other.duration == duration &&
        other.fee == fee &&
        other.adminAction == adminAction &&
        other.createdAt == createdAt &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        other.taggedSkills == taggedSkills &&
        other.batchLimit == batchLimit &&
        other.status == status &&
        other.instructorName == instructorName &&
        other.mode == mode &&
        other.certificationAllowed == certificationAllowed &&
        other.moduleTitle == moduleTitle &&
        other.moduleDescription == moduleDescription &&
        other.media == media &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        instituteId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        duration.hashCode ^
        fee.hashCode ^
        adminAction.hashCode ^
        (createdAt?.hashCode ?? 0) ^
        (categoryId?.hashCode ?? 0) ^
        (categoryName?.hashCode ?? 0) ^
        (taggedSkills?.hashCode ?? 0) ^
        (batchLimit?.hashCode ?? 0) ^
        (status?.hashCode ?? 0) ^
        (instructorName?.hashCode ?? 0) ^
        (mode?.hashCode ?? 0) ^
        (certificationAllowed?.hashCode ?? 0) ^
        (moduleTitle?.hashCode ?? 0) ^
        (moduleDescription?.hashCode ?? 0) ^
        (media?.hashCode ?? 0) ^
        (updatedAt?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'Course(id: $id, instituteId: $instituteId, title: $title, duration: $duration, fee: $fee, adminAction: $adminAction)';
  }
}

/// Courses API response model
class CoursesResponse {
  final bool status;
  final String message;
  final List<Course> courses;
  final int totalCount;
  final String userRole;

  CoursesResponse({
    required this.status,
    required this.message,
    required this.courses,
    required this.totalCount,
    required this.userRole,
  });

  factory CoursesResponse.fromJson(Map<String, dynamic> json) {
    return CoursesResponse(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      courses:
          (json['courses'] as List<dynamic>?)
              ?.map((course) => Course.fromJson(course))
              .toList() ??
          [],
      totalCount: json['total_count'] ?? 0,
      userRole: json['user_role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'courses': courses.map((course) => course.toJson()).toList(),
      'total_count': totalCount,
      'user_role': userRole,
    };
  }
}

/// Course Details API response model
class CourseDetailsResponse {
  final bool status;
  final String message;
  final String? userRole;
  final Course course;

  CourseDetailsResponse({
    required this.status,
    required this.course,
    this.message = '',
    this.userRole,
  });

  factory CourseDetailsResponse.fromJson(Map<String, dynamic> json) {
    return CourseDetailsResponse(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      userRole: json['user_role']?.toString(),
      course: Course.fromJson(json['course'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (userRole != null) 'user_role': userRole,
      'course': course.toJson(),
    };
  }
}
