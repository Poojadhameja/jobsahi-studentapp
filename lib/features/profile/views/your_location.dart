/// Location Screen 1 - Your Location

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class YourLocationScreen extends StatelessWidget {
  const YourLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(const LoadProfileDataEvent()),
      child: const _YourLocationView(),
    );
  }
}

class _YourLocationView extends StatefulWidget {
  const _YourLocationView();

  @override
  State<_YourLocationView> createState() => _YourLocationViewState();
}

class _YourLocationViewState extends State<_YourLocationView> {
  /// Search controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with empty search query
    context.read<ProfileBloc>().add(
      const UpdateSearchQueryEvent(searchQuery: ''),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String? selectedLocation;
        List<Map<String, String>> filteredLocations = [];

        if (state is LocationState) {
          selectedLocation = state.selectedLocation;
          filteredLocations = state.filteredLocations;
        }

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
              onPressed: () => context.pop(),
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
                  _buildSearchBar(context),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Use current location option
                  _buildCurrentLocationOption(),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Search results header
                  if (filteredLocations.isNotEmpty) ...[
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
                  Expanded(
                    child: _buildLocationList(
                      context,
                      filteredLocations,
                      selectedLocation,
                    ),
                  ),

                  // Next button
                  _buildNextButton(context, selectedLocation),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the search bar
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<ProfileBloc>().add(
            UpdateSearchQueryEvent(searchQuery: value),
          );
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
              context.go(
                '${AppRoutes.locationPermission}?isFromCurrentLocation=true',
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
  Widget _buildLocationList(
    BuildContext context,
    List<Map<String, String>> filteredLocations,
    String? selectedLocation,
  ) {
    if (filteredLocations.isEmpty) {
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
      itemCount: filteredLocations.length,
      itemBuilder: (context, index) {
        final location = filteredLocations[index];
        final isSelected = selectedLocation == location['name'];

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
              context.read<ProfileBloc>().add(
                SelectLocationEvent(locationName: location['name']!),
              );
            },
          ),
        );
      },
    );
  }

  /// Builds the next button
  Widget _buildNextButton(BuildContext context, String? selectedLocation) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: selectedLocation != null
            ? () => _continueToNext(context)
            : null,
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
  void _continueToNext(BuildContext context) {
    // TODO: Save selected location
    // When selecting from search results, go directly to home (skip location permission page)
    context.go(AppRoutes.home);
  }
}
