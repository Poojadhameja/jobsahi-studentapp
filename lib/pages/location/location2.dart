/// Location Screen 2

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import '../home/home.dart';

class Location2Screen extends StatefulWidget {
  const Location2Screen({super.key});

  @override
  State<Location2Screen> createState() => _Location2ScreenState();
}

class _Location2ScreenState extends State<Location2Screen> {
  /// Whether the location is being saved
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(
        title: 'Confirm Location',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              _buildSuccessIcon(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Content
              _buildContent(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Continue button
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the success icon
  Widget _buildSuccessIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: AppConstants.successColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.location_on,
        color: Colors.white,
        size: 50,
      ),
    );
  }

  /// Builds the content section
  Widget _buildContent() {
    return Column(
      children: [
        const Text(
          'Location Set Successfully!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        
        const Text(
          'Your preferred work location has been set. We will show you relevant job opportunities based on your location preference.',
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondaryColor,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppConstants.backgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppConstants.primaryColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Mumbai, Maharashtra',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the continue button
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _continueToHome,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Continue to Home',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Continues to the home screen
  void _continueToHome() {
    setState(() {
      _isSaving = true;
    });

    // Simulate saving process
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isSaving = false;
      });
      
      // Navigate to home screen
      NavigationService.smartNavigate(destination: const HomeScreen());
    });
  }
}
