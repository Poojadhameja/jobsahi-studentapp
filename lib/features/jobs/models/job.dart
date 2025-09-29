/// Job model representing a job posting from the API
class Job {
  final int id;
  final int? recruiterId;
  final String title;
  final String description;
  final String location;
  final String skillsRequired;
  final String salaryMin;
  final String salaryMax;
  final String jobType;
  final String experienceRequired;
  final String applicationDeadline;
  final bool isRemote;
  final int noOfVacancies;
  final String status;
  final String adminAction;
  final String createdAt;
  final int views;

  const Job({
    required this.id,
    this.recruiterId,
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
    required this.views,
  });

  /// Create Job from JSON
  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as int,
      recruiterId: json['recruiter_id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      skillsRequired: json['skills_required'] as String? ?? '',
      salaryMin: json['salary_min'] as String? ?? '0',
      salaryMax: json['salary_max'] as String? ?? '0',
      jobType: json['job_type'] as String? ?? '',
      experienceRequired: json['experience_required'] as String? ?? '',
      applicationDeadline: json['application_deadline'] as String? ?? '',
      isRemote: (json['is_remote'] as int? ?? 0) == 1,
      noOfVacancies: json['no_of_vacancies'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      adminAction: json['admin_action'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      views: json['views'] as int? ?? 0,
    );
  }

  /// Convert Job to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recruiter_id': recruiterId,
      'title': title,
      'description': description,
      'location': location,
      'skills_required': skillsRequired,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'job_type': jobType,
      'experience_required': experienceRequired,
      'application_deadline': applicationDeadline,
      'is_remote': isRemote ? 1 : 0,
      'no_of_vacancies': noOfVacancies,
      'status': status,
      'admin_action': adminAction,
      'created_at': createdAt,
      'views': views,
    };
  }

  /// Get formatted salary range
  String get formattedSalary {
    final min = double.tryParse(salaryMin) ?? 0;
    final max = double.tryParse(salaryMax) ?? 0;

    if (min == 0 && max == 0) return 'Salary not specified';
    if (min == 0) return 'Up to ₹${_formatSalary(max)}';
    if (max == 0) return '₹${_formatSalary(min)}+';
    if (min == max) return '₹${_formatSalary(min)}';

    return '₹${_formatSalary(min)} - ₹${_formatSalary(max)}';
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

  /// Get skills as a list
  List<String> get skillsList {
    if (skillsRequired.isEmpty) return [];
    return skillsRequired.split(',').map((skill) => skill.trim()).toList();
  }

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

  /// Check if job is active
  bool get isActive =>
      status.toLowerCase() == 'open' && adminAction.toLowerCase() == 'approved';

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

  @override
  String toString() {
    return 'Job(id: $id, title: $title, location: $location, salary: $formattedSalary)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Job && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
