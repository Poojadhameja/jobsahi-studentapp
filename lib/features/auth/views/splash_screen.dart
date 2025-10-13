import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/onboarding_service.dart';
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
    with SingleTickerProviderStateMixin {
  // Track when the splash screen was created
  final DateTime _startTime = DateTime.now();
  bool _hasNavigated = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          // User is already logged in, navigate to home
          await _navigateWithMinimumDelay(context, AppRoutes.home);
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
      child: Scaffold(
        // White background for clean, professional look
        backgroundColor: Colors.white,
        body: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo - main branding element with bounce effect
                      Image.asset(
                        'assets/images/logo/jobsahi_logo.png',
                        height: 120,
                      ),
                      const SizedBox(height: 24),
                      // Loading indicator to show the app is starting up
                      const CircularProgressIndicator(color: Colors.green),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
