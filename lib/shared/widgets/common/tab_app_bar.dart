import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';

/// Centralized App Bar for non-home tabs
/// Provides consistent title and back button functionality
class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const TabAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppConstants.cardBackgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: onBackPressed ?? () => context.go('/home'),
        icon: Icon(
          onBackPressed != null ? Icons.arrow_back : Icons.menu,
          color: AppConstants.primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppConstants.primaryColor,
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
