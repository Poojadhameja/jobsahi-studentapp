import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

class CustomBottomNavigation extends StatelessWidget {
  /// Currently selected index
  final int currentIndex;

  /// Callback function when a tab is selected
  final Function(int) onTap;

  /// Whether to show unselected labels (default: true)
  final bool showUnselectedLabels;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showUnselectedLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppConstants.cardBackgroundColor,
      selectedItemColor: AppConstants.bottomNavActiveColor,
      unselectedItemColor: AppConstants.bottomNavInactiveColor,
      showUnselectedLabels: showUnselectedLabels,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      items: _buildNavigationItems(),
    );
  }

  /// Builds the navigation items for the bottom navigation bar
  List<BottomNavigationBarItem> _buildNavigationItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(currentIndex == 0 ? Icons.home : Icons.home_outlined),
        label: AppConstants.homeLabel,
      ),
      BottomNavigationBarItem(
        icon: Icon(currentIndex == 1 ? Icons.school : Icons.school_outlined),
        label: AppConstants.coursesLabel,
      ),
      BottomNavigationBarItem(
        icon: Icon(
          currentIndex == 2 ? Icons.assignment : Icons.assignment_outlined,
        ),
        label: AppConstants.applicationsLabel,
      ),
      BottomNavigationBarItem(
        icon: Icon(currentIndex == 3 ? Icons.person : Icons.person_outline),
        label: AppConstants.profileLabel,
      ),
    ];
  }
}

/// Bottom Navigation with Screens Widget
/// A complete bottom navigation setup with screen management
class BottomNavigationWithScreens extends StatefulWidget {
  /// List of screens to be displayed
  final List<Widget> screens;

  /// Initial selected index (default: 0)
  final int initialIndex;

  const BottomNavigationWithScreens({
    super.key,
    required this.screens,
    this.initialIndex = 0,
  });

  @override
  State<BottomNavigationWithScreens> createState() =>
      _BottomNavigationWithScreensState();
}

class _BottomNavigationWithScreensState
    extends State<BottomNavigationWithScreens> {
  /// Currently selected index
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  /// Handles tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      body: widget.screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
