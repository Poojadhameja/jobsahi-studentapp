/// Location Screen 2 - Enter Current Location

library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/navigation_service.dart';

class LocationPermissionScreen extends StatefulWidget {
  final bool isFromCurrentLocation;

  const LocationPermissionScreen({
    super.key,
    this.isFromCurrentLocation = false,
  });

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  /// Whether the location is being processed
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => NavigationService.goBack(),
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
              _buildAllowLocationButton(),
              const SizedBox(height: AppConstants.defaultPadding),

              // Manual location entry option (only show if not from current location)
              if (!widget.isFromCurrentLocation) ...[
                _buildManualLocationOption(),
              ],
            ],
          ),
        ),
      ),
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
    final questionText = widget.isFromCurrentLocation
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
    final descriptionText = widget.isFromCurrentLocation
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
  Widget _buildAllowLocationButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _allowLocationAccess,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 0,
        ),
        child: _isProcessing
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
  Widget _buildManualLocationOption() {
    return TextButton(
      onPressed: _isProcessing ? null : _enterLocationManually,
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
  }

  /// Handles allowing location access
  void _allowLocationAccess() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // TODO: Implement actual location permission request
      // For now, simulate the process
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to home screen after successful location access using smart navigation
      NavigationService.smartNavigate(routeName: RouteNames.home);
    } catch (e) {
      // Handle location permission denied
      setState(() {
        _isProcessing = false;
      });

      // Show error message
      if (mounted) {
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
  void _enterLocationManually() {
    // Navigate back to location1 screen for manual selection
    NavigationService.goBack();
  }
}
