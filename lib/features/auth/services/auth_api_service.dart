import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../shared/services/api_service.dart';

/// Auth-specific API service
/// Contains all authentication-related API methods
class AuthApiService {
  final ApiService _apiService;

  AuthApiService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Generate OTP (unified API for both forgot password and resend OTP)
  Future<ForgotPasswordResponse> generateOtp({
    required String email,
    required String purpose,
  }) async {
    try {
      debugPrint(
        '🔵 Sending generate OTP request for: $email with purpose: $purpose',
      );

      final requestData = {'email': email, 'purpose': purpose};

      debugPrint('🔵 Request data: $requestData');

      final response = await _apiService.post(
        '/auth/generate-otp.php',
        data: requestData, // Pass Map directly, Dio will JSON encode it
      );

      debugPrint('🔵 Generate OTP API Status: ${response.statusCode}');
      debugPrint('🔵 Generate OTP API Response: ${response.data}');
      debugPrint(
        '🔵 Generate OTP API Response Type: ${response.data.runtimeType}',
      );

      final responseData = response.data;

      // Handle different response formats
      Map<String, dynamic> parsedData;
      if (responseData is Map<String, dynamic>) {
        parsedData = responseData;
      } else if (responseData is String) {
        try {
          parsedData = jsonDecode(responseData) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('🔴 Failed to parse JSON string: $e');
          return ForgotPasswordResponse(
            success: false,
            message: 'Invalid response format',
          );
        }
      } else {
        debugPrint('🔴 Unexpected response type: ${responseData.runtimeType}');
        return ForgotPasswordResponse(
          success: false,
          message: 'Unexpected response format',
        );
      }

      // Debug: Print raw parsed data to verify API response structure
      debugPrint('🔵 Parsed Data: $parsedData');
      debugPrint('🔵 Parsed Data status: ${parsedData['status']}');
      debugPrint('🔵 Parsed Data user_id: ${parsedData['user_id']}');
      debugPrint('🔵 Parsed Data message: ${parsedData['message']}');
      debugPrint('🔵 Parsed Data purpose: ${parsedData['purpose']}');
      debugPrint('🔵 Parsed Data expires_in: ${parsedData['expires_in']}');

      final generateOtpResponse = ForgotPasswordResponse.fromJson(parsedData);

      debugPrint(
        '🔵 Generate OTP Response success: ${generateOtpResponse.success}',
      );
      debugPrint(
        '🔵 Generate OTP Response message: ${generateOtpResponse.message}',
      );
      debugPrint(
        '🔵 Generate OTP Response purpose: ${generateOtpResponse.purpose}',
      );
      debugPrint(
        '🔵 Generate OTP Response userId: ${generateOtpResponse.userId}',
      );
      debugPrint(
        '🔵 Generate OTP Response expiresIn: ${generateOtpResponse.expiresIn}',
      );

      // Double-check: If API returned 200 but status is false, treat as error
      if (response.statusCode == 200 && parsedData['status'] == false) {
        debugPrint(
          '🔴 API returned 200 but status is false - treating as error',
        );
        return ForgotPasswordResponse(
          success: false,
          message: parsedData['message'] ?? 'Failed to generate OTP',
        );
      }

      return generateOtpResponse;
    } catch (e) {
      debugPrint('🔴 Error in generate OTP API: $e');
      debugPrint('🔴 Error type: ${e.runtimeType}');

      // Handle DioException specifically
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        debugPrint('🔴 DioException Status: $statusCode');
        debugPrint('🔴 DioException Response Data: $responseData');

        if (statusCode == 401) {
          // User not exist (401) - Email not registered
          String errorMessage = 'User not exist';
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] ?? errorMessage;
          } else if (responseData is String) {
            try {
              final parsed = jsonDecode(responseData) as Map<String, dynamic>;
              errorMessage = parsed['message'] ?? errorMessage;
            } catch (parseError) {
              errorMessage = responseData;
            }
          }

          return ForgotPasswordResponse(success: false, message: errorMessage);
        } else if (statusCode == 400) {
          String errorMessage = 'Invalid email or request';
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] ?? errorMessage;
          } else if (responseData is String) {
            try {
              final parsed = jsonDecode(responseData) as Map<String, dynamic>;
              errorMessage = parsed['message'] ?? errorMessage;
            } catch (parseError) {
              errorMessage = responseData;
            }
          }
          return ForgotPasswordResponse(success: false, message: errorMessage);
        }
      }

      // Handle Exception thrown by ApiService (which converts DioException to Exception)
      final errorString = e.toString();
      debugPrint('🔴 Exception string: $errorString');

      // Extract status code and message from exception string
      if (errorString.contains('Unauthorized:') ||
          errorString.contains('401')) {
        // User not exist (401) - Email not registered
        String errorMessage = _extractErrorMessage(
          errorString,
          'Unauthorized:',
        );
        if (errorMessage.isEmpty ||
            errorMessage.toLowerCase().contains('user not exist') ||
            errorMessage.toLowerCase().contains('user does not exist')) {
          errorMessage = 'User not exist';
        }

        return ForgotPasswordResponse(success: false, message: errorMessage);
      } else if (errorString.contains('Bad request:') ||
          errorString.contains('400')) {
        String errorMessage = _extractErrorMessage(errorString, 'Bad request:');
        if (errorMessage.isEmpty || errorMessage == 'Bad request') {
          errorMessage = 'Invalid email or request';
        }
        return ForgotPasswordResponse(success: false, message: errorMessage);
      } else if (errorString.contains('Connection timeout') ||
          errorString.contains('timeout')) {
        return ForgotPasswordResponse(
          success: false,
          message:
              'Connection timeout. Please check your internet connection and try again.',
        );
      } else if (errorString.contains('No internet connection') ||
          errorString.contains('network')) {
        return ForgotPasswordResponse(
          success: false,
          message:
              'Network error. Please check your internet connection and try again.',
        );
      }

      // Generic error handling
      String cleanMessage = errorString;
      if (cleanMessage.startsWith('Exception: ')) {
        cleanMessage = cleanMessage.substring(11);
      }

      return ForgotPasswordResponse(
        success: false,
        message: cleanMessage.isNotEmpty
            ? cleanMessage
            : 'Failed to generate OTP. Please try again.',
      );
    }
  }

  /// Send OTP for login
  Future<LoginResponse> sendOtp({required String phoneNumber}) async {
    try {
      debugPrint('🔵 Sending OTP to: $phoneNumber');

      final requestData = {'phone': phoneNumber};

      final response = await _apiService.post(
        '/auth/send_otp.php',
        data: jsonEncode(requestData),
      );

      debugPrint('🔵 OTP API Response Status: ${response.statusCode}');
      debugPrint('🔵 OTP API Response Data: ${response.data}');

      final responseData = response.data;

      return LoginResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'OTP sent successfully',
      );
    } catch (e) {
      debugPrint('🔴 Error sending OTP: $e');
      return LoginResponse(
        success: false,
        message: 'Failed to send OTP: ${e.toString()}',
      );
    }
  }

  /// Phone login - Send OTP to phone number
  Future<PhoneLoginResponse> phoneLogin({required String phoneNumber}) async {
    try {
      debugPrint('🔵 Sending phone login OTP to: $phoneNumber');

      final requestData = {'phone_number': phoneNumber};

      debugPrint('🔵 Request data: $requestData');

      final response = await _apiService.post(
        '/auth/phone_login.php',
        data: requestData, // Pass Map directly, Dio will JSON encode it
      );

      debugPrint('🔵 Phone Login API Status: ${response.statusCode}');
      debugPrint('🔵 Phone Login API Response: ${response.data}');

      final responseData = response.data;
      final phoneLoginResponse = PhoneLoginResponse.fromJson(responseData);

      debugPrint(
        '🔵 Phone Login Response success: ${phoneLoginResponse.success}',
      );
      debugPrint(
        '🔵 Phone Login Response message: ${phoneLoginResponse.message}',
      );
      debugPrint(
        '🔵 Phone Login Response userId: ${phoneLoginResponse.userId}',
      );
      debugPrint(
        '🔵 Phone Login Response expiresIn: ${phoneLoginResponse.expiresIn}',
      );

      return phoneLoginResponse;
    } catch (e) {
      debugPrint('🔴 Error in phone login API: $e');
      debugPrint('🔴 Error type: ${e.runtimeType}');

      // Handle DioException directly (if ApiService hasn't converted it yet)
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        debugPrint('🔴 DioException Status Code: $statusCode');
        debugPrint('🔴 DioException Response Data: $responseData');

        if (statusCode == 400) {
          // Invalid format or missing field
          String errorMessage =
              'Invalid phone number format or phone number is required';
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] ?? errorMessage;
          } else if (responseData is String) {
            try {
              final parsed = jsonDecode(responseData) as Map<String, dynamic>;
              errorMessage = parsed['message'] ?? errorMessage;
            } catch (parseError) {
              // Keep default error message
            }
          }
          return PhoneLoginResponse(success: false, message: errorMessage);
        } else if (statusCode == 200 && responseData != null) {
          // Phone number not found (200 but status: false)
          return PhoneLoginResponse.fromJson(responseData);
        } else if (statusCode == 404 || statusCode == 401) {
          // User not found
          String errorMessage = 'User does not exist';
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] ?? errorMessage;
          } else if (responseData is String) {
            try {
              final parsed = jsonDecode(responseData) as Map<String, dynamic>;
              errorMessage = parsed['message'] ?? errorMessage;
            } catch (parseError) {
              // Keep default error message
            }
          }
          return PhoneLoginResponse(success: false, message: errorMessage);
        }
      }

      // Handle Exception thrown by ApiService (which converts DioException to Exception)
      // Format: "Exception: Unauthorized: User not exist" or "Unauthorized: User does not exist"
      final errorString = e.toString();
      debugPrint('🔴 Exception string: $errorString');

      // Extract status code and message from exception string
      if (errorString.contains('Unauthorized:') ||
          errorString.contains('401')) {
        // User not found (401) - phone number doesn't exist
        String errorMessage = _extractErrorMessage(
          errorString,
          'Unauthorized:',
        );
        if (errorMessage.isEmpty ||
            errorMessage.toLowerCase().contains('user not exist') ||
            errorMessage.toLowerCase().contains('user does not exist')) {
          errorMessage = 'User does not exist';
        }
        return PhoneLoginResponse(success: false, message: errorMessage);
      } else if (errorString.contains('Not found:') ||
          errorString.contains('404')) {
        // User not found (404)
        String errorMessage = _extractErrorMessage(errorString, 'Not found:');
        if (errorMessage.isEmpty || errorMessage == 'Not found') {
          errorMessage = 'User does not exist';
        }
        return PhoneLoginResponse(success: false, message: errorMessage);
      } else if (errorString.contains('Bad request:') ||
          errorString.contains('400')) {
        // Invalid format or missing field (400)
        String errorMessage = _extractErrorMessage(errorString, 'Bad request:');
        if (errorMessage.isEmpty || errorMessage == 'Bad request') {
          errorMessage =
              'Invalid phone number format or phone number is required';
        }
        return PhoneLoginResponse(success: false, message: errorMessage);
      } else if (errorString.contains('Connection timeout') ||
          errorString.contains('timeout')) {
        // Network timeout
        return PhoneLoginResponse(
          success: false,
          message:
              'Connection timeout. Please check your internet connection and try again.',
        );
      } else if (errorString.contains('No internet connection') ||
          errorString.contains('network')) {
        // Network error
        return PhoneLoginResponse(
          success: false,
          message:
              'Network error. Please check your internet connection and try again.',
        );
      }

      // Generic error handling
      // Try to clean up the error message
      String cleanMessage = errorString;
      if (cleanMessage.startsWith('Exception: ')) {
        cleanMessage = cleanMessage.substring(11);
      }
      // Remove "Failed to send OTP: " prefix if present
      if (cleanMessage.startsWith('Failed to send OTP: ')) {
        cleanMessage = cleanMessage.substring(21);
      }

      return PhoneLoginResponse(
        success: false,
        message: cleanMessage.isNotEmpty
            ? cleanMessage
            : 'Failed to send OTP. Please try again.',
      );
    }
  }

  /// Verify OTP for phone login
  Future<LoginResponse> verifyPhoneLoginOtp({
    required int userId,
    required String otp,
  }) async {
    try {
      debugPrint(
        '🔵 Verifying phone login OTP for user: $userId with OTP: $otp',
      );

      // Validate inputs
      if (userId <= 0) {
        debugPrint('🔴 Invalid userId: $userId');
        return LoginResponse(
          success: false,
          message: 'Invalid user ID. Please request a new OTP',
        );
      }

      if (otp.isEmpty || otp.length != 4) {
        debugPrint('🔴 Invalid OTP length: ${otp.length}');
        return LoginResponse(
          success: false,
          message: 'Please enter a valid 4-digit OTP',
        );
      }

      final requestData = {'user_id': userId, 'otp': otp};

      debugPrint('🔵 Request data: $requestData');
      debugPrint('🔵 Request data type: ${requestData.runtimeType}');

      final response = await _apiService.post(
        '/auth/verify-otp.php',
        data: requestData, // Pass Map directly, Dio will JSON encode it
      );

      debugPrint(
        '🔵 Verify Phone Login OTP API Status: ${response.statusCode}',
      );
      debugPrint('🔵 Verify Phone Login OTP API Response: ${response.data}');
      debugPrint(
        '🔵 Verify Phone Login OTP API Response Type: ${response.data.runtimeType}',
      );

      final responseData = response.data;

      // Handle error responses
      if (response.statusCode == 400 || response.statusCode == 403) {
        String errorMessage = 'OTP verification failed';
        bool isExpired = false;

        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? errorMessage;
          isExpired = responseData['expired'] == true;
        } else if (responseData is String) {
          try {
            final parsed = jsonDecode(responseData) as Map<String, dynamic>;
            errorMessage = parsed['message'] ?? errorMessage;
            isExpired = parsed['expired'] == true;
          } catch (e) {
            errorMessage = responseData;
          }
        }

        debugPrint(
          '🔴 OTP verification failed: $errorMessage (expired: $isExpired)',
        );

        return LoginResponse(
          success: false,
          message: isExpired
              ? 'OTP has expired. Please request a new one'
              : errorMessage,
        );
      }

      // Parse response data
      Map<String, dynamic> parsedData;
      if (responseData is Map<String, dynamic>) {
        parsedData = responseData;
      } else if (responseData is String) {
        try {
          parsedData = jsonDecode(responseData) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('🔴 Failed to parse response: $e');
          return LoginResponse(
            success: false,
            message: 'Invalid response format',
          );
        }
      } else {
        debugPrint('🔴 Unexpected response type: ${responseData.runtimeType}');
        return LoginResponse(
          success: false,
          message: 'Unexpected response format',
        );
      }

      return LoginResponse.fromJson(parsedData);
    } catch (e) {
      debugPrint('🔴 Error verifying phone login OTP: $e');
      debugPrint('🔴 Error type: ${e.runtimeType}');

      // Handle DioException
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        debugPrint('🔴 DioException Status: $statusCode');
        debugPrint('🔴 DioException Response Data: $responseData');

        if (statusCode == 400) {
          String errorMessage = 'Invalid OTP';
          bool isExpired = false;

          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] ?? errorMessage;
            isExpired = responseData['expired'] == true;
          } else if (responseData is String) {
            try {
              final parsed = jsonDecode(responseData) as Map<String, dynamic>;
              errorMessage = parsed['message'] ?? errorMessage;
              isExpired = parsed['expired'] == true;
            } catch (parseError) {
              errorMessage = responseData;
            }
          }

          return LoginResponse(
            success: false,
            message: isExpired
                ? 'OTP has expired. Please request a new one'
                : errorMessage,
          );
        } else if (statusCode == 403) {
          return LoginResponse(success: false, message: 'Account not verified');
        }
      }

      return LoginResponse(
        success: false,
        message: 'Failed to verify OTP: ${e.toString()}',
      );
    }
  }

  /// Verify OTP
  Future<LoginResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      debugPrint('🔵 Verifying OTP for: $phoneNumber');

      final requestData = {'phone': phoneNumber, 'otp': otp};

      final response = await _apiService.post(
        '/auth/verify_otp.php',
        data: jsonEncode(requestData),
      );

      debugPrint(
        '🔵 OTP Verification API Response Status: ${response.statusCode}',
      );
      debugPrint('🔵 OTP Verification API Response Data: ${response.data}');

      final responseData = response.data;
      return LoginResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('🔴 Error verifying OTP: $e');
      return LoginResponse(
        success: false,
        message: 'Failed to verify OTP: ${e.toString()}',
      );
    }
  }

  /// Verify OTP for forgot password
  Future<VerifyOtpResponse> verifyForgotPasswordOtp({
    required int userId,
    required String otp,
    required String purpose,
  }) async {
    try {
      debugPrint('🔵 Verifying forgot password OTP for user: $userId');

      final requestData = {'user_id': userId, 'otp': otp, 'purpose': purpose};

      debugPrint('🔵 Request data: $requestData');

      final response = await _apiService.post(
        '/auth/verify-otp.php',
        data: jsonEncode(requestData),
      );

      debugPrint('🔵 Verify OTP API Status: ${response.statusCode}');
      debugPrint('🔵 Verify OTP API Response: ${response.data}');

      final responseData = response.data;

      // Check if the response indicates an invalid OTP
      if (response.statusCode == 400 &&
          responseData is Map<String, dynamic> &&
          (responseData['message']?.toString().toLowerCase().contains(
                    'invalid otp',
                  ) ==
                  true ||
              responseData['message']?.toString().toLowerCase().contains(
                    'otp',
                  ) ==
                  true)) {
        return VerifyOtpResponse(
          success: false,
          message: 'Invalid OTP. Please check and try again.',
          userId: userId,
        );
      }

      final verifyOtpResponse = VerifyOtpResponse.fromJson(responseData);

      debugPrint(
        '🔵 Verify OTP Response success: ${verifyOtpResponse.success}',
      );
      debugPrint(
        '🔵 Verify OTP Response message: ${verifyOtpResponse.message}',
      );
      debugPrint('🔵 Verify OTP Response userId: ${verifyOtpResponse.userId}');

      return verifyOtpResponse;
    } catch (e) {
      debugPrint('🔴 Error in verify OTP API: $e');

      // Check if it's a bad request error (invalid OTP)
      if (e.toString().contains('Bad request') &&
          e.toString().contains('Invalid OTP')) {
        return VerifyOtpResponse(
          success: false,
          message: 'Invalid OTP. Please check and try again.',
          userId: userId,
        );
      }

      return VerifyOtpResponse(
        success: false,
        message: 'Failed to verify OTP. Please try again.',
        userId: userId,
      );
    }
  }

  /// Login with email and password
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔵 Sending login request for: $email');

      final requestData = {"email": email, "password": password};

      final response = await _apiService.post(
        '/auth/login.php',
        data: jsonEncode(requestData),
      );

      debugPrint('🔵 Login API Status Code: ${response.statusCode}');
      debugPrint('🔵 Login API Response: ${response.data}');

      // Handle different response types
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          responseData =
              jsonDecode(response.data as String) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('🔴 Failed to parse JSON string: $e');
          responseData = {
            "status": false,
            "message": "Invalid response format",
          };
        }
      } else {
        debugPrint(
          '🔴 Unexpected response data type: ${response.data.runtimeType}',
        );
        responseData = {
          "status": false,
          "message": "Unexpected response format",
        };
      }

      // Handle case where API returns success but with different field names
      if (response.statusCode == 200) {
        if (!responseData.containsKey('success') &&
            !responseData.containsKey('status')) {
          debugPrint(
            '🔵 API returned 200 but no success/status field, assuming success',
          );
          responseData['status'] = true;
          responseData['message'] =
              responseData['message'] ?? 'Login successful';
        }
      }

      return LoginResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('🔴 Error in login API: $e');
      debugPrint('🔴 Error type: ${e.runtimeType}');

      // Handle DioException directly (if ApiService hasn't converted it yet)
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        debugPrint('🔴 DioException Status Code: $statusCode');
        debugPrint('🔴 DioException Response Data: $responseData');

        return _parseDioExceptionError(e, statusCode, responseData);
      }

      // Handle Exception thrown by ApiService (which converts DioException to Exception)
      // Format: "Exception: Unauthorized: Invalid credentials" or "Unauthorized: Password is wrong"
      final errorString = e.toString();
      debugPrint('🔴 Exception string: $errorString');

      // Extract status code and message from exception string
      if (errorString.contains('Unauthorized:') ||
          errorString.contains('401')) {
        // Wrong password (401)
        String errorMessage = _extractErrorMessage(
          errorString,
          'Unauthorized:',
        );

        // Normalize common error messages to user-friendly format
        final lowerMessage = errorMessage.toLowerCase();
        if (lowerMessage.contains('invalid credentials') ||
            lowerMessage.contains('wrong password') ||
            lowerMessage.contains('incorrect password') ||
            lowerMessage.contains('password is wrong')) {
          errorMessage = 'Password is wrong';
        } else if (errorMessage.isEmpty) {
          errorMessage = 'Password is wrong';
        }
        // Otherwise use the extracted message as-is (it might already be user-friendly)

        return LoginResponse(
          success: false,
          message: errorMessage,
          errorCode: 'WRONG_PASSWORD',
        );
      } else if (errorString.contains('Not found:') ||
          errorString.contains('404')) {
        // User not found (404)
        String errorMessage = _extractErrorMessage(errorString, 'Not found:');
        if (errorMessage.isEmpty || errorMessage == 'Not found') {
          errorMessage = 'User does not exist';
        }

        return LoginResponse(
          success: false,
          message: errorMessage,
          errorCode: 'USER_NOT_FOUND',
        );
      } else if (errorString.contains('Forbidden:') ||
          errorString.contains('403')) {
        // Account not verified (403)
        String errorMessage = _extractErrorMessage(errorString, 'Forbidden:');
        if (errorMessage.isEmpty || errorMessage == 'Forbidden') {
          errorMessage = 'Account not verified';
        }

        return LoginResponse(
          success: false,
          message: errorMessage,
          errorCode: 'ACCOUNT_NOT_VERIFIED',
        );
      } else if (errorString.contains('Bad request:') ||
          errorString.contains('400')) {
        // Missing or empty fields (400)
        String errorMessage = _extractErrorMessage(errorString, 'Bad request:');
        if (errorMessage.isEmpty || errorMessage == 'Bad request') {
          errorMessage = 'Email/Phone and password are required';
        }

        return LoginResponse(
          success: false,
          message: errorMessage,
          errorCode: 'MISSING_FIELDS',
        );
      } else if (errorString.contains('Connection timeout') ||
          errorString.contains('timeout')) {
        // Network timeout
        return LoginResponse(
          success: false,
          message:
              'Connection timeout. Please check your internet connection and try again.',
          errorCode: 'NETWORK_TIMEOUT',
        );
      } else if (errorString.contains('No internet connection') ||
          errorString.contains('network')) {
        // Network error
        return LoginResponse(
          success: false,
          message:
              'Network error. Please check your internet connection and try again.',
          errorCode: 'NETWORK_ERROR',
        );
      }

      // Generic error handling
      // Try to clean up the error message
      String cleanMessage = errorString;
      if (cleanMessage.startsWith('Exception: ')) {
        cleanMessage = cleanMessage.substring(11);
      }

      return LoginResponse(
        success: false,
        message: cleanMessage.isNotEmpty
            ? cleanMessage
            : 'Login failed. Please try again.',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Helper method to parse DioException errors
  LoginResponse _parseDioExceptionError(
    DioException e,
    int? statusCode,
    dynamic responseData,
  ) {
    String errorMessage = '';
    String? errorCode;

    // Try to extract error from response data
    if (responseData is Map<String, dynamic>) {
      errorMessage = responseData['message'] ?? '';
      errorCode = responseData['error_code'];
    } else if (responseData is String) {
      try {
        final parsed = jsonDecode(responseData) as Map<String, dynamic>;
        errorMessage = parsed['message'] ?? '';
        errorCode = parsed['error_code'];
      } catch (parseError) {
        errorMessage = responseData;
      }
    }

    // Set defaults based on status code if message is empty
    if (errorMessage.isEmpty) {
      switch (statusCode) {
        case 404:
          errorMessage = 'User does not exist';
          errorCode ??= 'USER_NOT_FOUND';
          break;
        case 401:
          errorMessage = 'Password is wrong';
          errorCode ??= 'WRONG_PASSWORD';
          break;
        case 403:
          errorMessage = 'Account not verified';
          errorCode ??= 'ACCOUNT_NOT_VERIFIED';
          break;
        case 400:
          errorMessage = 'Email/Phone and password are required';
          errorCode ??= 'MISSING_FIELDS';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
          errorCode ??= 'UNKNOWN_ERROR';
      }
    }

    // Handle network errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return LoginResponse(
        success: false,
        message:
            'Connection timeout. Please check your internet connection and try again.',
        errorCode: 'NETWORK_TIMEOUT',
      );
    } else if (e.type == DioExceptionType.connectionError) {
      return LoginResponse(
        success: false,
        message:
            'Network error. Please check your internet connection and try again.',
        errorCode: 'NETWORK_ERROR',
      );
    }

    return LoginResponse(
      success: false,
      message: errorMessage,
      errorCode: errorCode ?? 'UNKNOWN_ERROR',
    );
  }

  /// Helper method to extract error message from exception string
  String _extractErrorMessage(String errorString, String prefix) {
    try {
      // Remove "Exception: " prefix if present
      String cleaned = errorString.replaceFirst('Exception: ', '');

      // Extract message after the prefix
      final index = cleaned.indexOf(prefix);
      if (index != -1) {
        final message = cleaned.substring(index + prefix.length).trim();
        return message.isNotEmpty ? message : '';
      }

      // If prefix not found, try to extract from common patterns
      if (cleaned.contains(':')) {
        final parts = cleaned.split(':');
        if (parts.length > 1) {
          return parts.sublist(1).join(':').trim();
        }
      }

      return cleaned;
    } catch (e) {
      debugPrint('🔴 Error extracting message: $e');
      return '';
    }
  }

  /// Create new account
  Future<CreateAccountResponse> createAccount({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      debugPrint('🔵 Creating account for: $email');

      final requestData = {
        'user_name': name,
        'email': email,
        'phone_number': phone,
        'password': password,
        'role': role,
        'is_verified': true,
      };

      debugPrint('🔵 Request data: $requestData');

      final response = await _apiService.post(
        '/user/create_user.php',
        data: jsonEncode(requestData),
      );

      debugPrint('🔵 Create Account API Status: ${response.statusCode}');
      debugPrint('🔵 Create Account API Response: ${response.data}');

      final responseData = response.data;
      return CreateAccountResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('🔴 Error creating account: $e');
      return CreateAccountResponse(
        success: false,
        message: 'Account creation failed: ${e.toString()}',
      );
    }
  }

  /// Resends OTP to the specified email (uses unified generate-otp endpoint)
  Future<ResendOtpResponse> resendOtp({
    required String email,
    required String purpose,
  }) async {
    try {
      debugPrint(
        '🔵 AuthApiService: Resending OTP to email: $email with purpose: $purpose',
      );

      // Use the unified generate-otp endpoint for resending OTP
      final generateOtpResponse = await generateOtp(
        email: email,
        purpose: purpose,
      );

      return ResendOtpResponse(
        success: generateOtpResponse.success,
        message: generateOtpResponse.message,
        email: email,
        expiresIn: generateOtpResponse.expiresIn?.toString(),
      );
    } catch (e) {
      debugPrint('🔴 AuthApiService: Resend OTP error: $e');
      debugPrint('🔴 AuthApiService: Error type: ${e.runtimeType}');

      // Handle DioException specifically
      if (e is DioException) {
        debugPrint(
          '🔴 AuthApiService: DioException status code: ${e.response?.statusCode}',
        );
        debugPrint(
          '🔴 AuthApiService: DioException response data: ${e.response?.data}',
        );
        debugPrint('🔴 AuthApiService: DioException message: ${e.message}');
      }

      return ResendOtpResponse(
        success: false,
        message: 'Failed to resend OTP: ${e.toString()}',
      );
    }
  }

  /// Reset password using user ID and new password
  Future<ResetPasswordResponse> resetPassword({
    required int userId,
    required String newPassword,
  }) async {
    try {
      debugPrint('🔵 Sending reset password request for user: $userId');

      final requestData = {'user_id': userId, 'new_password': newPassword};

      debugPrint('🔵 Request data: $requestData');

      final response = await _apiService.post(
        '/auth/reset_password.php',
        data: jsonEncode(requestData),
      );

      debugPrint('🔵 Reset Password API Status: ${response.statusCode}');
      debugPrint('🔵 Reset Password API Response: ${response.data}');

      final responseData = response.data;
      final resetPasswordResponse = ResetPasswordResponse.fromJson(
        responseData,
      );

      debugPrint(
        '🔵 Reset Password Response success: ${resetPasswordResponse.success}',
      );
      debugPrint(
        '🔵 Reset Password Response message: ${resetPasswordResponse.message}',
      );

      return resetPasswordResponse;
    } catch (e) {
      debugPrint('🔴 Error in reset password API: $e');

      // Handle specific error cases and provide user-friendly messages
      String errorMessage = 'Failed to reset password. Please try again.';

      if (e.toString().contains('Bad request')) {
        // Extract the actual error message from the response
        if (e.toString().contains('New password must be different')) {
          errorMessage =
              'New password must be different from your current password';
        } else if (e.toString().contains('Invalid password')) {
          errorMessage = 'Please enter a valid password';
        } else {
          errorMessage =
              'Invalid request. Please check your input and try again.';
        }
      } else if (e.toString().contains('Network')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      }

      return ResetPasswordResponse(success: false, message: errorMessage);
    }
  }

  /// Sign in with Google OAuth
  Future<LoginResponse> signInWithGoogle({required String idToken}) async {
    try {
      debugPrint('🔵 Sending Google OAuth request with ID token');

      final requestData = {'id_token': idToken};

      debugPrint('🔵 Request data: $requestData');

      final response = await _apiService.post(
        '/auth/oauth/google/callback.php',
        data: requestData,
      );

      debugPrint('🔵 Google OAuth API Status: ${response.statusCode}');
      debugPrint('🔵 Google OAuth API Response: ${response.data}');

      final responseData = response.data;
      Map<String, dynamic> parsedData;
      if (responseData is Map<String, dynamic>) {
        parsedData = responseData;
      } else if (responseData is String) {
        try {
          parsedData = jsonDecode(responseData) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('🔴 Failed to parse JSON string: $e');
          return LoginResponse(
            success: false,
            message: 'Invalid response format',
          );
        }
      } else {
        debugPrint('🔴 Unexpected response type: ${responseData.runtimeType}');
        return LoginResponse(
          success: false,
          message: 'Unexpected response format',
        );
      }

      return LoginResponse.fromJson(parsedData);
    } catch (e) {
      debugPrint('🔴 Error in Google OAuth API: $e');
      debugPrint('🔴 Error type: ${e.runtimeType}');

      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        debugPrint('🔴 DioException Status: $statusCode');
        debugPrint('🔴 DioException Response Data: $responseData');

        String errorMessage = 'Google login failed';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? errorMessage;
        } else if (responseData is String) {
          try {
            final parsed = jsonDecode(responseData) as Map<String, dynamic>;
            errorMessage = parsed['message'] ?? errorMessage;
          } catch (parseError) {
            errorMessage = responseData;
          }
        }

        return LoginResponse(success: false, message: errorMessage);
      }

      final errorString = e.toString();
      String cleanMessage = errorString;
      if (cleanMessage.startsWith('Exception: ')) {
        cleanMessage = cleanMessage.substring(11);
      }

      return LoginResponse(
        success: false,
        message: cleanMessage.isNotEmpty
            ? cleanMessage
            : 'Google login failed. Please try again.',
      );
    }
  }

  /// Sign in with LinkedIn OAuth
  Future<LoginResponse> signInWithLinkedIn({required String code}) async {
    try {
      debugPrint('🔵 Sending LinkedIn OAuth request with authorization code');

      final requestData = {'code': code};

      debugPrint('🔵 Request data: $requestData');

      final response = await _apiService.post(
        '/auth/oauth/linkedin/callback.php',
        data: requestData,
      );

      debugPrint('🔵 LinkedIn OAuth API Status: ${response.statusCode}');
      debugPrint('🔵 LinkedIn OAuth API Response: ${response.data}');

      final responseData = response.data;
      Map<String, dynamic> parsedData;
      if (responseData is Map<String, dynamic>) {
        parsedData = responseData;
      } else if (responseData is String) {
        try {
          parsedData = jsonDecode(responseData) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('🔴 Failed to parse JSON string: $e');
          return LoginResponse(
            success: false,
            message: 'Invalid response format',
          );
        }
      } else {
        debugPrint('🔴 Unexpected response type: ${responseData.runtimeType}');
        return LoginResponse(
          success: false,
          message: 'Unexpected response format',
        );
      }

      return LoginResponse.fromJson(parsedData);
    } catch (e) {
      debugPrint('🔴 Error in LinkedIn OAuth API: $e');
      debugPrint('🔴 Error type: ${e.runtimeType}');

      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        debugPrint('🔴 DioException Status: $statusCode');
        debugPrint('🔴 DioException Response Data: $responseData');

        String errorMessage = 'LinkedIn login failed';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? errorMessage;
        } else if (responseData is String) {
          try {
            final parsed = jsonDecode(responseData) as Map<String, dynamic>;
            errorMessage = parsed['message'] ?? errorMessage;
          } catch (parseError) {
            errorMessage = responseData;
          }
        }

        return LoginResponse(success: false, message: errorMessage);
      }

      final errorString = e.toString();
      String cleanMessage = errorString;
      if (cleanMessage.startsWith('Exception: ')) {
        cleanMessage = cleanMessage.substring(11);
      }

      return LoginResponse(
        success: false,
        message: cleanMessage.isNotEmpty
            ? cleanMessage
            : 'LinkedIn login failed. Please try again.',
      );
    }
  }

  /// Logout user and revoke JWT token
  Future<LogoutResponse> logout({required int userId}) async {
    try {
      debugPrint('🔵 Sending logout request for user: $userId');

      final requestData = {'uid': userId};

      debugPrint('🔵 Logout Request data: $requestData');

      final response = await _apiService.post(
        '/auth/logout.php',
        data: jsonEncode(requestData),
      );

      debugPrint('🔵 Logout API Status: ${response.statusCode}');
      debugPrint('🔵 Logout API Response: ${response.data}');

      final responseData = response.data;
      final logoutResponse = LogoutResponse.fromJson(responseData);

      debugPrint('🔵 Logout Response success: ${logoutResponse.success}');
      debugPrint('🔵 Logout Response message: ${logoutResponse.message}');

      return logoutResponse;
    } catch (e) {
      debugPrint('🔴 Error in logout API: $e');

      // Handle specific error cases and provide user-friendly messages
      String errorMessage = 'Failed to logout. Please try again.';

      if (e.toString().contains('Bad request')) {
        errorMessage = 'Invalid logout request. Please try again.';
      } else if (e.toString().contains('Network')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      } else if (e.toString().contains('Unauthorized')) {
        errorMessage = 'Session expired. Please login again.';
      }

      return LogoutResponse(success: false, message: errorMessage);
    }
  }
}

/// Forgot password response model
class ForgotPasswordResponse {
  final bool success;
  final String message;
  final String? purpose;
  final int? userId;
  final int? expiresIn;

  ForgotPasswordResponse({
    required this.success,
    required this.message,
    this.purpose,
    this.userId,
    this.expiresIn,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['status'] ?? false,
      message: json['message'] ?? '',
      purpose: json['purpose'],
      userId: json['user_id'],
      expiresIn: json['expires_in'],
    );
  }
}

/// Verify OTP response model
class VerifyOtpResponse {
  final bool success;
  final String message;
  final int? userId;

  VerifyOtpResponse({
    required this.success,
    required this.message,
    this.userId,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    String message = json['message'] ?? '';

    // Convert technical error messages to user-friendly messages
    if (message.toLowerCase().contains('invalid otp') ||
        message.toLowerCase().contains('otp') &&
            message.toLowerCase().contains('invalid')) {
      message = 'Invalid OTP. Please check and try again.';
    }

    return VerifyOtpResponse(
      success: json['status'] ?? false,
      message: message,
      userId: json['user_id'],
    );
  }
}

/// Resend OTP response model
class ResendOtpResponse {
  final bool success;
  final String message;
  final String? email;
  final String? expiresIn;
  final String? timestamp;

  ResendOtpResponse({
    required this.success,
    required this.message,
    this.email,
    this.expiresIn,
    this.timestamp,
  });

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    print('🔵 ResendOtpResponse.fromJson: Parsing response: $json');

    final data = json['data'] as Map<String, dynamic>?;
    print('🔵 ResendOtpResponse.fromJson: Data field: $data');

    final response = ResendOtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      email: data?['email'],
      expiresIn: data?['expires_in'],
      timestamp: json['timestamp'],
    );

    print(
      '🔵 ResendOtpResponse.fromJson: Parsed response - success: ${response.success}, message: ${response.message}',
    );

    return response;
  }
}

/// Reset password response model
class ResetPasswordResponse {
  final bool success;
  final String message;

  ResetPasswordResponse({required this.success, required this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

/// Logout response model
class LogoutResponse {
  final bool success;
  final String message;

  LogoutResponse({required this.success, required this.message});

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      success: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

/// Phone login response model (OTP send)
class PhoneLoginResponse {
  final bool success;
  final String message;
  final int? userId;
  final int? expiresIn; // in seconds

  PhoneLoginResponse({
    required this.success,
    required this.message,
    this.userId,
    this.expiresIn,
  });

  factory PhoneLoginResponse.fromJson(Map<String, dynamic> json) {
    return PhoneLoginResponse(
      success: json['status'] ?? false,
      message: json['message'] ?? '',
      userId: json['user_id'] != null
          ? int.tryParse(json['user_id'].toString())
          : null,
      expiresIn: json['expires_in'] != null
          ? int.tryParse(json['expires_in'].toString())
          : null,
    );
  }
}
