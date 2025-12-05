import 'package:shared_preferences/shared_preferences.dart';

/// Optimized service to manage onboarding state
/// Uses in-memory caching and SharedPreferences caching for best performance
class OnboardingService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  // Singleton instance
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  static OnboardingService get instance => _instance;

  // Cached SharedPreferences instance
  SharedPreferences? _prefs;

  // In-memory cache for faster subsequent reads
  bool? _cachedValue;

  /// Initialize SharedPreferences (call once at app startup)
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Always read from storage on app startup to ensure sync
      final storedValue = _prefs!.getBool(_hasSeenOnboardingKey);
      _cachedValue = storedValue;
    } catch (e) {
      _cachedValue = null;
    }
  }

  /// Get SharedPreferences instance (with caching)
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Check if user has seen onboarding (optimized with cache)
  Future<bool> hasSeenOnboarding() async {
    try {
      // Return cached value if available
      if (_cachedValue != null) {
        return _cachedValue!;
      }

      // Otherwise fetch from storage
      final prefs = await _getPrefs();
      _cachedValue = prefs.getBool(_hasSeenOnboardingKey) ?? false;
      return _cachedValue!;
    } catch (e) {
      return false;
    }
  }

  /// Check synchronously if already cached (ultra-fast)
  bool hasSeenOnboardingSync() {
    return _cachedValue ?? false;
  }

  /// Mark onboarding as completed (updates both cache and storage)
  Future<bool> setOnboardingComplete() async {
    try {
      final prefs = await _getPrefs();
      final success = await prefs.setBool(_hasSeenOnboardingKey, true);

      if (success) {
        _cachedValue = true; // Update cache
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Reset onboarding status (for testing purposes)
  Future<bool> resetOnboarding() async {
    try {
      final prefs = await _getPrefs();
      final success = await prefs.remove(_hasSeenOnboardingKey);

      if (success) {
        _cachedValue = null; // Clear cache
      }

      return success;
    } catch (e) {
      return false;
    }
  }
}
