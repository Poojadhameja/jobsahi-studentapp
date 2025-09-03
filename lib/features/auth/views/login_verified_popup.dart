import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';

class LoginVerifiedPopupScreen extends StatefulWidget {
  const LoginVerifiedPopupScreen({super.key});

  @override
  State<LoginVerifiedPopupScreen> createState() =>
      _LoginVerifiedPopupScreenState();
}

class _LoginVerifiedPopupScreenState extends State<LoginVerifiedPopupScreen>
    with TickerProviderStateMixin {
  /// Whether the verification is in progress
  bool _isVerifying = false;

  /// Animation controllers
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    // Reset verification state when screen initializes
    _isVerifying = false;

    // Initialize scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize check animation controller
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Create scale animation with bouncy effect
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Create check animation
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );

    // Start animations
    _startAnimations();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  /// Start the success icon animations
  void _startAnimations() {
    // Start scale animation
    _scaleController.forward();

    // Start check animation after scale animation completes
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _checkController.forward();
      }
    });
  }

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
          onPressed: () => context.pop(),
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

  /// Builds the success icon with animation
  Widget _buildSuccessIcon() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppConstants.successColor,
              shape: BoxShape.circle,
            ),
            child: AnimatedBuilder(
              animation: _checkAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _checkAnimation.value,
                  child: Transform.scale(
                    scale: _checkAnimation.value,
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
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
            color: AppConstants.successColor,
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
          backgroundColor: AppConstants.successColor,
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

      // Navigate to profile builder step 1
      if (mounted) {
        context.go(AppRoutes.profileBuilderStep1);
      }
    });
  }
}
