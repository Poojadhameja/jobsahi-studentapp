import 'dart:convert'; // ✅ for jsonEncode
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/token_storage.dart';
import '../../../shared/services/fcm_service.dart';
import '../../../shared/services/profile_cache_service.dart';
import '../../../core/utils/app_constants.dart';
import '../services/auth_api_service.dart';

/// Abstract interface for authentication repository
abstract class AuthRepository {
  Future<CreateAccountResponse> createAccount({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<LoginResponse> login({
    required String email,
    required String password,
  });

  Future<LoginResponse> loginWithOtp({required String phoneNumber});

  Future<LoginResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<PhoneLoginResponse> phoneLogin({required String phoneNumber});

  Future<LoginResponse> verifyPhoneLoginOtp({
    required int userId,
    required String otp,
  });

  Future<ForgotPasswordResponse> generateOtp({
    required String email,
    required String purpose,
  });

  Future<VerifyOtpResponse> verifyForgotPasswordOtp({
    required int userId,
    required String otp,
    required String purpose,
  });

  Future<ResendOtpResponse> resendOtp({
    required String email,
    required String purpose,
  });

  Future<ResetPasswordResponse> resetPassword({
    required int userId,
    required String newPassword,
  });

  Future<bool> logout();
  Future<bool> isLoggedIn();
  Future<bool> hasToken();
  Future<User?> getCurrentUser();
  
  Future<LoginResponse> signInWithGoogle({required String idToken});
  Future<LoginResponse> signInWithLinkedIn({required String code});
}

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;
  final AuthApiService _authApiService;

  AuthRepositoryImpl({
    required ApiService apiService,
    required TokenStorage tokenStorage,
    AuthApiService? authApiService,
  }) : _apiService = apiService,
       _tokenStorage = tokenStorage,
       _authApiService =
           authApiService ?? AuthApiService(apiService: apiService);

  @override
  Future<CreateAccountResponse> createAccount({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      debugPrint('Creating account for: $email');

      final createAccountResponse = await _authApiService.createAccount(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: AppConstants.studentRole,
      );

      // If account creation is successful, store user data
      if (createAccountResponse.success && createAccountResponse.user != null) {
        final user = createAccountResponse.user!;

        // ✅ Role validation - only students can access the app
        if (user.role != null && user.role != AppConstants.studentRole) {
          debugPrint(
            "🔴 Access denied: User role '${user.role}' is not allowed. Only students can access this app.",
          );
          return CreateAccountResponse(
            success: false,
            message: AppConstants.userDoesNotExist,
          );
        }

        // If role is null, we'll allow access but log a warning
        if (user.role == null) {
          debugPrint(
            "⚠️ Warning: User role is null. Allowing access but this should be investigated.",
          );
        }

        // Note: Token storage would need to be handled differently
        // since createAccount API might not return token immediately
        // This depends on your backend implementation
      }

      return createAccountResponse;
    } catch (e) {
      debugPrint('Error creating account: $e');
      return CreateAccountResponse(
        success: false,
        message: 'Account creation failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("🔵 Sending login request for: $email");

      final loginResponse = await _authApiService.login(
        email: email,
        password: password,
      );

      debugPrint("🔵 LoginResponse success: ${loginResponse.success}");
      debugPrint("🔵 LoginResponse message: ${loginResponse.message}");
      debugPrint("🔵 LoginResponse user: ${loginResponse.user}");
      debugPrint("🔵 LoginResponse token: ${loginResponse.token}");

      if (loginResponse.success) {
        // अगर login success है तो user और token save करो
        if (loginResponse.user != null && loginResponse.token != null) {
          final user = loginResponse.user!;

          // ✅ Role validation - only students can access the app
          if (user.role != null && user.role != AppConstants.studentRole) {
            debugPrint(
              "🔴 Access denied: User role '${user.role}' is not allowed. Only students can access this app.",
            );
            return LoginResponse(
              success: false,
              message: AppConstants.userDoesNotExist,
              errorCode: 'ACCESS_DENIED',
            );
          }

          // If role is null, we'll allow access but log a warning
          if (user.role == null) {
            debugPrint(
              "⚠️ Warning: User role is null. Allowing access but this should be investigated.",
            );
          }

          await _tokenStorage.storeLoginSession(
            token: loginResponse.token!,
            userId: user.id,
            email: user.email,
            name: user.name,
            phone: user.phone,
            role: user.role,
          );
          _apiService.setAuthToken(loginResponse.token!);
          debugPrint(
            "🔵 User data stored successfully with role: ${user.role}",
          );

          // Save FCM token after successful login
          try {
            final fcmService = FcmService();
            await fcmService.saveTokenToBackend();
            debugPrint('✅ FCM token saved after login');
          } catch (e) {
            debugPrint('🔴 Error saving FCM token after login: $e');
            // Don't fail login if FCM token save fails
          }
        } else {
          debugPrint("🔴 User or token is null in successful response");
        }
        return loginResponse;
      } else {
        // Preserve the error message and error code from API response
        debugPrint("🔴 Login failed: ${loginResponse.message} (Error Code: ${loginResponse.errorCode})");
        return loginResponse;
      }
    } catch (e) {
      debugPrint("🔴 Login error: $e");
      // Check if it's a network error
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Network') ||
          e.toString().contains('timeout')) {
        return LoginResponse(
          success: false,
          message: 'Network error. Please check your internet connection and try again.',
          errorCode: 'NETWORK_ERROR',
        );
      }
      return LoginResponse(
        success: false,
        message: 'Login failed. Please try again.',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<LoginResponse> loginWithOtp({required String phoneNumber}) async {
    try {
      debugPrint('Sending OTP to: $phoneNumber');

      final response = await _authApiService.sendOtp(phoneNumber: phoneNumber);

      return response;
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      return LoginResponse(
        success: false,
        message: AppConstants.userDoesNotExist,
      );
    }
  }

  @override
  Future<LoginResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      debugPrint('Verifying OTP for: $phoneNumber');

      final loginResponse = await _authApiService.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );

      if (loginResponse.success &&
          loginResponse.user != null &&
          loginResponse.token != null) {
        final user = loginResponse.user!;

        // ✅ Role validation - only students can access the app
        if (user.role != null && user.role != AppConstants.studentRole) {
          debugPrint(
            "🔴 Access denied: User role '${user.role}' is not allowed. Only students can access this app.",
          );
          return LoginResponse(
            success: false,
            message: AppConstants.userDoesNotExist,
          );
        }

        // If role is null, we'll allow access but log a warning
        if (user.role == null) {
          debugPrint(
            "⚠️ Warning: User role is null. Allowing access but this should be investigated.",
          );
        }

        await _tokenStorage.storeLoginSession(
          token: loginResponse.token!,
          userId: user.id,
          email: user.email,
          name: user.name,
          phone: user.phone,
          role: user.role,
        );

        _apiService.setAuthToken(loginResponse.token!);

        // Save FCM token after successful login
        try {
          final fcmService = FcmService();
          await fcmService.saveTokenToBackend();
          debugPrint('✅ FCM token saved after OTP verification');
        } catch (e) {
          debugPrint('🔴 Error saving FCM token after OTP verification: $e');
          // Don't fail login if FCM token save fails
        }
      }

      return loginResponse;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return LoginResponse(
        success: false,
        message: AppConstants.userDoesNotExist,
      );
    }
  }

  @override
  Future<PhoneLoginResponse> phoneLogin({required String phoneNumber}) async {
    try {
      debugPrint('🔵 Sending phone login OTP to: $phoneNumber');

      final response = await _authApiService.phoneLogin(phoneNumber: phoneNumber);

      debugPrint('🔵 Phone Login Repository Response success: ${response.success}');
      debugPrint('🔵 Phone Login Repository Response message: ${response.message}');
      debugPrint('🔵 Phone Login Repository Response userId: ${response.userId}');
      debugPrint('🔵 Phone Login Repository Response expiresIn: ${response.expiresIn}');

      return response;
    } catch (e) {
      debugPrint('🔴 Error in phone login repository: $e');
      return PhoneLoginResponse(
        success: false,
        message: 'Failed to send OTP: ${e.toString()}',
      );
    }
  }

  @override
  Future<LoginResponse> verifyPhoneLoginOtp({
    required int userId,
    required String otp,
  }) async {
    try {
      debugPrint('🔵 Verifying phone login OTP for user: $userId');

      final loginResponse = await _authApiService.verifyPhoneLoginOtp(
        userId: userId,
        otp: otp,
      );

      debugPrint('🔵 Verify Phone Login OTP Repository Response success: ${loginResponse.success}');
      debugPrint('🔵 Verify Phone Login OTP Repository Response message: ${loginResponse.message}');

      if (loginResponse.success &&
          loginResponse.user != null &&
          loginResponse.token != null) {
        final user = loginResponse.user!;

        // ✅ Role validation - only students can access the app
        if (user.role != null && user.role != AppConstants.studentRole) {
          debugPrint(
            "🔴 Access denied: User role '${user.role}' is not allowed. Only students can access this app.",
          );
          return LoginResponse(
            success: false,
            message: AppConstants.userDoesNotExist,
          );
        }

        // If role is null, we'll allow access but log a warning
        if (user.role == null) {
          debugPrint(
            "⚠️ Warning: User role is null. Allowing access but this should be investigated.",
          );
        }

        await _tokenStorage.storeLoginSession(
          token: loginResponse.token!,
          userId: user.id,
          email: user.email,
          name: user.name,
          phone: user.phone,
          role: user.role,
        );

        _apiService.setAuthToken(loginResponse.token!);
        debugPrint(
          "🔵 User data stored successfully with role: ${user.role}",
        );

        // Save FCM token after successful login
        try {
          final fcmService = FcmService();
          await fcmService.saveTokenToBackend();
          debugPrint('✅ FCM token saved after phone login OTP verification');
        } catch (e) {
          debugPrint('🔴 Error saving FCM token after phone login OTP verification: $e');
          // Don't fail login if FCM token save fails
        }
      }

      return loginResponse;
    } catch (e) {
      debugPrint('🔴 Error verifying phone login OTP: $e');
      return LoginResponse(
        success: false,
        message: 'Failed to verify OTP: ${e.toString()}',
      );
    }
  }

  @override
  Future<ForgotPasswordResponse> generateOtp({
    required String email,
    required String purpose,
  }) async {
    try {
      debugPrint(
        '🔵 Sending generate OTP request for: $email with purpose: $purpose',
      );

      final response = await _authApiService.generateOtp(
        email: email,
        purpose: purpose,
      );

      debugPrint('🔵 Generate OTP Repository Response: ${response.success}');
      debugPrint('🔵 Generate OTP Repository Message: ${response.message}');

      return response;
    } catch (e) {
      debugPrint('🔴 Error in generate OTP repository: $e');
      return ForgotPasswordResponse(
        success: false,
        message: 'Failed to generate OTP: ${e.toString()}',
      );
    }
  }

  @override
  Future<VerifyOtpResponse> verifyForgotPasswordOtp({
    required int userId,
    required String otp,
    required String purpose,
  }) async {
    try {
      debugPrint(
        '🔵 Verifying forgot password OTP for user: $userId with purpose: $purpose',
      );

      final response = await _authApiService.verifyForgotPasswordOtp(
        userId: userId,
        otp: otp,
        purpose: purpose,
      );

      debugPrint('🔵 Verify OTP Repository Response: ${response.success}');
      debugPrint('🔵 Verify OTP Repository Message: ${response.message}');

      return response;
    } catch (e) {
      debugPrint('🔴 Error in verify OTP repository: $e');

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

  @override
  Future<ResendOtpResponse> resendOtp({
    required String email,
    required String purpose,
  }) async {
    try {
      debugPrint('🔵 Resending OTP to email: $email with purpose: $purpose');

      final response = await _authApiService.resendOtp(
        email: email,
        purpose: purpose,
      );

      debugPrint('🔵 Resend OTP Repository Response: ${response.success}');
      debugPrint('🔵 Resend OTP Repository Message: ${response.message}');

      return response;
    } catch (e) {
      debugPrint('🔴 Error in resend OTP repository: $e');
      debugPrint('🔴 Error type: ${e.runtimeType}');

      // Handle DioException specifically
      if (e is DioException) {
        debugPrint('🔴 DioException status code: ${e.response?.statusCode}');
        debugPrint('🔴 DioException response data: ${e.response?.data}');
        debugPrint('🔴 DioException type: ${e.type}');
        debugPrint('🔴 DioException message: ${e.message}');

        // Check for CORS errors
        if (e.type == DioExceptionType.connectionError ||
            e.message?.contains('CORS') == true ||
            e.message?.contains('cors') == true) {
          return ResendOtpResponse(
            success: false,
            message:
                'Network error. Please check your connection and try again.',
          );
        }

        // Check for specific error responses
        if (e.response?.statusCode == 400) {
          return ResendOtpResponse(
            success: false,
            message: 'Invalid request. Please check your email and try again.',
          );
        } else if (e.response?.statusCode == 404) {
          return ResendOtpResponse(
            success: false,
            message: 'Service not found. Please try again later.',
          );
        } else if (e.response?.statusCode == 405) {
          return ResendOtpResponse(
            success: false,
            message: 'Method not allowed. Please contact support.',
          );
        } else if (e.response?.statusCode == 500) {
          return ResendOtpResponse(
            success: false,
            message: 'Server error. Please try again later.',
          );
        }
      }

      return ResendOtpResponse(
        success: false,
        message: 'Failed to resend OTP. Please try again.',
      );
    }
  }

  @override
  Future<ResetPasswordResponse> resetPassword({
    required int userId,
    required String newPassword,
  }) async {
    try {
      debugPrint('🔵 Sending reset password request for user: $userId');

      final response = await _authApiService.resetPassword(
        userId: userId,
        newPassword: newPassword,
      );

      debugPrint('🔵 Reset Password Repository Response: ${response.success}');
      debugPrint('🔵 Reset Password Repository Message: ${response.message}');

      return response;
    } catch (e) {
      debugPrint('🔴 Error in reset password repository: $e');

      // Handle specific error cases and provide user-friendly messages
      String errorMessage = 'Failed to reset password. Please try again.';

      if (e.toString().contains('New password must be different')) {
        errorMessage =
            'New password must be different from your current password';
      } else if (e.toString().contains('Invalid password')) {
        errorMessage = 'Please enter a valid password';
      } else if (e.toString().contains('Network')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      }

      return ResetPasswordResponse(success: false, message: errorMessage);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      // Get user ID for logout API call
      final userIdString = await _tokenStorage.getUserId();
      if (userIdString != null && userIdString.isNotEmpty) {
        final userId = int.tryParse(userIdString);
        if (userId != null) {
          debugPrint('🔵 Calling logout API for user: $userId');

          // Call logout API to revoke JWT token on server
          final logoutResponse = await _authApiService.logout(userId: userId);

          if (logoutResponse.success) {
            debugPrint('🔵 Logout API successful: ${logoutResponse.message}');
          } else {
            debugPrint('🔴 Logout API failed: ${logoutResponse.message}');
            // Continue with local logout even if API fails
          }
        } else {
          debugPrint('🔴 Invalid user ID format: $userIdString');
        }
      } else {
        debugPrint('🔴 No user ID found for logout');
      }

      // Clear auth data
      await _tokenStorage.clearAuthData();
      _apiService.clearAuthToken();
      
      // Clear profile cache on logout (to prevent old user data showing)
      try {
        final profileCacheService = ProfileCacheService.instance;
        await profileCacheService.clearCache();
        await profileCacheService.clearProfileImageCache();
        debugPrint('🔵 Profile cache cleared on logout');
      } catch (e) {
        debugPrint('⚠️ Error clearing profile cache: $e');
      }
      
      debugPrint('🔵 User logged out successfully (auth data cleared, profile cache cleared)');
      return true;
    } catch (e) {
      debugPrint('🔴 Error during logout: $e');

      // Clear auth data even if there's an error
      try {
        await _tokenStorage.clearAuthData();
        _apiService.clearAuthToken();
        
        // Clear profile cache on logout (to prevent old user data showing)
        try {
          final profileCacheService = ProfileCacheService.instance;
          await profileCacheService.clearCache();
          await profileCacheService.clearProfileImageCache();
          debugPrint('🔵 Profile cache cleared on logout (despite error)');
        } catch (cacheError) {
          debugPrint('⚠️ Error clearing profile cache: $cacheError');
        }
        
        debugPrint('🔵 Auth data cleared despite error (profile cache cleared)');
        return true;
      } catch (clearError) {
        debugPrint('🔴 Error clearing local data: $clearError');
        return false;
      }
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = await _tokenStorage.isLoggedIn();
      final hasToken = await _tokenStorage.hasToken();

      if (isLoggedIn && !hasToken) {
        await _tokenStorage.clearAll();
        return false;
      }

      return isLoggedIn && hasToken;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  @override
  Future<bool> hasToken() async {
    try {
      return await _tokenStorage.hasToken();
    } catch (e) {
      debugPrint('Error checking token: $e');
      return false;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final isLoggedIn = await this.isLoggedIn();
      if (!isLoggedIn) return null;

      final userId = await _tokenStorage.getUserId();
      final email = await _tokenStorage.getUserEmail();
      final name = await _tokenStorage.getUserName();
      final phone = await _tokenStorage.getUserPhone();

      if (userId == null || email == null || name == null || phone == null) {
        return null;
      }

      return User(id: userId, name: name, email: email, phone: phone);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<LoginResponse> signInWithGoogle({required String idToken}) async {
    try {
      debugPrint('🔵 Sending Google OAuth request for login');

      final loginResponse = await _authApiService.signInWithGoogle(
        idToken: idToken,
      );

      debugPrint('🔵 Google OAuth Response success: ${loginResponse.success}');
      debugPrint('🔵 Google OAuth Response message: ${loginResponse.message}');

      if (loginResponse.success) {
        if (loginResponse.user != null && loginResponse.token != null) {
          final user = loginResponse.user!;

          // ✅ Role validation - only students can access the app
          if (user.role != null && user.role != AppConstants.studentRole) {
            debugPrint(
              "🔴 Access denied: User role '${user.role}' is not allowed. Only students can access this app.",
            );
            return LoginResponse(
              success: false,
              message: AppConstants.userDoesNotExist,
              errorCode: 'ACCESS_DENIED',
            );
          }

          await _tokenStorage.storeLoginSession(
            token: loginResponse.token!,
            userId: user.id,
            email: user.email,
            name: user.name,
            phone: user.phone,
            role: user.role,
          );
          _apiService.setAuthToken(loginResponse.token!);
          debugPrint(
            "🔵 User data stored successfully with role: ${user.role}",
          );

          // Save FCM token after successful login
          try {
            final fcmService = FcmService();
            await fcmService.saveTokenToBackend();
            debugPrint('✅ FCM token saved after Google OAuth login');
          } catch (e) {
            debugPrint('🔴 Error saving FCM token after Google OAuth login: $e');
            // Don't fail login if FCM token save fails
          }
        } else {
          debugPrint("🔴 User or token is null in successful response");
        }
      }

      return loginResponse;
    } catch (e) {
      debugPrint('🔴 Error in Google OAuth login: $e');
      return LoginResponse(
        success: false,
        message: 'Google login failed. Please try again.',
        errorCode: 'OAUTH_ERROR',
      );
    }
  }

  @override
  Future<LoginResponse> signInWithLinkedIn({required String code}) async {
    try {
      debugPrint('🔵 Sending LinkedIn OAuth request for login');

      final loginResponse = await _authApiService.signInWithLinkedIn(
        code: code,
      );

      debugPrint('🔵 LinkedIn OAuth Response success: ${loginResponse.success}');
      debugPrint('🔵 LinkedIn OAuth Response message: ${loginResponse.message}');

      if (loginResponse.success) {
        if (loginResponse.user != null && loginResponse.token != null) {
          final user = loginResponse.user!;

          // ✅ Role validation - only students can access the app
          if (user.role != null && user.role != AppConstants.studentRole) {
            debugPrint(
              "🔴 Access denied: User role '${user.role}' is not allowed. Only students can access this app.",
            );
            return LoginResponse(
              success: false,
              message: AppConstants.userDoesNotExist,
              errorCode: 'ACCESS_DENIED',
            );
          }

          await _tokenStorage.storeLoginSession(
            token: loginResponse.token!,
            userId: user.id,
            email: user.email,
            name: user.name,
            phone: user.phone,
            role: user.role,
          );
          _apiService.setAuthToken(loginResponse.token!);
          debugPrint(
            "🔵 User data stored successfully with role: ${user.role}",
          );

          // Save FCM token after successful login
          try {
            final fcmService = FcmService();
            await fcmService.saveTokenToBackend();
            debugPrint('✅ FCM token saved after LinkedIn OAuth login');
          } catch (e) {
            debugPrint('🔴 Error saving FCM token after LinkedIn OAuth login: $e');
            // Don't fail login if FCM token save fails
          }
        } else {
          debugPrint("🔴 User or token is null in successful response");
        }
      }

      return loginResponse;
    } catch (e) {
      debugPrint('🔴 Error in LinkedIn OAuth login: $e');
      return LoginResponse(
        success: false,
        message: 'LinkedIn login failed. Please try again.',
        errorCode: 'OAUTH_ERROR',
      );
    }
  }

  /// Test method to debug API response
  Future<void> testLoginAPI(String email, String password) async {
    try {
      debugPrint('=== TESTING LOGIN API ===');
      debugPrint('Email: $email');
      debugPrint('Password: $password');

      final requestData = {'email': email, 'password': password};
      debugPrint('Request Data: $requestData');

      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: jsonEncode(requestData),
      );

      debugPrint('=== RAW API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data toString(): ${response.data.toString()}');
      debugPrint('=== END RAW RESPONSE ===');

      // Test parsing
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          responseData =
              jsonDecode(response.data as String) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('Failed to parse JSON string: $e');
          responseData = {
            "success": false,
            "message": "Invalid response format",
          };
        }
      } else {
        responseData = {
          "success": false,
          "message": "Unexpected response format",
        };
      }

      debugPrint('=== PARSED RESPONSE ===');
      debugPrint('Parsed Data: $responseData');

      final loginResponse = LoginResponse.fromJson(responseData);
      debugPrint('LoginResponse success: ${loginResponse.success}');
      debugPrint('LoginResponse message: ${loginResponse.message}');
      debugPrint('LoginResponse token: ${loginResponse.token}');
      debugPrint('LoginResponse user: ${loginResponse.user}');
      debugPrint('=== END PARSED RESPONSE ===');
    } catch (e) {
      debugPrint('=== API TEST ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('=== END API TEST ERROR ===');
    }
  }
}
