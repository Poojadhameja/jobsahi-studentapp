import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';
import '../models/job.dart';
import '../models/job_detail_models.dart';

/// Jobs API response model
class JobsResponse {
  final String message;
  final bool status;
  final int count;
  final List<Job> data;
  final String timestamp;

  const JobsResponse({
    required this.message,
    required this.status,
    required this.count,
    required this.data,
    required this.timestamp,
  });

  factory JobsResponse.fromJson(Map<String, dynamic> json) {
    return JobsResponse(
      message: json['message'] as String? ?? '',
      status: json['status'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((jobJson) => Job.fromJson(jobJson as Map<String, dynamic>))
              .toList() ??
          [],
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}

/// Abstract interface for jobs repository
abstract class JobsRepository {
  Future<JobsResponse> getJobs();
  Future<Job?> getJobById(int id);
  Future<JobDetailResponse> getJobDetails(int id);
  Future<List<Job>> searchJobs({
    String? query,
    String? location,
    String? jobType,
    String? experienceLevel,
    String? salaryRange,
  });
}

/// Implementation of JobsRepository
class JobsRepositoryImpl implements JobsRepository {
  final ApiService _apiService;

  JobsRepositoryImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<JobsResponse> getJobs() async {
    try {
      debugPrint('🔵 Fetching jobs from API...');

      // Check if user is authenticated
      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('🔴 User not authenticated, cannot fetch jobs');
        throw Exception('User must be logged in to view jobs');
      }

      final response = await _apiService.get('/jobs/jobs.php');

      debugPrint('🔵 Jobs API Response Status: ${response.statusCode}');
      debugPrint('🔵 Jobs API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle different response types
        Map<String, dynamic> jsonData;
        if (responseData is Map<String, dynamic>) {
          jsonData = responseData;
        } else if (responseData is String) {
          try {
            jsonData = jsonDecode(responseData) as Map<String, dynamic>;
          } catch (e) {
            debugPrint('🔴 Failed to parse JSON string: $e');
            throw Exception('Invalid response format');
          }
        } else {
          debugPrint(
            '🔴 Unexpected response data type: ${responseData.runtimeType}',
          );
          throw Exception('Unexpected response format');
        }

        final jobsResponse = JobsResponse.fromJson(jsonData);

        debugPrint('🔵 Parsed ${jobsResponse.data.length} jobs successfully');
        return jobsResponse;
      } else {
        debugPrint('🔴 Jobs API failed with status: ${response.statusCode}');
        throw Exception('Failed to fetch jobs: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 Error fetching jobs: $e');
      rethrow;
    }
  }

  @override
  Future<Job?> getJobById(int id) async {
    try {
      debugPrint('🔵 Fetching job by ID: $id');

      // Check if user is authenticated
      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('🔴 User not authenticated, cannot fetch job details');
        throw Exception('User must be logged in to view job details');
      }

      final response = await _apiService.get('/jobs/jobs.php?id=$id');

      if (response.statusCode == 200) {
        final responseData = response.data;

        Map<String, dynamic> jsonData;
        if (responseData is Map<String, dynamic>) {
          jsonData = responseData;
        } else if (responseData is String) {
          jsonData = jsonDecode(responseData) as Map<String, dynamic>;
        } else {
          throw Exception('Unexpected response format');
        }

        final jobsResponse = JobsResponse.fromJson(jsonData);

        if (jobsResponse.data.isNotEmpty) {
          return jobsResponse.data.first;
        }
      }

      return null;
    } catch (e) {
      debugPrint('🔴 Error fetching job by ID: $e');
      return null;
    }
  }

  @override
  Future<JobDetailResponse> getJobDetails(int id) async {
    try {
      debugPrint(
        '🔵 [Repository] Fetching detailed job information for ID: $id',
      );

      // Check if user is authenticated
      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('🔴 [Repository] User not authenticated');
        throw Exception('User must be logged in to view job details');
      }

      debugPrint('🔵 [Repository] User authenticated, calling API service');

      final responseData = await _apiService.getJobDetails(id);

      debugPrint('🔵 [Repository] API Response received');
      debugPrint('🔵 [Repository] Response keys: ${responseData.keys}');

      // Parse the response
      final jobDetailResponse = JobDetailResponse.fromJson(responseData);

      debugPrint(
        '🔵 [Repository] Response parsed, status: ${jobDetailResponse.status}',
      );

      if (!jobDetailResponse.status) {
        debugPrint('🔴 [Repository] Job details API returned false status');
        final errorMessage = jobDetailResponse.message.isNotEmpty
            ? jobDetailResponse.message
            : 'Failed to fetch job details';
        debugPrint('🔴 [Repository] Error message: $errorMessage');
        throw Exception(errorMessage);
      }

      debugPrint(
        '🔵 [Repository] Job details fetched successfully for ID: $id',
      );
      debugPrint(
        '🔵 [Repository] Job title: ${jobDetailResponse.data.jobInfo.title}',
      );
      debugPrint(
        '🔵 [Repository] Company: ${jobDetailResponse.data.companyInfo.companyName}',
      );

      return jobDetailResponse;
    } catch (e) {
      debugPrint('🔴 [Repository] Error fetching job details for ID $id: $e');
      debugPrint('🔴 [Repository] Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  @override
  Future<List<Job>> searchJobs({
    String? query,
    String? location,
    String? jobType,
    String? experienceLevel,
    String? salaryRange,
  }) async {
    try {
      debugPrint('🔵 Searching jobs with filters...');

      // Check if user is authenticated
      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('🔴 User not authenticated, cannot search jobs');
        throw Exception('User must be logged in to search jobs');
      }

      // Build query parameters
      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) {
        queryParams['search'] = query;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (jobType != null && jobType.isNotEmpty) {
        queryParams['job_type'] = jobType;
      }
      if (experienceLevel != null && experienceLevel.isNotEmpty) {
        queryParams['experience'] = experienceLevel;
      }
      if (salaryRange != null && salaryRange.isNotEmpty) {
        queryParams['salary'] = salaryRange;
      }

      // Build query string
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint = queryString.isNotEmpty
          ? '/jobs/jobs.php?$queryString'
          : '/jobs/jobs.php';

      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        final responseData = response.data;

        Map<String, dynamic> jsonData;
        if (responseData is Map<String, dynamic>) {
          jsonData = responseData;
        } else if (responseData is String) {
          jsonData = jsonDecode(responseData) as Map<String, dynamic>;
        } else {
          throw Exception('Unexpected response format');
        }

        final jobsResponse = JobsResponse.fromJson(jsonData);

        debugPrint(
          '🔵 Found ${jobsResponse.data.length} jobs matching search criteria',
        );
        return jobsResponse.data;
      } else {
        debugPrint(
          '🔴 Search jobs API failed with status: ${response.statusCode}',
        );
        throw Exception('Failed to search jobs: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 Error searching jobs: $e');
      rethrow;
    }
  }
}
