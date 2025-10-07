import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../repository/auth_repository.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/token_storage.dart';
import '../../../core/router/app_router.dart';

/// Authentication BLoC
/// Handles all authentication-related business logic
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
    : _authRepository = authRepository ?? _createDefaultRepository(),
      super(const AuthInitial()) {
    // Register event handlers
    on<LoginWithOtpEvent>(_onLoginWithOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<SocialLoginEvent>(_onSocialLogin);
    on<CreateAccountEvent>(_onCreateAccount);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<ChangePasswordEvent>(_onChangePassword);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<ClearAuthErrorEvent>(_onClearAuthError);
    on<SplashInitializationEvent>(_onSplashInitialization);
    on<OnboardingPageChangeEvent>(_onOnboardingPageChange);
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
    on<SkipOnboardingEvent>(_onSkipOnboarding);
    on<TogglePasswordVisibilityEvent>(_onTogglePasswordVisibility);
    on<ToggleTermsAcceptanceEvent>(_onToggleTermsAcceptance);
    on<SetFormSubmittingEvent>(_onSetFormSubmitting);
    on<SetForgotPasswordSendingEvent>(_onSetForgotPasswordSending);
    on<VerifyForgotPasswordOtpEvent>(_onVerifyForgotPasswordOtp);
    on<ResendOtpEvent>(_onResendOtp);
  }

  /// Create default repository instance
  static AuthRepository _createDefaultRepository() {
    final apiService = ApiService();
    final tokenStorage = TokenStorage.instance;
    return AuthRepositoryImpl(
      apiService: apiService,
      tokenStorage: tokenStorage,
    );
  }

  /// Handle login with OTP
  Future<void> _onLoginWithOtp(
    LoginWithOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      if (event.phoneNumber.length != 10) {
        emit(
          const AuthError(
            message: 'Please enter a valid 10-digit phone number',
          ),
        );
        return;
      }

      final response = await _authRepository.loginWithOtp(
        phoneNumber: event.phoneNumber,
      );

      if (response.success) {
        emit(OtpSentState(phoneNumber: event.phoneNumber));
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: 'Failed to send OTP: ${e.toString()}'));
    }
  }

  /// Handle OTP verification
  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const OtpVerificationLoading());

      if (event.otp.length != 6) {
        emit(const AuthError(message: 'Please enter a valid 6-digit OTP'));
        return;
      }

      String phoneNumber = '';
      if (state is OtpSentState) {
        phoneNumber = (state as OtpSentState).phoneNumber;
      }

      final response = await _authRepository.verifyOtp(
        phoneNumber: phoneNumber,
        otp: event.otp,
      );

      if (response.success) {
        // ✅ Role validation is already handled in the repository
        // If we reach here, the user has the correct role (student)
        emit(const OtpVerificationSuccess());
        await Future.delayed(const Duration(milliseconds: 500));
        emit(AuthSuccess(message: response.message));

        // Notify router about auth state change
        AuthStateNotifier.instance.notify();
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      // ✅ Handle role-based access control errors
      final errorMessage = e.toString();
      if (errorMessage.contains('Access denied') ||
          errorMessage.contains('Only students can access')) {
        emit(AuthError(message: errorMessage));
      } else {
        emit(AuthError(message: 'OTP verification failed: ${e.toString()}'));
      }
    }
  }

  /// Handle login with email
  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      if (!event.email.contains('@')) {
        emit(const AuthError(message: 'Please enter a valid email address'));
        return;
      }

      if (event.password.length < 6) {
        emit(
          const AuthError(message: 'Password must be at least 6 characters'),
        );
        return;
      }

      final response = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      if (response.success) {
        // ✅ Role validation is already handled in the repository
        // If we reach here, the user has the correct role (student)
        emit(AuthSuccess(message: response.message));

        // Notify router about auth state change
        AuthStateNotifier.instance.notify();
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      // ✅ Handle role-based access control errors
      final errorMessage = e.toString();
      if (errorMessage.contains('Access denied') ||
          errorMessage.contains('Only students can access')) {
        emit(AuthError(message: errorMessage));
      } else {
        emit(AuthError(message: 'Login failed: ${e.toString()}'));
      }
    }
  }

  /// Handle social login
  Future<void> _onSocialLogin(
    SocialLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      await Future.delayed(const Duration(seconds: 2));

      emit(
        AuthSuccess(
          message: '${event.provider.capitalize()} login successful',
          user: {}, // social login के बाद भी user खाली Map रख दो
        ),
      );

      // Notify router about auth state change
      AuthStateNotifier.instance.notify();
    } catch (e) {
      emit(
        AuthError(
          message:
              '${event.provider.capitalize()} login failed: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle account creation
  Future<void> _onCreateAccount(
    CreateAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      if (event.name.isEmpty) {
        emit(const AuthError(message: 'Please enter your name'));
        return;
      }
      if (event.name.trim().length < 6) {
        emit(const AuthError(message: 'Name must be at least 6 letters long'));
        return;
      }
      // Check if name contains at least 2 words (first name and surname)
      final nameParts = event.name.trim().split(RegExp(r'\s+'));
      if (nameParts.length < 2) {
        emit(
          const AuthError(message: 'Please enter your full name with surname'),
        );
        return;
      }
      // Check if all parts have at least 2 characters
      for (String part in nameParts) {
        if (part.length < 2) {
          emit(
            const AuthError(
              message: 'Each name part must be at least 2 letters',
            ),
          );
          return;
        }
      }
      if (!event.email.contains('@')) {
        emit(const AuthError(message: 'Please enter a valid email address'));
        return;
      }
      if (event.phone.length != 10 ||
          !RegExp(r'^[0-9]{10}$').hasMatch(event.phone)) {
        emit(
          const AuthError(
            message:
                'Please enter a valid 10-digit phone number with only numbers',
          ),
        );
        return;
      }
      if (event.password.length < 6) {
        emit(
          const AuthError(message: 'Password must be at least 6 characters'),
        );
        return;
      }

      final response = await _authRepository.createAccount(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
      );

      if (response.success) {
        // ✅ Role validation is already handled in the repository
        // If we reach here, the user has the correct role (student)
        emit(AccountCreationSuccess(message: response.message));
      } else {
        // Check for specific error messages to show appropriate popups
        final errorMessage = response.message.toLowerCase();

        if (errorMessage.contains('email') &&
            (errorMessage.contains('already') ||
                errorMessage.contains('exists') ||
                errorMessage.contains('duplicate'))) {
          emit(const EmailAlreadyExistsError(message: 'Email already exists'));
        } else if (errorMessage.contains('phone') &&
            (errorMessage.contains('already') ||
                errorMessage.contains('exists') ||
                errorMessage.contains('duplicate'))) {
          emit(
            const PhoneAlreadyExistsError(
              message: 'Phone number already exists',
            ),
          );
        } else if (errorMessage.contains('rate limit') ||
            errorMessage.contains('too many requests')) {
          emit(
            const AuthError(
              message: 'Too many requests. Please wait a moment and try again.',
            ),
          );
        } else {
          emit(AuthError(message: response.message));
        }
      }
    } catch (e) {
      // ✅ Handle role-based access control errors
      final errorMessage = e.toString();
      if (errorMessage.contains('Access denied') ||
          errorMessage.contains('Only students can access')) {
        emit(AuthError(message: errorMessage));
      } else {
        emit(AuthError(message: 'Account creation failed: ${e.toString()}'));
      }
    }
  }

  /// Handle forgot password
  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      if (!event.email.contains('@')) {
        emit(const AuthError(message: 'Please enter a valid email address'));
        return;
      }

      final response = await _authRepository.generateOtp(
        email: event.email,
        purpose: 'forgot_password', // Using forgot_password as the purpose
      );

      if (response.success) {
        emit(
          PasswordResetCodeSentState(
            email: event.email,
            userId: response.userId,
          ),
        );
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: 'Failed to send reset code: ${e.toString()}'));
    }
  }

  /// Handle password reset
  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      if (event.newPassword.length < 6) {
        emit(
          const AuthError(message: 'Password must be at least 6 characters'),
        );
        return;
      }

      final response = await _authRepository.resetPassword(
        userId: event.userId,
        newPassword: event.newPassword,
      );

      if (response.success) {
        emit(const PasswordResetSuccess());
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      // Handle specific error cases and provide user-friendly messages
      String errorMessage = 'Password reset failed. Please try again.';

      if (e.toString().contains('New password must be different')) {
        errorMessage =
            'New password must be different from your current password';
      } else if (e.toString().contains('Invalid password')) {
        errorMessage = 'Please enter a valid password';
      } else if (e.toString().contains('Network')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      }

      emit(AuthError(message: errorMessage));
    }
  }

  /// Handle password change
  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      await Future.delayed(const Duration(seconds: 1));

      if (event.currentPassword.isEmpty) {
        emit(const AuthError(message: 'Please enter your current password'));
        return;
      }
      if (event.newPassword.length < 6) {
        emit(
          const AuthError(
            message: 'New password must be at least 6 characters',
          ),
        );
        return;
      }

      emit(const PasswordChangeSuccess());
    } catch (e) {
      emit(AuthError(message: 'Password change failed: ${e.toString()}'));
    }
  }

  /// Handle logout
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthLoading());

      final success = await _authRepository.logout();

      if (success) {
        emit(const LogoutSuccess());

        // Notify router about auth state change (logout)
        AuthStateNotifier.instance.notify();
      } else {
        emit(const AuthError(message: 'Logout failed'));
      }
    } catch (e) {
      emit(AuthError(message: 'Logout failed: ${e.toString()}'));
    }
  }

  /// Handle authentication status check
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Add a small delay for better UX
      await Future.delayed(const Duration(seconds: 1));

      final isLoggedIn = await _authRepository.isLoggedIn();
      final hasToken = await _authRepository.hasToken();

      if (isLoggedIn && hasToken) {
        // Get user data from storage
        final tokenStorage = TokenStorage.instance;
        final userName = await tokenStorage.getUserName();
        final userEmail = await tokenStorage.getUserEmail();

        // Restore auth token in API service
        final token = await tokenStorage.getToken();
        if (token != null) {
          final apiService = ApiService();
          apiService.setAuthToken(token);
        }

        // Create user data map
        final userData = {'name': userName ?? 'User', 'email': userEmail ?? ''};

        emit(
          AuthSuccess(
            message: 'Welcome back, ${userName ?? 'User'}!',
            isLoggedIn: true,
            user: userData,
          ),
        );
      } else {
        // Clear any invalid session data
        if (isLoggedIn && !hasToken) {
          await _authRepository.logout();
        }
        emit(const AuthInitial());
      }
    } catch (e) {
      debugPrint('🔴 Error checking auth status: $e');
      emit(const AuthInitial());
    }
  }

  void _onClearAuthError(ClearAuthErrorEvent event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }

  Future<void> _onSplashInitialization(
    SplashInitializationEvent event,
    Emitter<AuthState> emit,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    emit(const SplashReadyToNavigate());
  }

  void _onOnboardingPageChange(
    OnboardingPageChangeEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(OnboardingState(currentPage: event.pageIndex));
  }

  void _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(const OnboardingCompleted());
  }

  void _onSkipOnboarding(SkipOnboardingEvent event, Emitter<AuthState> emit) {
    emit(const OnboardingSkipped());
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibilityEvent event,
    Emitter<AuthState> emit,
  ) {
    if (state is CreateAccountFormState) {
      final currentState = state as CreateAccountFormState;
      if (event.isPassword) {
        emit(currentState.copyWith(isPasswordVisible: event.isVisible));
      } else {
        emit(currentState.copyWith(isConfirmPasswordVisible: event.isVisible));
      }
    } else {
      if (event.isPassword) {
        emit(CreateAccountFormState(isPasswordVisible: event.isVisible));
      } else {
        emit(CreateAccountFormState(isConfirmPasswordVisible: event.isVisible));
      }
    }
  }

  void _onToggleTermsAcceptance(
    ToggleTermsAcceptanceEvent event,
    Emitter<AuthState> emit,
  ) {
    if (state is CreateAccountFormState) {
      final currentState = state as CreateAccountFormState;
      emit(currentState.copyWith(isTermsAccepted: event.isAccepted));
    } else {
      emit(CreateAccountFormState(isTermsAccepted: event.isAccepted));
    }
  }

  void _onSetFormSubmitting(
    SetFormSubmittingEvent event,
    Emitter<AuthState> emit,
  ) {
    if (state is CreateAccountFormState) {
      final currentState = state as CreateAccountFormState;
      emit(currentState.copyWith(isSubmitting: event.isSubmitting));
    } else {
      emit(CreateAccountFormState(isSubmitting: event.isSubmitting));
    }
  }

  void _onSetForgotPasswordSending(
    SetForgotPasswordSendingEvent event,
    Emitter<AuthState> emit,
  ) {
    if (state is ForgotPasswordFormState) {
      final currentState = state as ForgotPasswordFormState;
      emit(currentState.copyWith(isSending: event.isSending));
    } else {
      emit(ForgotPasswordFormState(isSending: event.isSending));
    }
  }

  /// Handle forgot password OTP verification
  Future<void> _onVerifyForgotPasswordOtp(
    VerifyForgotPasswordOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      if (event.otp.length != 6) {
        emit(const AuthError(message: 'Please enter a valid 6-digit OTP'));
        return;
      }

      final response = await _authRepository.verifyForgotPasswordOtp(
        userId: event.userId,
        otp: event.otp,
        purpose: event.purpose,
      );

      if (response.success) {
        emit(
          ForgotPasswordOtpVerificationSuccess(
            userId: response.userId ?? event.userId,
            message: response.message,
          ),
        );
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      // Check if it's a bad request error (invalid OTP)
      if (e.toString().contains('Bad request') &&
          e.toString().contains('Invalid OTP')) {
        emit(
          const AuthError(message: 'Invalid OTP. Please check and try again.'),
        );
      } else {
        emit(AuthError(message: 'Failed to verify OTP. Please try again.'));
      }
    }
  }

  /// Handle resend OTP event
  Future<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final response = await _authRepository.resendOtp(
        email: event.email,
        purpose: event.purpose,
      );

      if (response.success) {
        emit(
          ResendOtpSuccess(
            message: response.message,
            email: response.email,
            expiresIn: response.expiresIn,
          ),
        );
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: 'Failed to resend OTP. Please try again.'));
    }
  }
}

/// Extension to capitalize first letter of string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
