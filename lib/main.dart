import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/di/injection_container.dart';
import 'core/services/onboarding_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/home/bloc/home_bloc.dart';
import 'features/jobs/bloc/jobs_bloc.dart';
import 'features/profile/bloc/profile_bloc.dart';
import 'features/courses/bloc/courses_bloc.dart';
import 'features/messages/bloc/messages_bloc.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'features/skill_test/bloc/skill_test_bloc.dart';
import 'shared/services/api_service.dart';

/// The main function - this is where the Flutter app starts
/// It calls runApp() which inflates the given widget and attaches it to the screen
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await initializeDependencies();

  // Initialize API service with token restoration
  final apiService = sl<ApiService>();
  await apiService.initialize();

  // Initialize onboarding service for optimized performance
  await OnboardingService.instance.initialize();

  runApp(const MyApp());
}

/// MyApp - The root widget of the application
/// This is a StatelessWidget that sets up the MaterialApp with all necessary configurations
/// StatelessWidget means this widget doesn't change over time - it's static
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// The build method is called whenever Flutter needs to render this widget
  /// It returns a MaterialApp which provides Material Design styling and navigation
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC
        BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
        // Home BLoC
        BlocProvider<HomeBloc>(create: (context) => sl<HomeBloc>()),
        // Jobs BLoC
        BlocProvider<JobsBloc>(create: (context) => sl<JobsBloc>()),
        // Profile BLoC
        BlocProvider<ProfileBloc>(create: (context) => sl<ProfileBloc>()),
        // Courses BLoC
        BlocProvider<CoursesBloc>(create: (context) => sl<CoursesBloc>()),
        // Messages BLoC
        BlocProvider<MessagesBloc>(create: (context) => sl<MessagesBloc>()),
        // Settings BLoC
        BlocProvider<SettingsBloc>(create: (context) => sl<SettingsBloc>()),
        // Skill Test BLoC
        BlocProvider<SkillTestBloc>(create: (context) => sl<SkillTestBloc>()),
      ],
      child: MaterialApp.router(
        // Remove the debug banner in the top-right corner (for production apps)
        debugShowCheckedModeBanner: false,

        // The title of the app (shown in task switcher on mobile)
        title: 'Jobsahi',

        // Use GoRouter for modern navigation with deep linking support
        // This provides better URL handling, deep linking, and navigation state management
        routerConfig: AppRouter.router,
      ),
    );
  }
}
