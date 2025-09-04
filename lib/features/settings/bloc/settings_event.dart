import 'package:equatable/equatable.dart';

/// Settings events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
}

/// Load settings event
class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Update notification preferences event
class UpdateNotificationPreferencesEvent extends SettingsEvent {
  final Map<String, bool> preferences;

  const UpdateNotificationPreferencesEvent({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

/// Update language event
class UpdateLanguageEvent extends SettingsEvent {
  final String language;

  const UpdateLanguageEvent({required this.language});

  @override
  List<Object?> get props => [language];
}

/// Update theme event
class UpdateThemeEvent extends SettingsEvent {
  final String theme; // 'light', 'dark', 'system'

  const UpdateThemeEvent({required this.theme});

  @override
  List<Object?> get props => [theme];
}

/// Update privacy settings event
class UpdatePrivacySettingsEvent extends SettingsEvent {
  final Map<String, bool> privacySettings;

  const UpdatePrivacySettingsEvent({required this.privacySettings});

  @override
  List<Object?> get props => [privacySettings];
}

/// Clear cache event
class ClearCacheEvent extends SettingsEvent {
  const ClearCacheEvent();

  @override
  List<Object?> get props => [];
}

/// Export data event
class ExportDataEvent extends SettingsEvent {
  const ExportDataEvent();

  @override
  List<Object?> get props => [];
}

/// Delete account event
class DeleteAccountEvent extends SettingsEvent {
  final String password;

  const DeleteAccountEvent({required this.password});

  @override
  List<Object?> get props => [password];
}

/// Logout event
class LogoutEvent extends SettingsEvent {
  const LogoutEvent();

  @override
  List<Object?> get props => [];
}

/// Refresh settings event
class RefreshSettingsEvent extends SettingsEvent {
  const RefreshSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load change password form event
class LoadChangePasswordFormEvent extends SettingsEvent {
  const LoadChangePasswordFormEvent();

  @override
  List<Object?> get props => [];
}

/// Update password visibility event
class UpdatePasswordVisibilityEvent extends SettingsEvent {
  final String field; // 'old', 'new', 'confirm'
  final bool isVisible;

  const UpdatePasswordVisibilityEvent({
    required this.field,
    required this.isVisible,
  });

  @override
  List<Object?> get props => [field, isVisible];
}

/// Change password event
class ChangePasswordEvent extends SettingsEvent {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword, confirmPassword];
}

/// Load terms & conditions screen state
class LoadTermsConditionsEvent extends SettingsEvent {
  const LoadTermsConditionsEvent();

  @override
  List<Object?> get props => [];
}

/// Toggle terms agreement checkbox
class ToggleTermsAgreementEvent extends SettingsEvent {
  final bool isAgreed;

  const ToggleTermsAgreementEvent({required this.isAgreed});

  @override
  List<Object?> get props => [isAgreed];
}

/// Accept terms action
class AcceptTermsEvent extends SettingsEvent {
  const AcceptTermsEvent();

  @override
  List<Object?> get props => [];
}
