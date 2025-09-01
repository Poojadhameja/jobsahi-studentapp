import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../pages/profile/profile.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title to be displayed in the app bar
  final String? title;

  /// Whether to show the search bar (default: true)
  final bool showSearchBar;

  /// Whether to show the back button (default: false)
  final bool showBackButton;

  /// Whether to show the menu button (default: true)
  final bool showMenuButton;

  /// Whether to show the notification icon (default: true)
  final bool showNotificationIcon;

  /// Whether to show the bookmark icon (default: false)
  final bool showBookmarkIcon;

  /// Callback function when search is performed
  final Function(String)? onSearch;

  /// Callback function when back button is pressed
  final VoidCallback? onBackPressed;

  /// Callback function when menu button is pressed
  final VoidCallback? onMenuPressed;

  /// Callback function when notification icon is pressed
  final VoidCallback? onNotificationPressed;

  /// Callback function when bookmark icon is pressed
  final VoidCallback? onBookmarkPressed;

  /// Search hint text
  final String searchHint;

  const CustomAppBar({
    super.key,
    this.title,
    this.showSearchBar = true,
    this.showBackButton = false,
    this.showMenuButton = true,
    this.showNotificationIcon = true,
    this.showBookmarkIcon = false,
    this.onSearch,
    this.onBackPressed,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.onBookmarkPressed,
    this.searchHint = AppConstants.searchPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppConstants.cardBackgroundColor,
      elevation: 1,
      titleSpacing: 0,
      leading: _buildLeadingWidget(),
      title: _buildTitleWidget(),
      actions: _buildActionWidgets(),
    );
  }

  /// Builds the leading widget (back button or menu button)
  Widget? _buildLeadingWidget() {
    if (showBackButton) {
      return IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppConstants.textPrimaryColor,
        ),
        onPressed: onBackPressed ?? () {},
      );
    } else if (showMenuButton) {
      return IconButton(
        icon: const Icon(Icons.menu, color: AppConstants.textPrimaryColor),
        onPressed:
            onMenuPressed ??
            () {
              // Navigate to profile page when hamburger menu is tapped
              NavigationService.smartNavigate(
                destination: const ProfileScreen(),
              );
            },
      );
    }
    return null;
  }

  /// Builds the title widget (search bar or title text)
  Widget _buildTitleWidget() {
    if (showSearchBar) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: _buildSearchBar(),
      );
    } else if (title != null) {
      return Text(
        title!,
        style: const TextStyle(color: AppConstants.textPrimaryColor),
      );
    }
    return const SizedBox.shrink();
  }

  /// Builds the search bar widget
  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: searchHint,
        prefixIcon: const Icon(
          Icons.search,
          color: AppConstants.textPrimaryColor,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      onSubmitted: onSearch,
    );
  }

  /// Builds the action widgets (notification and bookmark icons)
  List<Widget> _buildActionWidgets() {
    final actions = <Widget>[];

    // Add bookmark icon if needed
    if (showBookmarkIcon) {
      actions.add(
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: const Icon(
              Icons.bookmark_border,
              color: AppConstants.textPrimaryColor,
            ),
            onPressed: onBookmarkPressed ?? () {},
          ),
        ),
      );
    }

    // Add notification icon if needed
    if (showNotificationIcon) {
      actions.add(
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: AppConstants.textPrimaryColor,
            ),
            onPressed: onNotificationPressed,
          ),
        ),
      );
    }

    return actions;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Tab App Bar Widget
/// A simple app bar for tabs with heading and back icon
/// Used for courses, applications, messages, and profile tabs
/// Note: onBackPressed callback is required for proper navigation
class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title to be displayed in the app bar
  final String title;

  /// Callback function when back button is pressed (required)
  final VoidCallback onBackPressed;

  /// Background color of the app bar
  final Color backgroundColor;

  /// Text color of the title
  final Color textColor;

  const TabAppBar({
    super.key,
    required this.title,
    required this.onBackPressed,
    this.backgroundColor = AppConstants.cardBackgroundColor,
    this.textColor = AppConstants.textPrimaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: textColor),
        onPressed: onBackPressed,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
