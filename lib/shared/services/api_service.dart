import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/app_constants.dart';
import '../../features/courses/models/course.dart';
import '../../features/profile/models/student_profile.dart';
import '../../features/jobs/models/job_details_api_models.dart';
import '../../features/profile/models/profile_update_response.dart';
import 'token_storage.dart';
import '../../features/jobs/models/job_application_response.dart';

/// API Service for making HTTP requests
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(
        seconds: 15,
      ), // Reduced from 30 to 15 seconds
      receiveTimeout: const Duration(
        seconds: 15,
      ), // Reduced from 30 to 15 seconds
      sendTimeout: const Duration(seconds: 10), // Reduced from 30 to 10 seconds
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

  /// Make a PATCH request
  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch(
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
        final errorMsg = error.message ?? 'Unknown error';
        return Exception('An unexpected error occurred: $errorMsg');
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
      name: json['name'] ?? json['user_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phone_number'] ?? '',
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
  final String? errorCode;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.errorCode,
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

    // Extract error code if present
    String? errorCode;
    if (json.containsKey('error_code')) {
      errorCode = json['error_code'];
    }

    return LoginResponse(
      success: success,
      message: message,
      token: token,
      user: user,
      errorCode: errorCode,
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
        data: {'course_id': courseId},
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
        data: {'course_id': courseId},
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
        queryParameters: {'limit': limit, 'offset': offset},
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Auth/Settings API methods
extension AuthSettingsApi on ApiService {
  /// Change current user's password
  /// Requires Authorization: Bearer <JWT>
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Ensure user is logged in
    final loggedIn = await isLoggedIn();
    if (!loggedIn) {
      throw Exception('User must be logged in');
    }

    try {
      final response = await post(
        AppConstants.changePasswordEndpoint,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      final raw = response.data;
      late final Map<String, dynamic> jsonData;
      if (raw is Map<String, dynamic>) {
        jsonData = raw;
      } else if (raw is String) {
        jsonData = jsonDecode(raw) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response format from server');
      }

      // Normalize keys: expect { status: bool, message: string }
      final status =
          (jsonData['status'] == true) ||
          (jsonData['success'] == true) ||
          (jsonData['result'] == true);
      final message =
          (jsonData['message'] ?? jsonData['msg'] ?? jsonData['error'] ?? '')
              .toString();

      return {'status': status, 'message': message};
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

      final response = await get(
        '/jobs/jobs.php',
        queryParameters: {'featured': 'true'},
      );

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

      // Check for CORS-related errors
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('cors') ||
          errorString.contains('cross-origin') ||
          errorString.contains('network error') ||
          (e is DioException &&
              (e.type == DioExceptionType.connectionError ||
                  e.type == DioExceptionType.unknown))) {
        debugPrint('🔴 [Jobs] Possible CORS error detected');
        throw Exception(
          'CORS Error: Please ensure the server allows cross-origin requests. '
          'If testing on web, the server must include proper CORS headers.',
        );
      }

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
      debugPrint('🔵 [Jobs] Fetching job details for ID: $jobId');

      final response = await get(
        '/jobs/job-detail.php',
        queryParameters: {'id': jobId},
      );

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

  /// Submit a job application
  Future<JobApplicationResponse> submitJobApplication({
    required int jobId,
    required int studentId,
    String? coverLetter,
  }) async {
    try {
      debugPrint(
        '🔵 [Jobs] Submitting job application: jobId=$jobId, studentId=$studentId',
      );

      final payload = <String, dynamic>{
        'job_id': jobId,
        'student_id': studentId,
        'cover_letter': coverLetter?.trim() ?? '',
      };

      final response = await post('/jobs/job_apply.php', data: payload);

      debugPrint(
        '🔵 [Jobs] Job application response status: ${response.statusCode}',
      );

      final rawData = response.data;
      late final Map<String, dynamic> jsonData;

      if (rawData is Map<String, dynamic>) {
        jsonData = rawData;
      } else if (rawData is String) {
        try {
          jsonData = jsonDecode(rawData) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('🔴 [Jobs] Failed to decode job application response: $e');
          throw Exception('Invalid response format from server');
        }
      } else {
        debugPrint(
          '🔴 [Jobs] Unexpected job application response type: ${rawData.runtimeType}',
        );
        throw Exception('Unexpected response format from server');
      }

      final result = JobApplicationResponse.fromJson(jsonData);

      if (!result.success) {
        final failureMessage = result.message.isNotEmpty
            ? result.message
            : 'Failed to submit job application';
        debugPrint('🔴 [Jobs] Job application failed: $failureMessage');
        throw Exception(failureMessage);
      }

      debugPrint('✅ [Jobs] Job application submitted successfully');
      return result;
    } catch (e) {
      debugPrint('🔴 [Jobs] Error submitting job application: $e');
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
      final isSuccess =
          successFlag == true ||
          successFlag == 'true' ||
          successFlag == 1 ||
          statusFlag == true ||
          statusFlag == 'true' ||
          statusFlag == 1;

      if (!isSuccess) {
        final message =
            jsonData['message']?.toString() ?? 'Failed to load student profile';
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
        'meta': metaPayload is Map<String, dynamic>
            ? metaPayload
            : <String, dynamic>{},
      };

      final result = StudentProfileResponse.fromJson(normalized);
      debugPrint(
        '🔵 [StudentProfile] Profiles fetched: '
        '${result.data.profiles.length}',
      );
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
      debugPrint('🔵 [StudentProfile] Payload structure:');
      debugPrint('   personal_info: ${payload['personal_info'] != null}');
      debugPrint(
        '   professional_info: ${payload['professional_info'] != null}',
      );
      debugPrint('   documents: ${payload['documents'] != null}');
      debugPrint(
        '   social_links: ${payload['social_links'] is List ? 'List (${(payload['social_links'] as List).length} items)' : payload['social_links']?.runtimeType}',
      );
      debugPrint('   additional_info: ${payload['additional_info'] != null}');
      debugPrint('   contact_info: ${payload['contact_info'] != null}');

      // Log social_links structure for debugging
      if (payload['social_links'] is List) {
        final socialLinks = payload['social_links'] as List;
        debugPrint('🔵 [StudentProfile] Social links structure:');
        for (int i = 0; i < socialLinks.length; i++) {
          final link = socialLinks[i];
          if (link is Map) {
            debugPrint(
              '   Link $i: title="${link['title']}", profile_url="${link['profile_url']}"',
            );
          }
        }
      }

      final response = await put(
        AppConstants.updateStudentProfileEndpoint,
        data: payload,
      );

      debugPrint(
        '🔵 [StudentProfile] Update Response Status: ${response.statusCode}',
      );
      debugPrint(
        '🔵 [StudentProfile] Update Response Type: ${response.data?.runtimeType ?? 'null'}',
      );
      debugPrint('🔵 [StudentProfile] Update Response Data: ${response.data}');

      final rawData = response.data;

      // Handle null response
      if (rawData == null) {
        debugPrint('🔴 [StudentProfile] Response data is null');
        throw Exception('Server returned an empty response');
      }

      late final Map<String, dynamic> jsonData;

      if (rawData is Map<String, dynamic>) {
        jsonData = rawData;
      } else if (rawData is String) {
        if (rawData.trim().isEmpty) {
          debugPrint('🔴 [StudentProfile] Response string is empty');
          throw Exception('Server returned an empty response');
        }

        // Check if response is HTML (PHP error page) instead of JSON
        final trimmedResponse = rawData.trim();
        if (trimmedResponse.startsWith('<') ||
            trimmedResponse.startsWith('<!')) {
          debugPrint(
            '🔴 [StudentProfile] Server returned HTML instead of JSON',
          );
          debugPrint(
            '🔴 [StudentProfile] HTML Response (first 500 chars): ${trimmedResponse.substring(0, trimmedResponse.length > 500 ? 500 : trimmedResponse.length)}',
          );

          // Try to extract error message from HTML
          String errorMessage =
              'Server returned an error page instead of JSON response';
          if (trimmedResponse.contains('<b>') &&
              trimmedResponse.contains('</b>')) {
            final startIndex = trimmedResponse.indexOf('<b>') + 3;
            final endIndex = trimmedResponse.indexOf('</b>', startIndex);
            if (endIndex > startIndex) {
              errorMessage = trimmedResponse
                  .substring(startIndex, endIndex)
                  .trim();
            }
          } else if (trimmedResponse.contains('Fatal error') ||
              trimmedResponse.contains('Warning')) {
            // Extract PHP error message
            final errorMatch = RegExp(
              r'(Fatal error|Warning|Parse error|Notice):\s*(.+?)(?:\n|$)',
            ).firstMatch(trimmedResponse);
            if (errorMatch != null) {
              errorMessage = errorMatch.group(2)?.trim() ?? errorMessage;
            }
          }

          throw Exception(
            'Server error: $errorMessage. Please check server logs.',
          );
        }

        try {
          jsonData = jsonDecode(rawData) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('🔴 [StudentProfile] Failed to decode response: $e');
          debugPrint(
            '🔴 [StudentProfile] Raw response string (first 500 chars): ${rawData.length > 500 ? rawData.substring(0, 500) : rawData}',
          );
          throw Exception(
            'Invalid response format from server: ${e.toString()}',
          );
        }
      } else {
        debugPrint(
          '🔴 [StudentProfile] Unexpected response type: ${rawData.runtimeType}',
        );
        debugPrint('🔴 [StudentProfile] Response value: $rawData');
        throw Exception(
          'Unexpected response format from server. Expected Map or String, got ${rawData.runtimeType}',
        );
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

  /// Delete profile image
  Future<Map<String, dynamic>> deleteProfileImage() async {
    debugPrint('🔵 [StudentProfile] Deleting profile image');

    final userLoggedIn = await isLoggedIn();
    if (!userLoggedIn) {
      debugPrint('🔴 [StudentProfile] User not authenticated');
      throw Exception('User must be logged in to delete profile image');
    }

    try {
      final response = await post(AppConstants.profileImageDeleteEndpoint);

      debugPrint('🔵 [StudentProfile] Delete Response Status: ${response.statusCode}');
      debugPrint('🔵 [StudentProfile] Delete Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          debugPrint('✅ [StudentProfile] Profile image deleted successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Profile image deleted successfully',
          };
        } else {
          final message = data['message'] ?? 'Failed to delete profile image';
          debugPrint('🔴 [StudentProfile] Delete failed: $message');
          throw Exception(message);
        }
      } else {
        throw Exception('Failed to delete profile image. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 [StudentProfile] Error deleting profile image: $e');
      rethrow;
    }
  }
}

/// Student Applications API methods
extension StudentApplicationsApi on ApiService {
  /// Get student's applied jobs
  Future<List<Map<String, dynamic>>> getStudentAppliedJobs() async {
    try {
      final response = await get('/student/applications.php');

      final rawData = response.data;
      late final Map<String, dynamic> jsonData;

      if (rawData is Map<String, dynamic>) {
        jsonData = rawData;
      } else if (rawData is String) {
        jsonData = jsonDecode(rawData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response format from applications API');
      }

      final statusFlag = jsonData['status'];
      final isSuccess =
          statusFlag == true ||
          statusFlag == 1 ||
          statusFlag == '1' ||
          (statusFlag is String && statusFlag.toLowerCase() == 'true');

      if (!isSuccess) {
        final message =
            jsonData['message']?.toString() ?? 'Failed to load applications';
        throw Exception(message);
      }

      final data = jsonData['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      return const <Map<String, dynamic>>[];
    } catch (e) {
      debugPrint('🔴 [StudentApplications] Error fetching applied jobs: $e');
      rethrow;
    }
  }

  /// Get detailed information for a single student application
  Future<Map<String, dynamic>> getStudentApplicationDetail(
    int applicationId,
  ) async {
    try {
      final response = await get(
        '/student/get_application.php',
        queryParameters: {'id': applicationId},
      );

      final rawData = response.data;
      late final Map<String, dynamic> jsonData;

      if (rawData is Map<String, dynamic>) {
        jsonData = rawData;
      } else if (rawData is String) {
        jsonData = jsonDecode(rawData) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Unexpected response format from application detail API',
        );
      }

      final statusFlag = jsonData['status'];
      final isSuccess =
          statusFlag == true ||
          statusFlag == 1 ||
          statusFlag == '1' ||
          (statusFlag is String && statusFlag.toLowerCase() == 'true');

      if (!isSuccess) {
        final message =
            jsonData['message']?.toString() ??
            'Failed to load application detail';
        throw Exception(message);
      }

      final data = jsonData['data'];
      if (data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception('Invalid application detail payload');
    } catch (e) {
      debugPrint(
        '🔴 [StudentApplications] Error fetching application detail: $e',
      );
      rethrow;
    }
  }

  /// Fetch skill test questions for a job
  Future<List<Map<String, dynamic>>> getSkillTestQuestions({
    required String jobId,
  }) async {
    try {
      final response = await get(
        '/skills/skill-questions.php',
        queryParameters: {'job_id': jobId},
      );

      final rawData = response.data;
      late final Map<String, dynamic> jsonData;

      if (rawData is Map<String, dynamic>) {
        jsonData = rawData;
      } else if (rawData is String) {
        jsonData = jsonDecode(rawData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response format from skill questions API');
      }

      final statusFlag = jsonData['status'];
      final isSuccess =
          statusFlag == true ||
          statusFlag == 1 ||
          statusFlag == '1' ||
          (statusFlag is String && statusFlag.toLowerCase() == 'true');

      if (!isSuccess) {
        final message =
            jsonData['message']?.toString() ?? 'Failed to load skill questions';
        throw Exception(message);
      }

      final data = jsonData['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((question) => Map<String, dynamic>.from(question))
            .toList();
      }

      return const <Map<String, dynamic>>[];
    } catch (e) {
      debugPrint('🔴 [SkillTest] Error fetching skill questions: $e');
      rethrow;
    }
  }

  /// Get student's hired jobs (status = 'selected')
  Future<List<Map<String, dynamic>>> getStudentHiredJobs({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await get(
        '/student/get_hired_jobs.php',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final rawData = response.data;
      late final Map<String, dynamic> jsonData;

      if (rawData is Map<String, dynamic>) {
        jsonData = rawData;
      } else if (rawData is String) {
        jsonData = jsonDecode(rawData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response format from hired jobs API');
      }

      final statusFlag = jsonData['status'];
      final isSuccess =
          statusFlag == true ||
          statusFlag == 1 ||
          statusFlag == '1' ||
          (statusFlag is String && statusFlag.toLowerCase() == 'true');

      if (!isSuccess) {
        final message =
            jsonData['message']?.toString() ?? 'Failed to load hired jobs';
        throw Exception(message);
      }

      final data = jsonData['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      return const <Map<String, dynamic>>[];
    } catch (e) {
      debugPrint('🔴 [StudentApplications] Error fetching hired jobs: $e');
      rethrow;
    }
  }

  /// Get detailed information for a hired job
  Future<Map<String, dynamic>> getHiredJobDetail(int applicationId) async {
    try {
      final response = await get(
        '/student/get_hired_job_detail.php',
        queryParameters: {'application_id': applicationId},
      );

      final rawData = response.data;
      late final Map<String, dynamic> jsonData;

      if (rawData is Map<String, dynamic>) {
        jsonData = rawData;
      } else if (rawData is String) {
        jsonData = jsonDecode(rawData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response format from hired job detail API');
      }

      final statusFlag = jsonData['status'];
      final isSuccess =
          statusFlag == true ||
          statusFlag == 1 ||
          statusFlag == '1' ||
          (statusFlag is String && statusFlag.toLowerCase() == 'true');

      if (!isSuccess) {
        final message =
            jsonData['message']?.toString() ??
            'Failed to load hired job detail';
        throw Exception(message);
      }

      final data = jsonData['data'];
      if (data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception('Invalid hired job detail payload');
    } catch (e) {
      debugPrint(
        '🔴 [StudentApplications] Error fetching hired job detail: $e',
      );
      rethrow;
    }
  }

  /// Submit student skill test attempts (batch preferred)
  Future<Map<String, dynamic>> submitSkillTestAttempts({
    required List<Map<String, dynamic>> attempts,
  }) async {
    if (attempts.isEmpty) {
      throw Exception('No attempts to submit');
    }

    try {
      final userLoggedIn = await isLoggedIn();
      if (!userLoggedIn) {
        throw Exception('User must be logged in to submit skill test attempts');
      }

      final payload = {'attempts': attempts};

      final response = await post('/student/skill-attempts.php', data: payload);

      final rawData = response.data;
      late final Map<String, dynamic> jsonData;

      if (rawData is Map<String, dynamic>) {
        jsonData = rawData;
      } else if (rawData is String) {
        jsonData = jsonDecode(rawData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response format from skill attempts API');
      }

      final statusFlag = jsonData['status'];
      final isSuccess =
          statusFlag == true ||
          statusFlag == 1 ||
          statusFlag == '1' ||
          (statusFlag is String && statusFlag.toLowerCase() == 'true');

      final result = Map<String, dynamic>.from(jsonData);
      result['success'] = isSuccess;
      if (!isSuccess) {
        final message =
            jsonData['message']?.toString() ??
            'Failed to submit skill attempts';
        result['error_message'] = message;
      }

      return result;
    } catch (e) {
      debugPrint('🔴 [SkillTest] Error submitting skill attempts: $e');
      rethrow;
    }
  }

  /// Start or resume a skill test for an application
  Future<Map<String, dynamic>> startSkillTest({
    required int applicationId,
  }) async {
    try {
      final response = await post(
        '/skills/skill-tests.php',
        data: {'application_id': applicationId},
      );

      final rawData = response.data;
      late final Map<String, dynamic> jsonData;

      if (rawData is Map<String, dynamic>) {
        jsonData = rawData;
      } else if (rawData is String) {
        jsonData = jsonDecode(rawData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response format from skill test API');
      }

      final statusFlag = jsonData['status'];
      final isSuccess =
          statusFlag == true ||
          statusFlag == 1 ||
          statusFlag == '1' ||
          (statusFlag is String && statusFlag.toLowerCase() == 'true');

      if (!isSuccess) {
        final message =
            jsonData['message']?.toString() ?? 'Failed to start skill test';
        throw Exception(message);
      }

      return jsonData;
    } catch (e) {
      debugPrint('🔴 [SkillTest] Error starting skill test: $e');
      rethrow;
    }
  }
}
