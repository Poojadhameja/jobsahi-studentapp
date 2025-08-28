import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

class NotificationPermissionPage extends StatelessWidget {
  const NotificationPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top dark gray bar (status bar area)
          Container(height: 4, color: const Color(0xFF424242)),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Illustration
                  _buildIllustration(),

                  const SizedBox(height: AppConstants.largePadding * 2),

                  // Main Question
                  Text(
                    'Do you want to turn on notification?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Descriptive Text in Hindi
                  Text(
                    'नोटिफिकेशन चालू करें ताकि आपको अपनी नौकरी की खोज से जुड़ी ज़रूरी जानकारी सीधे अपने फ़ोन पर मिल सके',
                    style: AppConstants.bodyStyle.copyWith(
                      color: const Color(0xFF666666),
                      height: 1.6,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppConstants.largePadding * 2),

                  // Allow Notifications Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle notification permission
                        _requestNotificationPermission(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.secondaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Allow Notifications',
                        style: AppConstants.buttonTextStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // SKIP Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle skip action
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.secondaryColor,
                        side: BorderSide(
                          color: AppConstants.secondaryColor,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        'SKIP',
                        style: AppConstants.buttonTextStyle.copyWith(
                          color: AppConstants.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Megaphone base
          Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: AppConstants.secondaryColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),

          // Megaphone handle
          Positioned(
            right: 40,
            bottom: 20,
            child: Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: AppConstants.secondaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Sound waves
          Positioned(
            left: 20,
            top: 30,
            child: Row(
              children: [
                _buildSoundWave(20, 0.3),
                const SizedBox(width: 8),
                _buildSoundWave(25, 0.5),
                const SizedBox(width: 8),
                _buildSoundWave(30, 0.7),
              ],
            ),
          ),

          // Speech bubble with dots
          Positioned(
            top: 10,
            right: 30,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.secondaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDot(),
                  const SizedBox(width: 4),
                  _buildDot(),
                  const SizedBox(width: 4),
                  _buildDot(),
                ],
              ),
            ),
          ),

          // Bell icon
          Positioned(
            right: 20,
            top: 60,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[600],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.notifications, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundWave(double height, double opacity) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: AppConstants.secondaryColor.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  void _requestNotificationPermission(BuildContext context) {
    // Show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notifications enabled successfully!'),
        backgroundColor: AppConstants.secondaryColor,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}
