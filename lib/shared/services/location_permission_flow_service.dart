import 'package:flutter/foundation.dart';
import '../../core/constants/app_routes.dart';
import 'location_service.dart';

/// Service to handle the location permission flow after login
class LocationPermissionFlowService {
  static LocationPermissionFlowService? _instance;
  static LocationPermissionFlowService get instance =>
      _instance ??= LocationPermissionFlowService._internal();
  LocationPermissionFlowService._internal();

  final LocationService _locationService = LocationService.instance;

  /// Check if user needs to go through location permission flow
  Future<bool> needsLocationPermissionFlow() async {
    try {
      debugPrint('🔵 Checking if user needs location permission flow...');

      // Check if user has already granted location permission
      final permissionGranted = await _locationService
          .isLocationPermissionGranted();
      if (permissionGranted) {
        debugPrint('✅ User has already granted location permission');
        return false;
      }

      // Check if user has location data stored locally
      final hasLocationData = await _locationService.hasLocationData();
      if (hasLocationData) {
        debugPrint('✅ User has location data stored locally');
        return false;
      }

      // Check if we've already asked for permission
      final hasAsked = await _locationService.hasAskedForLocationPermission();
      if (hasAsked) {
        debugPrint('✅ User has already been asked for location permission');
        return false;
      }

      debugPrint('🔵 User needs location permission flow');
      return true;
    } catch (e) {
      debugPrint('🔴 Error checking location permission flow: $e');
      return false;
    }
  }

  /// Navigate to location permission screen if needed
  Future<void> handleLocationPermissionFlow() async {
    try {
      final needsFlow = await needsLocationPermissionFlow();

      if (needsFlow) {
        debugPrint('🔵 Navigating to location permission screen...');
        // Navigate to location permission screen
        // Note: This will be called from the router or after login
        // The actual navigation will be handled by the calling context
      } else {
        debugPrint('✅ No location permission flow needed');
      }
    } catch (e) {
      debugPrint('🔴 Error handling location permission flow: $e');
    }
  }

  /// Get the appropriate route based on location permission status
  Future<String> getInitialRouteAfterLogin() async {
    try {
      // Always redirect to location permission page first after login
      // This ensures all users go through location permission flow
      debugPrint(
        '🔵 Always redirecting to location permission page after login',
      );
      return AppRoutes.locationPermission;
    } catch (e) {
      debugPrint('🔴 Error getting initial route: $e');
      return AppRoutes
          .locationPermission; // Default to location permission page on error
    }
  }

  /// Complete the location permission flow
  Future<bool> completeLocationPermissionFlow() async {
    try {
      debugPrint('🔵 Completing location permission flow...');

      // Request permission
      final permissionGranted = await _locationService
          .requestLocationPermission();

      if (!permissionGranted) {
        debugPrint('❌ Location permission not granted');
        return false;
      }

      // Get location and update server
      final locationSuccess = await _locationService.completeLocationFlow();

      if (locationSuccess) {
        debugPrint('✅ Location permission flow completed successfully');
        return true;
      } else {
        debugPrint('❌ Failed to complete location flow');
        return false;
      }
    } catch (e) {
      debugPrint('🔴 Error completing location permission flow: $e');
      return false;
    }
  }
}
