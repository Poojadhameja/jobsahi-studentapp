import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
/// Handles all authentication-related business logic
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
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
  }

  /// Handle login with OTP
  Future<void> _onLoginWithOtp(
    LoginWithOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Validate phone number
      if (event.phoneNumber.length != 10) {
        emit(
          const AuthError(
            message: 'Please enter a valid 10-digit phone number',
          ),
        );
        return;
      }

      // Simulate successful OTP sending
      emit(OtpSentState(phoneNumber: event.phoneNumber));
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

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Validate OTP (in real app, this would be server-side validation)
      if (event.otp.length != 6) {
        emit(const AuthError(message: 'Please enter a valid 6-digit OTP'));
        return;
      }

      // Simulate successful OTP verification
      emit(const OtpVerificationSuccess());

      // After successful verification, emit login success
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const AuthSuccess(message: 'Login successful'));
    } catch (e) {
      emit(AuthError(message: 'OTP verification failed: ${e.toString()}'));
    }
  }

  /// Handle login with email and password
  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Validate email format
      if (!event.email.contains('@')) {
        emit(const AuthError(message: 'Please enter a valid email address'));
        return;
      }

      // Validate password
      if (event.password.length < 6) {
        emit(
          const AuthError(message: 'Password must be at least 6 characters'),
        );
        return;
      }

      // Simulate successful login
      emit(const AuthSuccess(message: 'Login successful'));
    } catch (e) {
      emit(AuthError(message: 'Login failed: ${e.toString()}'));
    }
  }

  /// Handle social login
  Future<void> _onSocialLogin(
    SocialLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful social login
      emit(
        AuthSuccess(message: '${event.provider.capitalize()} login successful'),
      );
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

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Validate input
      if (event.name.isEmpty) {
        emit(const AuthError(message: 'Please enter your name'));
        return;
      }

      if (!event.email.contains('@')) {
        emit(const AuthError(message: 'Please enter a valid email address'));
        return;
      }

      if (event.phone.length != 10) {
        emit(
          const AuthError(
            message: 'Please enter a valid 10-digit phone number',
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

      // Simulate successful account creation
      emit(const AccountCreationSuccess());
    } catch (e) {
      emit(AuthError(message: 'Account creation failed: ${e.toString()}'));
    }
  }

  /// Handle forgot password
  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Validate email
      if (!event.email.contains('@')) {
        emit(const AuthError(message: 'Please enter a valid email address'));
        return;
      }

      // Simulate successful password reset code sending
      emit(PasswordResetCodeSentState(email: event.email));
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

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Validate inputs
      if (event.otp.length != 6) {
        emit(const AuthError(message: 'Please enter a valid 6-digit code'));
        return;
      }

      if (event.newPassword.length < 6) {
        emit(
          const AuthError(message: 'Password must be at least 6 characters'),
        );
        return;
      }

      // Simulate successful password reset
      emit(const PasswordResetSuccess());
    } catch (e) {
      emit(AuthError(message: 'Password reset failed: ${e.toString()}'));
    }
  }

  /// Handle password change
  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Validate inputs
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

      // Simulate successful password change
      emit(const PasswordChangeSuccess());
    } catch (e) {
      emit(AuthError(message: 'Password change failed: ${e.toString()}'));
    }
  }

  /// Handle logout
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate successful logout
      emit(const LogoutSuccess());
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

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // In a real app, this would check if user is logged in
      // For now, we'll assume user is not logged in initially
      emit(const AuthInitial());
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to check authentication status: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle clear error
  void _onClearAuthError(ClearAuthErrorEvent event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }

  /// Handle splash screen initialization
  Future<void> _onSplashInitialization(
    SplashInitializationEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));
    emit(const SplashReadyToNavigate());
  }

  /// Handle onboarding page change
  void _onOnboardingPageChange(
    OnboardingPageChangeEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(OnboardingState(currentPage: event.pageIndex));
  }

  /// Handle complete onboarding
  void _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(const OnboardingCompleted());
  }

  /// Handle skip onboarding
  void _onSkipOnboarding(SkipOnboardingEvent event, Emitter<AuthState> emit) {
    emit(const OnboardingSkipped());
  }

  /// Handle toggle password visibility
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

  /// Handle toggle terms acceptance
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

  /// Handle set form submitting state
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

  /// Handle set forgot password sending state
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
}

/// Extension to capitalize first letter of string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
