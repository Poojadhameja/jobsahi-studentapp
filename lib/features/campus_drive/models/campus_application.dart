
/// Campus Application Model
/// Represents a student's application to a campus drive

class CampusApplication {
  final int id;
  final int studentId;
  final int driveId;
  final String appliedAt;
  final String status;
  final int? assignedDayId;
  final String? assignedDay;
  final String? rejectionReason;
  final List<CampusPreference> preferences;
  
  // Drive details included in the application response
  final int? driveIdFromJoin;
  final String? driveTitle;
  final String? organizer;
  final String? venue;
  final String? city;
  final String? driveStartDate;
  final String? driveEndDate;
  final String? driveStatus;
  final String? assignedDate;
  final int? dayNumber;
  final String? resumePath;

  // For detailed view where full drive object might be nested
  final Map<String, dynamic>? drive;

  CampusApplication({
    required this.id,
    required this.studentId,
    required this.driveId,
    required this.appliedAt,
    required this.status,
    this.assignedDayId,
    this.assignedDay,
    this.rejectionReason,
    this.preferences = const [],
    this.driveIdFromJoin,
    this.driveTitle,
    this.organizer,
    this.venue,
    this.city,
    this.driveStartDate,
    this.driveEndDate,
    this.driveStatus,
    this.assignedDate,
    this.dayNumber,
    this.resumePath,
    this.drive,
  });

  factory CampusApplication.fromJson(Map<String, dynamic> json) {
    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return CampusApplication(
      id: _toInt(json['id']) ?? 0,
      studentId: _toInt(json['student_id']) ?? 0,
      driveId: _toInt(json['drive_id']) ?? 0,
      appliedAt: json['applied_at']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      assignedDayId: _toInt(json['assigned_day_id']),
      assignedDay: json['assigned_day']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      preferences: (json['preferences'] as List<dynamic>?)
              ?.asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final data = entry.value as Map<String, dynamic>;
                // Add preference number based on array index (0-based index + 1)
                data['preference_number'] = index + 1;
                return CampusPreference.fromJson(data);
              })
              .toList() ??
          [],
      // Drive details from join
      driveIdFromJoin: _toInt(json['drive_id']), 
      driveTitle: json['drive_title']?.toString(),
      organizer: json['organizer']?.toString(),
      venue: json['venue']?.toString(),
      city: json['city']?.toString(),
      driveStartDate: json['drive_start_date']?.toString(),
      driveEndDate: json['drive_end_date']?.toString(),
      driveStatus: json['drive_status']?.toString(),
      assignedDate: json['assigned_date']?.toString(),
      dayNumber: _toInt(json['day_number']),
      resumePath: json['resume_path']?.toString(),
      drive: json['drive'] as Map<String, dynamic>?,
    );
  }
}

class CampusPreference {
  final int preferenceNumber;
  final int? driveCompanyId; // This is the company_id (cdc.id) that needs to match
  final int? companyId;
  final String? companyName;
  final String? logo;
  final List<String> jobRoles;
  final Map<String, dynamic> criteria;
  final int? vacancies;

  CampusPreference({
    required this.preferenceNumber,
    this.driveCompanyId,
    this.companyId,
    this.companyName,
    this.logo,
    this.jobRoles = const [],
    this.criteria = const {},
    this.vacancies,
  });

  factory CampusPreference.fromJson(Map<String, dynamic> json) {
    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Helper to safely convert criteria to Map
    Map<String, dynamic> _parseCriteria(dynamic value) {
      if (value == null) return {};
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return {};
    }

    return CampusPreference(
      preferenceNumber: _toInt(json['preference_number']) ?? 0,
      driveCompanyId: _toInt(json['id']), // This is cdc.id from API response
      companyId: _toInt(json['company_id']),
      companyName: json['company_name']?.toString(),
      logo: json['logo']?.toString(),
      jobRoles: (json['job_roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      criteria: _parseCriteria(json['criteria']),
      vacancies: _toInt(json['vacancies']),
    );
  }
}
