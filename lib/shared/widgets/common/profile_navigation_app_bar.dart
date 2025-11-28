import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';

/// Profile Navigation App Bar Widget
/// A custom app bar for pages opened from profile navigation
/// Shows a back button that navigates back to profile
class ProfileNavigationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Title to be displayed in the app bar
  final String title;

  /// Background color of the app bar
  final Color backgroundColor;

  /// Text color of the title
  final Color textColor;

  /// Whether to show the back button (default: true)
  final bool showBackButton;

  /// Optional actions to show on the right side
  final List<Widget>? actions;

  const ProfileNavigationAppBar({
    super.key,
    required this.title,
    this.backgroundColor = AppConstants.cardBackgroundColor,
    this.textColor = AppConstants.textPrimaryColor,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0, // Prevent color change on scroll
      surfaceTintColor: Colors.transparent, // Prevent tint on scroll
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () {
                // Navigate back to profile menu
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.profile);
                }
              },
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
