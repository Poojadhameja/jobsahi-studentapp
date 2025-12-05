import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

/// Custom Jobsahi green loader widget
/// Provides a consistent loading indicator with Jobsahi branding
class JobsahiLoader extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final String? message;
  final bool showMessage;

  const JobsahiLoader({
    super.key,
    this.size = 40.0,
    this.strokeWidth = 3.0,
    this.message,
    this.showMessage = false,
  });

  @override
  State<JobsahiLoader> createState() => _JobsahiLoaderState();
}

class _JobsahiLoaderState extends State<JobsahiLoader>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Rotation animation (continuous)
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Scale animation (pulse effect)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Start animations
    _rotationController.repeat();
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated loader
        AnimatedBuilder(
          animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CircularProgressIndicator(
                    color: AppConstants.secondaryColor, // Jobsahi green
                    strokeWidth: widget.strokeWidth,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppConstants.secondaryColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Optional message
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: const TextStyle(
              fontSize: 16,
              color: AppConstants.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Full screen overlay loader with Jobsahi branding
class JobsahiOverlayLoader extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const JobsahiOverlayLoader({super.key, this.message, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: JobsahiLoader(
            size: 50,
            strokeWidth: 4,
            message: message,
            showMessage: message != null,
          ),
        ),
      ),
    );
  }
}

/// Simple dialog loader with Jobsahi branding
class JobsahiDialogLoader {
  static void show({
    required BuildContext context,
    String? message,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: JobsahiOverlayLoader(
          message: message,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
