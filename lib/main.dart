import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/router/app_router.dart';
import 'core/di/injection_container.dart';
import 'core/services/onboarding_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/home/bloc/home_bloc.dart';
import 'features/jobs/bloc/jobs_bloc.dart';
import 'features/profile/bloc/profile_bloc.dart';
import 'features/courses/bloc/courses_bloc.dart';
import 'features/interviews/bloc/interviews_bloc.dart';
import 'features/messages/bloc/messages_bloc.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'features/skill_test/bloc/skill_test_bloc.dart';
import 'shared/services/api_service.dart';
import 'shared/services/inactivity_service.dart';
import 'shared/services/fcm_service.dart';

/// The main function - this is where the Flutter app starts
/// It calls runApp() which inflates the given widget and attaches it to the screen
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (MUST complete before FCM)
  // Note: Web platform requires FirebaseOptions, Android/iOS use google-services.json
  FirebaseApp? firebaseApp;
  
  // Only initialize Firebase for mobile platforms (Android/iOS)
  // Web requires firebase_options.dart which we don't have yet
  if (!kIsWeb) {
  try {
      firebaseApp = await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');
      debugPrint('✅ Firebase App Name: ${firebaseApp.name}');
  } catch (e) {
    debugPrint('🔴 Error initializing Firebase: $e');
      debugPrint('🔴 Firebase initialization failed, FCM will not work');
      // Continue app startup even if Firebase fails
    }
  } else {
    debugPrint('⚠️ Web platform detected - Firebase initialization skipped');
    debugPrint('⚠️ FCM not supported on web without firebase_options.dart');
  }

  // Set up background message handler (only if Firebase initialized and not web)
  if (firebaseApp != null && !kIsWeb) {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Initialize dependency injection
  await initializeDependencies();

  // Initialize API service with token restoration
  final apiService = sl<ApiService>();
  await apiService.initialize();

  // Initialize FCM service (only if Firebase initialized successfully and not web)
  if (firebaseApp != null && !kIsWeb) {
  try {
    final fcmService = sl<FcmService>();
    await fcmService.initialize();
    debugPrint('✅ FCM Service initialized successfully');
  } catch (e) {
    debugPrint('🔴 Error initializing FCM Service: $e');
      debugPrint('🔴 FCM Service will not be available');
    }
  } else {
    if (kIsWeb) {
      debugPrint('⚠️ FCM Service skipped - Web platform not supported');
    } else {
      debugPrint('⚠️ FCM Service skipped - Firebase not initialized');
    }
  }

  // Initialize onboarding service for optimized performance
  await OnboardingService.instance.initialize();

  // Initialize inactivity service for token expiry management
  await InactivityService.instance.initialize();

  runApp(const MyApp());
}

/// MyApp - The root widget of the application
/// This is a StatefulWidget that handles app lifecycle events for inactivity monitoring
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - check for token expiry
        _checkInactivity();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App went to background or became inactive
        break;
      case AppLifecycleState.detached:
        // App is detached
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        break;
    }
  }

  /// Check for user inactivity and handle token expiry if needed
  Future<void> _checkInactivity() async {
    if (mounted) {
      await InactivityService.instance.checkAndHandleTokenExpiry(context);
    }
  }

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
        // Interviews BLoC
        BlocProvider<InterviewsBloc>(create: (context) => sl<InterviewsBloc>()),
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
