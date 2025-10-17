import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/router/app_router.dart';
import 'bottom_navigation.dart';
import 'tab_navigation_manager.dart';
import 'custom_app_bar.dart';
import 'tab_app_bar.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late TabNavigationManager _navigationManager;

  @override
  void initState() {
    super.initState();
    _navigationManager = TabNavigationManager.instance;
    _navigationManager.addListener(_onNavigationChanged);
  }

  @override
  void dispose() {
    _navigationManager.removeListener(_onNavigationChanged);
    super.dispose();
  }

  void _onNavigationChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current location to determine active tab
    final String location = GoRouterState.of(context).uri.path;
    final int currentIndex = _getCurrentIndex(location);

    // Update navigation manager's current tab only if different
    if (_navigationManager.currentTabIndex != currentIndex) {
      _navigationManager.setCurrentTab(currentIndex);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPress(context, currentIndex);
        }
      },
      child: Scaffold(
        backgroundColor: AppConstants.cardBackgroundColor,
        appBar: _buildAppBar(_navigationManager.currentTabIndex),
        body: widget.child,
        bottomNavigationBar: CustomBottomNavigation(
          currentIndex: _navigationManager.currentTabIndex,
          onTap: (index) => _onTabSelected(context, index),
        ),
      ),
    );
  }

  /// Build appropriate app bar based on current tab
  PreferredSizeWidget? _buildAppBar(int currentIndex) {
    switch (currentIndex) {
      case 0:
        // Home tab - show hamburger menu, search, and notification
        return CustomAppBar(
          showSearchBar: true,
          showMenuButton: true,
          showNotificationIcon: true,
          onSearch: _onSearch,
          onNotificationPressed: _onNotificationPressed,
        );
      case 1:
        // Learning tab - show title with back button
        return TabAppBar(
          title: 'Learning Center',
          onBackPressed: () => _handleBackPress(context, currentIndex),
        );
      case 2:
        // Application Tracker tab - show title with back button
        return TabAppBar(
          title: 'Application Tracker',
          onBackPressed: () => _handleBackPress(context, currentIndex),
        );
      case 3:
        // Messages tab - show title with back button
        return TabAppBar(
          title: 'Messages',
          onBackPressed: () => _handleBackPress(context, currentIndex),
        );
      case 4:
        // Profile tab - show title with back button
        return TabAppBar(
          title: 'Profile Details',
          onBackPressed: () => _handleBackPress(context, currentIndex),
        );
      default:
        return null;
    }
  }

  /// Get current tab index based on route path
  int _getCurrentIndex(String path) {
    int index = 0;
    if (path.startsWith('/home'))
      index = 0;
    else if (path.startsWith('/learning'))
      index = 1;
    else if (path.startsWith('/application-tracker'))
      index = 2;
    else if (path.startsWith('/messages'))
      index = 3;
    else if (path.startsWith('/profile'))
      index = 4;
    else
      index = 0; // Default to home

    print('📍 Path: $path -> Tab Index: $index');
    return index;
  }

  /// Handle tab selection with stack navigation
  void _onTabSelected(BuildContext context, int index) {
    _navigationManager.switchToTab(index);
  }

  /// Handle back press with stack navigation logic
  void _handleBackPress(BuildContext context, int currentIndex) {
    final handled = _navigationManager.handleBackNavigation();

    if (!handled && currentIndex == 0) {
      // On home tab and no navigation history - show exit confirmation
      _showExitConfirmation(context);
    }
  }

  /// Show exit confirmation dialog
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  /// Handle search functionality
  static void _onSearch(String query) {
    // Navigate to search results screen
    AppRouter.push('/jobs/search?query=${Uri.encodeComponent(query)}');
  }

  /// Handle notification icon tap
  void _onNotificationPressed() {
    context.push('/settings/notifications');
  }
}
