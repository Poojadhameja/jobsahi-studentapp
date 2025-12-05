import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

/// Custom top snackbar with close button and compact design
class TopSnackBar {
  /// Show top snackbar using Overlay
  static OverlayEntry? _currentOverlay;
  static Timer? _countdownTimer;
  static ValueNotifier<int>? _remainingSeconds;

  static void show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 5),
  }) {
    // Remove existing overlay if any
    hide(context);

    final overlayState = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final totalSeconds = duration.inSeconds;

    // Initialize countdown
    _remainingSeconds = ValueNotifier<int>(totalSeconds);

    _currentOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: topPadding + 8,
          left: 16,
          right: 16,
          child: SafeArea(
            bottom: false,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, -50 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 0.0),
                  duration: duration,
                  curve: Curves.linear,
                  builder: (context, progress, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: backgroundColor.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Main content
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Icon in colored circle
                                  if (icon != null) ...[
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: backgroundColor.withValues(
                                          alpha: 0.15,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        icon,
                                        color: backgroundColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  // Message text
                                  Expanded(
                                    child: Text(
                                      message,
                                      style: const TextStyle(
                                        color: Color(0xFF1A1A1A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Close button (no background)
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => hide(context),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: Colors.grey.shade600,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Smooth animated progress bar at bottom
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Background (full width)
                                    Container(
                                      width: double.infinity,
                                      color: Colors.grey.withValues(alpha: 0.1),
                                    ),
                                    // Smooth progress bar (decreasing continuously)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: progress.clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: backgroundColor,
                                            borderRadius:
                                                const BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    16,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    16,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(_currentOverlay!);

    // Start countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds != null) {
        _remainingSeconds!.value--;
        if (_remainingSeconds!.value <= 0) {
          timer.cancel();
          hide(context);
        }
      }
    });

    // Auto hide after duration (backup)
    Timer(duration, () {
      hide(context);
    });
  }

  /// Hide current overlay
  static void hide(BuildContext context) {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _remainingSeconds?.dispose();
    _remainingSeconds = null;
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }
  }

  /// Show success snackbar at top
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 5),
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppConstants.successColor,
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  /// Show error snackbar at top
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 5),
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppConstants.errorColor,
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  /// Show info snackbar at top
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 5),
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppConstants.primaryColor,
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  /// Show GPS/location warning snackbar at top
  static void showGPSWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 5),
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppConstants.errorColor,
      icon: Icons.location_off_outlined,
      duration: duration,
    );
  }
}
