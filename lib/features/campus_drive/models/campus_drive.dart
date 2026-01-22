/// Import for jsonDecode
import 'dart:convert';
import 'campus_application.dart';

export 'campus_application.dart';

/// Campus Drive Model
/// Represents a campus drive with all its details

class CampusDrive {
  final int id;
  final String title;
  final String organizer;
  final String venue;
  final String city;
  final String startDate;
  final String endDate;
  final int capacityPerDay;
  final String status;
  final int? totalCompanies;
  final int? totalApplications;
  final bool? hasApplied;
  final String? applicationStatus;
  final String? assignedDay;
  final String? assignedDate;

  CampusDrive({
    required this.id,
    required this.title,
    required this.organizer,
    required this.venue,
    required this.city,
    required this.startDate,
    required this.endDate,
    required this.capacityPerDay,
    required this.status,
    this.totalCompanies,
    this.totalApplications,
    this.hasApplied,
    this.applicationStatus,
    this.assignedDay,
    this.assignedDate,
  });

  factory CampusDrive.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return CampusDrive(
      id: _toInt(json['id']) ?? 0,
      title: json['title']?.toString() ?? '',
      organizer: json['organizer']?.toString() ?? '',
      venue: json['venue']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      capacityPerDay: _toInt(json['capacity_per_day']) ?? 0,
      status: json['status']?.toString() ?? 'draft',
      totalCompanies: _toInt(json['total_companies']),
      totalApplications: _toInt(json['total_applications']),
      hasApplied:
          json['has_applied'] == true ||
          json['has_applied'] == 1 ||
          json['has_applied'] == '1',
      applicationStatus: json['application_status']?.toString(),
      assignedDay: json['assigned_day']?.toString(),
      assignedDate: json['assigned_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'organizer': organizer,
      'venue': venue,
      'city': city,
      'start_date': startDate,
      'end_date': endDate,
      'capacity_per_day': capacityPerDay,
      'status': status,
      if (totalCompanies != null) 'total_companies': totalCompanies,
      if (totalApplications != null) 'total_applications': totalApplications,
      if (hasApplied != null) 'has_applied': hasApplied,
      if (applicationStatus != null) 'application_status': applicationStatus,
      if (assignedDay != null) 'assigned_day': assignedDay,
      if (assignedDate != null) 'assigned_date': assignedDate,
    };
  }
}

/// Campus Drive Company Model
/// Represents a company participating in a campus drive
class CampusDriveCompany {
  final int id;
  final int? preferenceId; // campus_drive_companies.id for preferences
  final int driveId;
  final int companyId;
  final String companyName;
  final String? logo;
  final String? companyDescription;
  final String? companyLocation;
  final List<String>? jobRoles;
  final Map<String, dynamic>? criteria;
  final int vacancies;

  CampusDriveCompany({
    required this.id,
    this.preferenceId,
    required this.driveId,
    required this.companyId,
    required this.companyName,
    this.logo,
    this.companyDescription,
    this.companyLocation,
    this.jobRoles,
    this.criteria,
    required this.vacancies,
  });

  factory CampusDriveCompany.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Parse job_roles
    List<String>? jobRolesList;
    if (json['job_roles'] != null) {
      if (json['job_roles'] is String) {
        try {
          final parsed = jsonDecode(json['job_roles'] as String);
          if (parsed is List) {
            jobRolesList = parsed.map((e) => e.toString()).toList();
          }
        } catch (e) {
          jobRolesList = [];
        }
      } else if (json['job_roles'] is List) {
        jobRolesList = (json['job_roles'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    // Parse criteria
    Map<String, dynamic>? criteriaMap;
    if (json['criteria'] != null) {
      if (json['criteria'] is String) {
        try {
          criteriaMap =
              jsonDecode(json['criteria'] as String) as Map<String, dynamic>?;
        } catch (e) {
          criteriaMap = {};
        }
      } else if (json['criteria'] is Map) {
        criteriaMap = json['criteria'] as Map<String, dynamic>;
      }
    }

    return CampusDriveCompany(
      id: _toInt(json['id']) ?? 0,
      preferenceId: _toInt(json['preference_id']) ?? _toInt(json['id']),
      driveId: _toInt(json['drive_id']) ?? 0,
      companyId: _toInt(json['company_id']) ?? 0,
      companyName: json['company_name']?.toString() ?? '',
      logo: json['logo']?.toString(),
      companyDescription: json['company_description']?.toString(),
      companyLocation:
          json['company_location']?.toString() ??
          json['location']?.toString() ??
          json['manual_company_location']?.toString(),
      jobRoles: jobRolesList,
      criteria: criteriaMap,
      vacancies: _toInt(json['vacancies']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (preferenceId != null) 'preference_id': preferenceId,
      'drive_id': driveId,
      'company_id': companyId,
      'company_name': companyName,
      if (logo != null) 'logo': logo,
      if (companyDescription != null) 'company_description': companyDescription,
      if (companyLocation != null) 'company_location': companyLocation,
      if (jobRoles != null) 'job_roles': jobRoles,
      if (criteria != null) 'criteria': criteria,
      'vacancies': vacancies,
    };
  }
}

/// Campus Drive Details Model
/// Complete details of a campus drive including companies
class CampusDriveDetails {
  final CampusDrive drive;
  final List<CampusDriveCompany> companies;
  final CampusApplication? application;

  CampusDriveDetails({
    required this.drive,
    required this.companies,
    this.application,
  });

  factory CampusDriveDetails.fromJson(Map<String, dynamic> json) {
    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Backend sometimes returns `application: {}` or `application: []` when user has not applied.
    // Treat those cases as null to avoid showing "Application Submitted" incorrectly.
    CampusApplication? _parseApplication(dynamic raw) {
      if (raw == null) return null;
      if (raw is List) return null; // [] => no application
      if (raw is! Map<String, dynamic>) return null;
      if (raw.isEmpty) return null; // {} => no application

      final id = _toInt(raw['id']) ?? 0;
      if (id <= 0) return null;

      return CampusApplication.fromJson(raw);
    }

    return CampusDriveDetails(
      drive: CampusDrive.fromJson(json['drive'] as Map<String, dynamic>),
      companies:
          (json['companies'] as List<dynamic>?)
              ?.map(
                (c) => CampusDriveCompany.fromJson(c as Map<String, dynamic>),
              )
              .toList() ??
          [],
      application: _parseApplication(json['application']),
    );
  }
}
