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
    3: ['/messages'], // Messages tab
    4: ['/profile'], // Profile tab
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
    print('🧭 Navigating to route: $route in tab $_currentTabIndex');
    print('📚 Current stack: $currentStack');

    // Prevent duplicate entries
    if (currentStack.isNotEmpty && currentStack.last == route) {
      print('⚠️ Duplicate route, skipping navigation');
      return;
    }

    // Add to current tab's stack
    currentStack.add(route);
    _tabStacks[_currentTabIndex] = currentStack;
    print('✅ Added to stack. New stack: $currentStack');

    // Navigate using GoRouter
    AppRouter.go(route);
    notifyListeners();
  }

  /// Switch to a tab (used when bottom nav is tapped)
  void switchToTab(int tabIndex) {
    print('🔄 Switching from tab $_currentTabIndex to tab $tabIndex');

    if (tabIndex == _currentTabIndex) {
      // Same tab - no action needed
      print('✅ Same tab, no action needed');
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
    print('🎯 Navigating to default route: $defaultRoute');
    print('📚 Tab history: $_tabHistory');

    // Navigate to the default route
    AppRouter.go(defaultRoute);
  }

  /// Handle back navigation
  bool handleBackNavigation() {
    final currentStack = _tabStacks[_currentTabIndex] ?? [];
    print('🔙 Handling back navigation for tab $_currentTabIndex');
    print('📚 Current stack: $currentStack');
    print('📚 Tab history: $_tabHistory');

    if (currentStack.length > 1) {
      // Remove current route and go to previous route in stack
      currentStack.removeLast();
      final previousRoute = currentStack.last;
      _tabStacks[_currentTabIndex] = currentStack;
      print('⬅️ Going back to: $previousRoute');
      print('📚 New stack: $currentStack');

      AppRouter.go(previousRoute);
      return true; // Handled the back navigation
    } else {
      // If stack is empty, go to previous tab from history
      if (_tabHistory.isNotEmpty) {
        // Get the last tab from history (previous tab)
        final previousTab = _tabHistory.last;

        // Remove it from history so next back goes to tab before that
        _tabHistory.removeLast();

        print('🔄 Switching to previous tab from history: $previousTab');
        _currentTabIndex = previousTab;
        final defaultRoute = _getDefaultRouteForTab(previousTab);
        AppRouter.go(defaultRoute);
        notifyListeners();
        return true;
      } else if (_currentTabIndex != 0) {
        // If no history or already on home, go to home
        print('🏠 Going to home tab');
        _currentTabIndex = 0;
        AppRouter.go('/home');
        notifyListeners();
        return true;
      }
    }

    print('❌ Let system handle back (close app)');
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
        return '/messages';
      case 4:
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
    print('🧹 Cleared tab history');
  }

  /// Get tab history for debugging
  List<int> get tabHistory => List.from(_tabHistory);
}
