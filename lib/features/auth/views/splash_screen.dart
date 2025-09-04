import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// SplashScreen - The initial splash screen that users see when opening the app
/// Shows the Job Sahi logo with a loading indicator and automatically
/// transitions to the onboarding screen after 2 seconds
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(const SplashInitializationEvent()),
      child: const _SplashScreenView(),
    );
  }
}

class _SplashScreenView extends StatelessWidget {
  const _SplashScreenView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SplashReadyToNavigate) {
          // Navigate to onboarding screen when ready
          context.go(AppRoutes.onboarding);
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
