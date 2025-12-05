import 'tab_navigation_manager.dart';

/// Helper class for navigation within tabs
class NavigationHelper {
  static final TabNavigationManager _navManager = TabNavigationManager.instance;

  /// Navigate to a route within current tab
  static void navigateTo(String route) {
    _navManager.navigateToRoute(route);
  }

  /// Navigate back within current tab
  static bool goBack() {
    return _navManager.handleBackNavigation();
  }

  /// Check if current tab has navigation history
  static bool hasHistory() {
    return _navManager.hasNavigationHistory();
  }

  /// Get current stack depth
  static int getStackDepth() {
    return _navManager.getCurrentStackDepth();
  }
}
