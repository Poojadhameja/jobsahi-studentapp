import 'package:equatable/equatable.dart';

/// Authentication states
abstract class AuthState extends Equatable {
  const AuthState();
}

/// Initial authentication state
class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

/// Authentication loading state
class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

/// Authentication success state
class AuthSuccess extends AuthState {
  final String message;
  final bool isLoggedIn;
  final Map<String, dynamic>? user; // ✅ dynamic user data

  const AuthSuccess({required this.message, this.isLoggedIn = true, this.user});

  @override
  List<Object?> get props => [message, isLoggedIn, user];
}

/// Authentication error state
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// OTP sent state
class OtpSentState extends AuthState {
  final String phoneNumber;

  const OtpSentState({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

/// OTP verification loading state
class OtpVerificationLoading extends AuthState {
  const OtpVerificationLoading();

  @override
  List<Object?> get props => [];
}

/// OTP verification success state
class OtpVerificationSuccess extends AuthState {
  const OtpVerificationSuccess();

  @override
  List<Object?> get props => [];
}

/// Password reset code sent state
class PasswordResetCodeSentState extends AuthState {
  final String email;
  final int? userId;

  const PasswordResetCodeSentState({required this.email, this.userId});

  @override
  List<Object?> get props => [email, userId];
}

/// Password reset success state
class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();

  @override
  List<Object?> get props => [];
}

/// Password change success state
class PasswordChangeSuccess extends AuthState {
  const PasswordChangeSuccess();

  @override
  List<Object?> get props => [];
}

/// Account creation success state
class AccountCreationSuccess extends AuthState {
  final String message;

  const AccountCreationSuccess({this.message = 'Account created successfully'});

  @override
  List<Object?> get props => [message];
}

/// Logout success state
class LogoutSuccess extends AuthState {
  const LogoutSuccess();

  @override
  List<Object?> get props => [];
}

/// Splash screen ready to navigate state
class SplashReadyToNavigate extends AuthState {
  const SplashReadyToNavigate();

  @override
  List<Object?> get props => [];
}

/// Onboarding state with current page
class OnboardingState extends AuthState {
  final int currentPage;

  const OnboardingState({required this.currentPage});

  @override
  List<Object?> get props => [currentPage];
}

/// Onboarding completed state
class OnboardingCompleted extends AuthState {
  const OnboardingCompleted();

  @override
  List<Object?> get props => [];
}

/// Onboarding skipped state
class OnboardingSkipped extends AuthState {
  const OnboardingSkipped();

  @override
  List<Object?> get props => [];
}

/// Create account form state
class CreateAccountFormState extends AuthState {
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isTermsAccepted;
  final bool isSubmitting;

  const CreateAccountFormState({
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isTermsAccepted = false,
    this.isSubmitting = false,
  });

  @override
  List<Object?> get props => [
    isPasswordVisible,
    isConfirmPasswordVisible,
    isTermsAccepted,
    isSubmitting,
  ];

  CreateAccountFormState copyWith({
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isTermsAccepted,
    bool? isSubmitting,
  }) {
    return CreateAccountFormState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isTermsAccepted: isTermsAccepted ?? this.isTermsAccepted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Forgot password form state
class ForgotPasswordFormState extends AuthState {
  final bool isSending;

  const ForgotPasswordFormState({this.isSending = false});

  @override
  List<Object?> get props => [isSending];

  ForgotPasswordFormState copyWith({bool? isSending}) {
    return ForgotPasswordFormState(isSending: isSending ?? this.isSending);
  }
}

/// Email already exists error state
class EmailAlreadyExistsError extends AuthState {
  final String message;

  const EmailAlreadyExistsError({this.message = 'Email already exists'});

  @override
  List<Object?> get props => [message];
}

/// Phone number already exists error state
class PhoneAlreadyExistsError extends AuthState {
  final String message;

  const PhoneAlreadyExistsError({this.message = 'Phone number already exists'});

  @override
  List<Object?> get props => [message];
}

/// Forgot password OTP verification success state
class ForgotPasswordOtpVerificationSuccess extends AuthState {
  final int userId;
  final String message;

  const ForgotPasswordOtpVerificationSuccess({
    required this.userId,
    required this.message,
  });

  @override
  List<Object?> get props => [userId, message];
}

class ResendOtpSuccess extends AuthState {
  final String message;
  final String? email;
  final String? expiresIn;

  const ResendOtpSuccess({required this.message, this.email, this.expiresIn});

  @override
  List<Object?> get props => [message, email, expiresIn];
}
