/// Course model for API responses
class Course {
  final int id;
  final int instituteId;
  final String title;
  final String description;
  final String duration;
  final String fee;
  final String adminAction;

  Course({
    required this.id,
    required this.instituteId,
    required this.title,
    required this.description,
    required this.duration,
    required this.fee,
    required this.adminAction,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      instituteId: json['institute_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      fee: json['fee'] ?? '0.00',
      adminAction: json['admin_action'] ?? '',
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
    };
  }

  // Convert to the format expected by the UI
  Map<String, dynamic> toUIMap() {
    return {
      'id': id.toString(),
      'title': title,
      'titleEnglish': title, // For compatibility with existing UI
      'description': description,
      'duration': duration,
      'fees': double.tryParse(fee) ?? 0.0,
      'category': 'General', // Default category since API doesn't provide this
      'rating': 4.0, // Default rating
      'totalRatings': 0, // Default ratings count
      'institute': 'Institute $instituteId', // Default institute name
      'level': 'Beginner', // Default level
      'isSaved': false, // Default saved status
      'imageUrl': 'assets/images/courses/default.png', // Default image
      'benefits': [
        'Professional training',
        'Industry certification',
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
  }) {
    return Course(
      id: id ?? this.id,
      instituteId: instituteId ?? this.instituteId,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      fee: fee ?? this.fee,
      adminAction: adminAction ?? this.adminAction,
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
        other.adminAction == adminAction;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        instituteId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        duration.hashCode ^
        fee.hashCode ^
        adminAction.hashCode;
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
      message: json['message'] ?? '',
      courses:
          (json['courses'] as List<dynamic>?)
              ?.map((course) => Course.fromJson(course))
              .toList() ??
          [],
      totalCount: json['total_count'] ?? 0,
      userRole: json['user_role'] ?? '',
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
  final Course course;

  CourseDetailsResponse({required this.status, required this.course});

  factory CourseDetailsResponse.fromJson(Map<String, dynamic> json) {
    return CourseDetailsResponse(
      status: json['status'] ?? false,
      course: Course.fromJson(json['course'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'course': course.toJson()};
  }
}
