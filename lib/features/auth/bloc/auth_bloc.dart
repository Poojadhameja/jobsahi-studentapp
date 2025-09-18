import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../repository/auth_repository.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/token_storage.dart';

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
        emit(const OtpVerificationSuccess());
        await Future.delayed(const Duration(milliseconds: 500));
        emit(AuthSuccess(message: response.message));
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: 'OTP verification failed: ${e.toString()}'));
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
        emit(AuthSuccess(message: response.message));
      } else {
        emit(AuthError(message: response.message));
      }
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

      await Future.delayed(const Duration(seconds: 2));

      emit(
        AuthSuccess(
          message: '${event.provider.capitalize()} login successful',
          user: {}, // social login के बाद भी user खाली Map रख दो
        ),
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

      final response = await _authRepository.createAccount(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
      );

      if (response.success) {
        emit(AccountCreationSuccess(message: response.message));
      } else {
        emit(AuthError(message: response.message));
      }
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
      await Future.delayed(const Duration(seconds: 1));

      if (!event.email.contains('@')) {
        emit(const AuthError(message: 'Please enter a valid email address'));
        return;
      }

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
      await Future.delayed(const Duration(seconds: 1));

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

      final isLoggedIn = await _authRepository.isLoggedIn();

      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        emit(
          AuthSuccess(
            message: user != null ? 'Welcome back,!' : 'Welcome back!',
          ),
        );
      } else {
        emit(const AuthInitial());
      }
    } catch (e) {
      emit(
        AuthError(
          message: 'Failed to check authentication status: ${e.toString()}',
        ),
      );
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
}

/// Extension to capitalize first letter of string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
