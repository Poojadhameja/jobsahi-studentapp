import 'package:flutter/material.dart';
import 'utils/navigation_service.dart';

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
    return MaterialApp(
      // Remove the debug banner in the top-right corner (for production apps)
      debugShowCheckedModeBanner: false,

      // The title of the app (shown in task switcher on mobile)
      title: 'Job Sahi',

      // Use the NavigationService navigator key for global navigation
      // This allows us to navigate from anywhere in the app, even outside widgets
      navigatorKey: NavigationService.navigatorKey,

      // Use the RouteGenerator for named routes
      // This handles all the navigation between different screens
      onGenerateRoute: RouteGenerator.generateRoute,

      // Set initial route to the splash screen
      // This is the first screen users see when they open the app
      initialRoute: RouteNames.splash,
    );
  }
}
