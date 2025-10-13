import 'package:flutter/material.dart';

/// Keyboard Dismiss Wrapper Widget
/// A reusable widget that automatically dismisses the keyboard when the user taps
/// anywhere outside a TextField. This wrapper preserves scrollable widget behavior
/// and doesn't interfere with existing GestureDetectors.
class KeyboardDismissWrapper extends StatelessWidget {
  /// The child widget to wrap
  final Widget child;

  /// Whether to enable keyboard dismissal (default: true)
  final bool enableKeyboardDismiss;

  const KeyboardDismissWrapper({
    super.key,
    required this.child,
    this.enableKeyboardDismiss = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableKeyboardDismiss) {
      return child;
    }

    return GestureDetector(
      // Dismiss keyboard when tapping on empty space
      onTap: () {
        // Unfocus any focused text field to dismiss keyboard
        FocusScope.of(context).unfocus();
      },
      // Allow the child to handle its own gestures
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
