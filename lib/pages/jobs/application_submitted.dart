import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import '../home/home.dart';
import 'app_tracker1.dart';

class ApplicationSubmittedScreen extends StatefulWidget {
  const ApplicationSubmittedScreen({super.key});

  @override
  State<ApplicationSubmittedScreen> createState() =>
      _ApplicationSubmittedScreenState();
}

class _ApplicationSubmittedScreenState
    extends State<ApplicationSubmittedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SimpleAppBar(
        title: 'Application Submitted',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main icon with document and checkmark
              _buildMainIcon(),
              const SizedBox(height: AppConstants.largePadding),

              // Success heading
              _buildSuccessHeading(),
              const SizedBox(height: AppConstants.defaultPadding),

              // Hindi text
              _buildHindiText(),
              const SizedBox(height: AppConstants.largePadding),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the main icon with document and checkmark
  Widget _buildMainIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Light blue background shape
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD).withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),

        // Document icon
        Container(
          width: 100,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Document header
              Container(
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
              // Document lines
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: List.generate(
                      5,
                      (index) => Container(
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Green checkmark circle
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppConstants.successColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  /// Builds the success heading
  Widget _buildSuccessHeading() {
    return const Text(
      'Application Submitted!',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E3A8A), // Dark blue color
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds the Hindi text section
  Widget _buildHindiText() {
    return const Text(
      'आपका आवेदन L&T Construction में Electrician के पद के लिए सफलतापूर्वक भेज दिया गया है।',
      style: TextStyle(
        fontSize: 16,
        color: Color(0xFF64748B), // Light blue/grey color
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds the action buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Track Application button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _trackApplication,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Track Application',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Take Test button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _takeTest,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.successColor,
              side: const BorderSide(
                color: AppConstants.successColor,
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Take Test',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// Handles track application button press
  void _trackApplication() {
    // Navigate to AppTracker1 page
    NavigationService.smartNavigate(destination: const AppTracker1Screen());
  }

  /// Handles take test button press
  void _takeTest() {
    // Navigate to home screen
    NavigationService.smartNavigate(destination: const HomeScreen());
  }
}
