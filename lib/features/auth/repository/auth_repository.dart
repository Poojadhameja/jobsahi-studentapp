import 'dart:convert'; // ✅ for jsonEncode
import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/token_storage.dart';
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

  Future<ForgotPasswordResponse> forgotPassword({
    required String email,
    required String purpose,
  });

  Future<bool> logout();
  Future<bool> isLoggedIn();
  Future<User?> getCurrentUser();
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
            throw Exception(AppConstants.userDoesNotExist);
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
        } else {
          debugPrint("🔴 User or token is null in successful response");
        }
        return loginResponse;
      } else {
        // अगर success false है तो generic error message दो
        debugPrint("🔴 Login failed: ${loginResponse.message}");
        throw Exception(AppConstants.userDoesNotExist);
      }
    } catch (e) {
      debugPrint("🔴 Login error: $e");
      return LoginResponse(
        success: false,
        message: AppConstants.userDoesNotExist,
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
  Future<ForgotPasswordResponse> forgotPassword({
    required String email,
    required String purpose,
  }) async {
    try {
      debugPrint(
        '🔵 Sending forgot password request for: $email with purpose: $purpose',
      );

      final response = await _authApiService.forgotPassword(
        email: email,
        purpose: purpose,
      );

      debugPrint('🔵 Forgot Password Repository Response: ${response.success}');
      debugPrint('🔵 Forgot Password Repository Message: ${response.message}');

      return response;
    } catch (e) {
      debugPrint('🔴 Error in forgot password repository: $e');
      return ForgotPasswordResponse(
        success: false,
        message: 'Failed to send reset code: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _tokenStorage.clearAll();
      _apiService.clearAuthToken();
      debugPrint('User logged out successfully');
      return true;
    } catch (e) {
      debugPrint('Error during logout: $e');
      return false;
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
