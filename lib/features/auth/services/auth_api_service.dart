import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';

/// Auth-specific API service
/// Contains all authentication-related API methods
class AuthApiService {
  final ApiService _apiService;

  AuthApiService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Send forgot password OTP
  Future<ForgotPasswordResponse> forgotPassword({
    required String email,
    required String purpose,
  }) async {
    try {
      debugPrint('🔵 Sending forgot password request for: $email');

      final requestData = {'email': email, 'purpose': purpose};

      debugPrint('🔵 Request data: $requestData');

      final response = await _apiService.post(
        '/auth/forgot-password.php',
        data: jsonEncode(requestData),
      );

      debugPrint('🔵 Forgot Password API Status: ${response.statusCode}');
      debugPrint('🔵 Forgot Password API Response: ${response.data}');

      final responseData = response.data;
      final forgotPasswordResponse = ForgotPasswordResponse.fromJson(
        responseData,
      );

      debugPrint(
        '🔵 Forgot Password Response success: ${forgotPasswordResponse.success}',
      );
      debugPrint(
        '🔵 Forgot Password Response message: ${forgotPasswordResponse.message}',
      );
      debugPrint(
        '🔵 Forgot Password Response purpose: ${forgotPasswordResponse.purpose}',
      );
      debugPrint(
        '🔵 Forgot Password Response userId: ${forgotPasswordResponse.userId}',
      );
      debugPrint(
        '🔵 Forgot Password Response expiresIn: ${forgotPasswordResponse.expiresIn}',
      );

      return forgotPasswordResponse;
    } catch (e) {
      debugPrint('🔴 Error in forgot password API: $e');
      return ForgotPasswordResponse(
        success: false,
        message: 'Failed to send reset code: ${e.toString()}',
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
      return VerifyOtpResponse(
        success: false,
        message: 'Failed to verify OTP: ${e.toString()}',
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
    return VerifyOtpResponse(
      success: json['status'] ?? false,
      message: json['message'] ?? '',
      userId: json['user_id'],
    );
  }
}
