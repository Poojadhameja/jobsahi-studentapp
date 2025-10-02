/// Location Screen 2 - Enter Current Location

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

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
                  _buildMainQuestion(),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Description text
                  _buildDescription(),
                  const SizedBox(height: AppConstants.largePadding),

                  // Allow location access button
                  _buildAllowLocationButton(context, isProcessing),
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
  Widget _buildMainQuestion() {
    final questionText = isFromCurrentLocation
        ? AppConstants.allowLocationQuestion
        : AppConstants.enterLocationTitle;

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
  Widget _buildDescription() {
    final descriptionText = isFromCurrentLocation
        ? AppConstants.currentLocationDescription
        : AppConstants.locationDescription;

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
  Widget _buildAllowLocationButton(BuildContext context, bool isProcessing) {
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
                AppConstants.allowLocationAccess,
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

  /// Handles allowing location access
  void _allowLocationAccess(BuildContext context) async {
    context.read<ProfileBloc>().add(const RequestLocationPermissionEvent());

    try {
      // TODO: Implement actual location permission request
      // For now, simulate the process
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful permission grant
      if (context.mounted) {
        context.read<ProfileBloc>().add(const LocationPermissionGrantedEvent());
        // Navigate to home screen after successful location access using smart navigation
        context.go(AppRoutes.home);
      }
    } catch (e) {
      // Handle location permission denied
      if (context.mounted) {
        context.read<ProfileBloc>().add(const LocationPermissionDeniedEvent());
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location access denied. Please try again.'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  /// Handles manual location entry
  void _enterLocationManually(BuildContext context) {
    // Navigate back to location1 screen for manual selection
    context.pop();
  }
}
