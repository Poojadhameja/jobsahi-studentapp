import 'dart:convert'; // ✅ for jsonEncode
import 'package:flutter/foundation.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/token_storage.dart';
import '../../../core/utils/app_constants.dart';

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

  Future<bool> logout();
  Future<bool> isLoggedIn();
  Future<User?> getCurrentUser();
}

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required ApiService apiService,
    required TokenStorage tokenStorage,
  }) : _apiService = apiService,
       _tokenStorage = tokenStorage;

  @override
  Future<CreateAccountResponse> createAccount({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      debugPrint('Creating account for: $email');

      // ✅ Prepare request data as JSON
      final requestData = {
        'user_name': name,
        'email': email,
        'phone_number': phone,
        'password': password,
        'role': AppConstants.studentRole,
        'is_verified': true, // New accounts start as unverified
      };

      debugPrint(
        'Sending request to: ${AppConstants.baseUrl}${AppConstants.createUserEndpoint}',
      );
      debugPrint('Request data: $requestData');

      // ✅ Send JSON body
      final response = await _apiService.post(
        AppConstants.createUserEndpoint,
        data: jsonEncode(requestData),
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Data: ${response.data}');

      final responseData = response.data;
      final createAccountResponse = CreateAccountResponse.fromJson(
        responseData,
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

        await _tokenStorage.storeLoginSession(
          token: responseData['token'] ?? '',
          userId: user.id,
          email: user.email,
          name: user.name,
          phone: user.phone,
          role: user.role,
        );

        if (responseData['token'] != null) {
          _apiService.setAuthToken(responseData['token']);
        }
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
      final requestData = {"email": email, "password": password};

      debugPrint(
        "🔵 Sending login request to: ${AppConstants.baseUrl}${AppConstants.loginEndpoint}",
      );
      debugPrint("🔵 Request data: $requestData");

      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: jsonEncode(requestData), // ✅ हमेशा JSON भेजो
      );

      // Debug log
      debugPrint("🔵 Login API Status Code: ${response.statusCode}");
      debugPrint("🔵 Login API Headers: ${response.headers}");
      debugPrint("🔵 Login API raw response: ${response.data}");
      debugPrint("🔵 Response data type: ${response.data.runtimeType}");

      // Handle different response types
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        // Try to parse JSON string
        try {
          responseData =
              jsonDecode(response.data as String) as Map<String, dynamic>;
        } catch (e) {
          debugPrint("🔴 Failed to parse JSON string: $e");
          responseData = {
            "success": false,
            "message": "Invalid response format",
          };
        }
      } else {
        debugPrint(
          "🔴 Unexpected response data type: ${response.data.runtimeType}",
        );
        responseData = {
          "success": false,
          "message": "Unexpected response format",
        };
      }

      // Handle case where API returns success but with different field names
      // Some APIs use 'status' instead of 'success', or return data directly
      if (response.statusCode == 200) {
        // If status code is 200, consider it successful even if success field is missing
        if (!responseData.containsKey('success') &&
            !responseData.containsKey('status')) {
          debugPrint(
            "🔵 API returned 200 but no success/status field, assuming success",
          );
          responseData['success'] = true;
          responseData['message'] =
              responseData['message'] ?? 'Login successful';
        }
      }

      debugPrint("🔵 Parsed response data: $responseData");

      // ✅ Safe parsing
      final loginResponse = LoginResponse.fromJson(responseData);

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

      final requestData = {'phone': phoneNumber};

      final response = await _apiService.post(
        '/auth/send_otp.php',
        data: jsonEncode(requestData), // ✅ send JSON
      );

      debugPrint('OTP API Response Status: ${response.statusCode}');
      debugPrint('OTP API Response Data: ${response.data}');

      final responseData = response.data;

      return LoginResponse(
        success: responseData['success'] ?? false,
        message: responseData['message'] ?? 'OTP sent successfully',
      );
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

      final requestData = {'phone': phoneNumber, 'otp': otp};

      final response = await _apiService.post(
        '/auth/verify_otp.php',
        data: jsonEncode(requestData), // ✅ send JSON
      );

      debugPrint(
        'OTP Verification API Response Status: ${response.statusCode}',
      );
      debugPrint('OTP Verification API Response Data: ${response.data}');

      final responseData = response.data;
      final loginResponse = LoginResponse.fromJson(responseData);

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
