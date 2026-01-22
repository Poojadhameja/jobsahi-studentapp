import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/network_error_helper.dart';
import '../../../shared/data/user_data.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../../../shared/widgets/common/top_snackbar.dart';
import '../../../shared/widgets/loaders/jobsahi_loader.dart';
import '../../../shared/widgets/profile/profile_header_card.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/services/profile_cache_service.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with WidgetsBindingObserver {
  final ProfileCacheService _cacheService = ProfileCacheService.instance;
  ProfileDetailsLoaded? _cachedProfileState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize cache and load profile data when menu opens
    // This ensures blue profile section shows cached data immediately and updates
    _initializeCacheAndLoadProfile();
  }

  /// Initialize cache service and load profile data
  Future<void> _initializeCacheAndLoadProfile() async {
    try {
      // Initialize cache service
      await _cacheService.initialize();
      
      // Check if cache is available and valid
      final isCacheValid = await _cacheService.isCacheValid(maxAgeHours: 24);
      if (isCacheValid) {
        final cachedData = await _cacheService.getProfileData();
        if (cachedData != null && cachedData.isNotEmpty && mounted) {
          // Create cached state from cache data
          _cachedProfileState = ProfileDetailsLoaded(
            userProfile: Map<String, dynamic>.from(
              cachedData['userProfile'] ?? {},
            ),
            skills: List<String>.from(cachedData['skills'] ?? []),
            education: List<Map<String, dynamic>>.from(
              cachedData['education'] ?? [],
            ),
            experience: List<Map<String, dynamic>>.from(
              cachedData['experience'] ?? [],
            ),
            jobPreferences: Map<String, dynamic>.from(
              cachedData['jobPreferences'] ?? {},
            ),
            sectionExpansionStates: {
              'profile': false,
              'summary': false,
              'education': false,
              'skills': false,
              'experience': false,
              'resume': false,
              'certificates': false,
              'contact': false,
              'general_info': false,
              'social': false,
            },
            certificates: List<Map<String, dynamic>>.from(
              cachedData['certificates'] ?? [],
            ),
            profileImagePath: cachedData['profileImagePath'],
            profileImageName: cachedData['profileImageName'],
            resumeFileName: cachedData['resumeFileName'],
            lastResumeUpdatedDate: cachedData['lastResumeUpdatedDate'],
            resumeFileSize: cachedData['resumeFileSize'] ?? 0,
            resumeDownloadUrl: cachedData['resumeDownloadUrl'],
            isSyncing: false,
            statusMessage: null,
            statusIsError: false,
            statusMessageKey: 0,
          );
          
          // Trigger rebuild to show cached data
          if (mounted) {
            setState(() {});
          }
        }
      }
      
      // Load profile data from ProfileBloc (will use cache if available, then refresh)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
    final profileBloc = context.read<ProfileBloc>();
        
        // First load from cache for instant display
        profileBloc.add(const LoadProfileDataEvent(forceRefresh: false));
        
        // Then immediately refresh to get latest data (rewrite blue section)
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
    profileBloc.add(const LoadProfileDataEvent(forceRefresh: true));
          }
        });
      });
    } catch (e) {
      debugPrint('⚠️ [Menu] Error initializing cache: $e');
      // Continue with normal load even if cache fails
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final profileBloc = context.read<ProfileBloc>();
        profileBloc.add(const LoadProfileDataEvent(forceRefresh: false));
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh profile data when app comes to foreground
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<ProfileBloc>().add(const LoadProfileDataEvent(forceRefresh: true));
    }
  }

  /// Gets user's saved location for display (without requesting permission)
  /// ⚠️ IMPORTANT: This method does NOT request location permission or trigger location dialogs.
  /// It only reads saved location data if available and converts coordinates to address.
  Future<String> _getUserLocation() async {
    try {
      final locationService = LocationService.instance;
      await locationService.initialize();

      // Only try to get saved location - DO NOT request current location
      // This prevents triggering location permission dialogs
      final savedLocation = await locationService.getSavedLocation();
      if (savedLocation != null) {
        // Try to reverse geocode coordinates to get address
        try {
          final address = await _reverseGeocode(
            savedLocation.latitude,
            savedLocation.longitude,
          );
          if (address != null && address.isNotEmpty) {
            return address;
          }
        } catch (e) {
          debugPrint('⚠️ [Menu] Reverse geocoding failed: $e');
        }
        
        // If reverse geocoding fails, don't show raw coordinates
        // Return "Location not provided" instead
        return 'Location not provided';
      }

      // Return null/empty if no saved location - don't request current location
      // This prevents the system location accuracy dialog from appearing
      return 'Location not provided';
    } catch (e) {
      // Silently fail - don't trigger any location-related operations
      return 'Location not provided';
    }
  }

  /// Reverse geocode coordinates to get city and state
  Future<String?> _reverseGeocode(double latitude, double longitude) async {
    try {
      debugPrint('🔵 [Menu] Starting reverse geocoding for: $latitude, $longitude');

      // Using OpenStreetMap Nominatim API (free, no API key required)
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&addressdetails=1&zoom=18&accept-language=en',
      );

      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': 'JobsahiApp/1.0', // Required by Nominatim
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('Reverse geocoding timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          // Extract city - try multiple field names
          String city = '';
          final cityFields = [
            'city',
            'town',
            'district',
            'city_district',
            'county',
            'village',
            'municipality',
            'suburb',
          ];

          for (final field in cityFields) {
            final value = address[field]?.toString().trim();
            if (value != null && value.isNotEmpty) {
              city = value;
              break;
            }
          }

          // Extract state
          final state = (address['state'] ?? 
                        address['region'] ?? 
                        address['state_district'] ?? 
                        '').toString().trim();

          // Return city, state if both available
          if (city.isNotEmpty && state.isNotEmpty) {
            return '$city, $state';
          }

          // Return city only if available
          if (city.isNotEmpty) {
            return city;
          }

          // Return state only if available
          if (state.isNotEmpty) {
            return state;
          }

          // Fallback to display_name
          final displayName = data['display_name']?.toString() ?? '';
          if (displayName.isNotEmpty) {
            // Extract city and state from display_name
            final parts = displayName.split(',');
            if (parts.length >= 2) {
              return '${parts[parts.length - 2].trim()}, ${parts[parts.length - 1].trim()}';
            }
            return displayName;
          }
        }
      }

      return null;
    } on TimeoutException {
      debugPrint('⏱️ [Menu] Reverse geocoding timeout');
      return null;
    } catch (e) {
      debugPrint('🔴 [Menu] Error in reverse geocoding: $e');
      return null;
    }
  }

  String? _extractLocation(dynamic locationValue) {
    if (locationValue == null) {
      return null;
    }

    final locationString = locationValue.toString().trim();
    if (locationString.isEmpty || locationString.toLowerCase() == 'null') {
      return null;
    }

    return locationString;
  }

  String? _extractBio(dynamic bioValue) {
    if (bioValue == null) {
      return null;
    }

    final bioString = bioValue.toString().trim();
    if (bioString.isEmpty || bioString.toLowerCase() == 'null') {
      return null;
    }

    return bioString;
  }

  /// Check if location string is coordinates (lat, lng format)
  bool _isCoordinates(String location) {
    if (location.isEmpty) return false;
    
    // Check for patterns like "28.7041, 77.1025" or "28.7041,77.1025"
    final coordPattern = RegExp(r'^-?\d+\.?\d*\s*,\s*-?\d+\.?\d*$');
    if (coordPattern.hasMatch(location.trim())) {
      return true;
    }
    
    // Check for "Lat: X, Lng: Y" format
    if (location.toLowerCase().contains('lat:') && 
        location.toLowerCase().contains('lng:')) {
      return true;
    }
    
    return false;
  }

  /// Handle back navigation
  void _handleBackNavigation(BuildContext context) {
    // Check if we came from a specific screen
    final state = GoRouterState.of(context);
    final fromScreen = state.uri.queryParameters['from'];
    
    if (context.canPop()) {
      context.pop();
    } else {
      // Navigate back to the screen we came from
      if (fromScreen == 'campus-drive') {
        context.go(AppRoutes.campusDriveList);
      } else {
        // Default to home
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackNavigation(context);
        }
      },
      child: KeyboardDismissWrapper(
        child: Scaffold(
          backgroundColor: AppConstants.cardBackgroundColor,
          appBar: AppBar(
            backgroundColor: AppConstants.cardBackgroundColor,
            elevation: 0,
            title: const Text(
              'Menu',
              style: TextStyle(
                color: AppConstants.textPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppConstants.textPrimaryColor,
              ),
              onPressed: () {
                _handleBackNavigation(context);
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  // Profile header
                  _buildProfileHeader(context),
                  const SizedBox(height: AppConstants.largePadding),

                  // Menu options
                  _buildMenuOptions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the profile header section
  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        // Show cached data during loading (like profile details page)
        if (state is ProfileLoading && _cachedProfileState != null) {
          return _buildProfileHeaderContent(context, _cachedProfileState!);
        }

        if (state is ProfileLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppConstants.largePadding),
            child: Center(
              child: JobsahiLoader(
                size: 48,
                strokeWidth: 3,
                message: 'Loading profile...',
                showMessage: true,
              ),
            ),
          );
        }

        if (state is ProfileDetailsLoaded) {
          // Update cached state when new data is loaded
          _cachedProfileState = state;
          return _buildProfileHeaderContent(context, state);
        }

        if (state is ProfileError) {
          // Check if it's a network error
          final isNetworkError = NetworkErrorHelper.isNetworkError(
            state.message,
          );

          if (isNetworkError) {
            return NoInternetErrorWidget(
              errorMessage: state.message,
              onRetry: () {
                context.read<ProfileBloc>().add(const LoadProfileDataEvent());
              },
              showImage: true,
              enablePullToRefresh: true,
            );
          }

          // For non-network errors, show fallback with error message
          final fallbackUser = UserData.currentUser;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeaderCard(
                name: fallbackUser['name'] ?? 'User Name',
                email: fallbackUser['email'] ?? 'user@email.com',
                location:
                    _extractLocation(fallbackUser['location'] ?? '') ??
                    'Location not provided',
                profileImagePath: fallbackUser['profileImage'],
                bio: _extractBio(fallbackUser['bio']),
                onTap: () => context.push(AppRoutes.profileDetails),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                state.message,
                style: const TextStyle(
                  color: AppConstants.errorColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.read<ProfileBloc>().add(
                  const LoadProfileDataEvent(),
                ),
                icon: const Icon(
                  Icons.refresh,
                  color: AppConstants.primaryColor,
                ),
                label: const Text(
                  'Retry',
                  style: TextStyle(color: AppConstants.primaryColor),
                ),
              ),
            ],
          );
        }

        // Default fallback while waiting for first state.
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppConstants.largePadding),
          child: JobsahiLoader(
            size: 48,
            strokeWidth: 3,
            message: 'Loading profile...',
            showMessage: true,
          ),
        );
      },
    );
  }

  /// Builds the profile header content from ProfileDetailsLoaded state
  Widget _buildProfileHeaderContent(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    final userProfile = state.userProfile;
    final location = _extractLocation(userProfile['location']);

    Widget headerCard(String? resolvedLocation) {
      return ProfileHeaderCard(
        name: userProfile['name']?.toString().isNotEmpty == true
            ? userProfile['name'] as String
            : (UserData.currentUser['name'] ?? 'User Name'),
        email: userProfile['email']?.toString().isNotEmpty == true
            ? userProfile['email'] as String
            : (UserData.currentUser['email'] ?? 'user@email.com'),
        location: resolvedLocation,
        profileImagePath:
            state.profileImagePath ?? userProfile['profileImage'],
        bio: _extractBio(userProfile['bio']),
        onTap: () => context.push(AppRoutes.profileDetails),
        margin: EdgeInsets.zero,
      );
    }

    // Check if location is coordinates (lat, lng format) - don't show raw coordinates
    String? displayLocation;
    if (location != null && location.isNotEmpty) {
      // Check if it's coordinates format (e.g., "28.7041, 77.1025" or "Lat: 28.7041, Lng: 77.1025")
      final locationLower = location.toLowerCase();
      if (_isCoordinates(location) || locationLower.contains('lat:') || locationLower.contains('lng:')) {
        // It's coordinates, try to get saved location or show "Location not provided"
        displayLocation = null;
      } else {
        // It's a proper location string, use it
        displayLocation = location;
      }
    }

    if (displayLocation != null && displayLocation.isNotEmpty) {
      return headerCard(displayLocation);
    }

    // If no proper location, try to get saved location or show default
    return FutureBuilder<String>(
      future: _getUserLocation(),
      builder: (context, snapshot) {
        final detectedLocation =
            snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData &&
                snapshot.data!.isNotEmpty &&
                snapshot.data != 'Location not provided'
            ? snapshot.data
            : null;
        return headerCard(detectedLocation ?? 'Location not provided');
      },
    );
  }

  /// Builds the menu options section
  Widget _buildMenuOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          icon: Icons.timeline,
          title: 'Track Application / आवेदन ट्रैक करें',
          onTap: () {
            context.push('${AppRoutes.applicationTracker}?fromProfile=true');
          },
        ),
        _buildOptionTile(
          icon: Icons.help_outline,
          title: 'FAQs / सामान्य प्रश्न',
          onTap: () {
            context.push(AppRoutes.faqs);
          },
        ),
        _buildOptionTile(
          icon: Icons.info_outline,
          title: 'About / हमारे बारे में',
          onTap: () {
            context.push(AppRoutes.about);
          },
        ),
        _buildOptionTile(
          icon: Icons.support_agent_outlined,
          title: 'Contact Us / संपर्क करें',
          onTap: () {
            context.push(AppRoutes.contactUs);
          },
        ),
        _buildOptionTile(
          icon: Icons.feedback_outlined,
          title: 'Feedback / प्रतिक्रिया',
          onTap: () {
            context.push(AppRoutes.feedback);
          },
        ),
        _buildOptionTile(
          icon: Icons.settings_outlined,
          title: 'Settings / सेटिंग्स',
          onTap: () {
            context.push(AppRoutes.settings);
          },
        ),
        _buildOptionTile(
          icon: Icons.logout,
          title: 'Logout / लॉगआउट',
          onTap: () {
            _showLogoutDialog(context);
          },
          isDestructive: true,
        ),
      ],
    );
  }

  /// Builds an option tile
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final borderRadius = BorderRadius.circular(AppConstants.borderRadius);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: onTap,
          splashColor: isDestructive
              ? AppConstants.errorColor.withOpacity(0.2)
              : null,
          highlightColor: isDestructive
              ? AppConstants.errorColor.withOpacity(0.1)
              : null,
          hoverColor: isDestructive
              ? AppConstants.errorColor.withOpacity(0.1)
              : null,
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            leading: Icon(
              icon,
              color: isDestructive
                  ? AppConstants.errorColor
                  : AppConstants.textPrimaryColor,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isDestructive
                    ? AppConstants.errorColor
                    : AppConstants.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  /// Shows logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            // Hide the dialog and navigate to login screen
            Navigator.of(dialogContext).pop();
            context.go(AppRoutes.loginOtpEmail);
          } else if (state is AuthError) {
            // Hide the dialog and show error
            Navigator.of(dialogContext).pop();
            TopSnackBar.showError(context, message: state.message);
          }
        },
        child: _LogoutDialog(),
      ),
    );
  }
}

/// Logout dialog widget that shows confirmation and then loader
class _LogoutDialog extends StatefulWidget {
  @override
  State<_LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<_LogoutDialog> {
  bool _isLoggingOut = false;

  void _handleLogout() {
    setState(() {
      _isLoggingOut = true;
    });

    // Dispatch logout event to AuthBloc
    context.read<AuthBloc>().add(const LogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                children: [
                  if (!_isLoggingOut) ...[
                    Text(
                      'Logout',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.errorColor,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _isLoggingOut
                      ? JobsahiLoader(
                          size: 50,
                          strokeWidth: 4,
                          message: 'Logging out',
                          showMessage: true,
                        )
                      : const Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                ],
              ),
            ),

            // Action buttons
            if (!_isLoggingOut) ...[
              Container(height: 1, color: Colors.grey.shade300),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black54,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ),
                  Container(height: 40, width: 1, color: Colors.grey.shade300),
                  Expanded(
                    child: TextButton(
                      onPressed: _handleLogout,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppConstants.errorColor,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppConstants.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
