import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';
import '../../../core/utils/app_constants.dart';
import '../models/job.dart' hide CompanyInfo, JobStatistics;
import '../models/job_detail_models.dart';
import '../models/job_details_api_models.dart';

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
  Future<SaveJobResponse> saveJob(int jobId);
  Future<UnsaveJobResponse> unsaveJob(int jobId);
  Future<SavedJobsResponse> getSavedJobs({
    int? limit,
    int? offset,
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
      debugPrint('🔵 Fetching job details for ID: $id');

      // Use the new job details API
      final jobDetailsResponse = await _apiService.getJobDetails(id.toString());

      debugPrint('🔵 Job details API response received');
      debugPrint('🔵 Job Title: ${jobDetailsResponse.jobInfo.title}');
      debugPrint('🔵 Company: ${jobDetailsResponse.companyInfo.companyName}');

      // Convert API response to legacy format for compatibility
      final jobInfo = jobDetailsResponse.jobInfo;
      final companyInfo = jobDetailsResponse.companyInfo;
      final statistics = jobDetailsResponse.statistics;

      // Create JobInfo for legacy compatibility
      final jobInfoData = JobInfo(
        id: jobInfo.id,
        title: jobInfo.title,
        description: jobInfo.description,
        location: jobInfo.location,
        skillsRequired: jobInfo.skillsRequired,
        salaryMin: jobInfo.salaryMin.toDouble(),
        salaryMax: jobInfo.salaryMax.toDouble(),
        jobType: jobInfo.jobType,
        experienceRequired: jobInfo.experienceRequired,
        applicationDeadline: jobInfo.applicationDeadline,
        isRemote: jobInfo.isRemote,
        noOfVacancies: jobInfo.noOfVacancies,
        status: jobInfo.status,
        adminAction: jobInfo.adminAction,
        createdAt: jobInfo.createdAt,
        isSaved: jobInfo.isSaved,
        isApplied: jobInfo.isApplied,
      );

      // Create CompanyInfo for legacy compatibility
      final companyInfoData = CompanyInfo(
        recruiterId: companyInfo.recruiterId,
        companyName: companyInfo.companyName,
        companyLogo: companyInfo.companyLogo,
        industry: companyInfo.industry,
        website: companyInfo.website,
        location: companyInfo.location,
      );

      // Create JobStatistics for legacy compatibility
      final statisticsData = JobStatistics(
        totalViews: statistics.totalViews,
        totalApplications: statistics.totalApplications,
        pendingApplications: statistics.pendingApplications,
        shortlistedApplications: statistics.shortlistedApplications,
        selectedApplications: statistics.selectedApplications,
        timesSaved: statistics.timesSaved,
      );

      // Create JobDetailData
      final jobDetailData = JobDetailData(
        jobInfo: jobInfoData,
        companyInfo: companyInfoData,
        statistics: statisticsData,
      );

      // Create final response
      final response = JobDetailResponse(
        status: jobDetailsResponse.status,
        message: jobDetailsResponse.message,
        data: jobDetailData,
        timestamp: jobDetailsResponse.timestamp,
      );

      debugPrint('🔵 Job details converted to legacy format successfully');
      return response;
    } catch (e) {
      debugPrint('🔴 Error fetching job details: $e');
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

  @override
  Future<SaveJobResponse> saveJob(int jobId) async {
    try {
      debugPrint('🔵 Saving job with ID: $jobId');

      // Check if user is authenticated
      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('🔴 User not authenticated, cannot save job');
        throw Exception('User must be logged in to save jobs');
      }

      // Prepare request body
      final requestData = {
        'job_id': jobId,
      };

      debugPrint('🔵 Save Job Request Data: $requestData');
      debugPrint('🔵 Save Job Endpoint: ${AppConstants.saveJobEndpoint}');

      // Make POST request
      final response = await _apiService.post(
        AppConstants.saveJobEndpoint,
        data: requestData,
      );

      debugPrint('🔵 Save Job API Response Status: ${response.statusCode}');
      debugPrint('🔵 Save Job API Response Data: ${response.data}');

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

        final saveJobResponse = SaveJobResponse.fromJson(jsonData);

        // Log response details
        debugPrint('🔵 Save Job Response Status: ${saveJobResponse.status}');
        debugPrint('🔵 Save Job Response Message: ${saveJobResponse.message}');
        debugPrint('🔵 Save Job Already Saved: ${saveJobResponse.alreadySaved}');

        if (saveJobResponse.isSuccess) {
          debugPrint(
            '✅ Job saved successfully. Saved Job ID: ${saveJobResponse.data?.savedJobId}',
          );
        } else if (saveJobResponse.isAlreadySaved) {
          debugPrint('ℹ️ Job is already saved by the user');
        } else if (saveJobResponse.isJobNotFound) {
          debugPrint('⚠️ Job not found or not available for saving');
        } else if (saveJobResponse.isInvalidToken) {
          debugPrint('🔴 Invalid token: ${saveJobResponse.message}');
        }

        return saveJobResponse;
      } else {
        debugPrint(
          '🔴 Save Job API failed with status: ${response.statusCode}',
        );
        throw Exception('Failed to save job: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 Error saving job: $e');
      rethrow;
    }
  }

  @override
  Future<UnsaveJobResponse> unsaveJob(int jobId) async {
    try {
      debugPrint('🔵 Unsaving job with ID: $jobId');

      // Check if user is authenticated
      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('🔴 User not authenticated, cannot unsave job');
        throw Exception('User must be logged in to unsave jobs');
      }

      // Prepare request body
      final requestData = {
        'job_id': jobId,
      };

      debugPrint('🔵 Unsave Job Request Data: $requestData');
      debugPrint('🔵 Unsave Job Endpoint: ${AppConstants.unsaveJobEndpoint}');

      // Make POST request
      final response = await _apiService.post(
        AppConstants.unsaveJobEndpoint,
        data: requestData,
      );

      debugPrint('🔵 Unsave Job API Response Status: ${response.statusCode}');
      debugPrint('🔵 Unsave Job API Response Data: ${response.data}');

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

        final unsaveJobResponse = UnsaveJobResponse.fromJson(jsonData);

        // Log response details
        debugPrint('🔵 Unsave Job Response Status: ${unsaveJobResponse.status}');
        debugPrint('🔵 Unsave Job Response Message: ${unsaveJobResponse.message}');

        if (unsaveJobResponse.isSuccess) {
          debugPrint(
            '✅ Job removed from saved list successfully. Job ID: ${unsaveJobResponse.data?.jobId}',
          );
        } else if (unsaveJobResponse.isJobNotSaved) {
          debugPrint('⚠️ Job is not saved by you or doesn\'t exist');
        }

        return unsaveJobResponse;
      } else {
        debugPrint(
          '🔴 Unsave Job API failed with status: ${response.statusCode}',
        );
        throw Exception('Failed to unsave job: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 Error unsaving job: $e');
      rethrow;
    }
  }

  @override
  Future<SavedJobsResponse> getSavedJobs({
    int? limit,
    int? offset,
  }) async {
    try {
      debugPrint('🔵 Fetching saved jobs...');
      debugPrint('🔵 Limit: ${limit ?? 20}, Offset: ${offset ?? 0}');

      // Check if user is authenticated
      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('🔴 User not authenticated, cannot fetch saved jobs');
        throw Exception('User must be logged in to view saved jobs');
      }

      // Build query parameters - ensure all values are strings
      Map<String, dynamic>? queryParams;
      if (limit != null || offset != null) {
        queryParams = <String, dynamic>{};
        if (limit != null) {
          queryParams['limit'] = limit.toString();
        }
        if (offset != null) {
          queryParams['offset'] = offset.toString();
        }
      }

      debugPrint('🔵 Get Saved Jobs Endpoint: ${AppConstants.getSavedJobsEndpoint}');
      debugPrint('🔵 Query Parameters: $queryParams');

      // Make GET request
      final response = await _apiService.get(
        AppConstants.getSavedJobsEndpoint,
        queryParameters: queryParams,
      );

      debugPrint('🔵 Get Saved Jobs API Response Status: ${response.statusCode}');
      debugPrint('🔵 Get Saved Jobs API Response Data: ${response.data}');

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

        final savedJobsResponse = SavedJobsResponse.fromJson(jsonData);

        // Log response details
        debugPrint('🔵 Saved Jobs Response Status: ${savedJobsResponse.status}');
        debugPrint('🔵 Saved Jobs Response Message: ${savedJobsResponse.message}');
        debugPrint('🔵 Saved Jobs Count: ${savedJobsResponse.data.length}');
        
        if (savedJobsResponse.pagination != null) {
          debugPrint('🔵 Total Saved Jobs: ${savedJobsResponse.pagination!.total}');
          debugPrint('🔵 Has More: ${savedJobsResponse.pagination!.hasMore}');
        }

        if (savedJobsResponse.status) {
          debugPrint(
            '✅ Saved jobs retrieved successfully. Count: ${savedJobsResponse.data.length}',
          );
        }

        return savedJobsResponse;
      } else {
        debugPrint(
          '🔴 Get Saved Jobs API failed with status: ${response.statusCode}',
        );
        throw Exception('Failed to fetch saved jobs: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 Error fetching saved jobs: $e');
      rethrow;
    }
  }
}
