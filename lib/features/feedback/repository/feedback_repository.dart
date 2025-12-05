import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';
import '../../../core/utils/app_constants.dart';
import '../models/feedback_models.dart';

/// Abstract interface for feedback repository
abstract class FeedbackRepository {
  Future<FeedbackResponse> submitFeedback({
    required String feedback,
    String? subject,
  });
}

/// Implementation of FeedbackRepository
class FeedbackRepositoryImpl implements FeedbackRepository {
  final ApiService _apiService;

  FeedbackRepositoryImpl({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<FeedbackResponse> submitFeedback({
    required String feedback,
    String? subject,
  }) async {
    try {
      debugPrint('🔵 Submitting feedback...');
      debugPrint('🔵 Feedback: $feedback');
      if (subject != null) {
        debugPrint('🔵 Subject: $subject');
      }

      final requestData = FeedbackRequest(
        feedback: feedback,
        subject: subject,
      ).toJson();

      debugPrint('🔵 Request data: $requestData');

      final response = await _apiService.post(
        AppConstants.feedbackEndpoint,
        data: jsonEncode(requestData),
      );

      debugPrint('🔵 Feedback API Status: ${response.statusCode}');
      debugPrint('🔵 Feedback API Response: ${response.data}');

      final responseData = response.data;

      // Handle different response formats
      if (responseData is Map<String, dynamic>) {
        // Check if it's a rate limit error (429)
        if (response.statusCode == 429) {
          final rateLimitError = RateLimitErrorResponse.fromJson(responseData);
          throw RateLimitException(
            message: rateLimitError.message,
            messageEn: rateLimitError.messageEn,
            submissionsInWindow: rateLimitError.submissionsInWindow,
            windowStartDate: rateLimitError.windowStartDate,
            resetDate: rateLimitError.resetDate,
            remainingDays: rateLimitError.remainingDays,
          );
        }

        // Check for error responses
        if (responseData['status'] == false) {
          final errorMessage = responseData['message'] as String? ??
              'Failed to submit feedback';
          throw Exception(errorMessage);
        }

        // Success response
        return FeedbackResponse.fromJson(responseData);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      debugPrint('🔴 Error in submitFeedback: $e');
      
      // Check if it's a rate limit exception (thrown from DioException handler above)
      if (e is RateLimitException) {
        rethrow;
      }
      
      // Check if the error message indicates a 429 rate limit
      // ApiService converts DioException to Exception with message "HTTP 429: ..."
      final errorString = e.toString();
      if (errorString.contains('HTTP 429') || errorString.contains('429')) {
        // Try to extract rate limit info from the error message
        // This is a fallback since ApiService converts DioException
        throw RateLimitException(
          message: errorString.replaceFirst('Exception: ', '').replaceFirst('HTTP 429: ', ''),
        );
      }
      
      rethrow;
    }
  }
}

/// Custom exception for rate limit errors
class RateLimitException implements Exception {
  final String message;
  final String? messageEn;
  final int? submissionsInWindow;
  final String? windowStartDate;
  final String? resetDate;
  final int? remainingDays;

  RateLimitException({
    required this.message,
    this.messageEn,
    this.submissionsInWindow,
    this.windowStartDate,
    this.resetDate,
    this.remainingDays,
  });

  @override
  String toString() => message;
}

