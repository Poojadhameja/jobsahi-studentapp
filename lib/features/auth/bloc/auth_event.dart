import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

/// Login with OTP event
class LoginWithOtpEvent extends AuthEvent {
  final String phoneNumber;

  const LoginWithOtpEvent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

/// Verify OTP event
class VerifyOtpEvent extends AuthEvent {
  final String otp;
  final String?
  phoneNumber; // Optional: pass phone number if state doesn't have it
  final int? userId; // Optional: pass user ID if state doesn't have it

  const VerifyOtpEvent({required this.otp, this.phoneNumber, this.userId});

  @override
  List<Object?> get props => [otp, phoneNumber, userId];
}

/// Login with email and password event
class LoginWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Social login event
class SocialLoginEvent extends AuthEvent {
  final String provider; // 'google' or 'linkedin'
  final BuildContext? context; // Required for LinkedIn WebView

  const SocialLoginEvent({required this.provider, this.context});

  @override
  List<Object?> get props => [provider, context];
}

/// Create account event
class CreateAccountEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;

  const CreateAccountEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, phone, password];
}

/// Forgot password event
class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Reset password event
class ResetPasswordEvent extends AuthEvent {
  final int userId;
  final String newPassword;

  const ResetPasswordEvent({required this.userId, required this.newPassword});

  @override
  List<Object?> get props => [userId, newPassword];
}

/// Change password event
class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Logout event
class LogoutEvent extends AuthEvent {
  const LogoutEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status event
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();

  @override
  List<Object?> get props => [];
}

/// Clear error event
class ClearAuthErrorEvent extends AuthEvent {
  const ClearAuthErrorEvent();

  @override
  List<Object?> get props => [];
}

/// Splash screen initialization event
class SplashInitializationEvent extends AuthEvent {
  const SplashInitializationEvent();

  @override
  List<Object?> get props => [];
}

/// Onboarding page change event
class OnboardingPageChangeEvent extends AuthEvent {
  final int pageIndex;

  const OnboardingPageChangeEvent({required this.pageIndex});

  @override
  List<Object?> get props => [pageIndex];
}

/// Complete onboarding event
class CompleteOnboardingEvent extends AuthEvent {
  const CompleteOnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Skip onboarding event
class SkipOnboardingEvent extends AuthEvent {
  const SkipOnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Toggle password visibility event
class TogglePasswordVisibilityEvent extends AuthEvent {
  final bool isPassword;
  final bool isVisible;

  const TogglePasswordVisibilityEvent({
    required this.isPassword,
    required this.isVisible,
  });

  @override
  List<Object?> get props => [isPassword, isVisible];
}

/// Toggle terms acceptance event
class ToggleTermsAcceptanceEvent extends AuthEvent {
  final bool isAccepted;

  const ToggleTermsAcceptanceEvent({required this.isAccepted});

  @override
  List<Object?> get props => [isAccepted];
}

/// Set form submitting state event
class SetFormSubmittingEvent extends AuthEvent {
  final bool isSubmitting;

  const SetFormSubmittingEvent({required this.isSubmitting});

  @override
  List<Object?> get props => [isSubmitting];
}

/// Set forgot password sending state event
class SetForgotPasswordSendingEvent extends AuthEvent {
  final bool isSending;

  const SetForgotPasswordSendingEvent({required this.isSending});

  @override
  List<Object?> get props => [isSending];
}

/// Verify forgot password OTP event
class VerifyForgotPasswordOtpEvent extends AuthEvent {
  final int userId;
  final String otp;
  final String purpose;

  const VerifyForgotPasswordOtpEvent({
    required this.userId,
    required this.otp,
    required this.purpose,
  });

  @override
  List<Object?> get props => [userId, otp, purpose];
}

class ResendOtpEvent extends AuthEvent {
  final String email;
  final String purpose;

  const ResendOtpEvent({required this.email, required this.purpose});

  @override
  List<Object?> get props => [email, purpose];
}
