/// Location Screen 2 - Enter Current Location

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../shared/services/location_service.dart';

class LocationPermissionScreen extends StatelessWidget {
  final bool isFromCurrentLocation;

  const LocationPermissionScreen({
    super.key,
    this.isFromCurrentLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(const LoadProfileDataEvent()),
      child: _LocationPermissionView(
        isFromCurrentLocation: isFromCurrentLocation,
      ),
    );
  }
}

class _LocationPermissionView extends StatelessWidget {
  final bool isFromCurrentLocation;

  const _LocationPermissionView({required this.isFromCurrentLocation});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        bool isProcessing = false;

        if (state is LocationPermissionState) {
          isProcessing = state.isProcessing;
        }

        return FutureBuilder<bool>(
          future: LocationService.instance.isLocationPermissionGranted(),
          builder: (context, permissionSnapshot) {
            final hasPermission = permissionSnapshot.data ?? false;

            return Scaffold(
              backgroundColor: AppConstants.cardBackgroundColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppConstants.textPrimaryColor,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Location icon image
                      _buildLocationIcon(),
                      const SizedBox(height: AppConstants.largePadding),

                      // Main question
                      _buildMainQuestion(hasPermission),
                      const SizedBox(height: AppConstants.defaultPadding),

                      // Description text
                      _buildDescription(hasPermission),
                      const SizedBox(height: AppConstants.largePadding),

                      // Allow location access button
                      _buildAllowLocationButton(
                        context,
                        isProcessing,
                        hasPermission,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),

                      // Skip button for users who don't want to grant location permission
                      _buildSkipButton(context, isProcessing),
                      const SizedBox(height: AppConstants.defaultPadding),

                      // Manual location entry option (only show if not from current location)
                      if (!isFromCurrentLocation) ...[
                        _buildManualLocationOption(context),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Builds the location icon using the asset image
  Widget _buildLocationIcon() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Image.asset(
        'assets/images/location_icon.png',
        width: 120,
        height: 120,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to a custom location icon if image fails to load
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppConstants.secondaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.my_location, size: 60, color: Colors.white),
          );
        },
      ),
    );
  }

  /// Builds the main question
  Widget _buildMainQuestion(bool hasPermission) {
    String questionText;

    if (hasPermission) {
      questionText = 'Location Access Already Granted';
    } else if (isFromCurrentLocation) {
      questionText = AppConstants.allowLocationQuestion;
    } else {
      questionText = AppConstants.enterLocationTitle;
    }

    return Text(
      questionText,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppConstants.textPrimaryColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds the description text
  Widget _buildDescription(bool hasPermission) {
    String descriptionText;

    if (hasPermission) {
      descriptionText =
          'Your location permission is already granted. You can update your location or continue to the app.';
    } else if (isFromCurrentLocation) {
      descriptionText = AppConstants.currentLocationDescription;
    } else {
      descriptionText = AppConstants.locationDescription;
    }

    return Text(
      descriptionText,
      style: TextStyle(
        fontSize: 18,
        color: AppConstants.textSecondaryColor,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds the allow location access button
  Widget _buildAllowLocationButton(
    BuildContext context,
    bool isProcessing,
    bool hasPermission,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessing ? null : () => _allowLocationAccess(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 0,
        ),
        child: isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                hasPermission
                    ? 'Update Location'
                    : AppConstants.allowLocationAccess,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  /// Builds the manual location entry option
  Widget _buildManualLocationOption(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        bool isProcessing = false;
        if (state is LocationPermissionState) {
          isProcessing = state.isProcessing;
        }

        return TextButton(
          onPressed: isProcessing
              ? null
              : () => _enterLocationManually(context),
          style: TextButton.styleFrom(
            foregroundColor: AppConstants.secondaryColor,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            AppConstants.enterLocationManually,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      },
    );
  }

  /// Handles allowing location access - Simple flow
  void _allowLocationAccess(BuildContext context) async {
    debugPrint('🔵 Starting location access flow...');
    context.read<ProfileBloc>().add(const RequestLocationPermissionEvent());

    // Clear any existing location data first
    try {
      final locationService = LocationService.instance;
      await locationService.initialize();
      await locationService.clearLocationData();
      debugPrint('🔵 Cleared existing location data');
    } catch (e) {
      debugPrint('⚠️ Error clearing location data: $e');
    }

    // Quick diagnostic check
    try {
      final locationService = LocationService.instance;
      await locationService.initialize();

      debugPrint('🔵 === LOCATION DIAGNOSTIC ===');
      final permission = await Permission.location.status;
      debugPrint('🔵 Permission status: $permission');

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('🔵 GPS service enabled: $serviceEnabled');

      if (permission != PermissionStatus.granted) {
        debugPrint('❌ Permission not granted - requesting...');
        final requestResult = await Permission.location.request();
        debugPrint('🔵 Permission request result: $requestResult');
      }

      if (!serviceEnabled) {
        debugPrint(
          '❌ GPS service not enabled - user needs to enable in settings',
        );
        _showSimpleErrorDialog(
          context,
          'Please enable GPS/Location services in your device settings and try again.',
        );
        return;
      }

      debugPrint('🔵 === END DIAGNOSTIC ===');
    } catch (e) {
      debugPrint('🔴 Diagnostic error: $e');
    }

    try {
      final locationService = LocationService.instance;

      // Initialize location service first
      debugPrint('🔵 Initializing location service...');
      await locationService.initialize();

      // Step 1: Check if location permission is granted
      debugPrint('🔵 Checking location permission...');
      final permissionGranted = await locationService
          .isLocationPermissionGranted();

      debugPrint('🔵 Permission granted: $permissionGranted');

      if (!permissionGranted) {
        debugPrint('🔵 Requesting system permission...');
        // Step 2: Request system permission (shows system dialog)
        final systemPermission = await Permission.location.request();
        debugPrint('🔵 System permission result: $systemPermission');

        if (systemPermission != PermissionStatus.granted) {
          debugPrint('❌ User denied system permission');
          // User denied system permission
          if (context.mounted) {
            context.read<ProfileBloc>().add(
              const LocationPermissionDeniedEvent(),
            );
          }
          return;
        }
      }

      // Step 3: Check GPS status first
      debugPrint('🔵 Checking GPS status...');
      final gpsEnabled = await locationService.isLocationServiceEnabled();
      debugPrint('🔵 GPS enabled: $gpsEnabled');

      if (!gpsEnabled) {
        debugPrint('⚠️ GPS is disabled, will trigger system dialog');
        // GPS is disabled - system will show dialog when we try to get location
        // Stop the loading state first
        if (context.mounted) {
          context.read<ProfileBloc>().add(
            const LocationPermissionDeniedEvent(),
          );
        }

        // Try to get location - this will trigger system GPS dialog
        try {
          debugPrint(
            '🔵 Attempting to get location (will trigger GPS dialog)...',
          );
          final locationSuccess = await locationService.completeLocationFlow();
          debugPrint('🔵 Location flow result: $locationSuccess');

          if (context.mounted) {
            if (locationSuccess) {
              debugPrint('✅ Location flow successful, navigating to home');
              // Immediately update state and navigate
              context.read<ProfileBloc>().add(
                const LocationPermissionGrantedEvent(),
              );
              // Navigate immediately without waiting
              if (context.mounted) {
                context.go(AppRoutes.home);
              }
            } else {
              debugPrint('❌ Location flow failed');
              context.read<ProfileBloc>().add(
                const LocationPermissionDeniedEvent(),
              );
            }
          }
        } catch (e) {
          // User cancelled system dialog - already in denied state
          debugPrint('❌ User cancelled GPS dialog: $e');
        }
        return;
      }

      // Step 4: GPS is enabled, get location normally
      debugPrint('🔵 GPS is enabled, getting location normally...');

      // Test GPS directly first
      debugPrint('🔵 Testing GPS location directly...');
      await locationService.testGPSLocation();

      // Get fresh GPS location (ignore any saved data)
      debugPrint('🔵 Getting fresh GPS location...');
      final freshLocation = await locationService.getFreshGPSLocation(
        context: context,
      );
      if (freshLocation != null) {
        debugPrint('✅ Fresh GPS location: ${freshLocation.toString()}');
      } else {
        debugPrint('❌ Failed to get fresh GPS location');
        // Check what's wrong
        final permission = await locationService.isLocationPermissionGranted();
        final serviceEnabled = await locationService.isLocationServiceEnabled();
        debugPrint('🔵 Permission granted: $permission');
        debugPrint('🔵 Service enabled: $serviceEnabled');

        if (!permission) {
          _showSimpleErrorDialog(
            context,
            'Location permission not granted. Please enable location permission in settings.',
          );
          return;
        }

        if (!serviceEnabled) {
          _showSimpleErrorDialog(
            context,
            'Location services are disabled. Please enable GPS in settings.',
          );
          return;
        }
      }

      try {
        final locationSuccess = await locationService.completeLocationFlow();
        debugPrint('🔵 Location flow result: $locationSuccess');

        if (context.mounted) {
          if (locationSuccess) {
            debugPrint('✅ Location flow successful, navigating to home');
            // Immediately update state and navigate
            context.read<ProfileBloc>().add(
              const LocationPermissionGrantedEvent(),
            );
            // Navigate immediately without waiting
            if (context.mounted) {
              context.go(AppRoutes.home);
            }
          } else {
            debugPrint('❌ Location flow failed, showing error dialog');
            context.read<ProfileBloc>().add(
              const LocationPermissionDeniedEvent(),
            );
            _showSimpleErrorDialog(
              context,
              'Unable to get location. Please try again.',
            );
          }
        }
      } catch (e) {
        debugPrint('❌ Location error: $e');
        if (context.mounted) {
          context.read<ProfileBloc>().add(
            const LocationPermissionDeniedEvent(),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.read<ProfileBloc>().add(const LocationPermissionDeniedEvent());
        _showSimpleErrorDialog(
          context,
          'Something went wrong. Please try again.',
        );
      }
    }
  }

  /// Shows simple error dialog
  void _showSimpleErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Error',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  /// Handles manual location entry
  void _enterLocationManually(BuildContext context) {
    // Navigate back to location1 screen for manual selection
    context.pop();
  }

  /// Handles skipping location permission
  void _skipLocationPermission(BuildContext context) async {
    try {
      // First, emit the processing state
      context.read<ProfileBloc>().add(const RequestLocationPermissionEvent());

      // Initialize location service and mark that we've asked for permission
      final locationService = LocationService.instance;
      await locationService.initialize();
      await locationService.markLocationPermissionAsked();

      // Emit the denied state to stop processing
      if (context.mounted) {
        context.read<ProfileBloc>().add(const LocationPermissionDeniedEvent());

        // Navigate to home screen
        context.go(AppRoutes.home);
      }
    } catch (e) {
      // Even if there's an error, emit denied state and navigate to home
      if (context.mounted) {
        context.read<ProfileBloc>().add(const LocationPermissionDeniedEvent());
        context.go(AppRoutes.home);
      }
    }
  }

  /// Builds the skip button
  Widget _buildSkipButton(BuildContext context, bool isProcessing) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        bool isProcessing = false;

        if (state is LocationPermissionState) {
          isProcessing = state.isProcessing;
        }

        return SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: isProcessing
                ? null
                : () => _skipLocationPermission(context),
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.textSecondaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Skip for now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
      },
    );
  }
}
