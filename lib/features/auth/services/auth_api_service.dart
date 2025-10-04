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
        data: jsonEncode(requestData),
      );

      debugPrint('🔵 Generate OTP API Status: ${response.statusCode}');
      debugPrint('🔵 Generate OTP API Response: ${response.data}');

      final responseData = response.data;
      final generateOtpResponse = ForgotPasswordResponse.fromJson(responseData);

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

      return generateOtpResponse;
    } catch (e) {
      debugPrint('🔴 Error in generate OTP API: $e');
      return ForgotPasswordResponse(
        success: false,
        message: 'Failed to generate OTP: ${e.toString()}',
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
            "success": false,
            "message": "Invalid response format",
          };
        }
      } else {
        debugPrint(
          '🔴 Unexpected response data type: ${response.data.runtimeType}',
        );
        responseData = {
          "success": false,
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
          responseData['success'] = true;
          responseData['message'] =
              responseData['message'] ?? 'Login successful';
        }
      }

      return LoginResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('🔴 Error in login API: $e');
      return LoginResponse(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
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
