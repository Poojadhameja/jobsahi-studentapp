import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';

/// Custom App Bar Widget
/// A custom app bar with hamburger menu, search bar, and notification icon
/// Used specifically for the home screen
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Whether to show the search bar
  final bool showSearchBar;

  /// Whether to show the hamburger menu button
  final bool showMenuButton;

  /// Whether to show the notification icon
  final bool showNotificationIcon;

  /// Title to display
  final String? title;

  /// Custom title widget (takes precedence over title)
  final Widget? customTitle;

  /// Callback function when search is performed
  final Function(String)? onSearch;

  /// Callback function when notification icon is pressed
  final VoidCallback? onNotificationPressed;

  /// Background color of the app bar
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    this.showSearchBar = false,
    this.showMenuButton = false,
    this.showNotificationIcon = false,
    this.title,
    this.customTitle,
    this.onSearch,
    this.onNotificationPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          backgroundColor ??
          AppConstants.cardBackgroundColor, // Match home page background
      elevation: 0,
      toolbarHeight:
          kToolbarHeight + 16, // Add 16px total height (8px top + 8px bottom)
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
        ),
      ),
      leading: showMenuButton
          ? IconButton(
              icon: const Icon(
                Icons.menu,
                color: AppConstants.textPrimaryColor,
                size: 24,
              ),
              onPressed: () {
                // Navigate to main profile screen with personalized job feed and job status
                context.go(AppRoutes.profile);
              },
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 32, // Very compact width like bell icon
                minHeight: 32, // Very compact height like bell icon
              ),
            )
          : null,
      title:
          customTitle ??
          (showSearchBar
              ? _buildSearchBar()
              : (title != null ? Text(title!) : null)),
      centerTitle: customTitle == null && !showSearchBar,
      actions: showNotificationIcon
          ? [
              Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                ), // Add padding to actions
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppConstants.textPrimaryColor,
                  ),
                  onPressed: onNotificationPressed,
                ),
              ),
            ]
          : null,
      iconTheme: const IconThemeData(color: AppConstants.textPrimaryColor),
    );
  }

  /// Builds the search bar widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 8,
      ), // Add padding to search bar
      child: Container(
        height: 45, // Increased height from 40 to 45
        decoration: BoxDecoration(
          color:
              AppConstants.backgroundColor, // Light background for search bar
          borderRadius: BorderRadius.circular(
            22.5,
          ), // Adjusted border radius to match new height
          border: Border.all(color: AppConstants.borderColor, width: 1),
        ),
        child: TextField(
          onSubmitted: onSearch,
          decoration: const InputDecoration(
            hintText: 'नौकरी खोजें', // Hindi text for "Search jobs"
            hintStyle: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppConstants.textSecondaryColor,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ), // Increased vertical padding
          ),
          style: const TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16); // Added 16px for padding
}
