import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../../core/utils/app_constants.dart';
import '../widgets/location_permission_dialog.dart';
import 'api_service.dart';
import 'token_storage.dart';

/// Location data model
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, address: $address)';
  }
}

/// Location service for handling location permissions, fetching, and API integration
class LocationService {
  static LocationService? _instance;
  static LocationService get instance =>
      _instance ??= LocationService._internal();
  LocationService._internal();

  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage.instance;
  SharedPreferences? _prefs;

  // Keys for local storage
  static const String _locationDataKey = 'user_location_data';
  static const String _locationPermissionKey = 'location_permission_granted';
  static const String _locationPermissionAskedKey = 'location_permission_asked';

  /// Initialize the location service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('🔵 LocationService initialized');
  }

  /// Check if location permission has been asked before
  Future<bool> hasAskedForLocationPermission() async {
    if (_prefs == null) await initialize();
    return _prefs!.getBool(_locationPermissionAskedKey) ?? false;
  }

  /// Mark that location permission has been asked
  Future<void> markLocationPermissionAsked() async {
    if (_prefs == null) await initialize();
    await _prefs!.setBool(_locationPermissionAskedKey, true);
  }

  /// Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    final permission = await Permission.location.status;
    return permission == PermissionStatus.granted;
  }

  /// Check if location service is enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('🔴 Error checking location service: $e');
      return false;
    }
  }

  /// Request location permission with proper dialog
  Future<bool> requestLocationPermission({BuildContext? context}) async {
    try {
      debugPrint('🔵 Requesting location permission...');

      // Check current permission status first
      final currentPermission = await Permission.location.status;

      if (currentPermission == PermissionStatus.granted) {
        debugPrint('✅ Location permission already granted');
        // Mark that we've asked for permission
        await markLocationPermissionAsked();
        return true;
      }

      // Check if we've already asked for permission recently
      final hasAsked = await hasAskedForLocationPermission();
      if (hasAsked && currentPermission == PermissionStatus.denied) {
        debugPrint(
          '❌ User has already been asked for permission and denied it',
        );

        // Show popup dialog to guide user to settings
        if (context != null) {
          final openSettings =
              await LocationPermissionDeniedDialog.showLocationPermissionDeniedDialog(
                context,
              );
          if (openSettings) {
            await openLocationSettings();
          }
        }
        return false;
      }

      // Show simple permission dialog if context is provided
      bool userWantsPermission = true;
      if (context != null) {
        userWantsPermission =
            await LocationPermissionDialog.showLocationPermissionDialog(
              context,
            );
        if (!userWantsPermission) {
          debugPrint('❌ User declined location permission dialog');
          await markLocationPermissionAsked();
          return false;
        }
      }

      // Handle permanently denied permission
      if (currentPermission == PermissionStatus.permanentlyDenied) {
        if (context != null) {
          final openSettings =
              await LocationPermissionDeniedDialog.showLocationPermissionDeniedDialog(
                context,
              );
          if (openSettings) {
            await openLocationSettings();
          }
        }
        debugPrint('❌ Location permission permanently denied');
        // Mark that we've asked for permission
        await markLocationPermissionAsked();
        return false;
      }

      // Request permission
      final permission = await Permission.location.request();

      final isGranted = permission == PermissionStatus.granted;

      if (isGranted) {
        // Store permission status locally
        if (_prefs == null) await initialize();
        await _prefs!.setBool(_locationPermissionKey, true);
        debugPrint('✅ Location permission granted');
      } else {
        debugPrint('❌ Location permission denied: $permission');

        // Show popup dialog for permission denied
        if (context != null) {
          final openSettings =
              await LocationPermissionDeniedDialog.showLocationPermissionDeniedDialog(
                context,
              );
          if (openSettings) {
            await openLocationSettings();
          }
        }
      }

      // Mark that we've asked for permission regardless of result
      await markLocationPermissionAsked();

      return isGranted;
    } catch (e) {
      debugPrint('🔴 Error requesting location permission: $e');
      // Mark that we've asked for permission even on error
      await markLocationPermissionAsked();
      return false;
    }
  }

  /// Reverse geocoding - convert coordinates to address
  Future<String?> _reverseGeocode(double latitude, double longitude) async {
    try {
      debugPrint('🔵 Reverse geocoding: $latitude, $longitude');

      // Using OpenStreetMap Nominatim API (free)
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&addressdetails=1';

      final response = await http
          .get(Uri.parse(url), headers: {'User-Agent': 'JobsahiApp/1.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['display_name'] as String?;

        if (address != null) {
          // Simplify the address
          final parts = address.split(', ');
          if (parts.length >= 3) {
            // Take city, state, country
            return '${parts[0]}, ${parts[1]}, ${parts[2]}';
          }
          return address;
        }
      }

      debugPrint('⚠️ Reverse geocoding failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('🔴 Reverse geocoding error: $e');
      return null;
    }
  }

  /// Get current location with GPS enable dialog
  Future<LocationData?> getCurrentLocation({BuildContext? context}) async {
    try {
      debugPrint('🔵 Getting current location...');

      // GPS check will be handled by system when we try to get location

      // Check if permission is granted
      final permissionGranted = await isLocationPermissionGranted();
      if (!permissionGranted) {
        debugPrint('❌ Location permission not granted');
        return null;
      }

      // Try to get current position - this will automatically trigger system dialogs
      // if GPS is disabled or location accuracy needs to be enabled
      Position? position;

      try {
        // Try with medium accuracy first (faster than high)
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        );
      } catch (e) {
        debugPrint('⚠️ Medium accuracy failed, trying low accuracy: $e');

        try {
          // Fallback to low accuracy (fastest)
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 3),
          );
        } catch (e2) {
          debugPrint('⚠️ Low accuracy failed, trying lowest accuracy: $e2');

          try {
            // Final fallback to lowest accuracy (very fast)
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.lowest,
              timeLimit: const Duration(seconds: 2),
            );
          } catch (e3) {
            debugPrint('❌ All location attempts failed: $e3');
            // If user cancelled system dialog, throw a specific error
            if (e3.toString().contains('cancelled') ||
                e3.toString().contains('denied') ||
                e3.toString().contains('permission')) {
              throw Exception('Location cancelled by user');
            }
            rethrow;
          }
        }
      }

      // For testing purposes, return a mock location if in simulator/emulator
      if (kDebugMode) {
        debugPrint('🔧 Debug mode: Using mock location for testing');
        final mockLocationData = LocationData(
          latitude: 28.6139, // Delhi coordinates
          longitude: 77.2090,
          timestamp: DateTime.now(),
        );
        debugPrint('✅ Mock location: ${mockLocationData.toString()}');
        return mockLocationData;
      }

      // Position should be available at this point

      // Get address using reverse geocoding
      final address = await _reverseGeocode(
        position.latitude,
        position.longitude,
      );

      final locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        timestamp: DateTime.now(),
      );

      debugPrint('✅ Current location: ${locationData.toString()}');
      return locationData;
    } catch (e) {
      debugPrint('🔴 Error getting current location: $e');
      return null;
    }
  }

  /// Save location data locally
  Future<void> saveLocationLocally(LocationData locationData) async {
    try {
      if (_prefs == null) await initialize();

      final locationJson = jsonEncode(locationData.toJson());
      await _prefs!.setString(_locationDataKey, locationJson);

      debugPrint('✅ Location saved locally: ${locationData.toString()}');
    } catch (e) {
      debugPrint('🔴 Error saving location locally: $e');
    }
  }

  /// Get saved location data from local storage
  Future<LocationData?> getSavedLocation() async {
    try {
      if (_prefs == null) await initialize();

      final locationJson = _prefs!.getString(_locationDataKey);
      if (locationJson != null) {
        final locationMap = jsonDecode(locationJson);
        final locationData = LocationData.fromJson(locationMap);

        // If saved location doesn't have address, try to get it
        if (locationData.address == null) {
          debugPrint('🔵 Getting address for existing saved location...');
          final address = await _reverseGeocode(
            locationData.latitude,
            locationData.longitude,
          );
          if (address != null) {
            // Update and save with address
            final updatedLocationData = LocationData(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
              address: address,
              timestamp: locationData.timestamp,
            );
            await saveLocationLocally(updatedLocationData);
            debugPrint('✅ Updated saved location with address: $address');
            return updatedLocationData;
          }
        }

        debugPrint('✅ Retrieved saved location: ${locationData.toString()}');
        return locationData;
      }

      return null;
    } catch (e) {
      debugPrint('🔴 Error getting saved location: $e');
      return null;
    }
  }

  /// Update location on server
  Future<bool> updateLocationOnServer(LocationData locationData) async {
    try {
      debugPrint('🔵 Updating location on server...');
      debugPrint(
        '🔵 Location data: lat=${locationData.latitude}, lng=${locationData.longitude}',
      );

      final token = await _tokenStorage.getToken();
      if (token == null) {
        debugPrint('❌ No authentication token found');
        return false;
      }

      debugPrint('🔵 Token found: ${token.substring(0, 20)}...');

      // Decode token to get user_id
      final tokenData = _decodeJwtToken(token);
      final userId = tokenData?['user_id'];

      if (userId == null) {
        debugPrint('❌ No user_id found in token');
        debugPrint('🔵 Token data: $tokenData');
        debugPrint('🔵 Available keys: ${tokenData?.keys}');
        return false;
      }

      debugPrint('🔵 User ID type: ${userId.runtimeType}');
      debugPrint('🔵 User ID value: $userId');
      debugPrint('🔵 API Endpoint: ${AppConstants.updateLocationEndpoint}');
      debugPrint(
        '🔵 Full URL: ${AppConstants.baseUrl}${AppConstants.updateLocationEndpoint}',
      );

      // Validate location data before sending
      if (locationData.latitude < -90 || locationData.latitude > 90) {
        debugPrint('❌ Invalid latitude: ${locationData.latitude}');
        return false;
      }
      if (locationData.longitude < -180 || locationData.longitude > 180) {
        debugPrint('❌ Invalid longitude: ${locationData.longitude}');
        return false;
      }

      // Use the exact format that backend expects
      final requestData = {
        'user_id': userId,
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
      };

      debugPrint('🔵 Request data: $requestData');

      // Use the standard JSON POST method as backend expects
      debugPrint('🔵 Sending location update to backend...');
      final response = await _apiService.post(
        AppConstants.updateLocationEndpoint,
        data: requestData,
      );

      debugPrint('🔵 Response status code: ${response.statusCode}');
      debugPrint('🔵 Response data: ${response.data}');
      debugPrint('🔵 Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        debugPrint('✅ Location updated on server: $responseData');

        // Check if response indicates success based on actual backend format
        if (responseData is Map<String, dynamic>) {
          final status = responseData['status'];
          final message = responseData['message'] ?? 'No message';
          final action = responseData['action'] ?? 'No action';

          debugPrint('🔵 Backend status: $status');
          debugPrint('🔵 Backend message: $message');
          debugPrint('🔵 Backend action: $action');

          if (status == true) {
            debugPrint(
              '✅ Backend confirmed success - Location updated successfully',
            );
            return true;
          } else {
            debugPrint('⚠️ Backend returned false status');
            debugPrint('⚠️ Full response: $responseData');
            return false;
          }
        } else if (responseData is String) {
          if (responseData.toLowerCase().contains('success') ||
              responseData.toLowerCase().contains('updated') ||
              responseData.toLowerCase().contains('saved') ||
              responseData.toLowerCase().contains('ok')) {
            debugPrint('✅ Backend confirmed success via string response');
            return true;
          } else {
            debugPrint('⚠️ Backend returned success but with unclear status');
            debugPrint('⚠️ Response string: $responseData');
            return false;
          }
        } else {
          debugPrint('✅ Backend returned 200 status code');
          return true;
        }
      } else {
        debugPrint(
          '❌ Failed to update location on server: ${response.statusCode}',
        );
        debugPrint('❌ Response data: ${response.data}');
        debugPrint('❌ Response headers: ${response.headers}');

        // Try to extract error message from response
        if (response.data is Map<String, dynamic>) {
          final errorMessage = response.data['message'] ?? 'Unknown error';
          debugPrint('❌ Error message: $errorMessage');
        } else if (response.data is String) {
          debugPrint('❌ Error response: ${response.data}');
        }

        return false;
      }
    } catch (e) {
      debugPrint('🔴 Error updating location on server: $e');
      debugPrint('🔴 Error type: ${e.runtimeType}');
      if (e.toString().contains('Exception')) {
        debugPrint('🔴 Exception details: ${e.toString()}');
      }

      // Extract error details
      if (e is DioException) {
        debugPrint('🔴 DioException type: ${e.type}');
        debugPrint('🔴 DioException message: ${e.message}');
        debugPrint('🔴 DioException response: ${e.response?.data}');
        debugPrint('🔴 DioException status code: ${e.response?.statusCode}');
      }

      return false;
    }
  }

  /// Test location update with sample data
  Future<bool> testLocationUpdate() async {
    try {
      debugPrint('🔵 Testing location update with sample data...');

      final testLocationData = LocationData(
        latitude: 28.6, // Delhi coordinates (matching your example)
        longitude: 77.09,
        address: 'Test Location, Delhi',
        timestamp: DateTime.now(),
      );

      debugPrint(
        '🔵 Test data: lat=${testLocationData.latitude}, lng=${testLocationData.longitude}',
      );
      return await updateLocationOnServer(testLocationData);
    } catch (e) {
      debugPrint('🔴 Error in test location update: $e');
      return false;
    }
  }

  /// Complete location flow: get current location, save locally, and update on server
  Future<bool> completeLocationFlow({BuildContext? context}) async {
    try {
      debugPrint('🔵 Starting complete location flow...');

      // Ensure service is initialized
      if (_prefs == null) {
        await initialize();
      }

      // Get current location - this will automatically handle:
      // 1. Our custom permission dialog (if permission denied)
      // 2. System permission dialog (after user allows in our dialog)
      // 3. System GPS enable dialog (like in your image) if GPS is disabled
      final locationData = await getCurrentLocation(context: context);
      if (locationData == null) {
        debugPrint('❌ Could not get current location');
        return false;
      }

      // Get address using reverse geocoding if not already available
      if (locationData.address == null) {
        debugPrint('🔵 Getting address for saved location...');
        final address = await _reverseGeocode(
          locationData.latitude,
          locationData.longitude,
        );
        if (address != null) {
          // Update location data with address
          final updatedLocationData = LocationData(
            latitude: locationData.latitude,
            longitude: locationData.longitude,
            address: address,
            timestamp: locationData.timestamp,
          );

          // Save updated location with address
          await saveLocationLocally(updatedLocationData);
          debugPrint('✅ Location with address saved locally: $address');
        } else {
          // Save without address
          await saveLocationLocally(locationData);
          debugPrint('✅ Location saved locally (no address)');
        }
      } else {
        // Save as is
        await saveLocationLocally(locationData);
        debugPrint('✅ Location saved locally');
      }

      // Update server in background (don't wait for it)
      updateLocationOnServer(locationData)
          .then((success) {
            if (success) {
              debugPrint('✅ Location updated on server (background)');
            } else {
              debugPrint('⚠️ Server update failed (background)');
            }
          })
          .catchError((e) {
            debugPrint('🔴 Server update error (background): $e');
          });

      // Return immediately after local save
      debugPrint('✅ Complete location flow successful');
      return true;
    } catch (e) {
      debugPrint('🔴 Error in complete location flow: $e');
      // Re-throw if it's a user cancellation
      if (e.toString().contains('cancelled') ||
          e.toString().contains('denied') ||
          e.toString().contains('permission')) {
        rethrow;
      }
      return false;
    }
  }

  /// Check if user has location data (either from server or locally)
  Future<bool> hasLocationData() async {
    final savedLocation = await getSavedLocation();
    return savedLocation != null;
  }

  /// Clear all location data
  Future<void> clearLocationData() async {
    try {
      if (_prefs == null) await initialize();

      await _prefs!.remove(_locationDataKey);
      await _prefs!.remove(_locationPermissionKey);
      await _prefs!.remove(_locationPermissionAskedKey);

      debugPrint('✅ All location data cleared');
    } catch (e) {
      debugPrint('🔴 Error clearing location data: $e');
    }
  }

  /// Open location settings directly
  Future<void> openLocationSettings() async {
    try {
      // For Android, try to open location settings directly
      if (defaultTargetPlatform == TargetPlatform.android) {
        const locationSettingsUri = 'android.settings.LOCATION_SOURCE_SETTINGS';
        final uri = Uri.parse('android-app://$locationSettingsUri');

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          debugPrint('✅ Opened location settings directly');
          return;
        }
      }

      // Fallback to app settings
      await openAppSettings();
      debugPrint('✅ Opened app settings as fallback');
    } catch (e) {
      debugPrint('🔴 Error opening location settings: $e');
      // Final fallback to general app settings
      await openAppSettings();
    }
  }

  /// Get location permission status for UI display
  Future<LocationPermissionStatus> getLocationPermissionStatus() async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.disabled;
      }

      final permission = await Permission.location.status;
      switch (permission) {
        case PermissionStatus.granted:
          return LocationPermissionStatus.granted;
        case PermissionStatus.denied:
          return LocationPermissionStatus.denied;
        case PermissionStatus.permanentlyDenied:
          return LocationPermissionStatus.permanentlyDenied;
        case PermissionStatus.restricted:
          return LocationPermissionStatus.restricted;
        default:
          return LocationPermissionStatus.denied;
      }
    } catch (e) {
      debugPrint('🔴 Error getting location permission status: $e');
      return LocationPermissionStatus.denied;
    }
  }
}

/// Location permission status enum
enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  disabled,
}

extension LocationPermissionStatusExtension on LocationPermissionStatus {
  String get displayName {
    switch (this) {
      case LocationPermissionStatus.granted:
        return 'Granted';
      case LocationPermissionStatus.denied:
        return 'Denied';
      case LocationPermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case LocationPermissionStatus.restricted:
        return 'Restricted';
      case LocationPermissionStatus.disabled:
        return 'Location Services Disabled';
    }
  }

  bool get isGranted => this == LocationPermissionStatus.granted;
  bool get canRequest => this == LocationPermissionStatus.denied;
  bool get needsSettings => this == LocationPermissionStatus.permanentlyDenied;
}

/// JWT Token decoder helper
Map<String, dynamic>? _decodeJwtToken(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(resp) as Map<String, dynamic>;
  } catch (e) {
    debugPrint('🔴 Error decoding JWT token: $e');
    return null;
  }
}
