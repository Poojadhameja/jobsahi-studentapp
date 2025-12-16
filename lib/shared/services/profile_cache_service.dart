import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to cache profile data for offline use and performance
class ProfileCacheService {
  static const String _profileDataKey = 'profile_data_cache';
  static const String _cacheTimestampKey = 'profile_cache_timestamp';
  static const String _profileImageKey = 'profile_image_cache';
  static const String _profileImageTimestampKey =
      'profile_image_cache_timestamp';

  static ProfileCacheService? _instance;
  static ProfileCacheService get instance =>
      _instance ??= ProfileCacheService._internal();
  ProfileCacheService._internal();

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) await initialize();
    return _prefs!;
  }

  /// Store complete profile data
  Future<bool> storeProfileData({
    required Map<String, dynamic> userProfile,
    required List<String> skills,
    required List<Map<String, dynamic>> education,
    required List<Map<String, dynamic>> experience,
    required Map<String, dynamic> jobPreferences,
    required List<Map<String, dynamic>> certificates,
    String? profileImagePath,
    String? profileImageName,
    String? resumeFileName,
    String? lastResumeUpdatedDate,
    int? resumeFileSize,
    String? resumeDownloadUrl,
    String? baseUrl,
  }) async {
    try {
      final prefs = await _getPrefs();
      final data = {
        'userProfile': userProfile,
        'skills': skills,
        'education': education,
        'experience': experience,
        'jobPreferences': jobPreferences,
        'certificates': certificates,
        'profileImagePath': profileImagePath,
        'profileImageName': profileImageName,
        'resumeFileName': resumeFileName,
        'lastResumeUpdatedDate': lastResumeUpdatedDate,
        'resumeFileSize': resumeFileSize,
        'resumeDownloadUrl': resumeDownloadUrl,
        'baseUrl': baseUrl,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final jsonString = jsonEncode(data);
      await prefs.setString(_profileDataKey, jsonString);
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return true;
    } catch (e) {
      debugPrint('Error storing profile cache: $e');
      return false;
    }
  }

  /// Get cached profile data
  Future<Map<String, dynamic>?> getProfileData() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_profileDataKey);
      if (jsonString == null) return null;

      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded;
    } catch (e) {
      debugPrint('Error getting profile cache: $e');
      return null;
    }
  }

  /// Get cache timestamp
  Future<int?> getCacheTimestamp() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getInt(_cacheTimestampKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if cache is valid (less than specified hours old and same baseUrl)
  Future<bool> isCacheValid({
    int maxAgeHours = 24,
    String? currentBaseUrl,
  }) async {
    try {
      final timestamp = await getCacheTimestamp();
      if (timestamp == null) return false;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);

      // Check if cache is expired
      if (difference.inHours >= maxAgeHours) {
        return false;
      }

      // Check if baseUrl matches (if provided)
      if (currentBaseUrl != null) {
        final cachedData = await getProfileData();
        final cachedBaseUrl = cachedData?['baseUrl'] as String?;
        if (cachedBaseUrl != null && cachedBaseUrl != currentBaseUrl) {
          debugPrint(
            '⚠️ [ProfileCache] BaseUrl mismatch - Cache: $cachedBaseUrl, Current: $currentBaseUrl',
          );
          return false; // Cache is invalid if baseUrl changed
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear profile cache
  Future<bool> clearCache() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_profileDataKey);
      await prefs.remove(_cacheTimestampKey);
      return true;
    } catch (e) {
      debugPrint('Error clearing profile cache: $e');
      return false;
    }
  }

  /// Store profile image path
  Future<bool> storeProfileImage(String imagePath) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_profileImageKey, imagePath);
      await prefs.setInt(
        _profileImageTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return true;
    } catch (e) {
      debugPrint('Error storing profile image: $e');
      return false;
    }
  }

  /// Get cached profile image path
  Future<String?> getProfileImage() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_profileImageKey);
    } catch (e) {
      return null;
    }
  }

  /// Clear profile image cache
  Future<bool> clearProfileImageCache() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_profileImageKey);
      await prefs.remove(_profileImageTimestampKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update specific profile field in cache
  Future<bool> updateProfileField({
    required String field,
    required dynamic value,
  }) async {
    try {
      final cachedData = await getProfileData();
      if (cachedData == null) return false;

      if (cachedData['userProfile'] != null) {
        (cachedData['userProfile'] as Map<String, dynamic>)[field] = value;
        return await storeProfileData(
          userProfile: cachedData['userProfile'],
          skills: List<String>.from(cachedData['skills'] ?? []),
          education: List<Map<String, dynamic>>.from(
            cachedData['education'] ?? [],
          ),
          experience: List<Map<String, dynamic>>.from(
            cachedData['experience'] ?? [],
          ),
          jobPreferences: Map<String, dynamic>.from(
            cachedData['jobPreferences'] ?? {},
          ),
          certificates: List<Map<String, dynamic>>.from(
            cachedData['certificates'] ?? [],
          ),
          profileImagePath: cachedData['profileImagePath'],
          profileImageName: cachedData['profileImageName'],
          resumeFileName: cachedData['resumeFileName'],
          lastResumeUpdatedDate: cachedData['lastResumeUpdatedDate'],
          resumeFileSize: cachedData['resumeFileSize'],
          resumeDownloadUrl: cachedData['resumeDownloadUrl'],
          baseUrl: cachedData['baseUrl'] as String?,
        );
      }
      return false;
    } catch (e) {
      debugPrint('Error updating profile field in cache: $e');
      return false;
    }
  }
}
