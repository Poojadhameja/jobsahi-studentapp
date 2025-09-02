import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

/// The main function - this is where the Flutter app starts
/// It calls runApp() which inflates the given widget and attaches it to the screen
void main() => runApp(const MyApp());

/// MyApp - The root widget of the application
/// This is a StatelessWidget that sets up the MaterialApp with all necessary configurations
/// StatelessWidget means this widget doesn't change over time - it's static
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// The build method is called whenever Flutter needs to render this widget
  /// It returns a MaterialApp which provides Material Design styling and navigation
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Remove the debug banner in the top-right corner (for production apps)
      debugShowCheckedModeBanner: false,

      // The title of the app (shown in task switcher on mobile)
      title: 'Job Sahi',

      // Use GoRouter for modern navigation with deep linking support
      // This provides better URL handling, deep linking, and navigation state management
      routerConfig: AppRouter.router,
    );
  }
}
