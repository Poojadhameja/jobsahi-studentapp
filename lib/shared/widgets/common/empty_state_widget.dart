/// Reusable Empty State Widget
/// Can be used across different sections when no data is found

import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

class EmptyStateWidget extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Main title text
  final String title;

  /// Subtitle text
  final String subtitle;

  /// Size of the icon
  final double iconSize;

  /// Optional action button
  final Widget? actionButton;

  /// Custom padding
  final EdgeInsets padding;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.search_off,
    required this.title,
    required this.subtitle,
    this.iconSize = 80,
    this.actionButton,
    this.padding = const EdgeInsets.all(AppConstants.largePadding),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: AppConstants.textSecondaryColor),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              subtitle,
              style: const TextStyle(color: AppConstants.textSecondaryColor),
              textAlign: TextAlign.center,
            ),
            if (actionButton != null) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}
