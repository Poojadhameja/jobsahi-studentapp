import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to cache home page data (banner, tabs, filters) for offline use
class HomeCacheService {
  static const String _bannerImagesKey = 'home_banner_images';
  static const String _bannerLoadedKey = 'home_banner_loaded';
  static const String _homeDataKey = 'home_data_cache';
  static const String _cacheTimestampKey = 'home_cache_timestamp';

  static HomeCacheService? _instance;
  static HomeCacheService get instance => _instance ??= HomeCacheService._internal();
  HomeCacheService._internal();

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

  /// Store banner images list
  Future<bool> storeBannerImages(List<String> bannerImages) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = jsonEncode(bannerImages);
      await prefs.setString(_bannerImagesKey, jsonString);
      await prefs.setBool(_bannerLoadedKey, true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get cached banner images list
  Future<List<String>?> getBannerImages() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_bannerImagesKey);
      if (jsonString == null) return null;
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<String>();
    } catch (e) {
      return null;
    }
  }

  /// Check if banner is already loaded
  Future<bool> isBannerLoaded() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_bannerLoadedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Store home page data (jobs, featured jobs, etc.)
  Future<bool> storeHomeData({
    required List<Map<String, dynamic>> allJobs,
    required List<Map<String, dynamic>> featuredJobs,
    required List<String> savedJobIds,
  }) async {
    try {
      final prefs = await _getPrefs();
      final data = {
        'allJobs': allJobs,
        'featuredJobs': featuredJobs,
        'savedJobIds': savedJobIds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final jsonString = jsonEncode(data);
      await prefs.setString(_homeDataKey, jsonString);
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get cached home page data
  Future<Map<String, dynamic>?> getHomeData() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_homeDataKey);
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

  /// Store saved jobs data
  Future<bool> storeSavedJobs(List<Map<String, dynamic>> savedJobs) async {
    try {
      final prefs = await _getPrefs();
      final data = {
        'savedJobs': savedJobs,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final jsonString = jsonEncode(data);
      await prefs.setString('saved_jobs_cache', jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get cached saved jobs data
  Future<List<Map<String, dynamic>>?> getSavedJobs() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString('saved_jobs_cache');
      if (jsonString == null) return null;
      
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return List<Map<String, dynamic>>.from(decoded['savedJobs'] ?? []);
    } catch (e) {
      return null;
    }
  }

  /// Clear all cached home data
  Future<bool> clearCache() async {
    try {
      final prefs = await _getPrefs();
      await Future.wait([
        prefs.remove(_bannerImagesKey),
        prefs.remove(_bannerLoadedKey),
        prefs.remove(_homeDataKey),
        prefs.remove(_cacheTimestampKey),
        prefs.remove('saved_jobs_cache'),
      ]);
      return true;
    } catch (e) {
      return false;
    }
  }
}

