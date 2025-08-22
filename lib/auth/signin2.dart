import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/navigation_service.dart';

class Signin2Screen extends StatefulWidget {
  const Signin2Screen({super.key});

  @override
  State<Signin2Screen> createState() => _Signin2ScreenState();
}

class _Signin2ScreenState extends State<Signin2Screen> {
  /// Whether the verification is in progress
  bool _isVerifying = false;

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
              // Success icon
              _buildSuccessIcon(),
              const SizedBox(height: AppConstants.largePadding),

              // Title and description
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
      child: const Icon(Icons.check, color: Colors.white, size: 50),
    );
  }

  /// Builds the content section
  Widget _buildContent() {
    return Column(
      children: [
        const Text(
          'Verification Successful!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallPadding),

        const Text(
          'Your email has been verified successfully. You can now access all features of the app.',
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondaryColor,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the continue button
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isVerifying ? null : _continueToApp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: _isVerifying
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Continue to App',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// Continues to the main app
  void _continueToApp() {
    setState(() {
      _isVerifying = true;
    });

    // Simulate loading
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isVerifying = false;
      });

      // Navigate to location flow instead of directly to home using smart navigation
      NavigationService.smartNavigate(routeName: RouteNames.location1);
    });
  }
}
