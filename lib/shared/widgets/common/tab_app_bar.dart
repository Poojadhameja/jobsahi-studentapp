import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

/// Tab App Bar Widget
/// A custom app bar for tab screens with back button and title
/// Used for screens accessed from bottom navigation
class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title to display in the app bar
  final String title;

  /// Callback function when back button is pressed
  final VoidCallback? onBackPressed;

  /// Background color of the app bar
  final Color? backgroundColor;

  /// Text color of the title
  final Color? titleColor;

  /// Optional actions to show on the right side
  final List<Widget>? actions;

  const TabAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.backgroundColor,
    this.titleColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          backgroundColor ??
          AppConstants.cardBackgroundColor, // Match home page background
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppConstants.textPrimaryColor,
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppConstants.textPrimaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: actions,
      iconTheme: const IconThemeData(color: AppConstants.textPrimaryColor),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
