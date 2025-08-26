/// Location Screen 1 - Your Location

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';

class YourLocationScreen extends StatefulWidget {
  const YourLocationScreen({super.key});

  @override
  State<YourLocationScreen> createState() => _YourLocationScreenState();
}

class _YourLocationScreenState extends State<YourLocationScreen> {
  /// Selected location
  String? _selectedLocation;

  /// Search controller
  final TextEditingController _searchController = TextEditingController();

  /// Search query
  String _searchQuery = '';

  /// List of available locations
  final List<Map<String, String>> _locations = [
    {
      'name': 'Baker Street Library',
      'address': '221B Baker Street London, NW1 6XE United Kingdom',
    },
    {
      'name': 'The Greenfield Mall',
      'address': '45 High Street Greenfield, Manchester, M1 2AB United Kingdom',
    },
    {
      'name': 'Riverbank Business Park',
      'address': 'Unit 12, Riverside Drive Bristol, BS1 5RT United Kingdom',
    },
    {
      'name': 'Elmwood Community Centre',
      'address': '78 Elmwood Avenue Birmingham, B12 3DF United Kingdom',
    },
  ];

  /// Filtered locations based on search
  List<Map<String, String>> get _filteredLocations {
    if (_searchQuery.isEmpty) {
      return _locations;
    }
    return _locations.where((location) {
      return location['name']!.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          location['address']!.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppConstants.textPrimaryColor,
          ),
          onPressed: () => NavigationService.goBack(),
        ),
        title: Text(
          AppConstants.yourLocationTitle,
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              _buildSearchBar(),
              const SizedBox(height: AppConstants.defaultPadding),

              // Use current location option
              _buildCurrentLocationOption(),
              const SizedBox(height: AppConstants.defaultPadding),

              // Search results header
              if (_filteredLocations.isNotEmpty) ...[
                Text(
                  AppConstants.searchResultLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
              ],

              // Location list
              Expanded(child: _buildLocationList()),

              // Next button
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the search bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: AppConstants.searchAreaHint,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
        ),
      ),
    );
  }

  /// Builds the current location option
  Widget _buildCurrentLocationOption() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.my_location,
              color: AppConstants.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Text(
              AppConstants.useCurrentLocation,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate directly to location2 (permission page) when using current location
              NavigationService.smartNavigate(
                routeName: RouteNames.location2,
                arguments: {'isFromCurrentLocation': true},
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide(color: AppConstants.secondaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.smallBorderRadius,
                ),
              ),
            ),
            child: Text(
              AppConstants.selectButton,
              style: TextStyle(
                color: AppConstants.secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the location list
  Widget _buildLocationList() {
    if (_filteredLocations.isEmpty) {
      return const Center(
        child: Text(
          'No locations found',
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredLocations.length,
      itemBuilder: (context, index) {
        final location = _filteredLocations[index];
        final isSelected = _selectedLocation == location['name'];

        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
            ),
          ),
          child: ListTile(
            leading: Icon(
              Icons.location_on,
              color: Colors.blue.shade600,
              size: 24,
            ),
            title: Text(
              location['name']!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            subtitle: Text(
              location['address']!,
              style: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedLocation = location['name'];
              });
            },
          ),
        );
      },
    );
  }

  /// Builds the next button
  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedLocation != null ? _continueToNext : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 0,
        ),
        child: Text(
          AppConstants.nextButton,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  /// Continues to the next screen
  void _continueToNext() {
    if (_selectedLocation != null) {
      // TODO: Save selected location
      // When selecting from search results, go directly to home (skip location permission page)
      NavigationService.smartNavigate(routeName: RouteNames.home);
    }
  }
}
