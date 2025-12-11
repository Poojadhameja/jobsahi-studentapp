import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';

/// Manages navigation stacks for each tab
/// Prevents duplicate entries and handles back navigation
class TabNavigationManager extends ChangeNotifier {
  static final TabNavigationManager _instance =
      TabNavigationManager._internal();
  static TabNavigationManager get instance => _instance;

  TabNavigationManager._internal();

  // Navigation stacks for each tab
  final Map<int, List<String>> _tabStacks = {
    0: ['/home'], // Home tab
    1: ['/learning'], // Learning tab
    2: ['/application-tracker'], // Application Tracker tab
    3: ['/profile'], // Profile tab
  };

  /// Tab visit history for back navigation
  final List<int> _tabHistory = [0]; // Start with home tab

  /// Current active tab index
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  /// Set current tab index
  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  /// Navigate to a route within current tab
  void navigateToRoute(String route) {
    final currentStack = _tabStacks[_currentTabIndex] ?? [];

    // Check if this route is already in the stack (not just the last one)
    // If it's the last route, allow navigation to refresh the page
    // Only skip if we're already on this exact route AND it's the last route
    if (currentStack.isNotEmpty && currentStack.last == route) {
      // Allow navigation to same route to refresh/reload
      // Still navigate to refresh the page
      AppRouter.go(route);
      notifyListeners();
      return;
    }

    // Add to current tab's stack
    currentStack.add(route);
    _tabStacks[_currentTabIndex] = currentStack;

    // Navigate using GoRouter
    AppRouter.go(route);
    notifyListeners();
  }

  /// Switch to a tab (used when bottom nav is tapped)
  void switchToTab(int tabIndex) {
    if (tabIndex == _currentTabIndex) {
      // Same tab - no action needed
      return;
    }

    // Add current tab to history (always add to track sequence)
    _tabHistory.add(_currentTabIndex);

    // Keep history limited to last 5 tabs to avoid memory issues
    if (_tabHistory.length > 5) {
      _tabHistory.removeAt(0);
    }

    // Update current tab immediately for UI responsiveness
    _currentTabIndex = tabIndex;
    notifyListeners();

    // Get the default route for this tab
    final defaultRoute = _getDefaultRouteForTab(tabIndex);

    // Navigate to the default route
    AppRouter.go(defaultRoute);
  }

  /// Handle back navigation
  bool handleBackNavigation() {
    final currentStack = _tabStacks[_currentTabIndex] ?? [];

    if (currentStack.length > 1) {
      // Remove current route and go to previous route in stack
      currentStack.removeLast();
      final previousRoute = currentStack.last;
      _tabStacks[_currentTabIndex] = currentStack;

      AppRouter.go(previousRoute);
      return true; // Handled the back navigation
    } else {
      // If stack is empty, go to previous tab from history
      if (_tabHistory.isNotEmpty) {
        // Get the last tab from history (previous tab)
        final previousTab = _tabHistory.last;

        // Remove it from history so next back goes to tab before that
        _tabHistory.removeLast();

        _currentTabIndex = previousTab;
        final defaultRoute = _getDefaultRouteForTab(previousTab);
        AppRouter.go(defaultRoute);
        notifyListeners();
        return true;
      } else if (_currentTabIndex != 0) {
        // If no history or already on home, go to home
        _currentTabIndex = 0;
        AppRouter.go('/home');
        notifyListeners();
        return true;
      }
    }

    return false; // Let system handle back (close app)
  }

  /// Get current route for tab
  String getCurrentRouteForTab(int tabIndex) {
    final stack = _tabStacks[tabIndex] ?? [];
    return stack.isNotEmpty ? stack.last : _getDefaultRouteForTab(tabIndex);
  }

  /// Get default route for tab
  String _getDefaultRouteForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return '/home';
      case 1:
        return '/learning';
      case 2:
        return '/application-tracker';
      case 3:
        return '/profile';
      default:
        return '/home';
    }
  }

  /// Clear stack for a specific tab
  void clearStackForTab(int tabIndex) {
    _tabStacks[tabIndex] = [_getDefaultRouteForTab(tabIndex)];
    notifyListeners();
  }

  /// Get stack depth for current tab
  int getCurrentStackDepth() {
    final currentStack = _tabStacks[_currentTabIndex] ?? [];
    return currentStack.length;
  }

  /// Check if current tab has navigation history
  bool hasNavigationHistory() {
    return getCurrentStackDepth() > 1;
  }

  /// Clear tab history (useful for resetting navigation)
  void clearTabHistory() {
    _tabHistory.clear();
    _tabHistory.add(0); // Always start with home
  }

  /// Get tab history for debugging
  List<int> get tabHistory => List.from(_tabHistory);
}
