export 'custom_app_bar.dart' show CustomAppBar;

/// Simple App Bar Widget
/// A basic app bar with title and optional back button
/// Used across multiple screens for consistent navigation

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import 'navigation_helper.dart';

/// Simple app bar with title and optional back button
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title to display in the app bar
  final String title;

  /// Whether to show a back button
  final bool showBackButton;

  /// Whether to show a close button instead of back button
  final bool showCloseButton;

  /// Optional actions to show on the right side
  final List<Widget>? actions;

  /// Background color of the app bar
  final Color? backgroundColor;

  /// Text color of the title
  final Color? titleColor;

  /// Whether to center the title
  final bool centerTitle;

  const SimpleAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showCloseButton = false,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppConstants.textPrimaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppConstants.backgroundColor,
      elevation: 0,
      leading: _buildLeadingButton(context),
      actions: actions,
      iconTheme: IconThemeData(
        color: titleColor ?? AppConstants.textPrimaryColor,
      ),
      titleTextStyle: TextStyle(
        color: titleColor ?? AppConstants.textPrimaryColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Builds the leading button (back or close)
  Widget? _buildLeadingButton(BuildContext context) {
    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _handleBackAction(context),
      );
    } else if (showCloseButton) {
      return IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => _handleBackAction(context),
      );
    }
    return null;
  }

  /// Handles navigation when back/close is pressed
  void _handleBackAction(BuildContext context) {
    var handled = false;

    if (NavigationHelper.hasHistory()) {
      handled = NavigationHelper.goBack();
    }

    if (handled) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// App bar with search functionality
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Controller for the search text field
  final TextEditingController searchController;

  /// Callback when search text changes
  final Function(String)? onSearchChanged;

  /// Callback when search is submitted
  final Function(String)? onSearchSubmitted;

  /// Hint text for the search field
  final String hintText;

  /// Whether to show a back button
  final bool showBackButton;

  const SearchAppBar({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.hintText = 'Search...',
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppConstants.backgroundColor,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            )
          : null,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: AppConstants.borderColor),
        ),
        child: TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          onSubmitted: onSearchSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          style: TextStyle(color: AppConstants.textPrimaryColor, fontSize: 14),
        ),
      ),
      actions: [
        if (searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchController.clear();
              if (onSearchChanged != null) {
                onSearchChanged!('');
              }
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
