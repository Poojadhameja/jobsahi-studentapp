import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/app_constants.dart';
import '../../features/courses/models/course.dart';
import '../../features/profile/models/student_profile.dart';
import '../../features/jobs/models/job_details_api_models.dart';
import '../../features/profile/models/profile_update_response.dart';
import 'token_storage.dart';

/// API Service for making HTTP requests
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  /// Initialize the API service
  Future<void> initialize() async {
    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );

    // Add error handling interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          debugPrint('API Error: ${error.message}');
          debugPrint('API Error Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );

    // Restore authentication token if user is logged in
    await _restoreAuthToken();
  }

  /// Restore authentication token from storage
  Future<void> _restoreAuthToken() async {
    try {
      final tokenStorage = TokenStorage.instance;
      final isLoggedIn = await tokenStorage.isLoggedIn();
      final token = await tokenStorage.getToken();

      if (isLoggedIn && token != null && token.isNotEmpty) {
        setAuthToken(token);
        debugPrint('🔵 Authentication token restored successfully');
      } else {
        debugPrint('🔵 No valid authentication token found');
      }
    } catch (e) {
      debugPrint('🔴 Error restoring auth token: $e');
    }
  }

  /// Set authorization token for authenticated requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Check if user is logged in (has auth token)
  Future<bool> isLoggedIn() async {
    try {
      // Import TokenStorage to check if user is logged in
      final tokenStorage = TokenStorage.instance;
      return await tokenStorage.isLoggedIn();
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  /// Make a GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Make a POST request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Make a PUT request
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Make a DELETE request
  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert them to meaningful exceptions
  Exception _handleDioError(DioException error) {
    debugPrint('DioException Type: ${error.type}');
    debugPrint('DioException Message: ${error.message}');
    debugPrint('DioException Response: ${error.response?.data}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        // Try to extract message from different response formats
        String message = 'Server error occurred';
        if (responseData is Map<String, dynamic>) {
          message =
              responseData['message'] ??
              responseData['msg'] ??
              responseData['error'] ??
              'Server error occurred';
        } else if (responseData is String) {
          message = responseData;
        }

        debugPrint('Bad Response - Status: $statusCode, Message: $message');

        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            return Exception('Unauthorized: $message');
          case 403:
            return Exception('Forbidden: $message');
          case 404:
            return Exception('Not found: $message');
          case 500:
            return Exception('Internal server error: $message');
          default:
            return Exception('HTTP $statusCode: $message');
        }

      case DioExceptionType.cancel:
        return Exception('Request was cancelled');

      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');

      case DioExceptionType.badCertificate:
        return Exception('Certificate error. Please try again.');

      case DioExceptionType.unknown:
        return Exception('An unexpected error occurred: ${error.message}');
    }
  }
}

/// API Response model
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      statusCode: json['status_code'],
    );
  }
}

/// User model for API responses
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String? location;
  final String? experience;
  final String? education;
  final List<String>? skills;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.location,
    this.experience,
    this.education,
    this.skills,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profile_image'],
      location: json['location'],
      experience: json['experience'],
      education: json['education'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      role: json['role'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'location': location,
      'experience': experience,
      'education': education,
      'skills': skills,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Login response model
class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Handle different possible success indicators
    bool success = false;
    if (json.containsKey('success')) {
      success = json['success'] == true;
    } else if (json.containsKey('status')) {
      success = json['status'] == true || json['status'] == 'success';
    } else if (json.containsKey('result')) {
      success = json['result'] == true || json['result'] == 'success';
    }

    // Handle different message field names
    String message = '';
    if (json.containsKey('message')) {
      message = json['message'] ?? '';
    } else if (json.containsKey('msg')) {
      message = json['msg'] ?? '';
    } else if (json.containsKey('response')) {
      message = json['response'] ?? '';
    }

    // Handle different token field names
    String? token;
    if (json.containsKey('token')) {
      token = json['token'];
    } else if (json.containsKey('access_token')) {
      token = json['access_token'];
    } else if (json.containsKey('auth_token')) {
      token = json['auth_token'];
    }

    // Handle different user field names
    User? user;
    if (json.containsKey('user') && json['user'] != null) {
      user = User.fromJson(json['user']);
    } else if (json.containsKey('data') && json['data'] != null) {
      if (json['data'] is Map<String, dynamic>) {
        user = User.fromJson(json['data']);
      }
    }

    return LoginResponse(
      success: success,
      message: message,
      token: token,
      user: user,
    );
  }
}

/// Jobs API Response Model
class JobsApiResponse {
  final bool status;
  final String message;
  final int count;
  final List<Map<String, dynamic>> data;
  final String timestamp;

  JobsApiResponse({
    required this.status,
    required this.message,
    required this.count,
    required this.data,
    required this.timestamp,
  });

  factory JobsApiResponse.fromJson(Map<String, dynamic> json) {
    return JobsApiResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      data: json['data'] != null
          ? List<Map<String, dynamic>>.from(json['data'])
          : [],
      timestamp: json['timestamp'] ?? '',
    );
  }
}

/// Create account response model
class CreateAccountResponse {
  final bool success;
  final String message;
  final User? user;

  CreateAccountResponse({
    required this.success,
    required this.message,
    this.user,
  });

  factory CreateAccountResponse.fromJson(Map<String, dynamic> json) {
    return CreateAccountResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

/// Courses API methods
extension CoursesApi on ApiService {
  /// Get all courses
  Future<CoursesResponse> getCourses() async {
    try {
      final response = await get('/courses/courses.php');
      return CoursesResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch courses: ${e.toString()}');
    }
  }

  /// Save a course
  Future<Response> saveCourse({required int courseId}) async {
    try {
      return await post(
        '/courses/save_course.php',
        data: {
          'course_id': courseId,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Unsave a course
  Future<Response> unsaveCourse({required int courseId}) async {
    try {
      return await post(
        '/courses/unsave_course.php',
        data: {
          'course_id': courseId,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get saved courses
  Future<Response> getSavedCourses({int limit = 20, int offset = 0}) async {
    try {
      return await get(
        '/student/get_saved_courses.php',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Jobs API methods
extension JobsApi on ApiService {
  /// Get featured jobs
  Future<JobsApiResponse> getFeaturedJobs() async {
    try {
      debugPrint('🔵 [Jobs] Fetching featured jobs');

      final response = await get('/api/jobs/jobs.php?featured=true');

      debugPrint(
        '🔵 [Jobs] Featured Jobs API Response Status: ${response.statusCode}',
      );
      debugPrint('🔵 [Jobs] Featured Jobs API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle different response types
        Map<String, dynamic> jsonData;
        if (responseData is Map<String, dynamic>) {
          jsonData = responseData;
          debugPrint('🔵 [Jobs] Featured Jobs Response is already a Map');
        } else if (responseData is String) {
          debugPrint(
            '🔵 [Jobs] Featured Jobs Response is String, parsing JSON',
          );
          try {
            jsonData = jsonDecode(responseData) as Map<String, dynamic>;
            debugPrint('🔵 [Jobs] Featured Jobs JSON parsed successfully');
          } catch (e) {
            debugPrint('🔴 [Jobs] Featured Jobs JSON parsing failed: $e');
            throw Exception('Failed to parse featured jobs response');
          }
        } else {
          debugPrint(
            '🔴 [Jobs] Featured Jobs Unexpected response type: ${responseData.runtimeType}',
          );
          throw Exception('Unexpected response format from server');
        }

        // Check if the response indicates success
        if (jsonData['status'] == false) {
          final message =
              jsonData['message']?.toString() ?? 'No featured jobs found';
          debugPrint('🔴 [Jobs] Featured Jobs API returned error: $message');
          throw Exception(message);
        }

        // Parse the response
        final jobsResponse = JobsApiResponse.fromJson(jsonData);
        debugPrint('🔵 [Jobs] Featured jobs parsed successfully');
        debugPrint(
          '🔵 [Jobs] Featured Jobs Count: ${jobsResponse.data.length}',
        );

        return jobsResponse;
      } else {
        debugPrint(
          '🔴 [Jobs] Featured Jobs API call failed with status: ${response.statusCode}',
        );
        throw Exception(
          'Failed to fetch featured jobs: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('🔴 [Jobs] Error fetching featured jobs: $e');
      rethrow;
    }
  }

  /// Get job details by ID
  /// Requires authentication token (Bearer token)
  Future<JobDetailsApiResponse> getJobDetails(String jobId) async {
    try {
      debugPrint('🔵 [Jobs] Fetching job details for ID: $jobId');

      // Check if user is authenticated
      final userLoggedIn = await isLoggedIn();
      if (!userLoggedIn) {
        debugPrint('🔴 [Jobs] User not authenticated');
        throw Exception('User must be logged in to view job details');
      }

      debugPrint('🔵 [Jobs] User authenticated, making API call');
      final endpoint = '${AppConstants.baseUrl}/jobs/job-detail.php?id=$jobId';
      debugPrint('🔵 [Jobs] Endpoint: $endpoint');

      final response = await get(endpoint);

      debugPrint('🔵 [Jobs] API Response Status: ${response.statusCode}');
      debugPrint('🔵 [Jobs] API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle different response types
        Map<String, dynamic> jsonData;
        if (responseData is Map<String, dynamic>) {
          jsonData = responseData;
          debugPrint('🔵 [Jobs] Response is already a Map');
        } else if (responseData is String) {
          debugPrint('🔵 [Jobs] Response is String, parsing JSON');
          try {
            jsonData = jsonDecode(responseData) as Map<String, dynamic>;
            debugPrint('🔵 [Jobs] JSON parsed successfully');
          } catch (e) {
            debugPrint('🔴 [Jobs] JSON parsing failed: $e');
            throw Exception('Failed to parse job details response');
          }
        } else {
          debugPrint(
            '🔴 [Jobs] Unexpected response type: ${responseData.runtimeType}',
          );
          throw Exception('Unexpected response format from server');
        }

        // Check if the response indicates success
        if (jsonData['status'] == false) {
          final message = jsonData['message']?.toString() ?? 'Job not found';
          debugPrint('🔴 [Jobs] API returned error: $message');
          throw Exception(message);
        }

        // Parse the response
        final jobDetailsResponse = JobDetailsApiResponse.fromJson(jsonData);
        debugPrint('🔵 [Jobs] Job details parsed successfully');
        debugPrint('🔵 [Jobs] Job Title: ${jobDetailsResponse.jobInfo.title}');
        debugPrint(
          '🔵 [Jobs] Company: ${jobDetailsResponse.companyInfo.companyName}',
        );

        return jobDetailsResponse;
      } else {
        debugPrint(
          '🔴 [Jobs] API call failed with status: ${response.statusCode}',
        );
        throw Exception('Failed to fetch job details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 [Jobs] Error fetching job details: $e');
      rethrow;
    }
  }
}

/// Student Profile API methods
extension StudentProfileApi on ApiService {
  /// Get student profile data
  /// Requires authentication token (Bearer token)
  Future<StudentProfileResponse> getStudentProfile() async {
    debugPrint('🔵 [StudentProfile] Fetching student profile data');

    // Ensure user has a valid token before making the request
    final userLoggedIn = await isLoggedIn();
    if (!userLoggedIn) {
      debugPrint('🔴 [StudentProfile] User not authenticated');
      throw Exception('User must be logged in to view profile');
    }

    try {
      final response = await get(AppConstants.studentProfileEndpoint);
      debugPrint(
        '🔵 [StudentProfile] API Response Status: ${response.statusCode}',
      );
      debugPrint(
        '🔵 [StudentProfile] API Response Data Type: ${response.data.runtimeType}',
      );

      final rawData = response.data;
      late final Map<String, dynamic> jsonData;

      if (rawData is Map<String, dynamic>) {
        jsonData = rawData;
      } else if (rawData is String) {
        try {
          jsonData = jsonDecode(rawData) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('🔴 [StudentProfile] Failed to decode JSON string: $e');
          throw Exception('Invalid response format from server');
        }
      } else {
        debugPrint(
          '🔴 [StudentProfile] Unexpected response type: ${rawData.runtimeType}',
        );
        throw Exception('Unexpected response format from server');
      }

      final successFlag = jsonData['success'];
      final statusFlag = jsonData['status'];
      final isSuccess = successFlag == true ||
          successFlag == 'true' ||
          successFlag == 1 ||
          statusFlag == true ||
          statusFlag == 'true' ||
          statusFlag == 1;

      if (!isSuccess) {
        final message = jsonData['message']?.toString() ??
            'Failed to load student profile';
        debugPrint('🔴 [StudentProfile] API returned failure: $message');
        throw Exception(message);
      }

      final dataPayload = jsonData['data'];
      if (dataPayload is! Map<String, dynamic>) {
        debugPrint(
          '🔴 [StudentProfile] Invalid payload: data is ${dataPayload.runtimeType}',
        );
        throw Exception('Invalid student profile payload');
      }

      final metaPayload = jsonData['meta'];
      final normalized = <String, dynamic>{
        'success': jsonData['success'] ?? true,
        'message': jsonData['message'] ?? '',
        'data': dataPayload,
        'meta': metaPayload is Map<String, dynamic> ? metaPayload : <String, dynamic>{},
      };

      final result = StudentProfileResponse.fromJson(normalized);
      debugPrint('🔵 [StudentProfile] Profiles fetched: '
          '${result.data.profiles.length}');
      return result;
    } catch (e) {
      debugPrint('🔴 [StudentProfile] Error fetching student profile: $e');
      rethrow;
    }
  }

  /// Update student profile data
  /// Sends a PUT request with the complete profile payload
  Future<ProfileUpdateResponse> updateStudentProfile(
    Map<String, dynamic> payload,
  ) async {
    debugPrint('🔵 [StudentProfile] Updating student profile');

    final userLoggedIn = await isLoggedIn();
    if (!userLoggedIn) {
      debugPrint('🔴 [StudentProfile] User not authenticated');
      throw Exception('User must be logged in to update profile');
    }

    try {
      debugPrint('🔵 [StudentProfile] Payload keys: ${payload.keys.toList()}');
      final response = await put(
        AppConstants.updateStudentProfileEndpoint,
        data: payload,
      );

      debugPrint(
        '🔵 [StudentProfile] Update Response Status: ${response.statusCode}',
      );
      debugPrint(
        '🔵 [StudentProfile] Update Response Type: ${response.data.runtimeType}',
      );

      final rawData = response.data;
      late final Map<String, dynamic> jsonData;

      if (rawData is Map<String, dynamic>) {
        jsonData = rawData;
      } else if (rawData is String) {
        try {
          jsonData = jsonDecode(rawData) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('🔴 [StudentProfile] Failed to decode response: $e');
          throw Exception('Invalid response format from server');
        }
      } else {
        debugPrint(
          '🔴 [StudentProfile] Unexpected response type: ${rawData.runtimeType}',
        );
        throw Exception('Unexpected response format from server');
      }

      final result = ProfileUpdateResponse.fromJson(jsonData);
      if (!result.isSuccessful) {
        final failureMessage = result.message.isNotEmpty
            ? result.message
            : 'Failed to update student profile';
        debugPrint('🔴 [StudentProfile] Update failed: $failureMessage');
        throw Exception(failureMessage);
      }

      debugPrint('✅ [StudentProfile] Profile updated successfully');
      return result;
    } catch (e) {
      debugPrint('🔴 [StudentProfile] Error updating student profile: $e');
      rethrow;
    }
  }
}
