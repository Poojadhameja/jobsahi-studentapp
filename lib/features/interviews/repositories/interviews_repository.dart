import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';
import '../models/interview.dart';
import '../models/interview_detail.dart';

/// Abstract interface for interviews repository
abstract class InterviewsRepository {
  Future<InterviewsResponse> getInterviews({String? status, String? type});

  Future<InterviewDetailResponse> getInterviewDetail(int interviewId);
}

/// Implementation of InterviewsRepository
class InterviewsRepositoryImpl implements InterviewsRepository {
  final ApiService _apiService;

  InterviewsRepositoryImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<InterviewsResponse> getInterviews({
    String? status,
    String? type,
  }) async {
    try {
      debugPrint('🔵 Fetching interviews from API...');

      // Check if user is authenticated
      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('🔴 User not authenticated, cannot fetch interviews');
        throw Exception('User must be logged in to view interviews');
      }

      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      debugPrint('🔵 Get Interviews Endpoint: /student/interview-list.php');
      debugPrint('🔵 Query Parameters: $queryParams');

      // Make GET request (baseUrl already includes /api)
      final response = await _apiService.get(
        '/student/interview-list.php',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      debugPrint(
        '🔵 Get Interviews API Response Status: ${response.statusCode}',
      );
      debugPrint('🔵 Get Interviews API Response Data: ${response.data}');

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

        final interviewsResponse = InterviewsResponse.fromJson(jsonData);

        // Log response details
        debugPrint(
          '🔵 Interviews Response Status: ${interviewsResponse.status}',
        );
        debugPrint(
          '🔵 Interviews Response Message: ${interviewsResponse.message}',
        );
        debugPrint('🔵 Interviews Count: ${interviewsResponse.data.length}');

        if (interviewsResponse.status) {
          debugPrint(
            '✅ Interviews retrieved successfully. Count: ${interviewsResponse.data.length}',
          );
        }

        return interviewsResponse;
      } else {
        debugPrint(
          '🔴 Get Interviews API failed with status: ${response.statusCode}',
        );
        throw Exception('Failed to fetch interviews: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🔴 Error fetching interviews: $e');
      rethrow;
    }
  }

  @override
  Future<InterviewDetailResponse> getInterviewDetail(int interviewId) async {
    try {
      debugPrint('🔵 Fetching interview detail for ID: $interviewId');

      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('🔴 User not authenticated, cannot fetch interview detail');
        throw Exception('User must be logged in to view interview details');
      }

      debugPrint(
        '🔵 Get Interview Detail Endpoint: /student/interview_detail.php?id=$interviewId',
      );

      final response = await _apiService.get(
        '/student/interview_detail.php',
        queryParameters: {'id': interviewId},
      );

      debugPrint(
        '🔵 Get Interview Detail API Response Status: ${response.statusCode}',
      );
      debugPrint('🔵 Get Interview Detail API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

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

        final interviewDetailResponse = InterviewDetailResponse.fromJson(
          jsonData,
        );

        debugPrint(
          '🔵 Interview Detail Response Status: ${interviewDetailResponse.status}',
        );
        debugPrint(
          '🔵 Interview Detail Response Message: ${interviewDetailResponse.message}',
        );

        if (interviewDetailResponse.status) {
          debugPrint('✅ Interview detail retrieved successfully');
        }

        return interviewDetailResponse;
      } else {
        debugPrint(
          '🔴 Get Interview Detail API failed with status: ${response.statusCode}',
        );
        throw Exception(
          'Failed to fetch interview detail: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('🔴 Error fetching interview detail: $e');
      rethrow;
    }
  }
}
