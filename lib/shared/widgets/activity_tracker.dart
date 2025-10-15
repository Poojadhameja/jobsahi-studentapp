import 'package:flutter/material.dart';
import '../services/inactivity_service.dart';

/// A widget that tracks user activity and updates the last active timestamp
/// Wrap any screen or widget with this to automatically track user interactions
class ActivityTracker extends StatefulWidget {
  final Widget child;
  final bool enableTouchTracking;
  final bool enableScrollTracking;

  const ActivityTracker({
    super.key,
    required this.child,
    this.enableTouchTracking = true,
    this.enableScrollTracking = true,
  });

  @override
  State<ActivityTracker> createState() => _ActivityTrackerState();
}

class _ActivityTrackerState extends State<ActivityTracker> {
  @override
  Widget build(BuildContext context) {
    Widget trackedChild = widget.child;

    // Add touch tracking if enabled
    if (widget.enableTouchTracking) {
      trackedChild = GestureDetector(
        onTap: () => _updateActivity(),
        onScaleStart: (_) => _updateActivity(),
        child: trackedChild,
      );
    }

    // Add scroll tracking if enabled
    if (widget.enableScrollTracking) {
      trackedChild = NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            _updateActivity();
          }
          return false;
        },
        child: trackedChild,
      );
    }

    return trackedChild;
  }

  /// Update the last active timestamp
  void _updateActivity() {
    InactivityService.instance.updateLastActive();
  }
}

/// A mixin that provides activity tracking functionality to any widget
mixin ActivityTrackingMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    // Update activity when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InactivityService.instance.updateLastActive();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update activity when dependencies change (e.g., screen navigation)
    InactivityService.instance.updateLastActive();
  }

  /// Manually update activity - can be called from buttons, form submissions, etc.
  void updateActivity() {
    InactivityService.instance.updateLastActive();
  }
}

/// A helper function to wrap any widget with activity tracking
Widget withActivityTracking(Widget child) {
  return ActivityTracker(child: child);
}
