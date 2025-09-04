import 'package:equatable/equatable.dart';

/// Settings states
abstract class SettingsState extends Equatable {
  const SettingsState();
}

/// Initial settings state
class SettingsInitial extends SettingsState {
  const SettingsInitial();

  @override
  List<Object?> get props => [];
}

/// Settings loading state
class SettingsLoading extends SettingsState {
  const SettingsLoading();

  @override
  List<Object?> get props => [];
}

/// Settings loaded state
class SettingsLoaded extends SettingsState {
  final Map<String, bool> notificationPreferences;
  final String language;
  final String theme;
  final Map<String, bool> privacySettings;
  final String cacheSize;
  final String appVersion;

  const SettingsLoaded({
    required this.notificationPreferences,
    required this.language,
    required this.theme,
    required this.privacySettings,
    required this.cacheSize,
    required this.appVersion,
  });

  @override
  List<Object?> get props => [
    notificationPreferences,
    language,
    theme,
    privacySettings,
    cacheSize,
    appVersion,
  ];

  /// Copy with method for immutable state updates
  SettingsLoaded copyWith({
    Map<String, bool>? notificationPreferences,
    String? language,
    String? theme,
    Map<String, bool>? privacySettings,
    String? cacheSize,
    String? appVersion,
  }) {
    return SettingsLoaded(
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      privacySettings: privacySettings ?? this.privacySettings,
      cacheSize: cacheSize ?? this.cacheSize,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

/// Settings error state
class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Notification preferences updated state
class NotificationPreferencesUpdatedState extends SettingsState {
  final Map<String, bool> preferences;

  const NotificationPreferencesUpdatedState({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

/// Language updated state
class LanguageUpdatedState extends SettingsState {
  final String language;

  const LanguageUpdatedState({required this.language});

  @override
  List<Object?> get props => [language];
}

/// Theme updated state
class ThemeUpdatedState extends SettingsState {
  final String theme;

  const ThemeUpdatedState({required this.theme});

  @override
  List<Object?> get props => [theme];
}

/// Privacy settings updated state
class PrivacySettingsUpdatedState extends SettingsState {
  final Map<String, bool> privacySettings;

  const PrivacySettingsUpdatedState({required this.privacySettings});

  @override
  List<Object?> get props => [privacySettings];
}

/// Cache cleared state
class CacheClearedState extends SettingsState {
  final String message;

  const CacheClearedState({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Data exported state
class DataExportedState extends SettingsState {
  final String filePath;

  const DataExportedState({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// Account deleted state
class AccountDeletedState extends SettingsState {
  const AccountDeletedState();

  @override
  List<Object?> get props => [];
}

/// Logout success state
class LogoutSuccessState extends SettingsState {
  const LogoutSuccessState();

  @override
  List<Object?> get props => [];
}

/// Change password form loaded state
class ChangePasswordFormLoaded extends SettingsState {
  final bool isOldPasswordVisible;
  final bool isNewPasswordVisible;
  final bool isConfirmPasswordVisible;

  const ChangePasswordFormLoaded({
    required this.isOldPasswordVisible,
    required this.isNewPasswordVisible,
    required this.isConfirmPasswordVisible,
  });

  @override
  List<Object?> get props => [
    isOldPasswordVisible,
    isNewPasswordVisible,
    isConfirmPasswordVisible,
  ];

  ChangePasswordFormLoaded copyWith({
    bool? isOldPasswordVisible,
    bool? isNewPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return ChangePasswordFormLoaded(
      isOldPasswordVisible: isOldPasswordVisible ?? this.isOldPasswordVisible,
      isNewPasswordVisible: isNewPasswordVisible ?? this.isNewPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }
}

/// Password changing state
class PasswordChanging extends SettingsState {
  const PasswordChanging();

  @override
  List<Object?> get props => [];
}

/// Password changed successfully state
class PasswordChangedSuccess extends SettingsState {
  const PasswordChangedSuccess();

  @override
  List<Object?> get props => [];
}

/// Terms & conditions loaded state
class TermsConditionsLoaded extends SettingsState {
  final bool isAgreed;

  const TermsConditionsLoaded({required this.isAgreed});

  @override
  List<Object?> get props => [isAgreed];

  TermsConditionsLoaded copyWith({bool? isAgreed}) {
    return TermsConditionsLoaded(isAgreed: isAgreed ?? this.isAgreed);
  }
}
