import 'package:flutter/material.dart';
import 'enhanced_profile_details.dart';

/// ---------------- PROFILE DETAILS SCREEN ---------------- 
/// This screen now uses EnhancedProfileDetailsScreen for all functionality
class ProfileDetailsScreen extends StatelessWidget {
  final bool isFromBottomNavigation;

  const ProfileDetailsScreen({super.key, this.isFromBottomNavigation = false});

  @override
  Widget build(BuildContext context) {
    // Use the enhanced profile details screen
    return EnhancedProfileDetailsScreen(
      isFromBottomNavigation: isFromBottomNavigation,
    );
  }
}
