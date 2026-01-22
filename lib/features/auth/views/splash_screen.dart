import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/onboarding_service.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// SplashScreen - The initial splash screen that users see when opening the app
/// Shows the Jobsahi logo with a loading indicator
/// Minimum 2 second display time with smart navigation:
/// - First time user -> Onboarding
/// - Logged in user -> Home
/// - Returning user (not logged in) -> Login
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(const CheckAuthStatusEvent()),
      child: const _SplashScreenView(),
    );
  }
}

class _SplashScreenView extends StatefulWidget {
  const _SplashScreenView();

  @override
  State<_SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<_SplashScreenView>
    with TickerProviderStateMixin {
  // Track when the splash screen was created
  final DateTime _startTime = DateTime.now();
  bool _hasNavigated = false;

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _loaderAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _loaderRotationAnimation;
  late Animation<double> _loaderScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup main animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Setup loader animations
    _loaderAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade-in animation (0.0 to 1.0)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Bounce scale animation (0.5 to 1.0 with bounce)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Loader rotation animation (continuous rotation)
    _loaderRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loaderAnimationController, curve: Curves.linear),
    );

    // Loader scale animation (pulsing effect)
    _loaderScaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _loaderAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animations
    _animationController.forward();
    _loaderAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loaderAnimationController.dispose();
    super.dispose();
  }

  /// Navigate only after ensuring minimum 2 seconds have passed
  Future<void> _navigateWithMinimumDelay(
    BuildContext context,
    String route,
  ) async {
    if (_hasNavigated) return;

    final elapsed = DateTime.now().difference(_startTime);
    const minDuration = Duration(seconds: 2);

    // If less than 2 seconds have passed, wait for the remaining time
    if (elapsed < minDuration) {
      final remainingTime = minDuration - elapsed;
      await Future.delayed(remainingTime);
    }

    // Quick fade-out animation before navigation (300ms instead of 600ms)
    await _animationController.reverse(from: 1.0);

    // Immediate navigation without delay
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthSuccess) {
          // User is already logged in, navigate to campus drive
          await _navigateWithMinimumDelay(context, AppRoutes.campusDriveList);
        } else if (state is AuthInitial || state is AuthError) {
          // User is not logged in, check if they've seen onboarding
          final hasSeenOnboarding = await OnboardingService.instance
              .hasSeenOnboarding();

          if (hasSeenOnboarding) {
            // Returning user, go to login (no back button needed)
            await _navigateWithMinimumDelay(
              context,
              '${AppRoutes.loginOtpEmail}?fromSplash=true',
            );
          } else {
            // First time user, show onboarding
            await _navigateWithMinimumDelay(context, AppRoutes.onboarding);
          }
        }
      },
      child: KeyboardDismissWrapper(
        child: Scaffold(
          // White background for clean, professional look
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                // Centered logo and loader
                Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // App logo - main branding element with bounce effect
                              Image.asset(
                                'assets/images/logo/jobsahi_logo.png',
                                height: 120,
                              ),
                              const SizedBox(height: 24),
                              // Animated loading indicator with primary green color
                              AnimatedBuilder(
                                animation: _loaderAnimationController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _loaderScaleAnimation.value,
                                    child: Transform.rotate(
                                      angle:
                                          _loaderRotationAnimation.value *
                                          2 *
                                          3.14159,
                                      child: CircularProgressIndicator(
                                        color: AppConstants
                                            .secondaryColor, // Primary green color
                                        strokeWidth: 3.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppConstants.secondaryColor,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Powered by text at the bottom - positioned absolutely
                Positioned(
                  bottom: 90,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Powered by\n',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: 'Satpuda Group of Education',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
