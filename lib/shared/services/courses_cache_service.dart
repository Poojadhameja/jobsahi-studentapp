import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to cache courses data for offline use
class CoursesCacheService {
  static const String _coursesDataKey = 'courses_data_cache';
  static const String _cacheTimestampKey = 'courses_cache_timestamp';

  static CoursesCacheService? _instance;
  static CoursesCacheService get instance =>
      _instance ??= CoursesCacheService._internal();
  CoursesCacheService._internal();

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

  /// Store courses data
  Future<bool> storeCoursesData({
    required List<Map<String, dynamic>> allCourses,
    required List<Map<String, dynamic>> savedCourses,
    required Set<String> savedCourseIds,
  }) async {
    try {
      final prefs = await _getPrefs();
      final data = {
        'allCourses': allCourses,
        'savedCourses': savedCourses,
        'savedCourseIds': savedCourseIds.toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final jsonString = jsonEncode(data);
      await prefs.setString(_coursesDataKey, jsonString);
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get cached courses data
  Future<Map<String, dynamic>?> getCoursesData() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_coursesDataKey);
      if (jsonString == null) return null;

      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded;
    } catch (e) {
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

  /// Check if cache is valid (less than 24 hours old)
  Future<bool> isCacheValid() async {
    try {
      final timestamp = await getCacheTimestamp();
      if (timestamp == null) return false;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);

      // Cache is valid for 24 hours
      return difference.inHours < 24;
    } catch (e) {
      return false;
    }
  }

  /// Clear cache
  Future<bool> clearCache() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_coursesDataKey);
      await prefs.remove(_cacheTimestampKey);
      return true;
    } catch (e) {
      return false;
    }
  }
}














