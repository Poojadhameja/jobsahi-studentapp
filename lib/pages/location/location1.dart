/// Location Screen 1

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import 'location2.dart';

class Location1Screen extends StatefulWidget {
  const Location1Screen({super.key});

  @override
  State<Location1Screen> createState() => _Location1ScreenState();
}

class _Location1ScreenState extends State<Location1Screen> {
  /// Selected location
  String? _selectedLocation;

  /// List of available locations
  final List<String> _locations = [
    'Mumbai, Maharashtra',
    'Delhi, NCR',
    'Bangalore, Karnataka',
    'Pune, Maharashtra',
    'Chennai, Tamil Nadu',
    'Hyderabad, Telangana',
    'Kolkata, West Bengal',
    'Ahmedabad, Gujarat',
    'Nashik, Maharashtra',
    'Nagpur, Maharashtra',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(
        title: 'Select Location',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Location list
              Expanded(
                child: _buildLocationList(),
              ),
              
              // Continue button
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Where would you like to work?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        const Text(
          'Select your preferred work location. You can change this later in your profile settings.',
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondaryColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Builds the location list
  Widget _buildLocationList() {
    return ListView.builder(
      itemCount: _locations.length,
      itemBuilder: (context, index) {
        final location = _locations[index];
        final isSelected = _selectedLocation == location;
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            side: BorderSide(
              color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            leading: Icon(
              Icons.location_on,
              color: isSelected ? AppConstants.primaryColor : AppConstants.textSecondaryColor,
            ),
            title: Text(
              location,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppConstants.primaryColor : AppConstants.textPrimaryColor,
              ),
            ),
            trailing: isSelected
                ? const Icon(
                    Icons.check_circle,
                    color: AppConstants.primaryColor,
                  )
                : null,
            onTap: () {
              setState(() {
                _selectedLocation = location;
              });
            },
          ),
        );
      },
    );
  }

  /// Builds the continue button
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedLocation != null ? _continueToNext : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Continues to the next screen
  void _continueToNext() {
    if (_selectedLocation != null) {
      // TODO: Save selected location
      NavigationService.smartNavigate(destination: const Location2Screen());
    }
  }
}
