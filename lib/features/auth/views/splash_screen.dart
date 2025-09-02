import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';

/// SplashScreen - The initial splash screen that users see when opening the app
/// Shows the Job Sahi logo with a loading indicator and automatically
/// transitions to the onboarding screen after 2 seconds
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically navigate to first onboarding screen after 2 seconds
    // This gives users time to see the app logo and branding
    Future.delayed(const Duration(seconds: 2), () {
      // Check if the widget is still mounted to avoid navigation errors
      if (!mounted) return;
      // Use go_router to navigate to onboarding screen
      // This replaces the current screen so users can't go back to splash
      context.go(AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // White background for clean, professional look
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo - main branding element
            Image.asset('assets/images/logo/jobsahi_logo.png', height: 120),
            const SizedBox(height: 24),
            // Loading indicator to show the app is starting up
            const CircularProgressIndicator(color: Colors.green),
          ],
        ),
      ),
    );
  }
}
