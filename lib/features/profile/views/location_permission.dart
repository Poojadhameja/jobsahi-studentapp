/// Location Screen 2 - Enter Current Location

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/widgets/common/top_snackbar.dart';

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

class _LocationPermissionView extends StatefulWidget {
  final bool isFromCurrentLocation;

  const _LocationPermissionView({required this.isFromCurrentLocation});

  @override
  State<_LocationPermissionView> createState() =>
      _LocationPermissionViewState();
}

class _LocationPermissionViewState extends State<_LocationPermissionView>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _pulseController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Ripple animation controller
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    _rippleController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

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
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppConstants.cardBackgroundColor,
                      AppConstants.cardBackgroundColor.withValues(alpha: 0.95),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.largePadding,
                              vertical: AppConstants.largePadding,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),

                                // Location icon image
                                _buildLocationIcon(),
                                const SizedBox(height: 40),

                                // Main question
                                _buildMainQuestion(hasPermission),
                                const SizedBox(height: 16),

                                // Description text
                                _buildDescription(hasPermission),
                                const SizedBox(height: 50),

                                // Allow location access button
                                _buildAllowLocationButton(
                                  context,
                                  isProcessing,
                                  hasPermission,
                                ),
                                const SizedBox(height: 20),

                                // Skip button for users who don't want to grant location permission
                                _buildSkipButton(context, isProcessing),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: 0.8 + (_pulseAnimation.value - 0.98) * 2.5, // Fade in effect
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppConstants.secondaryColor.withValues(alpha: 0.15),
                  AppConstants.secondaryColor.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated ripple effects
                  _buildAnimatedRippleEffect(
                    AppConstants.secondaryColor.withValues(alpha: 0.1),
                    160,
                    0.0,
                  ),
                  _buildAnimatedRippleEffect(
                    AppConstants.secondaryColor.withValues(alpha: 0.15),
                    130,
                    0.3,
                  ),
                  _buildAnimatedRippleEffect(
                    AppConstants.secondaryColor.withValues(alpha: 0.2),
                    100,
                    0.6,
                  ),
                  // Main icon container with pulse animation
                  _buildAnimatedMainIcon(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds animated ripple effect container
  Widget _buildAnimatedRippleEffect(Color color, double size, double delay) {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        final animationValue = (_rippleAnimation.value + delay) % 1.0;
        final smoothValue = Curves.easeOut.transform(animationValue);

        // Fade-in effect for new layers
        final fadeInValue = Curves.easeIn.transform(
          (animationValue < 0.3) ? (animationValue / 0.3) : 1.0,
        );

        return Transform.scale(
          scale: 0.9 + (smoothValue * 0.3), // Scale from 0.9 to 1.2
          child: Opacity(
            opacity:
                fadeInValue *
                (1.0 - smoothValue) *
                0.6, // Fade in then fade out
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ),
        );
      },
    );
  }

  /// Builds animated main icon with pulse effect
  Widget _buildAnimatedMainIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstants.secondaryColor,
                  AppConstants.secondaryColor.withValues(alpha: 0.8),
                  AppConstants.secondaryColor.withValues(alpha: 0.9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.secondaryColor.withValues(alpha: 0.4),
                  blurRadius: 25,
                  spreadRadius: 8,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppConstants.secondaryColor.withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 15,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: const Icon(
              Icons.my_location_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  /// Builds the main question
  Widget _buildMainQuestion(bool hasPermission) {
    String questionText;

    if (hasPermission) {
      questionText = 'Location Access Already Granted';
    } else if (widget.isFromCurrentLocation) {
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
    } else if (widget.isFromCurrentLocation) {
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
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.secondaryColor,
            AppConstants.secondaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.secondaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isProcessing ? null : () => _allowLocationAccess(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isProcessing
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                hasPermission
                    ? 'Update Location'
                    : AppConstants.allowLocationAccess,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
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
          '❌ GPS service not enabled - system will show dialog when we try to get location',
        );
        // Don't return here - let the system handle GPS enable dialog
        // when we call getCurrentPosition()
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
        debugPrint('🔵 Requesting location permission with proper flow...');
        // Step 2: Request permission using LocationService (handles denied/permanently denied cases)
        final permissionResult = await locationService
            .requestLocationPermission(context: context);
        debugPrint('🔵 Permission request result: $permissionResult');

        if (!permissionResult) {
          debugPrint('❌ User denied or permission not granted');
          // User denied system permission or it was permanently denied
          // LocationService already showed the "Open Settings" dialog if needed
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
        debugPrint('⚠️ GPS is disabled, showing warning snackbar');
        // GPS is disabled - show warning snackbar (like in profile)
        if (context.mounted) {
          context.read<ProfileBloc>().add(
            const LocationPermissionDeniedEvent(),
          );
          // Show GPS warning snackbar
          TopSnackBar.showGPSWarning(
            context,
            message: 'Please enable GPS to get your location',
            duration: const Duration(seconds: 5),
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

        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppConstants.textSecondaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: TextButton(
            onPressed: isProcessing
                ? null
                : () => _skipLocationPermission(context),
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.textSecondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Skip for now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        );
      },
    );
  }
}
