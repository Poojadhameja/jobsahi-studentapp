import 'package:bloc/bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../../../shared/data/user_data.dart';

/// Settings BLoC
/// Handles all settings-related business logic
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsInitial()) {
    // Register event handlers
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateNotificationPreferencesEvent>(_onUpdateNotificationPreferences);
    on<UpdateLanguageEvent>(_onUpdateLanguage);
    on<UpdateThemeEvent>(_onUpdateTheme);
    on<UpdatePrivacySettingsEvent>(_onUpdatePrivacySettings);
    on<ClearCacheEvent>(_onClearCache);
    on<ExportDataEvent>(_onExportData);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<LogoutEvent>(_onLogout);
    on<RefreshSettingsEvent>(_onRefreshSettings);
    on<LoadChangePasswordFormEvent>(_onLoadChangePasswordForm);
    on<UpdatePasswordVisibilityEvent>(_onUpdatePasswordVisibility);
    on<ChangePasswordEvent>(_onChangePassword);
    on<LoadTermsConditionsEvent>(_onLoadTermsConditions);
    on<ToggleTermsAgreementEvent>(_onToggleTermsAgreement);
    on<AcceptTermsEvent>(_onAcceptTerms);
  }

  /// Handle load settings
  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Load settings from mock data
      final notificationPreferences = UserData.notificationPreferences;
      final language = 'English'; // Default language
      final theme = 'system'; // Default theme
      final privacySettings = {
        'profileVisibility': true,
        'showOnlineStatus': true,
        'allowMessages': true,
        'showLastSeen': false,
      };
      final cacheSize = '25.6 MB'; // Mock cache size
      final appVersion = '1.0.0'; // Mock app version

      emit(
        SettingsLoaded(
          notificationPreferences: notificationPreferences,
          language: language,
          theme: theme,
          privacySettings: privacySettings,
          cacheSize: cacheSize,
          appVersion: appVersion,
        ),
      );
    } catch (e) {
      emit(SettingsError(message: 'Failed to load settings: ${e.toString()}'));
    }
  }

  /// Handle update notification preferences
  Future<void> _onUpdateNotificationPreferences(
    UpdateNotificationPreferencesEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Update notification preferences
      // In a real app, this would be saved to server/local storage
      // UserData.notificationPreferences = event.preferences; // This is const

      emit(NotificationPreferencesUpdatedState(preferences: event.preferences));
    } catch (e) {
      emit(
        SettingsError(
          message: 'Failed to update notification preferences: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle update language
  Future<void> _onUpdateLanguage(
    UpdateLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Update language
      // In a real app, this would be saved to local storage

      emit(LanguageUpdatedState(language: event.language));
    } catch (e) {
      emit(
        SettingsError(message: 'Failed to update language: ${e.toString()}'),
      );
    }
  }

  /// Handle update theme
  Future<void> _onUpdateTheme(
    UpdateThemeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Update theme
      // In a real app, this would be saved to local storage

      emit(ThemeUpdatedState(theme: event.theme));
    } catch (e) {
      emit(SettingsError(message: 'Failed to update theme: ${e.toString()}'));
    }
  }

  /// Handle update privacy settings
  Future<void> _onUpdatePrivacySettings(
    UpdatePrivacySettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Update privacy settings
      // In a real app, this would be saved to server

      emit(PrivacySettingsUpdatedState(privacySettings: event.privacySettings));
    } catch (e) {
      emit(
        SettingsError(
          message: 'Failed to update privacy settings: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle clear cache
  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Clear cache
      // In a real app, this would clear app cache

      emit(const CacheClearedState(message: 'Cache cleared successfully'));
    } catch (e) {
      emit(SettingsError(message: 'Failed to clear cache: ${e.toString()}'));
    }
  }

  /// Handle export data
  Future<void> _onExportData(
    ExportDataEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 3));

      // Export data
      // In a real app, this would export user data to a file
      final filePath = '/storage/emulated/0/Download/jobsahi_data_export.json';

      emit(DataExportedState(filePath: filePath));
    } catch (e) {
      emit(SettingsError(message: 'Failed to export data: ${e.toString()}'));
    }
  }

  /// Handle delete account
  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Validate password (in real app, this would be server-side validation)
      if (event.password.isEmpty) {
        emit(const SettingsError(message: 'Password is required'));
        return;
      }

      // Delete account
      // In a real app, this would delete the account from server

      emit(const AccountDeletedState());
    } catch (e) {
      emit(SettingsError(message: 'Failed to delete account: ${e.toString()}'));
    }
  }

  /// Handle logout
  Future<void> _onLogout(LogoutEvent event, Emitter<SettingsState> emit) async {
    try {
      emit(const SettingsLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Logout
      // In a real app, this would clear user session and tokens

      emit(const LogoutSuccessState());
    } catch (e) {
      emit(SettingsError(message: 'Failed to logout: ${e.toString()}'));
    }
  }

  /// Handle refresh settings
  Future<void> _onRefreshSettings(
    RefreshSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    // Reload settings
    add(const LoadSettingsEvent());
  }

  /// Handle load change password form
  void _onLoadChangePasswordForm(
    LoadChangePasswordFormEvent event,
    Emitter<SettingsState> emit,
  ) {
    try {
      emit(
        const ChangePasswordFormLoaded(
          isOldPasswordVisible: false,
          isNewPasswordVisible: false,
          isConfirmPasswordVisible: false,
        ),
      );
    } catch (e) {
      emit(
        SettingsError(
          message: 'Failed to load change password form: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle update password visibility
  void _onUpdatePasswordVisibility(
    UpdatePasswordVisibilityEvent event,
    Emitter<SettingsState> emit,
  ) {
    try {
      if (state is ChangePasswordFormLoaded) {
        final currentState = state as ChangePasswordFormLoaded;

        switch (event.field) {
          case 'old':
            emit(currentState.copyWith(isOldPasswordVisible: event.isVisible));
            break;
          case 'new':
            emit(currentState.copyWith(isNewPasswordVisible: event.isVisible));
            break;
          case 'confirm':
            emit(
              currentState.copyWith(isConfirmPasswordVisible: event.isVisible),
            );
            break;
        }
      }
    } catch (e) {
      emit(
        SettingsError(
          message: 'Failed to update password visibility: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle change password
  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const PasswordChanging());

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Validate passwords
      if (event.newPassword != event.confirmPassword) {
        emit(const SettingsError(message: 'New passwords do not match'));
        return;
      }

      if (event.newPassword.length < 6) {
        emit(
          const SettingsError(
            message: 'New password must be at least 6 characters',
          ),
        );
        return;
      }

      // Simulate successful password change
      emit(const PasswordChangedSuccess());
    } catch (e) {
      emit(
        SettingsError(message: 'Failed to change password: ${e.toString()}'),
      );
    }
  }

  /// Handle load terms & conditions
  void _onLoadTermsConditions(
    LoadTermsConditionsEvent event,
    Emitter<SettingsState> emit,
  ) {
    emit(const TermsConditionsLoaded(isAgreed: false));
  }

  /// Handle toggle terms agreement
  void _onToggleTermsAgreement(
    ToggleTermsAgreementEvent event,
    Emitter<SettingsState> emit,
  ) {
    if (state is TermsConditionsLoaded) {
      final current = state as TermsConditionsLoaded;
      emit(current.copyWith(isAgreed: event.isAgreed));
    } else {
      emit(TermsConditionsLoaded(isAgreed: event.isAgreed));
    }
  }

  /// Handle accept terms
  void _onAcceptTerms(AcceptTermsEvent event, Emitter<SettingsState> emit) {
    // In real app, persist acceptance; here we keep current state
  }
}
