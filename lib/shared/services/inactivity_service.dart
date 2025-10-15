import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/constants/app_routes.dart';
import 'token_storage.dart';

/// Service to handle user inactivity and token expiry
/// Implements 30-day inactivity token expiry on the frontend
class InactivityService {
  static const String _lastActiveKey = 'last_active_timestamp';

  static InactivityService? _instance;
  static InactivityService get instance =>
      _instance ??= InactivityService._internal();
  InactivityService._internal();

  SharedPreferences? _prefs;
  TokenStorage? _tokenStorage;

  /// Initialize the inactivity service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _tokenStorage = TokenStorage.instance;
    await _tokenStorage!.initialize();
  }

  /// Update the last active timestamp to current time
  /// Call this on any user activity (app open, screen visit, interaction)
  Future<void> updateLastActive() async {
    if (_prefs == null) await initialize();
    if (_tokenStorage == null) await initialize();

    // Only update timestamp if user is logged in
    final isLoggedIn = await _tokenStorage!.isLoggedIn();
    final hasToken = await _tokenStorage!.hasToken();

    if (!isLoggedIn || !hasToken) {
      // User is not logged in, no need to track activity
      return;
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    await _prefs!.setInt(_lastActiveKey, currentTime);

    debugPrint('🟢 InactivityService: Updated last active timestamp');
  }

  /// Get the last active timestamp
  Future<int?> _getLastActiveTimestamp() async {
    if (_prefs == null) await initialize();
    return _prefs!.getInt(_lastActiveKey);
  }

  /// Check if the user has been inactive for more than 30 days
  /// Returns true if token should be expired
  Future<bool> isTokenExpired() async {
    if (_prefs == null) await initialize();
    if (_tokenStorage == null) await initialize();

    // Check if user is logged in first
    final isLoggedIn = await _tokenStorage!.isLoggedIn();
    final hasToken = await _tokenStorage!.hasToken();

    if (!isLoggedIn || !hasToken) {
      // User is not logged in, no need to check inactivity
      return false;
    }

    final lastActiveTimestamp = await _getLastActiveTimestamp();

    if (lastActiveTimestamp == null) {
      // No previous activity recorded, consider as first time login
      // Update the timestamp and don't expire
      await updateLastActive();
      return false;
    }

    final lastActiveDate = DateTime.fromMillisecondsSinceEpoch(
      lastActiveTimestamp,
    );
    final currentDate = DateTime.now();
    final timeDifference = currentDate.difference(lastActiveDate);

    debugPrint('🟡 InactivityService: Last active: $lastActiveDate');
    debugPrint('🟡 InactivityService: Current time: $currentDate');

    // Detailed time difference breakdown
    final days = timeDifference.inDays;
    final hours = timeDifference.inHours % 24;
    final minutes = timeDifference.inMinutes % 60;
    final seconds = timeDifference.inSeconds % 60;
    final months = days ~/ 30;
    final remainingDays = days % 30;

    if (months > 0) {
      debugPrint(
        '🟡 InactivityService: Time difference: $months months, $remainingDays days, $hours hours, $minutes minutes, $seconds seconds',
      );
    } else if (days > 0) {
      debugPrint(
        '🟡 InactivityService: Time difference: $days days, $hours hours, $minutes minutes, $seconds seconds',
      );
    } else if (hours > 0) {
      debugPrint(
        '🟡 InactivityService: Time difference: $hours hours, $minutes minutes, $seconds seconds',
      );
    } else if (minutes > 0) {
      debugPrint(
        '🟡 InactivityService: Time difference: $minutes minutes, $seconds seconds',
      );
    } else {
      debugPrint('🟡 InactivityService: Time difference: $seconds seconds');
    }

    return timeDifference > AppConstants.inactivityTimeout;
  }

  /// Handle token expiry by clearing user data and redirecting to login
  Future<void> handleTokenExpiry(BuildContext context) async {
    if (_tokenStorage == null) await initialize();

    debugPrint(
      '🔴 InactivityService: Token expired due to inactivity. Logging out user.',
    );

    // Clear all user data and tokens
    await _tokenStorage!.clearAll();

    // Clear the last active timestamp
    if (_prefs == null) await initialize();
    await _prefs!.remove(_lastActiveKey);

    // Directly navigate to login screen without showing dialog
    if (context.mounted) {
      AppRouter.go(AppRoutes.loginOtpEmail);
    }
  }

  /// Check and handle token expiry if needed
  /// Call this on app launch, resume, or any protected screen access
  Future<void> checkAndHandleTokenExpiry(BuildContext context) async {
    final isExpired = await isTokenExpired();

    if (isExpired) {
      await handleTokenExpiry(context);
    } else {
      // Update last active timestamp since user is active
      await updateLastActive();
    }
  }

  /// Get the remaining days until token expiry
  /// Returns null if no activity recorded or user not logged in
  Future<int?> getRemainingDaysUntilExpiry() async {
    if (_prefs == null) await initialize();
    if (_tokenStorage == null) await initialize();

    final isLoggedIn = await _tokenStorage!.isLoggedIn();
    if (!isLoggedIn) return null;

    final lastActiveTimestamp = await _getLastActiveTimestamp();
    if (lastActiveTimestamp == null) return null;

    final lastActiveDate = DateTime.fromMillisecondsSinceEpoch(
      lastActiveTimestamp,
    );
    final currentDate = DateTime.now();
    final timeDifference = currentDate.difference(lastActiveDate);
    final remainingDays =
        AppConstants.inactivityTimeout.inDays - timeDifference.inDays;

    return remainingDays > 0 ? remainingDays : 0;
  }

  /// Clear the last active timestamp (useful for logout)
  Future<void> clearLastActive() async {
    if (_prefs == null) await initialize();
    await _prefs!.remove(_lastActiveKey);
    debugPrint('🟢 InactivityService: Cleared last active timestamp');
  }

  /// Get the last active date for display purposes
  Future<DateTime?> getLastActiveDate() async {
    final timestamp = await _getLastActiveTimestamp();
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }
}
