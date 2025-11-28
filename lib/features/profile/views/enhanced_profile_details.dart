import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/widgets/common/top_snackbar.dart';
import '../../../shared/services/location_service.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Enhanced Profile Details Screen with Modern UI/UX
class EnhancedProfileDetailsScreen extends StatelessWidget {
  final bool isFromBottomNavigation;

  const EnhancedProfileDetailsScreen({
    super.key,
    this.isFromBottomNavigation = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(const LoadProfileDataEvent()),
      child: _EnhancedProfileDetailsView(
        isFromBottomNavigation: isFromBottomNavigation,
      ),
    );
  }
}

class _EnhancedProfileDetailsView extends StatefulWidget {
  final bool isFromBottomNavigation;

  const _EnhancedProfileDetailsView({required this.isFromBottomNavigation});

  @override
  State<_EnhancedProfileDetailsView> createState() =>
      _EnhancedProfileDetailsViewState();
}

class _EnhancedProfileDetailsViewState
    extends State<_EnhancedProfileDetailsView> {
  ProfileDetailsLoaded? _cachedState;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) {
        // If we have cached state and current is loading, keep showing cached
        if (_cachedState != null && current is ProfileLoading) {
          return false; // Don't rebuild, keep showing cached content
        }
        // Update cache when we get loaded state
        if (current is ProfileDetailsLoaded) {
          _cachedState = current;
          return true;
        }
        // Rebuild for other state changes
        return true;
      },
      listenWhen: (previous, current) {
        if (current is ProfileDetailsLoaded) {
          if (current.statusMessage == null) {
            return false;
          }
          final previousKey = previous is ProfileDetailsLoaded
              ? previous.statusMessageKey
              : -1;
          return current.statusMessageKey != previousKey;
        }
        return current is CertificateDeletedSuccess ||
            current is ProfileImageRemovedSuccess ||
            current is ProfileError;
      },
      listener: (context, state) {
        if (state is CertificateDeletedSuccess) {
          TopSnackBar.showSuccess(context, message: state.message);
        } else if (state is ProfileImageRemovedSuccess) {
          TopSnackBar.showSuccess(
            context,
            message: 'Profile image removed successfully!',
          );
        } else if (state is ProfileError) {
          TopSnackBar.showError(context, message: state.message);
        } else if (state is ProfileDetailsLoaded) {
          final message = state.statusMessage;
          if (message != null) {
            if (state.statusIsError) {
              TopSnackBar.showError(context, message: message);
            } else {
              TopSnackBar.showSuccess(context, message: message);
            }
          }
        }
      },
      builder: (context, state) {
        // Show cached content during reload (like courses section)
        if (state is ProfileLoading && _cachedState != null) {
          return _buildEnhancedProfileDetails(context, _cachedState!);
        }

        if (state is ProfileDetailsLoaded) {
          return _buildEnhancedProfileDetails(context, state);
        } else if (state is ProfileError) {
          return Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            body: RefreshIndicator(
              color: AppConstants.primaryColor,
              onRefresh: () async {
                context.read<ProfileBloc>().add(
                  const LoadProfileDataEvent(forceRefresh: true),
                );
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: NoInternetErrorWidget(
                    errorMessage: state.message,
                    onRetry: () {
                      context.read<ProfileBloc>().add(
                        const LoadProfileDataEvent(forceRefresh: true),
                      );
                    },
                    showImage: true,
                    enablePullToRefresh:
                        false, // We handle it with RefreshIndicator
                  ),
                ),
              ),
            ),
          );
        }

        // Show loading only on first load
        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          body: Center(
            child: CircularProgressIndicator(
              color: AppConstants.secondaryColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedProfileDetails(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    return KeyboardDismissWrapper(
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: Stack(
          children: [
            RefreshIndicator(
              color: AppConstants.primaryColor,
              onRefresh: () async {
                // Force refresh from API (rewrite system) - same as courses section
                context.read<ProfileBloc>().add(
                  const LoadProfileDataEvent(forceRefresh: true),
                );
                // Wait for the API call to complete
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Green loader line above blue box when syncing
                    if (state.isSyncing)
                      Container(
                        width: double.infinity,
                        height: 3,
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppConstants.successColor,
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    // Profile Header
                    _buildProfileHeader(context, state),

                    // Profile Content
                    Padding(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      child: Column(
                        children: [
                          // Profile Sections
                          _buildProfileSections(context, state),
                        ],
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
  }

  /// Profile Header Section
  Widget _buildProfileHeader(BuildContext context, ProfileDetailsLoaded state) {
    final user = state.userProfile;
    final rawBio = user['bio'];
    final String? profileBio = rawBio is String && rawBio.trim().isNotEmpty
        ? rawBio.trim()
        : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.defaultPadding,
            AppConstants.smallPadding,
            AppConstants.defaultPadding,
            AppConstants.defaultPadding,
          ),
          child: Column(
            children: [
              // Top Navigation Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  if (!widget.isFromBottomNavigation)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  else
                    const SizedBox(width: 48), // Spacer for alignment
                  // Action Buttons
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => _showProfileInfoEditSheet(
                          context: context,
                          state: state,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.smallPadding),

              // Profile Image (Centered)
              Stack(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: state.profileImagePath != null
                          ? ClipOval(
                              child: Image.asset(
                                state.profileImagePath!,
                                fit: BoxFit.cover,
                                width: 64,
                                height: 64,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultProfileImage();
                                },
                              ),
                            )
                          : _buildDefaultProfileImage(),
                    ),
                  ),
                  // Online Status Indicator
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppConstants.successColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.smallPadding),

              // User Info (Centered)
              Column(
                children: [
                  Text(
                    _capitalizeEachWord(user['name'] ?? 'User Name'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['email'] ?? 'user@email.com',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  if (user['phone']?.toString().trim().isNotEmpty == true)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user['phone']?.toString().trim() ?? '',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  if (user['phone']?.toString().trim().isNotEmpty == true)
                    const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (() {
                          final raw = user['location'];
                          if (raw is String && raw.trim().isNotEmpty) {
                            final locationText = raw.trim();
                            // Check if it's coordinates (format: "Lat: X.XXXX, Lng: Y.YYYY" or "X.XXXX, Y.YYYY")
                            if (_isCoordinates(locationText)) {
                              return 'Location not provided';
                            }
                            return locationText;
                          }
                          return 'Location not provided';
                        })(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (profileBio != null) ...[
                const SizedBox(height: AppConstants.defaultPadding),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      AppConstants.smallBorderRadius,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About me',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profileBio,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppConstants.defaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  /// Capitalize the first letter of each word (e.g., 'ram kumar' -> 'Ram Kumar')
  String _capitalizeEachWord(String input) {
    if (input.isEmpty) return input;
    final words = input.trim().split(RegExp(r'\\s+'));
    return words
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1) : ''}',
        )
        .join(' ');
  }

  /// Format date to "22 Jan 2021" format
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString();
    final month = months[date.month - 1];
    final year = date.year.toString();
    return '$day $month $year';
  }

  /// Parse date from various formats to DateTime
  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;

    try {
      // Try ISO format (yyyy-MM-dd)
      if (dateStr.contains('-')) {
        return DateTime.tryParse(dateStr);
      }
      // Try DD/MM/YYYY or MM/DD/YYYY
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          // Try DD/MM/YYYY first
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            if (month <= 12 && day <= 31) {
              return DateTime(year, month, day);
            }
          }
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  /// Format gender value to proper case (Male, Female, Other)
  String _formatGender(String gender) {
    if (gender.isEmpty) return gender;
    final lowerGender = gender.toLowerCase().trim();
    if (lowerGender == 'male') {
      return 'Male';
    } else if (lowerGender == 'female') {
      return 'Female';
    } else if (lowerGender == 'other') {
      return 'Other';
    }
    // If it's already in proper format or unknown, capitalize first letter
    return '${gender[0].toUpperCase()}${gender.length > 1 ? gender.substring(1).toLowerCase() : ''}';
  }

  void _showProfileInfoEditSheet({
    required BuildContext context,
    required ProfileDetailsLoaded state,
  }) {
    final parentContext = context;
    final bloc = parentContext.read<ProfileBloc>();
    final nameController = TextEditingController(
      text: state.userProfile['name']?.toString() ?? '',
    );
    final emailController = TextEditingController(
      text: state.userProfile['email']?.toString() ?? '',
    );
    final phoneController = TextEditingController(
      text: state.userProfile['phone']?.toString() ?? '',
    );
    final locationController = TextEditingController(
      text: state.userProfile['location']?.toString() ?? '',
    );
    final bioController = TextEditingController(
      text: state.userProfile['bio']?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      backgroundColor: AppConstants.cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final viewInsets = MediaQuery.of(sheetContext).viewInsets.bottom;
        // Track loading state for location fetch
        bool isLocationLoading = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Check if there are changes
            final currentName = nameController.text.trim();
            final currentEmail = emailController.text.trim();
            final currentPhone = phoneController.text.trim();
            final currentLocation = locationController.text.trim();
            final currentBio = bioController.text.trim();
            final initialName = (state.userProfile['name']?.toString() ?? '')
                .trim();
            final initialEmail = (state.userProfile['email']?.toString() ?? '')
                .trim();
            final initialPhone = (state.userProfile['phone']?.toString() ?? '')
                .trim();
            final initialLocation =
                (state.userProfile['location']?.toString() ?? '').trim();
            final initialBio = (state.userProfile['bio']?.toString() ?? '')
                .trim();
            final hasChanges =
                currentName != initialName ||
                currentEmail != initialEmail ||
                currentPhone != initialPhone ||
                currentLocation != initialLocation ||
                currentBio != initialBio;

            // Add listeners to trigger rebuilds when text changes
            void setupListeners() {
              nameController.removeListener(() {});
              emailController.removeListener(() {});
              phoneController.removeListener(() {});
              locationController.removeListener(() {});
              bioController.removeListener(() {});
              nameController.addListener(() => setModalState(() {}));
              emailController.addListener(() => setModalState(() {}));
              phoneController.addListener(() => setModalState(() {}));
              locationController.addListener(() => setModalState(() {}));
              bioController.addListener(() => setModalState(() {}));
            }

            setupListeners();

            Future<void> handleClose() async {
              if (hasChanges) {
                final shouldSave = await _showUnsavedChangesDialog(context);
                if (shouldSave == null) return; // Dialog dismissed
                if (shouldSave) {
                  // Save changes
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  bloc.add(
                    UpdateProfileHeaderInlineEvent(
                      name: currentName,
                      email: currentEmail,
                      phone: currentPhone,
                      location: currentLocation,
                      bio: currentBio.isNotEmpty ? currentBio : null,
                    ),
                  );
                }
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }

            return PopScope(
              canPop: !hasChanges,
              onPopInvokedWithResult: (didPop, result) async {
                if (!didPop && hasChanges) {
                  await handleClose();
                }
              },
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSheetHeader(
                                context: sheetContext,
                                title: 'Edit Profile Info',
                                onClose: handleClose,
                              ),
                              const SizedBox(
                                height: AppConstants.defaultPadding,
                              ),
                              _buildMainCard(
                                children: [
                                  TextFormField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Full Name *',
                                      border: OutlineInputBorder(),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.words,
                                    validator: (value) {
                                      final name = value?.trim() ?? '';
                                      if (name.isEmpty) {
                                        return 'Name is required';
                                      }
                                      final lettersOnly = name.replaceAll(
                                        RegExp(r'[^a-zA-Z]'),
                                        '',
                                      );
                                      if (lettersOnly.length < 3) {
                                        return 'Name must have at least 3 letters';
                                      }
                                      final words = name
                                          .split(RegExp(r'\s+'))
                                          .where((w) => w.isNotEmpty)
                                          .toList();
                                      if (words.length < 2) {
                                        return 'Name must have at least 2 words';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: AppConstants.smallPadding,
                                  ),
                                  TextFormField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email *',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      final email = value?.trim() ?? '';
                                      if (email.isEmpty) {
                                        return 'Email is required';
                                      }
                                      final emailRegex = RegExp(
                                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                      );
                                      if (!emailRegex.hasMatch(email)) {
                                        return 'Enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: AppConstants.smallPadding,
                                  ),
                                  TextFormField(
                                    controller: phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone *',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    validator: (value) {
                                      final phone = value?.trim() ?? '';
                                      if (phone.isEmpty) {
                                        return 'Phone is required';
                                      }
                                      if (!RegExp(r'^\d+$').hasMatch(phone)) {
                                        return 'Phone number must contain only digits';
                                      }
                                      if (phone.length != 10) {
                                        return 'Phone number must be exactly 10 digits';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: AppConstants.smallPadding,
                                  ),
                                  TextFormField(
                                    controller: locationController,
                                    decoration: InputDecoration(
                                      labelText: 'Location',
                                      hintText: 'City and State',
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: const Icon(
                                          Icons.my_location,
                                          color: Color(0xFF58B248),
                                        ),
                                        onPressed: () async {
                                          // Prevent multiple simultaneous requests
                                          if (isLocationLoading) return;

                                          final result =
                                              await _showGetCurrentLocationDialog(
                                                context,
                                              );
                                          if (result == true) {
                                            isLocationLoading = true;
                                            setModalState(() {});
                                            final scaffoldMessenger =
                                                ScaffoldMessenger.of(context);

                                            // Dismiss any existing snackbars
                                            scaffoldMessenger
                                                .hideCurrentSnackBar();

                                            // Get current location
                                            try {
                                              final locationService =
                                                  LocationService.instance;
                                              await locationService
                                                  .initialize();

                                              // Request permission and get location
                                              final hasPermission =
                                                  await locationService
                                                      .requestLocationPermission(
                                                        context: context,
                                                      );

                                              if (hasPermission) {
                                                // Check GPS status first
                                                final gpsEnabled =
                                                    await locationService
                                                        .isLocationServiceEnabled();
                                                if (!gpsEnabled) {
                                                  isLocationLoading = false;
                                                  setModalState(() {});
                                                  scaffoldMessenger.showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Please enable GPS to get your location',
                                                      ),
                                                      backgroundColor:
                                                          AppConstants
                                                              .errorColor,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      duration: Duration(
                                                        seconds: 3,
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                // Show loading indicator
                                                TopSnackBar.showInfo(
                                                  context,
                                                  message:
                                                      'Getting location...',
                                                  duration: const Duration(
                                                    seconds: 12,
                                                  ),
                                                );

                                                // Clear field first
                                                locationController.clear();
                                                setModalState(() {});

                                                // Get location - single attempt with shorter timeout
                                                LocationData? locationData;
                                                String? errorMessage;

                                                try {
                                                  // Double check permission before fetching
                                                  final permissionGranted =
                                                      await locationService
                                                          .isLocationPermissionGranted();
                                                  if (!permissionGranted) {
                                                    errorMessage =
                                                        'Location permission not granted';
                                                    locationData = null;
                                                  } else {
                                                    // Double check GPS before fetching
                                                    final gpsEnabled =
                                                        await locationService
                                                            .isLocationServiceEnabled();
                                                    if (!gpsEnabled) {
                                                      errorMessage =
                                                          'GPS is disabled. Please enable it.';
                                                      locationData = null;
                                                    } else {
                                                      // Fetch location
                                                      try {
                                                        locationData =
                                                            await locationService
                                                                .getCurrentLocation(
                                                                  context:
                                                                      context,
                                                                )
                                                                .timeout(
                                                                  const Duration(
                                                                    seconds: 12,
                                                                  ),
                                                                  onTimeout: () {
                                                                    debugPrint(
                                                                      '⏱️ Location timeout',
                                                                    );
                                                                    return null;
                                                                  },
                                                                );
                                                      } catch (e) {
                                                        debugPrint(
                                                          '⚠️ Location fetch error: $e',
                                                        );
                                                        errorMessage =
                                                            'Failed to get location: ${e.toString().contains('timeout') ? 'Request timed out' : 'Please try again'}';
                                                        locationData = null;
                                                      }
                                                    }
                                                  }
                                                } catch (e) {
                                                  debugPrint(
                                                    '🔴 Location error: $e',
                                                  );
                                                  errorMessage =
                                                      'Error: ${e.toString().length > 40 ? e.toString().substring(0, 40) + "..." : e.toString()}';
                                                  locationData = null;
                                                }

                                                // Hide loading
                                                scaffoldMessenger
                                                    .hideCurrentSnackBar();

                                                if (locationData == null) {
                                                  isLocationLoading = false;
                                                  setModalState(() {});

                                                  final message =
                                                      errorMessage ??
                                                      'Could not get location. Please check GPS and try again.';

                                                  TopSnackBar.showError(
                                                    context,
                                                    message: message,
                                                  );
                                                  return;
                                                }

                                                // Try reverse geocode with shorter timeout
                                                String? addressResult;
                                                try {
                                                  addressResult =
                                                      await _reverseGeocode(
                                                        locationData.latitude,
                                                        locationData.longitude,
                                                      ).timeout(
                                                        const Duration(
                                                          seconds: 5,
                                                        ),
                                                        onTimeout: () => null,
                                                      );
                                                } catch (e) {
                                                  debugPrint(
                                                    '🔴 Geocoding error: $e',
                                                  );
                                                  addressResult = null;
                                                }

                                                // Fill location - only fill if we have city/state, don't fill coordinates
                                                if (addressResult != null &&
                                                    addressResult
                                                        .trim()
                                                        .isNotEmpty) {
                                                  locationController.text =
                                                      addressResult.trim();
                                                } else {
                                                  // Don't fill coordinates, leave field empty
                                                  // User can manually enter city and state
                                                  locationController.text = '';
                                                }

                                                setModalState(() {});
                                                isLocationLoading = false;

                                                // Show result
                                                final locationMessage =
                                                    addressResult != null &&
                                                        addressResult
                                                            .trim()
                                                            .isNotEmpty
                                                    ? 'Location: ${addressResult.trim()}'
                                                    : 'Coordinates filled. Enter city and state manually.';

                                                if (addressResult != null &&
                                                    addressResult
                                                        .trim()
                                                        .isNotEmpty) {
                                                  TopSnackBar.showSuccess(
                                                    context,
                                                    message: locationMessage,
                                                  );
                                                } else {
                                                  TopSnackBar.showInfo(
                                                    context,
                                                    message: locationMessage,
                                                  );
                                                }
                                              } else {
                                                // Permission denied
                                                isLocationLoading = false;
                                                setModalState(() {});
                                                TopSnackBar.showError(
                                                  context,
                                                  message:
                                                      'Location permission denied. Please enable it in settings.',
                                                );
                                              }
                                            } catch (e) {
                                              isLocationLoading = false;
                                              setModalState(() {});
                                              scaffoldMessenger
                                                  .hideCurrentSnackBar();
                                              TopSnackBar.showError(
                                                context,
                                                message:
                                                    'Error getting location: ${e.toString()}',
                                              );
                                            }
                                          } else {
                                            isLocationLoading = false;
                                            setModalState(() {});
                                          }
                                        },
                                      ),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),
                                  const SizedBox(
                                    height: AppConstants.smallPadding,
                                  ),
                                  TextFormField(
                                    controller: bioController,
                                    decoration: const InputDecoration(
                                      labelText: 'About me',
                                      hintText:
                                          'Write a short summary about yourself',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 4,
                                    validator: (value) {
                                      final bio = value?.trim() ?? '';
                                      if (bio.isNotEmpty) {
                                        final lettersOnly = bio.replaceAll(
                                          RegExp(r'[^a-zA-Z]'),
                                          '',
                                        );
                                        if (lettersOnly.length < 15) {
                                          return 'About me must have at least 15 letters';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Fixed bottom button
                    Container(
                      padding: EdgeInsets.only(
                        left: AppConstants.defaultPadding,
                        right: AppConstants.defaultPadding,
                        top: AppConstants.defaultPadding,
                        bottom: viewInsets + AppConstants.defaultPadding,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.cardBackgroundColor,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: hasChanges
                              ? () {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  final updatedName = nameController.text
                                      .trim();
                                  final updatedEmail = emailController.text
                                      .trim();
                                  final updatedPhone = phoneController.text
                                      .trim();
                                  final updatedLocation = locationController
                                      .text
                                      .trim();
                                  final updatedBio = bioController.text.trim();

                                  bloc.add(
                                    UpdateProfileHeaderInlineEvent(
                                      name: updatedName,
                                      email: updatedEmail,
                                      phone: updatedPhone,
                                      location: updatedLocation,
                                      bio: updatedBio.isNotEmpty
                                          ? updatedBio
                                          : null,
                                    ),
                                  );
                                  Navigator.of(sheetContext).pop();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasChanges
                                ? Colors.green
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                            elevation: hasChanges ? 2 : 0,
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditSectionSheet({
    required BuildContext context,
    required String section,
    required ProfileDetailsLoaded state,
  }) {
    final bloc = context.read<ProfileBloc>();

    // If education section is empty and edit is clicked, automatically expand the section
    if (section == 'education' && state.education.isEmpty) {
      final isCurrentlyExpanded =
          state.sectionExpansionStates['education'] ?? false;
      if (!isCurrentlyExpanded) {
        bloc.add(const ToggleSectionEvent(section: 'education'));
      }
    }

    // For skills, create state containers and controllers BEFORE showModalBottomSheet (like profile info)
    List<String>? skillsDraft;
    TextEditingController? newSkillController;
    if (section == 'skills') {
      skillsDraft = List<String>.from(state.skills);
      newSkillController = TextEditingController();
    }

    // For experience, create state containers BEFORE showModalBottomSheet (like profile info)
    List<Map<String, dynamic>>? experienceDrafts;
    ValueNotifier<int>? experienceRebuildCounter;
    if (section == 'experience') {
      experienceDrafts = state.experience
          .map((exp) => Map<String, dynamic>.from(exp))
          .toList();

      if (experienceDrafts!.isEmpty) {
        experienceDrafts.add({
          'company': '',
          'position': '',
          'startDate': '',
          'endDate': '',
          'description': '',
        });
      }

      experienceRebuildCounter = ValueNotifier<int>(0);
    }

    // For education, create state containers BEFORE showModalBottomSheet (like profile info)
    List<Map<String, dynamic>>? educationDrafts;
    ValueNotifier<int>? educationRebuildCounter;
    if (section == 'education') {
      educationDrafts = state.education
          .map((edu) => Map<String, dynamic>.from(edu))
          .toList();

      // Add default empty block if list is empty (like Work Experience)
      if (educationDrafts!.isEmpty) {
        educationDrafts.add({
          'qualification': '',
          'institute': '',
          'startYear': '',
          'endYear': '',
          'isPursuing': false,
          'pursuingYear': null,
          'cgpa': '',
        });
      }

      educationRebuildCounter = ValueNotifier<int>(0);
    }

    // For general_info, create ALL state containers and controllers BEFORE showModalBottomSheet (like profile info)
    List<String?>? genderState;
    List<DateTime?>? dateState;
    TextEditingController? dobController;
    TextEditingController? aadharController;
    TextEditingController? languageInputController;
    List<String>? languages;
    GlobalKey<FormState>? formKey;

    if (section == 'general_info') {
      // Parse existing gender value (INITIAL value)
      String? initialGender;
      final existingGender =
          state.userProfile['gender']?.toString().toLowerCase() ?? '';
      if (existingGender == 'male') {
        initialGender = 'Male';
      } else if (existingGender == 'female') {
        initialGender = 'Female';
      } else if (existingGender == 'other') {
        initialGender = 'Other';
      }

      // Parse existing date of birth (INITIAL value)
      DateTime? initialDate;
      final dobText = state.userProfile['dateOfBirth']?.toString() ?? '';
      if (dobText.isNotEmpty) {
        initialDate = _parseDate(dobText);
      }

      // State containers initialized with initial values (will be updated when user changes)
      genderState = [initialGender];
      dateState = [initialDate];

      // Create controllers BEFORE showModalBottomSheet (like Profile Info pattern)
      dobController = TextEditingController(
        text: initialDate != null ? _formatDate(initialDate) : '',
      );
      aadharController = TextEditingController(
        text: state.userProfile['aadharNumber']?.toString() ?? '',
      );
      languageInputController = TextEditingController();

      // Get existing languages
      languages = [];
      if (state.userProfile['languages'] != null) {
        if (state.userProfile['languages'] is List) {
          languages = List<String>.from(state.userProfile['languages']);
        } else if (state.userProfile['languages'] is String) {
          languages = (state.userProfile['languages'] as String)
              .split(',')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty)
              .toList();
        }
      }

      formKey = GlobalKey<FormState>();
    }

    // For contact, create controllers BEFORE showModalBottomSheet (like profile info)
    TextEditingController? contactEmailController;
    TextEditingController? contactPhoneController;
    GlobalKey<FormState>? contactFormKey;
    if (section == 'contact') {
      final initialContactEmail =
          state.userProfile['contactEmail']?.toString().isNotEmpty == true
          ? state.userProfile['contactEmail']?.toString() ?? ''
          : (state.userProfile['email']?.toString() ?? '');
      final initialContactPhone =
          state.userProfile['contactPhone']?.toString().isNotEmpty == true
          ? state.userProfile['contactPhone']?.toString() ?? ''
          : (state.userProfile['phone']?.toString() ?? '');

      contactEmailController = TextEditingController(text: initialContactEmail);
      contactPhoneController = TextEditingController(text: initialContactPhone);
      contactFormKey = GlobalKey<FormState>();
    }

    // For social, create state containers BEFORE showModalBottomSheet (like profile info)
    List<Map<String, dynamic>>? socialLinks;
    ValueNotifier<int>? socialRebuildCounter;
    Map<int, Map<String, GlobalKey<FormFieldState<String>>>>? socialFieldKeys;
    if (section == 'social') {
      // Get existing social links from array or build from individual fields
      List<Map<String, dynamic>> initialSocialLinks = [];
      if (state.userProfile['socialLinks'] is List) {
        initialSocialLinks = List<Map<String, dynamic>>.from(
          (state.userProfile['socialLinks'] as List).map((link) {
            if (link is Map<String, dynamic>) {
              return Map<String, dynamic>.from(link);
            }
            return <String, dynamic>{};
          }),
        );
      } else {
        // Fallback: Build from individual fields
        final portfolio = state.userProfile['portfolioLink']?.toString() ?? '';
        final linkedin = state.userProfile['linkedinUrl']?.toString() ?? '';
        final github = state.userProfile['githubUrl']?.toString() ?? '';
        final twitter = state.userProfile['twitterUrl']?.toString() ?? '';

        if (portfolio.isNotEmpty) {
          initialSocialLinks.add({
            'title': 'Portfolio',
            'profile_url': portfolio,
          });
        }
        if (linkedin.isNotEmpty) {
          initialSocialLinks.add({
            'title': 'LinkedIn',
            'profile_url': linkedin,
          });
        }
        if (github.isNotEmpty) {
          initialSocialLinks.add({'title': 'GitHub', 'profile_url': github});
        }
        if (twitter.isNotEmpty) {
          initialSocialLinks.add({'title': 'Twitter', 'profile_url': twitter});
        }
      }

      // Create mutable copy for editing
      socialLinks = initialSocialLinks
          .map((link) => Map<String, dynamic>.from(link))
          .toList();

      // Add default empty block if list is empty (like Work Experience and Education)
      if (socialLinks!.isEmpty) {
        socialLinks!.add({'title': '', 'profile_url': ''});
      }

      socialRebuildCounter = ValueNotifier<int>(0);
      socialFieldKeys = <int, Map<String, GlobalKey<FormFieldState<String>>>>{};
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        switch (section) {
          case 'skills':
            return _buildSkillsEditSheet(
              parentContext: context,
              bloc: bloc,
              initialSkills: state.skills,
              skillsDraft: skillsDraft!,
              newSkillController: newSkillController!,
            );
          case 'experience':
            return _buildExperienceEditSheet(
              parentContext: context,
              bloc: bloc,
              initialExperience: state.experience,
              experienceDrafts: experienceDrafts!,
              experienceRebuildCounter: experienceRebuildCounter!,
            );
          case 'education':
            return _buildEducationEditSheet(
              parentContext: context,
              bloc: bloc,
              initialEducation: state.education,
              educationDrafts: educationDrafts!,
              educationRebuildCounter: educationRebuildCounter!,
            );
          case 'resume':
            return _buildResumeEditSheet(
              parentContext: context,
              bloc: bloc,
              resumeFileName: state.resumeFileName,
              lastUpdated: state.lastResumeUpdatedDate,
              downloadUrl: state.resumeDownloadUrl,
            );
          case 'certificates':
            return _buildCertificatesEditSheet(
              parentContext: context,
              bloc: bloc,
              initialCertificates: state.certificates,
            );
          case 'contact':
            return _buildContactEditSheet(
              parentContext: context,
              bloc: bloc,
              userProfile: state.userProfile,
              contactEmailController: contactEmailController!,
              contactPhoneController: contactPhoneController!,
              formKey: contactFormKey!,
            );
          case 'general_info':
            // Pass all controllers and state created BEFORE showModalBottomSheet (like Profile Info pattern)
            return _buildGeneralInformationEditSheet(
              parentContext: context,
              bloc: bloc,
              userProfile: state.userProfile,
              genderState: genderState!,
              dateState: dateState!,
              dobController: dobController!,
              aadharController: aadharController!,
              languageInputController: languageInputController!,
              languages: languages!,
              formKey: formKey!,
            );
          case 'social':
            return _buildSocialLinksEditSheet(
              parentContext: context,
              bloc: bloc,
              userProfile: state.userProfile,
              socialLinks: socialLinks!,
              socialRebuildCounter: socialRebuildCounter!,
              socialFieldKeys: socialFieldKeys!,
            );
          default:
            return _buildUnsupportedSectionSheet(sheetContext, section);
        }
      },
    );
  }

  Widget _buildUnsupportedSectionSheet(BuildContext context, String section) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final title = section.isEmpty
        ? 'Edit Section'
        : 'Edit ${section[0].toUpperCase()}${section.substring(1)}';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: viewInsets,
          left: AppConstants.defaultPadding,
          right: AppConstants.defaultPadding,
          top: AppConstants.defaultPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSheetHeader(context: context, title: title),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              'Editing for this section will be available soon.',
              style: TextStyle(color: AppConstants.textSecondaryColor),
            ),
            const SizedBox(height: AppConstants.largePadding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHeader({
    required BuildContext context,
    required String title,
    VoidCallback? onClose,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ),
        IconButton(
          onPressed: onClose ?? () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  /// Shows confirmation dialog when closing with unsaved changes
  Future<bool?> _showUnsavedChangesDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (dialogContext) => PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          // When barrierDismissible is true and user taps outside,
          // Flutter automatically pops the dialog, so we don't need to pop again
          // This prevents the Navigator lock error
          if (didPop) {
            // Dialog was already popped by Flutter (back button or outside tap)
            // No need to pop again
            return;
          }
        },
        child: AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. What would you like to do?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Discard', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
    return result;
  }

  /// Builds main card container matching skill test instructions design
  Widget _buildMainCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// Helper function to check if two lists of strings are equal
  bool _areStringListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    final sorted1 = [...list1]..sort();
    final sorted2 = [...list2]..sort();
    for (int i = 0; i < sorted1.length; i++) {
      if (sorted1[i].trim() != sorted2[i].trim()) return false;
    }
    return true;
  }

  /// Check if a string is coordinates format (latitude, longitude)
  bool _isCoordinates(String text) {
    if (text.isEmpty) return false;

    final trimmed = text.trim();

    // Check for patterns like "Lat: X.XXXX, Lng: Y.YYYY"
    final coordPattern1 = RegExp(
      r'^Lat:\s*-?\d+\.?\d*,\s*Lng:\s*-?\d+\.?\d*',
      caseSensitive: false,
    );

    // Check for patterns like "X.XXXX, Y.YYYY" (two decimal numbers separated by comma)
    final coordPattern2 = RegExp(r'^-?\d+\.?\d+\s*,\s*-?\d+\.?\d+$');

    // Check for patterns like "X.XXXX, Y.YYYY" with optional spaces
    final coordPattern3 = RegExp(r'^-?\d+\.\d+\s*,\s*-?\d+\.\d+');

    return coordPattern1.hasMatch(trimmed) ||
        coordPattern2.hasMatch(trimmed) ||
        coordPattern3.hasMatch(trimmed);
  }

  /// Helper function to normalize education map for comparison
  Map<String, dynamic> _normalizeEducationMap(Map<String, dynamic> edu) {
    return {
      'qualification': (edu['qualification'] ?? '').toString().trim(),
      'institute': (edu['institute'] ?? '').toString().trim(),
      'startYear': (edu['startYear'] ?? '').toString().trim(),
      'endYear': (edu['endYear'] ?? '').toString().trim(),
      'isPursuing':
          edu['isPursuing'] == true ||
          edu['isPursuing'] == 1 ||
          edu['isPursuing'] == '1' ||
          edu['isPursuing'] == 'true',
      'pursuingYear': edu['pursuingYear'],
      'cgpa': (edu['cgpa'] ?? '').toString().trim(),
    };
  }

  /// Helper function to check if two education lists are equal
  bool _areEducationListsEqual(
    List<Map<String, dynamic>> list1,
    List<Map<String, dynamic>> list2,
  ) {
    // Filter out empty entries from both lists
    final filtered1 = list1
        .map(_normalizeEducationMap)
        .where(
          (edu) =>
              edu['qualification'].toString().isNotEmpty ||
              edu['institute'].toString().isNotEmpty,
        )
        .toList();
    final filtered2 = list2
        .map(_normalizeEducationMap)
        .where(
          (edu) =>
              edu['qualification'].toString().isNotEmpty ||
              edu['institute'].toString().isNotEmpty,
        )
        .toList();

    if (filtered1.length != filtered2.length) return false;

    // Sort by qualification and institute for comparison
    filtered1.sort((a, b) {
      final key1 = '${a['qualification']}_${a['institute']}';
      final key2 = '${b['qualification']}_${b['institute']}';
      return key1.compareTo(key2);
    });
    filtered2.sort((a, b) {
      final key1 = '${a['qualification']}_${a['institute']}';
      final key2 = '${b['qualification']}_${b['institute']}';
      return key1.compareTo(key2);
    });

    for (int i = 0; i < filtered1.length; i++) {
      final edu1 = filtered1[i];
      final edu2 = filtered2[i];
      if (edu1['qualification'] != edu2['qualification'] ||
          edu1['institute'] != edu2['institute'] ||
          edu1['startYear'] != edu2['startYear'] ||
          edu1['endYear'] != edu2['endYear'] ||
          edu1['isPursuing'] != edu2['isPursuing'] ||
          edu1['pursuingYear'] != edu2['pursuingYear'] ||
          edu1['cgpa'] != edu2['cgpa']) {
        return false;
      }
    }
    return true;
  }

  /// Helper function to normalize experience map for comparison
  Map<String, dynamic> _normalizeExperienceMap(Map<String, dynamic> exp) {
    return {
      'company': (exp['company'] ?? '').toString().trim(),
      'position': (exp['position'] ?? '').toString().trim(),
      'startDate': (exp['startDate'] ?? '').toString().trim(),
      'endDate': (exp['endDate'] ?? '').toString().trim(),
      'description': (exp['description'] ?? '').toString().trim(),
    };
  }

  /// Helper function to check if two experience lists are equal
  bool _areExperienceListsEqual(
    List<Map<String, dynamic>> list1,
    List<Map<String, dynamic>> list2,
  ) {
    // Filter out empty entries from both lists
    final filtered1 = list1
        .map(_normalizeExperienceMap)
        .where((exp) => exp.values.any((value) => value.toString().isNotEmpty))
        .toList();
    final filtered2 = list2
        .map(_normalizeExperienceMap)
        .where((exp) => exp.values.any((value) => value.toString().isNotEmpty))
        .toList();

    if (filtered1.length != filtered2.length) return false;

    // Sort by company and position for comparison
    filtered1.sort((a, b) {
      final key1 = '${a['company']}_${a['position']}';
      final key2 = '${b['company']}_${b['position']}';
      return key1.compareTo(key2);
    });
    filtered2.sort((a, b) {
      final key1 = '${a['company']}_${a['position']}';
      final key2 = '${b['company']}_${b['position']}';
      return key1.compareTo(key2);
    });

    for (int i = 0; i < filtered1.length; i++) {
      final exp1 = filtered1[i];
      final exp2 = filtered2[i];
      if (exp1['company'] != exp2['company'] ||
          exp1['position'] != exp2['position'] ||
          exp1['startDate'] != exp2['startDate'] ||
          exp1['endDate'] != exp2['endDate'] ||
          exp1['description'] != exp2['description']) {
        return false;
      }
    }
    return true;
  }

  /// Helper function to normalize certificate map for comparison
  Map<String, dynamic> _normalizeCertificateMap(Map<String, dynamic> cert) {
    return {
      'name': (cert['name'] ?? '').toString().trim(),
      'type': (cert['type'] ?? 'Certificate').toString().trim(),
      'uploadDate': (cert['uploadDate'] ?? '').toString().trim(),
      'path': (cert['path'] ?? '').toString().trim(),
    };
  }

  /// Helper function to check if two certificate lists are equal
  bool _areCertificateListsEqual(
    List<Map<String, dynamic>> list1,
    List<Map<String, dynamic>> list2,
  ) {
    // Filter out empty entries from both lists
    final filtered1 = list1
        .map(_normalizeCertificateMap)
        .where((cert) => cert['name'].toString().isNotEmpty)
        .toList();
    final filtered2 = list2
        .map(_normalizeCertificateMap)
        .where((cert) => cert['name'].toString().isNotEmpty)
        .toList();

    if (filtered1.length != filtered2.length) return false;

    // Sort by name for comparison
    filtered1.sort((a, b) => a['name'].compareTo(b['name']));
    filtered2.sort((a, b) => a['name'].compareTo(b['name']));

    for (int i = 0; i < filtered1.length; i++) {
      final cert1 = filtered1[i];
      final cert2 = filtered2[i];
      if (cert1['name'] != cert2['name'] ||
          cert1['type'] != cert2['type'] ||
          cert1['uploadDate'] != cert2['uploadDate'] ||
          cert1['path'] != cert2['path']) {
        return false;
      }
    }
    return true;
  }

  /// Helper function to normalize social link map for comparison
  Map<String, dynamic> _normalizeSocialLinkMap(Map<String, dynamic> link) {
    return {
      'title': (link['title'] ?? '').toString().trim(),
      'profile_url': (link['profile_url'] ?? '').toString().trim(),
    };
  }

  /// Helper function to check if two social link lists are equal
  bool _areSocialLinkListsEqual(
    List<Map<String, dynamic>> list1,
    List<Map<String, dynamic>> list2,
  ) {
    // Filter out empty entries from both lists
    final filtered1 = list1
        .map(_normalizeSocialLinkMap)
        .where(
          (link) =>
              link['title'].toString().isNotEmpty ||
              link['profile_url'].toString().isNotEmpty,
        )
        .toList();
    final filtered2 = list2
        .map(_normalizeSocialLinkMap)
        .where(
          (link) =>
              link['title'].toString().isNotEmpty ||
              link['profile_url'].toString().isNotEmpty,
        )
        .toList();

    if (filtered1.length != filtered2.length) return false;

    // Sort by title for comparison
    filtered1.sort((a, b) => a['title'].compareTo(b['title']));
    filtered2.sort((a, b) => a['title'].compareTo(b['title']));

    for (int i = 0; i < filtered1.length; i++) {
      final link1 = filtered1[i];
      final link2 = filtered2[i];
      if (link1['title'] != link2['title'] ||
          link1['profile_url'] != link2['profile_url']) {
        return false;
      }
    }
    return true;
  }

  /// Helper function to check if two maps are equal (for contact, general info, etc.)
  bool _areMapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    final keys = {...map1.keys, ...map2.keys};
    for (final key in keys) {
      final val1 = map1[key]?.toString().trim() ?? '';
      final val2 = map2[key]?.toString().trim() ?? '';
      if (val1 != val2) return false;
    }
    return true;
  }

  Widget _buildSkillsEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required List<String> initialSkills,
    required List<String> skillsDraft,
    required TextEditingController newSkillController,
  }) {
    // ✅ State containers and controller passed from parent (created BEFORE showModalBottomSheet)
    // ✅ No recreation here - they persist across rebuilds

    void addSkill(String value, void Function(void Function()) setModalState) {
      final trimmedValue = value.trim();
      if (trimmedValue.isEmpty) {
        return;
      }
      final exists = skillsDraft.any(
        (skill) => skill.toLowerCase() == trimmedValue.toLowerCase(),
      );
      if (exists) {
        TopSnackBar.showInfo(parentContext, message: 'Skill already exists.');
        return;
      }
      setModalState(() {
        skillsDraft.add(trimmedValue);
        newSkillController.clear();
      });
    }

    return StatefulBuilder(
      builder: (context, setModalState) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;
        // Check if there are changes
        final sanitizedCurrent = skillsDraft
            .map((skill) => skill.trim())
            .where((skill) => skill.isNotEmpty)
            .toList();
        final sanitizedInitial = initialSkills
            .map((skill) => skill.trim())
            .where((skill) => skill.isNotEmpty)
            .toList();
        final hasChanges = !_areStringListsEqual(
          sanitizedCurrent,
          sanitizedInitial,
        );

        Future<void> handleClose() async {
          if (hasChanges) {
            final shouldSave = await _showUnsavedChangesDialog(context);
            if (shouldSave == null) return; // Dialog dismissed
            if (shouldSave) {
              // Save changes
              final sanitizedSkills = skillsDraft
                  .map((skill) => skill.trim())
                  .where((skill) => skill.isNotEmpty)
                  .toList();
              bloc.add(UpdateProfileSkillsInlineEvent(skills: sanitizedSkills));
            }
          }
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }

        return PopScope(
          canPop: !hasChanges,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop && hasChanges) {
              await handleClose();
            }
          },
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSheetHeader(
                          context: context,
                          title: 'Edit Skills',
                          onClose: handleClose,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        _buildMainCard(
                          children: [
                            if (skillsDraft.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(
                                  AppConstants.defaultPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: const Text(
                                  'No skills added yet. Add your skills to improve your profile.',
                                  style: TextStyle(
                                    color: AppConstants.textSecondaryColor,
                                  ),
                                ),
                              ),
                            if (skillsDraft.isNotEmpty) ...[
                              ...List.generate(skillsDraft.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppConstants.smallPadding,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          key: ValueKey('skill_field_$index'),
                                          initialValue: skillsDraft[index],
                                          decoration: InputDecoration(
                                            labelText: 'Skill ${index + 1}',
                                            border: const OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            setModalState(() {
                                              skillsDraft[index] = value;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        tooltip: 'Remove skill',
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppConstants.errorColor,
                                        ),
                                        onPressed: () {
                                          setModalState(() {
                                            skillsDraft.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(
                                height: AppConstants.defaultPadding,
                              ),
                            ],
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: newSkillController,
                                    decoration: const InputDecoration(
                                      labelText: 'Add new skill',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLength: 25,
                                    onSubmitted: (value) =>
                                        addSkill(value, setModalState),
                                  ),
                                ),
                                const SizedBox(
                                  width: AppConstants.smallPadding,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: ElevatedButton.icon(
                                    onPressed: () => addSkill(
                                      newSkillController.text,
                                      setModalState,
                                    ),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Add'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Fixed bottom button
                Container(
                  padding: EdgeInsets.only(
                    left: AppConstants.defaultPadding,
                    right: AppConstants.defaultPadding,
                    top: AppConstants.defaultPadding,
                    bottom: viewInsets + AppConstants.defaultPadding,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.cardBackgroundColor,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hasChanges
                          ? () {
                              final sanitizedSkills = skillsDraft
                                  .map((skill) => skill.trim())
                                  .where((skill) => skill.isNotEmpty)
                                  .toList();
                              bloc.add(
                                UpdateProfileSkillsInlineEvent(
                                  skills: sanitizedSkills,
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasChanges
                            ? Colors.green
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        elevation: hasChanges ? 2 : 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExperienceEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required List<Map<String, dynamic>> initialExperience,
    required List<Map<String, dynamic>> experienceDrafts,
    required ValueNotifier<int> experienceRebuildCounter,
  }) {
    // ✅ State containers and counter passed from parent (created BEFORE showModalBottomSheet)
    // ✅ No recreation here - they persist across rebuilds

    return StatefulBuilder(
      builder: (context, setModalState) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;
        // Check if there are changes
        final sanitizedCurrent = experienceDrafts
            .map(_normalizeExperienceMap)
            .where(
              (exp) => exp.values.any((value) => value.toString().isNotEmpty),
            )
            .toList();
        final sanitizedInitial = initialExperience
            .map(_normalizeExperienceMap)
            .where(
              (exp) => exp.values.any((value) => value.toString().isNotEmpty),
            )
            .toList();
        final hasChanges = !_areExperienceListsEqual(
          sanitizedCurrent,
          sanitizedInitial,
        );

        Future<void> handleClose() async {
          if (hasChanges) {
            final shouldSave = await _showUnsavedChangesDialog(context);
            if (shouldSave == null) return; // Dialog dismissed
            if (shouldSave) {
              // Save changes
              final sanitizedExperience = experienceDrafts
                  .map(_normalizeExperienceMap)
                  .where(
                    (exp) =>
                        exp.values.any((value) => value.toString().isNotEmpty),
                  )
                  .toList();

              final hasInvalidEntry = sanitizedExperience.any(
                (exp) =>
                    (exp['company'] as String).isEmpty ||
                    (exp['position'] as String).isEmpty,
              );

              if (hasInvalidEntry) {
                TopSnackBar.showError(
                  parentContext,
                  message: 'Company and position are required.',
                );
                return;
              }

              bloc.add(
                UpdateProfileExperienceListEvent(
                  experience: sanitizedExperience,
                ),
              );
            }
          }
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }

        void addEmptyExperience() {
          setModalState(() {
            experienceDrafts.add({
              'company': '',
              'position': '',
              'startDate': '',
              'endDate': '',
              'description': '',
            });
          });
        }

        void deleteExperience(int index) {
          setModalState(() {
            final isLastBlock = experienceDrafts.length == 1;

            // If it's the last block, clear its data instead of removing
            if (isLastBlock) {
              experienceDrafts[0] = {
                'company': '',
                'position': '',
                'startDate': '',
                'endDate': '',
                'description': '',
              };
              // Increment counter to force rebuild of fields
              experienceRebuildCounter.value++;
            } else {
              // Remove the block if there are multiple blocks
              experienceDrafts.removeAt(index);
            }
          });
        }

        return PopScope(
          canPop: !hasChanges,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop && hasChanges) {
              await handleClose();
            }
          },
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSheetHeader(
                          context: context,
                          title: 'Edit Work Experience',
                          onClose: handleClose,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        _buildMainCard(
                          children: [
                            ...List.generate(experienceDrafts.length, (index) {
                              final experience = experienceDrafts[index];
                              return Container(
                                margin: const EdgeInsets.only(
                                  bottom: AppConstants.defaultPadding,
                                ),
                                padding: const EdgeInsets.all(
                                  AppConstants.defaultPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.backgroundColor,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadius,
                                  ),
                                  border: Border.all(
                                    color: AppConstants.borderColor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Experience ${index + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        // Show delete icon only if block has data
                                        // Don't show delete icon if it's the last block and it's completely empty
                                        Builder(
                                          builder: (context) {
                                            final isLastBlock =
                                                experienceDrafts.length == 1;
                                            final hasData =
                                                (experience['company']
                                                        ?.toString()
                                                        .trim()
                                                        .isNotEmpty ??
                                                    false) ||
                                                (experience['position']
                                                        ?.toString()
                                                        .trim()
                                                        .isNotEmpty ??
                                                    false) ||
                                                (experience['startDate']
                                                        ?.toString()
                                                        .trim()
                                                        .isNotEmpty ??
                                                    false) ||
                                                (experience['endDate']
                                                        ?.toString()
                                                        .trim()
                                                        .isNotEmpty ??
                                                    false) ||
                                                (experience['description']
                                                        ?.toString()
                                                        .trim()
                                                        .isNotEmpty ??
                                                    false);

                                            // Show delete icon if block has data, or if it's not the last block
                                            if (hasData || !isLastBlock) {
                                              return IconButton(
                                                tooltip: 'Delete experience',
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color:
                                                      AppConstants.errorColor,
                                                ),
                                                onPressed: () =>
                                                    deleteExperience(index),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    TextFormField(
                                      key: ValueKey(
                                        'experience_company_${index}_${experienceRebuildCounter.value}',
                                      ),
                                      initialValue:
                                          (experience['company'] ?? '')
                                              as String,
                                      decoration: const InputDecoration(
                                        labelText: 'Company *',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setModalState(() {
                                          experience['company'] = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    TextFormField(
                                      key: ValueKey(
                                        'experience_position_${index}_${experienceRebuildCounter.value}',
                                      ),
                                      initialValue:
                                          (experience['position'] ?? '')
                                              as String,
                                      decoration: const InputDecoration(
                                        labelText: 'Position *',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setModalState(() {
                                          experience['position'] = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Builder(
                                            builder: (context) {
                                              final startDateStr =
                                                  (experience['startDate'] ??
                                                          '')
                                                      as String;
                                              DateTime? startDate = _parseDate(
                                                startDateStr,
                                              );
                                              final displayStartDate =
                                                  startDate != null
                                                  ? _formatDate(startDate)
                                                  : '';

                                              return TextFormField(
                                                key: ValueKey(
                                                  'experience_start_${index}_${experience['startDate']}',
                                                ),
                                                initialValue: displayStartDate,
                                                readOnly: true,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Start Date',
                                                      hintText: 'Select date',
                                                      border:
                                                          OutlineInputBorder(),
                                                      suffixIcon: Icon(
                                                        Icons.calendar_today,
                                                      ),
                                                    ),
                                                onTap: () async {
                                                  final pickedDate =
                                                      await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            startDate ??
                                                            DateTime.now(),
                                                        firstDate: DateTime(
                                                          1900,
                                                        ),
                                                        lastDate:
                                                            DateTime.now(),
                                                      );
                                                  if (pickedDate != null) {
                                                    setModalState(() {
                                                      experience['startDate'] =
                                                          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                                                    });
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: AppConstants.smallPadding,
                                        ),
                                        Expanded(
                                          child: Builder(
                                            builder: (context) {
                                              final endDateStr =
                                                  (experience['endDate'] ?? '')
                                                      as String;
                                              final isPresent =
                                                  endDateStr.toLowerCase() ==
                                                      'present' ||
                                                  endDateStr.isEmpty;
                                              DateTime? endDate = isPresent
                                                  ? null
                                                  : _parseDate(endDateStr);
                                              final displayEndDate = isPresent
                                                  ? 'Present'
                                                  : (endDate != null
                                                        ? _formatDate(endDate)
                                                        : '');

                                              return TextFormField(
                                                key: ValueKey(
                                                  'experience_end_${index}_${experience['endDate']}',
                                                ),
                                                initialValue: displayEndDate,
                                                readOnly: true,
                                                decoration: const InputDecoration(
                                                  labelText: 'End Date',
                                                  hintText:
                                                      'Select date or leave for Present',
                                                  border: OutlineInputBorder(),
                                                  suffixIcon: Icon(
                                                    Icons.calendar_today,
                                                  ),
                                                ),
                                                onTap: () async {
                                                  final pickedDate =
                                                      await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            endDate ??
                                                            DateTime.now(),
                                                        firstDate: DateTime(
                                                          1900,
                                                        ),
                                                        lastDate:
                                                            DateTime.now(),
                                                      );
                                                  if (pickedDate != null) {
                                                    setModalState(() {
                                                      experience['endDate'] =
                                                          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                                                    });
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    TextFormField(
                                      key: ValueKey(
                                        'experience_description_${index}_${experienceRebuildCounter.value}',
                                      ),
                                      initialValue:
                                          (experience['description'] ?? '')
                                              as String,
                                      decoration: const InputDecoration(
                                        labelText: 'Description',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 3,
                                      onChanged: (value) {
                                        setModalState(() {
                                          experience['description'] = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: AppConstants.defaultPadding),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: addEmptyExperience,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Experience'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Fixed bottom button
                Container(
                  padding: EdgeInsets.only(
                    left: AppConstants.defaultPadding,
                    right: AppConstants.defaultPadding,
                    top: AppConstants.defaultPadding,
                    bottom: viewInsets + AppConstants.defaultPadding,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.cardBackgroundColor,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hasChanges
                          ? () {
                              final sanitizedExperience = experienceDrafts
                                  .map(
                                    (exp) => {
                                      'company': (exp['company'] ?? '').trim(),
                                      'position': (exp['position'] ?? '')
                                          .trim(),
                                      'startDate': (exp['startDate'] ?? '')
                                          .trim(),
                                      'endDate': (exp['endDate'] ?? '').trim(),
                                      'description': (exp['description'] ?? '')
                                          .trim(),
                                    },
                                  )
                                  .where(
                                    (exp) => exp.values.any(
                                      (value) => value.toString().isNotEmpty,
                                    ),
                                  )
                                  .toList();

                              final hasInvalidEntry = sanitizedExperience.any(
                                (exp) =>
                                    (exp['company'] as String).isEmpty ||
                                    (exp['position'] as String).isEmpty ||
                                    (exp['startDate'] as String).isEmpty,
                              );

                              if (hasInvalidEntry) {
                                ScaffoldMessenger.of(
                                  parentContext,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please fill company, position, and start date for each experience.',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              bloc.add(
                                UpdateProfileExperienceListEvent(
                                  experience: sanitizedExperience,
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasChanges
                            ? Colors.green
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        elevation: hasChanges ? 2 : 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEducationEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required List<Map<String, dynamic>> initialEducation,
    required List<Map<String, dynamic>> educationDrafts,
    required ValueNotifier<int> educationRebuildCounter,
  }) {
    // ✅ State containers and counter passed from parent (created BEFORE showModalBottomSheet)
    // ✅ No recreation here - they persist across rebuilds

    return StatefulBuilder(
      builder: (context, setModalState) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;
        // Check if there are changes
        final sanitizedCurrent = educationDrafts
            .map(_normalizeEducationMap)
            .where(
              (edu) =>
                  edu['qualification'].toString().isNotEmpty ||
                  edu['institute'].toString().isNotEmpty,
            )
            .toList();
        final sanitizedInitial = initialEducation
            .map(_normalizeEducationMap)
            .where(
              (edu) =>
                  edu['qualification'].toString().isNotEmpty ||
                  edu['institute'].toString().isNotEmpty,
            )
            .toList();
        final hasChanges = !_areEducationListsEqual(
          sanitizedCurrent,
          sanitizedInitial,
        );

        Future<void> handleClose() async {
          if (hasChanges) {
            final shouldSave = await _showUnsavedChangesDialog(context);
            if (shouldSave == null) return; // Dialog dismissed
            if (shouldSave) {
              // Save changes - First filter out completely empty entries (like Work Experience)
              final sanitizedEducation = educationDrafts
                  .map(_normalizeEducationMap)
                  .where(
                    (edu) =>
                        (edu['qualification'] as String).isNotEmpty ||
                        (edu['institute'] as String).isNotEmpty ||
                        (edu['startYear'] as String).isNotEmpty ||
                        (edu['endYear'] as String).isNotEmpty ||
                        (edu['cgpa'] as String).isNotEmpty ||
                        edu['isPursuing'] == true,
                  )
                  .toList();

              // Only validate if there are entries after filtering
              // If all entries were empty and filtered out, allow save (like Work Experience)
              if (sanitizedEducation.isNotEmpty) {
                final hasInvalidEntry = sanitizedEducation.any(
                  (edu) =>
                      (edu['qualification'] as String).isEmpty ||
                      (edu['institute'] as String).isEmpty,
                );

                if (hasInvalidEntry) {
                  TopSnackBar.showError(
                    parentContext,
                    message: 'Qualification and institute are required.',
                  );
                  return;
                }
              }

              bloc.add(
                UpdateProfileEducationListEvent(education: sanitizedEducation),
              );
            }
          }
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }

        void addEducation() {
          setModalState(() {
            educationDrafts.add({
              'qualification': '',
              'institute': '',
              'startYear': '',
              'endYear': '',
              'isPursuing': false,
              'pursuingYear': null,
              'cgpa': '',
            });
          });
        }

        void deleteEducation(int index) {
          setModalState(() {
            final isLastBlock = educationDrafts.length == 1;

            // If it's the last block, clear its data instead of removing
            if (isLastBlock) {
              educationDrafts[0] = {
                'qualification': '',
                'institute': '',
                'startYear': '',
                'endYear': '',
                'isPursuing': false,
                'pursuingYear': null,
                'cgpa': '',
              };
              // Increment counter to force rebuild of fields
              educationRebuildCounter.value++;
            } else {
              // Remove the block if there are multiple blocks
              educationDrafts.removeAt(index);
            }
          });
        }

        return PopScope(
          canPop: !hasChanges,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop && hasChanges) {
              await handleClose();
            }
          },
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSheetHeader(
                          context: context,
                          title: 'Edit Education',
                          onClose: handleClose,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        _buildMainCard(
                          children: [
                            ...List.generate(educationDrafts.length, (index) {
                              final education = educationDrafts[index];
                              return Container(
                                margin: const EdgeInsets.only(
                                  bottom: AppConstants.defaultPadding,
                                ),
                                padding: const EdgeInsets.all(
                                  AppConstants.defaultPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.backgroundColor,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadius,
                                  ),
                                  border: Border.all(
                                    color: AppConstants.borderColor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Education ${index + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        // Show delete icon only if block has data
                                        // Don't show delete icon if it's the last block and it's completely empty
                                        Builder(
                                          builder: (context) {
                                            final isLastBlock =
                                                educationDrafts.length == 1;
                                            final hasData =
                                                (education['qualification']
                                                        ?.toString()
                                                        .trim()
                                                        .isNotEmpty ??
                                                    false) ||
                                                (education['institute']
                                                        ?.toString()
                                                        .trim()
                                                        .isNotEmpty ??
                                                    false) ||
                                                (education['startYear']
                                                        ?.toString()
                                                        .trim()
                                                        .isNotEmpty ??
                                                    false) ||
                                                (education['endYear']
                                                        ?.toString()
                                                        .trim()
                                                        .isNotEmpty ??
                                                    false) ||
                                                (education['cgpa']
                                                        ?.toString()
                                                        .trim()
                                                        .isNotEmpty ??
                                                    false) ||
                                                (education['isPursuing'] ==
                                                    true);

                                            // Show delete icon if block has data, or if it's not the last block
                                            if (hasData || !isLastBlock) {
                                              return IconButton(
                                                tooltip: 'Delete education',
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color:
                                                      AppConstants.errorColor,
                                                ),
                                                onPressed: () =>
                                                    deleteEducation(index),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    TextFormField(
                                      key: ValueKey(
                                        'education_qualification_${index}_${educationRebuildCounter.value}',
                                      ),
                                      initialValue:
                                          education['qualification'] != null
                                          ? education['qualification']
                                                .toString()
                                          : '',
                                      decoration: const InputDecoration(
                                        labelText: 'Qualification *',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setModalState(() {
                                          education['qualification'] = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    TextFormField(
                                      key: ValueKey(
                                        'education_institute_${index}_${educationRebuildCounter.value}',
                                      ),
                                      initialValue:
                                          education['institute'] != null
                                          ? education['institute'].toString()
                                          : '',
                                      decoration: const InputDecoration(
                                        labelText: 'Institute *',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setModalState(() {
                                          education['institute'] = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            key: ValueKey(
                                              'education_startYear_${index}_${educationRebuildCounter.value}',
                                            ),
                                            initialValue:
                                                education['startYear'] != null
                                                ? education['startYear']
                                                      .toString()
                                                : '',
                                            decoration: const InputDecoration(
                                              labelText: 'Start Year',
                                              border: OutlineInputBorder(),
                                              hintText: 'e.g., 2020',
                                            ),
                                            keyboardType: TextInputType.number,
                                            maxLength: 4,
                                            onChanged: (value) {
                                              setModalState(() {
                                                education['startYear'] = value;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: AppConstants.smallPadding,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            key: ValueKey(
                                              'education_endYear_${index}_${educationRebuildCounter.value}',
                                            ),
                                            initialValue:
                                                education['endYear'] != null
                                                ? education['endYear']
                                                      .toString()
                                                : '',
                                            decoration: const InputDecoration(
                                              labelText: 'End Year',
                                              border: OutlineInputBorder(),
                                              hintText: 'e.g., 2024',
                                            ),
                                            keyboardType: TextInputType.number,
                                            maxLength: 4,
                                            enabled:
                                                !(education['isPursuing'] ==
                                                    true),
                                            onChanged: (value) {
                                              setModalState(() {
                                                education['endYear'] = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Currently Pursuing'),
                                      value: education['isPursuing'] == true,
                                      onChanged: (value) {
                                        setModalState(() {
                                          education['isPursuing'] =
                                              value ?? false;
                                          if (value == true) {
                                            education['endYear'] = '';
                                          }
                                        });
                                      },
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    if (education['isPursuing'] == true) ...[
                                      const SizedBox(
                                        height: AppConstants.smallPadding,
                                      ),
                                      DropdownButtonFormField<int>(
                                        key: ValueKey(
                                          'education_pursuingYear_$index',
                                        ),
                                        value: () {
                                          // Get the pursuingYear value
                                          final pursuingYear =
                                              education['pursuingYear'];
                                          if (pursuingYear == null) return null;

                                          // Try to parse as int
                                          int? yearValue;
                                          if (pursuingYear is int) {
                                            yearValue = pursuingYear;
                                          } else {
                                            yearValue = int.tryParse(
                                              pursuingYear.toString(),
                                            );
                                          }

                                          // Only return if it's a valid academic year (1-4)
                                          // If it's a full year like 2024, return null
                                          if (yearValue != null &&
                                              yearValue >= 1 &&
                                              yearValue <= 4) {
                                            return yearValue;
                                          }
                                          return null;
                                        }(),
                                        decoration: const InputDecoration(
                                          labelText: 'Pursuing Year',
                                          border: OutlineInputBorder(),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 1,
                                            child: Text('1st Year'),
                                          ),
                                          DropdownMenuItem(
                                            value: 2,
                                            child: Text('2nd Year'),
                                          ),
                                          DropdownMenuItem(
                                            value: 3,
                                            child: Text('3rd Year'),
                                          ),
                                          DropdownMenuItem(
                                            value: 4,
                                            child: Text('4th Year'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setModalState(() {
                                            education['pursuingYear'] = value;
                                          });
                                        },
                                      ),
                                    ],
                                    const SizedBox(
                                      height: AppConstants.smallPadding,
                                    ),
                                    TextFormField(
                                      key: ValueKey(
                                        'education_cgpa_${index}_${educationRebuildCounter.value}',
                                      ),
                                      initialValue: education['cgpa'] != null
                                          ? education['cgpa'].toString()
                                          : '',
                                      decoration: const InputDecoration(
                                        labelText: 'CGPA / Percentage',
                                        border: OutlineInputBorder(),
                                        hintText: 'e.g., 8.5 or 85%',
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setModalState(() {
                                          education['cgpa'] = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: AppConstants.defaultPadding),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: addEducation,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Education'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Fixed bottom button
                Container(
                  padding: EdgeInsets.only(
                    left: AppConstants.defaultPadding,
                    right: AppConstants.defaultPadding,
                    top: AppConstants.defaultPadding,
                    bottom: viewInsets + AppConstants.defaultPadding,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.cardBackgroundColor,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hasChanges
                          ? () {
                              // First filter out completely empty entries (like Work Experience)
                              final sanitizedEducation = educationDrafts
                                  .map(
                                    (edu) => {
                                      'qualification':
                                          (edu['qualification'] ?? '')
                                              .toString()
                                              .trim(),
                                      'institute': (edu['institute'] ?? '')
                                          .toString()
                                          .trim(),
                                      'startYear': (edu['startYear'] ?? '')
                                          .toString()
                                          .trim(),
                                      'endYear': (edu['endYear'] ?? '')
                                          .toString()
                                          .trim(),
                                      'isPursuing':
                                          edu['isPursuing'] == true ||
                                          edu['isPursuing'] == 1 ||
                                          edu['isPursuing'] == '1' ||
                                          edu['isPursuing'] == 'true',
                                      'pursuingYear': edu['pursuingYear'],
                                      'cgpa': (edu['cgpa'] ?? '')
                                          .toString()
                                          .trim(),
                                    },
                                  )
                                  .where(
                                    (edu) =>
                                        (edu['qualification'] as String)
                                            .isNotEmpty ||
                                        (edu['institute'] as String)
                                            .isNotEmpty ||
                                        (edu['startYear'] as String)
                                            .isNotEmpty ||
                                        (edu['endYear'] as String).isNotEmpty ||
                                        (edu['cgpa'] as String).isNotEmpty ||
                                        edu['isPursuing'] == true,
                                  )
                                  .toList();

                              // Only validate if there are entries after filtering
                              // If all entries were empty and filtered out, allow save (like Work Experience)
                              if (sanitizedEducation.isNotEmpty) {
                                final hasInvalidEntry = sanitizedEducation.any(
                                  (edu) =>
                                      (edu['qualification'] as String)
                                          .isEmpty ||
                                      (edu['institute'] as String).isEmpty,
                                );

                                if (hasInvalidEntry) {
                                  ScaffoldMessenger.of(
                                    parentContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Qualification and institute are required.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                              }

                              bloc.add(
                                UpdateProfileEducationListEvent(
                                  education: sanitizedEducation,
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasChanges
                            ? Colors.green
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        elevation: hasChanges ? 2 : 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResumeEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    String? resumeFileName,
    String? lastUpdated,
    String? downloadUrl,
  }) {
    final nameController = TextEditingController(text: resumeFileName ?? '');
    final dateController = TextEditingController(text: lastUpdated ?? '');
    final urlController = TextEditingController(text: downloadUrl ?? '');
    final formKey = GlobalKey<FormState>();

    return StatefulBuilder(
      builder: (context, setModalState) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        // Add listeners to trigger rebuilds when text changes
        void setupListeners() {
          nameController.removeListener(() {});
          dateController.removeListener(() {});
          urlController.removeListener(() {});
          nameController.addListener(() => setModalState(() {}));
          dateController.addListener(() => setModalState(() {}));
          urlController.addListener(() => setModalState(() {}));
        }

        setupListeners();

        // Check if there are changes
        final currentName = nameController.text.trim();
        final currentDate = dateController.text.trim();
        final currentUrl = urlController.text.trim();
        final initialName = (resumeFileName ?? '').trim();
        final initialDate = (lastUpdated ?? '').trim();
        final initialUrl = (downloadUrl ?? '').trim();
        final hasChanges =
            currentName != initialName ||
            currentDate != initialDate ||
            currentUrl != initialUrl;

        String? validateUrl(String? value) {
          final trimmed = value?.trim() ?? '';
          if (trimmed.isEmpty) {
            return null;
          }
          final uri = Uri.tryParse(trimmed);
          if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
            return 'Enter a valid URL starting with http or https';
          }
          return null;
        }

        Future<void> handleClose() async {
          if (hasChanges) {
            final shouldSave = await _showUnsavedChangesDialog(context);
            if (shouldSave == null) return; // Dialog dismissed
            if (shouldSave) {
              // Save changes
              if (!formKey.currentState!.validate()) {
                return;
              }
              final name = nameController.text.trim();
              final updated = dateController.text.trim();
              final url = urlController.text.trim();
              final hasOtherValues = updated.isNotEmpty || url.isNotEmpty;

              if (name.isEmpty && hasOtherValues) {
                TopSnackBar.showError(
                  parentContext,
                  message:
                      'Resume name is required when other details are provided.',
                );
                return;
              }

              bloc.add(
                UpdateProfileResumeInlineEvent(
                  fileName: name,
                  lastUpdated: updated.isNotEmpty ? updated : null,
                  downloadUrl: url.isNotEmpty ? url : null,
                ),
              );
            }
          }
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }

        return PopScope(
          canPop: !hasChanges,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop && hasChanges) {
              await handleClose();
            }
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: viewInsets),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSheetHeader(
                          context: context,
                          title: 'Edit Resume',
                          onClose: handleClose,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Resume File Name',
                            hintText: 'Resume.pdf',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        TextFormField(
                          controller: dateController,
                          decoration: const InputDecoration(
                            labelText: 'Last Updated',
                            hintText: 'e.g., 15 July 2024',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        TextFormField(
                          controller: urlController,
                          decoration: const InputDecoration(
                            labelText: 'Resume URL (optional)',
                            hintText: 'https://example.com/resume.pdf',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.url,
                          validator: validateUrl,
                        ),
                        const SizedBox(height: AppConstants.largePadding),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: hasChanges
                                ? () {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    final name = nameController.text.trim();
                                    final updated = dateController.text.trim();
                                    final url = urlController.text.trim();
                                    final hasOtherValues =
                                        updated.isNotEmpty || url.isNotEmpty;

                                    if (name.isEmpty && hasOtherValues) {
                                      ScaffoldMessenger.of(
                                        parentContext,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Resume name is required when other details are provided.',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }

                                    bloc.add(
                                      UpdateProfileResumeInlineEvent(
                                        fileName: name,
                                        lastUpdated: updated.isNotEmpty
                                            ? updated
                                            : null,
                                        downloadUrl: url.isNotEmpty
                                            ? url
                                            : null,
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasChanges
                                  ? Colors.green
                                  : Colors.grey.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadius,
                                ),
                              ),
                              elevation: hasChanges ? 2 : 0,
                            ),
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCertificatesEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required List<Map<String, dynamic>> initialCertificates,
  }) {
    final certificateDrafts = initialCertificates
        .map((cert) => Map<String, dynamic>.from(cert))
        .toList();

    if (certificateDrafts.isEmpty) {
      certificateDrafts.add({
        'name': '',
        'type': 'Certificate',
        'uploadDate': '',
        'path': '',
        'extension': '',
        'size': 0,
      });
    }

    const certificateTypes = ['Certificate', 'License', 'ID Proof', 'Other'];

    String inferExtensionFromInputs({
      required String name,
      required String url,
    }) {
      final candidates = <String>[name, url];
      for (final candidate in candidates) {
        final trimmed = candidate.trim();
        if (trimmed.contains('.')) {
          final parts = trimmed.split('.');
          final ext = parts.isNotEmpty ? parts.last.trim() : '';
          if (ext.isNotEmpty) {
            return ext;
          }
        }
      }
      return 'file';
    }

    String? validateUrl(String? value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) {
        return null;
      }
      final uri = Uri.tryParse(trimmed);
      if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return 'Enter a valid URL starting with http or https';
      }
      return null;
    }

    return StatefulBuilder(
      builder: (context, setModalState) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;
        // Check if there are changes
        final sanitizedCurrent = certificateDrafts
            .map(_normalizeCertificateMap)
            .where((cert) => cert['name'].toString().isNotEmpty)
            .toList();
        final sanitizedInitial = initialCertificates
            .map(_normalizeCertificateMap)
            .where((cert) => cert['name'].toString().isNotEmpty)
            .toList();
        final hasChanges = !_areCertificateListsEqual(
          sanitizedCurrent,
          sanitizedInitial,
        );

        void addCertificate() {
          setModalState(() {
            certificateDrafts.add({
              'name': '',
              'type': 'Certificate',
              'uploadDate': '',
              'path': '',
              'extension': '',
              'size': 0,
            });
          });
        }

        void removeCertificate(int index) {
          setModalState(() {
            certificateDrafts.removeAt(index);
            if (certificateDrafts.isEmpty) {
              addCertificate();
            }
          });
        }

        Future<void> handleClose() async {
          if (hasChanges) {
            final shouldSave = await _showUnsavedChangesDialog(context);
            if (shouldSave == null) return; // Dialog dismissed
            if (shouldSave) {
              // Save changes
              final sanitizedCertificates = <Map<String, dynamic>>[];
              String? urlValidationMessage;
              var hasValidationError = false;

              for (final certificate in certificateDrafts) {
                final name = certificate['name']?.toString().trim() ?? '';
                final type = certificate['type']?.toString().trim() ?? '';
                final uploadDate =
                    certificate['uploadDate']?.toString().trim() ?? '';
                final url = certificate['path']?.toString().trim() ?? '';

                final hasAnyValue = [
                  name,
                  type,
                  uploadDate,
                  url,
                ].any((value) => value.isNotEmpty);

                if (hasAnyValue && name.isEmpty) {
                  hasValidationError = true;
                  break;
                }

                final validationMessage = validateUrl(url);
                if (validationMessage != null) {
                  urlValidationMessage = validationMessage;
                  break;
                }

                if (name.isEmpty) {
                  continue;
                }

                sanitizedCertificates.add({
                  'name': name,
                  'type': type.isNotEmpty ? type : 'Certificate',
                  'uploadDate': uploadDate.isNotEmpty
                      ? uploadDate
                      : 'Not specified',
                  'extension': inferExtensionFromInputs(name: name, url: url),
                  if (url.isNotEmpty) 'path': url,
                  'size': certificate['size'] is num
                      ? (certificate['size'] as num).toInt()
                      : 0,
                });
              }

              if (hasValidationError) {
                TopSnackBar.showError(
                  parentContext,
                  message: 'Please provide a name for each certificate.',
                );
                return;
              }

              if (urlValidationMessage != null) {
                TopSnackBar.showError(
                  parentContext,
                  message: urlValidationMessage,
                );
                return;
              }

              bloc.add(
                UpdateProfileCertificatesInlineEvent(
                  certificates: sanitizedCertificates,
                ),
              );
            }
          }
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }

        return PopScope(
          canPop: !hasChanges,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop && hasChanges) {
              await handleClose();
            }
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: viewInsets),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSheetHeader(
                        context: context,
                        title: 'Manage Certificates',
                        onClose: handleClose,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      ...List.generate(certificateDrafts.length, (index) {
                        final certificate = certificateDrafts[index];
                        final selectedType =
                            certificate['type']?.toString() ?? 'Certificate';

                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: AppConstants.defaultPadding,
                          ),
                          padding: const EdgeInsets.all(
                            AppConstants.defaultPadding,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.backgroundColor,
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                            border: Border.all(color: AppConstants.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Certificate ${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Delete certificate',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppConstants.errorColor,
                                    ),
                                    onPressed: () => removeCertificate(index),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppConstants.smallPadding),
                              TextFormField(
                                key: ValueKey('certificate_name_$index'),
                                initialValue:
                                    certificate['name']?.toString() ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Certificate Name',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setModalState(() {
                                    certificate['name'] = value;
                                  });
                                },
                              ),
                              const SizedBox(height: AppConstants.smallPadding),
                              DropdownButtonFormField<String>(
                                value: certificateTypes.contains(selectedType)
                                    ? selectedType
                                    : 'Certificate',
                                items: certificateTypes
                                    .map(
                                      (type) => DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(type),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setModalState(() {
                                    certificate['type'] = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Certificate Type',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: AppConstants.smallPadding),
                              TextFormField(
                                key: ValueKey('certificate_date_$index'),
                                initialValue:
                                    certificate['uploadDate']?.toString() ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Achievement Date',
                                  hintText: 'e.g., 10 July 2024',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setModalState(() {
                                    certificate['uploadDate'] = value;
                                  });
                                },
                              ),
                              const SizedBox(height: AppConstants.smallPadding),
                              TextFormField(
                                key: ValueKey('certificate_url_$index'),
                                initialValue:
                                    certificate['path']?.toString() ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Certificate URL (optional)',
                                  hintText:
                                      'https://example.com/certificate.pdf',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.url,
                                onChanged: (value) {
                                  setModalState(() {
                                    certificate['path'] = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: addCertificate,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Certificate'),
                        ),
                      ),
                      const SizedBox(height: AppConstants.largePadding),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: hasChanges
                              ? () {
                                  final sanitizedCertificates =
                                      <Map<String, dynamic>>[];
                                  String? urlValidationMessage;
                                  var hasValidationError = false;

                                  for (final certificate in certificateDrafts) {
                                    final name =
                                        certificate['name']
                                            ?.toString()
                                            .trim() ??
                                        '';
                                    final type =
                                        certificate['type']
                                            ?.toString()
                                            .trim() ??
                                        '';
                                    final uploadDate =
                                        certificate['uploadDate']
                                            ?.toString()
                                            .trim() ??
                                        '';
                                    final url =
                                        certificate['path']
                                            ?.toString()
                                            .trim() ??
                                        '';

                                    final hasAnyValue = [
                                      name,
                                      type,
                                      uploadDate,
                                      url,
                                    ].any((value) => value.isNotEmpty);

                                    if (hasAnyValue && name.isEmpty) {
                                      hasValidationError = true;
                                      break;
                                    }

                                    final validationMessage = validateUrl(url);
                                    if (validationMessage != null) {
                                      urlValidationMessage = validationMessage;
                                      break;
                                    }

                                    if (name.isEmpty) {
                                      continue;
                                    }

                                    sanitizedCertificates.add({
                                      'name': name,
                                      'type': type.isNotEmpty
                                          ? type
                                          : 'Certificate',
                                      'uploadDate': uploadDate.isNotEmpty
                                          ? uploadDate
                                          : 'Not specified',
                                      'extension': inferExtensionFromInputs(
                                        name: name,
                                        url: url,
                                      ),
                                      if (url.isNotEmpty) 'path': url,
                                      'size': certificate['size'] is num
                                          ? (certificate['size'] as num).toInt()
                                          : 0,
                                    });
                                  }

                                  if (hasValidationError) {
                                    ScaffoldMessenger.of(
                                      parentContext,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please provide a name for each certificate.',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }

                                  if (urlValidationMessage != null) {
                                    ScaffoldMessenger.of(
                                      parentContext,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(urlValidationMessage),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }

                                  bloc.add(
                                    UpdateProfileCertificatesInlineEvent(
                                      certificates: sanitizedCertificates,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasChanges
                                ? Colors.green
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required Map<String, dynamic> userProfile,
    required TextEditingController contactEmailController,
    required TextEditingController contactPhoneController,
    required GlobalKey<FormState> formKey,
  }) {
    // ✅ All controllers and formKey passed from parent (created BEFORE showModalBottomSheet)
    // ✅ No recreation here - they persist across rebuilds

    // Get INITIAL values from userProfile (for comparison - these never change)
    final initialContactEmail =
        userProfile['contactEmail']?.toString().isNotEmpty == true
        ? userProfile['contactEmail']?.toString() ?? ''
        : (userProfile['email']?.toString() ?? '');
    final initialContactPhone =
        userProfile['contactPhone']?.toString().isNotEmpty == true
        ? userProfile['contactPhone']?.toString() ?? ''
        : (userProfile['phone']?.toString() ?? '');

    return StatefulBuilder(
      builder: (context, setModalState) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        // Add listeners to trigger rebuilds when text changes
        void setupListeners() {
          contactEmailController.removeListener(() {});
          contactPhoneController.removeListener(() {});
          contactEmailController.addListener(() => setModalState(() {}));
          contactPhoneController.addListener(() => setModalState(() {}));
        }

        setupListeners();

        // Check if there are changes
        final currentEmail = contactEmailController.text.trim();
        final currentPhone = contactPhoneController.text.trim();
        final hasChanges =
            currentEmail != initialContactEmail.trim() ||
            currentPhone != initialContactPhone.trim();

        Future<void> handleClose() async {
          if (hasChanges) {
            final shouldSave = await _showUnsavedChangesDialog(context);
            if (shouldSave == null) return; // Dialog dismissed
            if (shouldSave) {
              // Save changes
              if (!formKey.currentState!.validate()) {
                return;
              }
              final contactEmail = contactEmailController.text.trim();
              final contactPhone = contactPhoneController.text.trim();

              // Get current values from state to preserve other fields
              final currentState = bloc.state;
              if (currentState is ProfileDetailsLoaded) {
                final currentProfile = currentState.userProfile;

                bloc.add(
                  UpdateProfileContactInlineEvent(
                    email: currentProfile['email']?.toString() ?? '',
                    phone: currentProfile['phone']?.toString() ?? '',
                    location: currentProfile['location']?.toString() ?? '',
                    gender: currentProfile['gender']?.toString(),
                    dateOfBirth: currentProfile['dateOfBirth']?.toString(),
                    contactEmail: contactEmail.isNotEmpty ? contactEmail : null,
                    contactPhone: contactPhone.isNotEmpty ? contactPhone : null,
                  ),
                );
              }
            }
          }
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }

        return PopScope(
          canPop: !hasChanges,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop && hasChanges) {
              await handleClose();
            }
          },
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSheetHeader(
                            context: context,
                            title: 'Edit Contact Details',
                            onClose: handleClose,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          _buildMainCard(
                            children: [
                              TextFormField(
                                controller: contactEmailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Enter email address',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  if (email.isEmpty) {
                                    return 'Email is required';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  );
                                  if (!emailRegex.hasMatch(email)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppConstants.smallPadding),
                              TextFormField(
                                controller: contactPhoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone',
                                  hintText: 'Enter phone number',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                validator: (value) {
                                  final phone = value?.trim() ?? '';
                                  if (phone.isEmpty) {
                                    return 'Phone is required';
                                  }
                                  if (!RegExp(r'^\d+$').hasMatch(phone)) {
                                    return 'Phone number must contain only digits';
                                  }
                                  if (phone.length != 10) {
                                    return 'Phone number must be exactly 10 digits';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Fixed bottom button
                Container(
                  padding: EdgeInsets.only(
                    left: AppConstants.defaultPadding,
                    right: AppConstants.defaultPadding,
                    top: AppConstants.defaultPadding,
                    bottom: viewInsets + AppConstants.defaultPadding,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.cardBackgroundColor,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hasChanges
                          ? () {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }

                              final contactEmail = contactEmailController.text
                                  .trim();
                              final contactPhone = contactPhoneController.text
                                  .trim();

                              // Get current values from state to preserve other fields
                              final currentState = bloc.state;
                              if (currentState is ProfileDetailsLoaded) {
                                final currentProfile = currentState.userProfile;

                                bloc.add(
                                  UpdateProfileContactInlineEvent(
                                    email:
                                        currentProfile['email']?.toString() ??
                                        '',
                                    phone:
                                        currentProfile['phone']?.toString() ??
                                        '',
                                    location:
                                        currentProfile['location']
                                            ?.toString() ??
                                        '',
                                    gender: currentProfile['gender']
                                        ?.toString(),
                                    dateOfBirth: currentProfile['dateOfBirth']
                                        ?.toString(),
                                    contactEmail: contactEmail.isNotEmpty
                                        ? contactEmail
                                        : null,
                                    contactPhone: contactPhone.isNotEmpty
                                        ? contactPhone
                                        : null,
                                  ),
                                );
                              }
                              Navigator.of(context).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasChanges
                            ? Colors.green
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        elevation: hasChanges ? 2 : 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeneralInformationEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required Map<String, dynamic> userProfile,
    required List<String?> genderState,
    required List<DateTime?> dateState,
    required TextEditingController dobController,
    required TextEditingController aadharController,
    required TextEditingController languageInputController,
    required List<String> languages,
    required GlobalKey<FormState> formKey,
  }) {
    // ✅ All controllers and state passed from parent (created BEFORE showModalBottomSheet)
    // ✅ No controller creation here - they persist across rebuilds

    // Get INITIAL values from userProfile (for comparison - these never change)
    String? initialGender;
    final existingGender =
        userProfile['gender']?.toString().toLowerCase() ?? '';
    if (existingGender == 'male') {
      initialGender = 'Male';
    } else if (existingGender == 'female') {
      initialGender = 'Female';
    } else if (existingGender == 'other') {
      initialGender = 'Other';
    }

    DateTime? initialDate;
    final dobText = userProfile['dateOfBirth']?.toString() ?? '';
    if (dobText.isNotEmpty) {
      initialDate = _parseDate(dobText);
    }

    final initialAadhar = (userProfile['aadharNumber']?.toString() ?? '')
        .trim();

    final initialLanguages = List<String>.from(
      userProfile['languages'] != null
          ? (userProfile['languages'] is List
                ? List<String>.from(userProfile['languages'])
                : (userProfile['languages'] as String)
                      .split(',')
                      .map((l) => l.trim())
                      .where((l) => l.isNotEmpty)
                      .toList())
          : [],
    )..sort();

    return Builder(
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        return StatefulBuilder(
          builder: (context, setState) {
            // ✅ Use current values from state containers/controllers (these update when user changes)
            final currentGender = genderState.isNotEmpty
                ? genderState[0]
                : null;
            final currentDate = dateState.isNotEmpty ? dateState[0] : null;
            final currentAadhar = aadharController.text.trim();
            final currentLanguages = [...languages]..sort();

            // ✅ Add listeners to controllers (like Profile Info pattern)
            void setupListeners() {
              dobController.removeListener(() {});
              aadharController.removeListener(() {});
              dobController.addListener(() => setState(() {}));
              aadharController.addListener(() => setState(() {}));
            }

            setupListeners();

            // ✅ Check if there are changes - compare current vs initial (initial never changes)
            final currentDob = currentDate != null
                ? _formatDate(currentDate!)
                : '';
            final initialDob = initialDate != null
                ? _formatDate(initialDate)
                : '';

            final hasGenderChange = currentGender != initialGender;
            final hasDobChange = currentDob != initialDob;
            final hasAadharChange = currentAadhar != initialAadhar;
            final hasLanguagesChange = !_areStringListsEqual(
              currentLanguages,
              initialLanguages,
            );
            final hasChanges =
                hasGenderChange ||
                hasDobChange ||
                hasAadharChange ||
                hasLanguagesChange;

            Future<void> handleClose() async {
              if (hasChanges) {
                final shouldSave = await _showUnsavedChangesDialog(context);
                if (shouldSave == null) return; // Dialog dismissed
                if (shouldSave) {
                  // Save changes
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  final gender = currentGender ?? initialGender;
                  final dob = currentDate != null
                      ? '${currentDate!.year}-${currentDate!.month.toString().padLeft(2, '0')}-${currentDate!.day.toString().padLeft(2, '0')}'
                      : '';
                  final aadharValue = aadharController.text.trim();

                  bloc.add(
                    UpdateProfileGeneralInfoInlineEvent(
                      gender: gender,
                      dateOfBirth: dob.isNotEmpty ? dob : null,
                      aadharNumber: aadharValue.isNotEmpty ? aadharValue : null,
                      languages: languages,
                    ),
                  );
                }
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }

            void addLanguage(String language) {
              final trimmed = language.trim();
              if (trimmed.isNotEmpty && !languages.contains(trimmed)) {
                setState(() {
                  languages.add(trimmed);
                  languageInputController.clear();
                });
              }
            }

            void removeLanguage(String language) {
              setState(() {
                languages.remove(language);
              });
            }

            return PopScope(
              canPop: !hasChanges,
              onPopInvokedWithResult: (didPop, result) async {
                if (!didPop && hasChanges) {
                  await handleClose();
                }
              },
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSheetHeader(
                                context: context,
                                title: 'Edit General Information',
                                onClose: handleClose,
                              ),
                              const SizedBox(
                                height: AppConstants.defaultPadding,
                              ),
                              _buildMainCard(
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: currentGender,
                                    decoration: const InputDecoration(
                                      labelText: 'Gender',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Male',
                                        child: Text('Male'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Female',
                                        child: Text('Female'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Other',
                                        child: Text('Other'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        genderState[0] = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                    height: AppConstants.smallPadding,
                                  ),
                                  TextFormField(
                                    controller: dobController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Date of Birth',
                                      hintText: 'Select date',
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    onTap: () async {
                                      final pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: currentDate != null
                                            ? currentDate!
                                            : DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          dateState[0] = pickedDate;
                                          dobController.text = _formatDate(
                                            pickedDate,
                                          );
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(
                                    height: AppConstants.smallPadding,
                                  ),
                                  const Text(
                                    'Languages',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppConstants.smallPadding,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: languageInputController,
                                          decoration: const InputDecoration(
                                            labelText: 'Add Language',
                                            hintText: 'e.g., Hindi, English',
                                            border: OutlineInputBorder(),
                                          ),
                                          textCapitalization:
                                              TextCapitalization.words,
                                          onFieldSubmitted: (value) {
                                            addLanguage(value);
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: AppConstants.smallPadding,
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          final value =
                                              languageInputController.text;
                                          addLanguage(value);
                                        },
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text('Add'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: AppConstants.smallPadding,
                                  ),
                                  if (languages.isNotEmpty)
                                    Wrap(
                                      spacing: AppConstants.smallPadding,
                                      runSpacing: AppConstants.smallPadding,
                                      children: languages.map((lang) {
                                        return Chip(
                                          label: Text(lang),
                                          deleteIcon: const Icon(
                                            Icons.close,
                                            size: 18,
                                          ),
                                          onDeleted: () => removeLanguage(lang),
                                        );
                                      }).toList(),
                                    ),
                                  const SizedBox(
                                    height: AppConstants.defaultPadding,
                                  ),
                                  TextFormField(
                                    controller: aadharController,
                                    decoration: const InputDecoration(
                                      labelText: 'Aadhar Number',
                                      hintText: '12-digit Aadhar number',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    maxLength: 12,
                                    validator: (value) {
                                      if (value != null &&
                                          value.trim().isNotEmpty) {
                                        if (value.trim().length != 12) {
                                          return 'Aadhar number must be 12 digits';
                                        }
                                        if (!RegExp(
                                          r'^\d+$',
                                        ).hasMatch(value.trim())) {
                                          return 'Aadhar number must contain only digits';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Fixed bottom button
                    Container(
                      padding: EdgeInsets.only(
                        left: AppConstants.defaultPadding,
                        right: AppConstants.defaultPadding,
                        top: AppConstants.defaultPadding,
                        bottom: viewInsets + AppConstants.defaultPadding,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.cardBackgroundColor,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: hasChanges
                              ? () {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final gender = currentGender;
                                  final dob = currentDate != null
                                      ? '${currentDate!.year}-${currentDate!.month.toString().padLeft(2, '0')}-${currentDate!.day.toString().padLeft(2, '0')}'
                                      : '';
                                  final aadhar = aadharController.text.trim();

                                  // Create a copy of languages list to ensure it's properly passed
                                  final languagesList = List<String>.from(
                                    languages,
                                  );

                                  bloc.add(
                                    UpdateProfileGeneralInfoInlineEvent(
                                      gender: gender,
                                      dateOfBirth: dob.isNotEmpty ? dob : null,
                                      languages: languagesList,
                                      aadharNumber: aadhar.isNotEmpty
                                          ? aadhar
                                          : null,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasChanges
                                ? Colors.green
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                            elevation: hasChanges ? 2 : 0,
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSocialLinksEditSheet({
    required BuildContext parentContext,
    required ProfileBloc bloc,
    required Map<String, dynamic> userProfile,
    required List<Map<String, dynamic>> socialLinks,
    required ValueNotifier<int> socialRebuildCounter,
    required Map<int, Map<String, GlobalKey<FormFieldState<String>>>>
    socialFieldKeys,
  }) {
    // ✅ State containers and counter passed from parent (created BEFORE showModalBottomSheet)
    // ✅ No recreation here - they persist across rebuilds

    // Get INITIAL values from userProfile (for comparison - these never change)
    List<Map<String, dynamic>> initialSocialLinks = [];
    if (userProfile['socialLinks'] is List) {
      initialSocialLinks = List<Map<String, dynamic>>.from(
        (userProfile['socialLinks'] as List).map((link) {
          if (link is Map<String, dynamic>) {
            return Map<String, dynamic>.from(link);
          }
          return <String, dynamic>{};
        }),
      );
    } else {
      // Fallback: Build from individual fields
      final portfolio = userProfile['portfolioLink']?.toString() ?? '';
      final linkedin = userProfile['linkedinUrl']?.toString() ?? '';
      final github = userProfile['githubUrl']?.toString() ?? '';
      final twitter = userProfile['twitterUrl']?.toString() ?? '';

      if (portfolio.isNotEmpty) {
        initialSocialLinks.add({
          'title': 'Portfolio',
          'profile_url': portfolio,
        });
      }
      if (linkedin.isNotEmpty) {
        initialSocialLinks.add({'title': 'LinkedIn', 'profile_url': linkedin});
      }
      if (github.isNotEmpty) {
        initialSocialLinks.add({'title': 'GitHub', 'profile_url': github});
      }
      if (twitter.isNotEmpty) {
        initialSocialLinks.add({'title': 'Twitter', 'profile_url': twitter});
      }
    }

    // Debounce timer for updating parent state (to enable save button)
    // This prevents keyboard dismiss during typing
    Timer? debounceTimer;

    return Builder(
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;

        String? validateUrl(String? value) {
          final trimmed = value?.trim() ?? '';
          if (trimmed.isEmpty) {
            return 'URL is required';
          }
          final uri = Uri.tryParse(trimmed);
          if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
            return 'Enter a valid URL starting with http or https';
          }
          return null;
        }

        String? validateTitle(String? value) {
          final trimmed = value?.trim() ?? '';
          if (trimmed.isEmpty) {
            return 'Title is required';
          }
          return null;
        }

        return StatefulBuilder(
          builder: (context, setState) {
            final formKey = GlobalKey<FormState>();

            // Function to debounce parent state update
            void debouncedUpdateState() {
              debounceTimer?.cancel();
              debounceTimer = Timer(const Duration(milliseconds: 300), () {
                setState(() {
                  // This will recalculate hasChanges and update save button
                  // But TextFormFields won't rebuild due to GlobalKey
                });
              });
            }

            // Check if there are changes
            final sanitizedCurrent = socialLinks
                .map(_normalizeSocialLinkMap)
                .where(
                  (link) =>
                      link['title'].toString().isNotEmpty ||
                      link['profile_url'].toString().isNotEmpty,
                )
                .toList();
            final sanitizedInitial = initialSocialLinks
                .map(_normalizeSocialLinkMap)
                .where(
                  (link) =>
                      link['title'].toString().isNotEmpty ||
                      link['profile_url'].toString().isNotEmpty,
                )
                .toList();
            final hasChanges = !_areSocialLinkListsEqual(
              sanitizedCurrent,
              sanitizedInitial,
            );

            Future<void> handleClose() async {
              if (hasChanges) {
                final shouldSave = await _showUnsavedChangesDialog(context);
                if (shouldSave == null) return; // Dialog dismissed
                if (shouldSave) {
                  // Save changes - First filter out completely empty links (like Work Experience)
                  final validLinks = socialLinks
                      .where((link) {
                        final title = link['title']?.toString().trim() ?? '';
                        final url =
                            link['profile_url']?.toString().trim() ?? '';
                        return title.isNotEmpty && url.isNotEmpty;
                      })
                      .map(_normalizeSocialLinkMap)
                      .toList();

                  // Only validate form if there are links after filtering
                  // If all links were empty and filtered out, allow save (like Work Experience)
                  if (validLinks.isNotEmpty) {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                  }

                  bloc.add(
                    UpdateProfileSocialLinksInlineEvent(
                      socialLinks: validLinks,
                    ),
                  );
                }
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }

            void addSocialLink() {
              debounceTimer?.cancel(); // Cancel any pending debounced updates
              socialLinks.add({'title': '', 'profile_url': ''});
              setState(() {}); // Immediate update for add/remove operations
            }

            void removeSocialLink(int index) {
              debounceTimer?.cancel(); // Cancel any pending debounced updates
              final isLastBlock = socialLinks.length == 1;

              // If it's the last block, clear its data instead of removing
              if (isLastBlock) {
                socialLinks[0] = {'title': '', 'profile_url': ''};
                // Increment counter to force rebuild of fields
                socialRebuildCounter.value++;
                // Clear field keys for the last block
                if (socialFieldKeys.containsKey(0)) {
                  socialFieldKeys[0] = {
                    'title': GlobalKey<FormFieldState<String>>(),
                    'url': GlobalKey<FormFieldState<String>>(),
                  };
                }
              } else {
                // Remove the block if there are multiple blocks
                socialLinks.removeAt(index);
                // Remove keys when link is removed - keys will be recreated on rebuild
                socialFieldKeys.remove(index);
              }
              setState(() {}); // Immediate update for add/remove operations
            }

            return PopScope(
              canPop: !hasChanges,
              onPopInvokedWithResult: (didPop, result) async {
                if (!didPop && hasChanges) {
                  await handleClose();
                }
              },
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSheetHeader(
                                context: context,
                                title: 'Edit Social Links',
                                onClose: handleClose,
                              ),
                              const SizedBox(
                                height: AppConstants.defaultPadding,
                              ),
                              _buildMainCard(
                                children: [
                                  ...socialLinks.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final link = entry.value;
                                    final titleValue =
                                        link['title']?.toString() ?? '';
                                    final urlValue =
                                        link['profile_url']?.toString() ?? '';

                                    // Initialize keys for this index if not exists
                                    if (!socialFieldKeys.containsKey(index)) {
                                      socialFieldKeys[index] = {
                                        'title':
                                            GlobalKey<FormFieldState<String>>(),
                                        'url':
                                            GlobalKey<FormFieldState<String>>(),
                                      };
                                    }

                                    return Container(
                                      key: ValueKey(
                                        'social_link_${index}_${socialRebuildCounter.value}',
                                      ),
                                      margin: const EdgeInsets.only(
                                        bottom: AppConstants.defaultPadding,
                                      ),
                                      padding: const EdgeInsets.all(
                                        AppConstants.defaultPadding,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppConstants.backgroundColor,
                                        borderRadius: BorderRadius.circular(
                                          AppConstants.borderRadius,
                                        ),
                                        border: Border.all(
                                          color: AppConstants.borderColor,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Link ${index + 1}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const Spacer(),
                                              // Show delete icon only if block has data
                                              // Don't show delete icon if it's the last block and it's completely empty
                                              Builder(
                                                builder: (context) {
                                                  final isLastBlock =
                                                      socialLinks.length == 1;
                                                  final hasData =
                                                      titleValue
                                                          .trim()
                                                          .isNotEmpty ||
                                                      urlValue
                                                          .trim()
                                                          .isNotEmpty;

                                                  // Show delete icon if block has data, or if it's not the last block
                                                  if (hasData || !isLastBlock) {
                                                    return IconButton(
                                                      tooltip:
                                                          'Delete social link',
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                        color: AppConstants
                                                            .errorColor,
                                                      ),
                                                      onPressed: () =>
                                                          removeSocialLink(
                                                            index,
                                                          ),
                                                    );
                                                  }
                                                  return const SizedBox.shrink();
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: AppConstants.smallPadding,
                                          ),
                                          TextFormField(
                                            key:
                                                socialFieldKeys[index]!['title'],
                                            initialValue:
                                                link['title']?.toString() ?? '',
                                            decoration: const InputDecoration(
                                              labelText:
                                                  'Title * (e.g., Portfolio, LinkedIn, GitHub)',
                                              hintText: 'Portfolio',
                                              border: OutlineInputBorder(),
                                            ),
                                            onChanged: (value) {
                                              // Update data directly - NO immediate parent rebuild
                                              link['title'] = value;
                                              // Debounced update to enable save button after typing stops
                                              debouncedUpdateState();
                                            },
                                            validator: validateTitle,
                                          ),
                                          const SizedBox(
                                            height: AppConstants.smallPadding,
                                          ),
                                          TextFormField(
                                            key: socialFieldKeys[index]!['url'],
                                            initialValue:
                                                link['profile_url']
                                                    ?.toString() ??
                                                '',
                                            decoration: const InputDecoration(
                                              labelText: 'URL *',
                                              hintText: 'https://example.com',
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.url,
                                            onChanged: (value) {
                                              // Update data directly - NO immediate parent rebuild
                                              link['profile_url'] = value;
                                              // Debounced update to enable save button after typing stops
                                              debouncedUpdateState();
                                            },
                                            validator: validateUrl,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(
                                    height: AppConstants.defaultPadding,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          addSocialLink();
                                        });
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Social Link'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Fixed bottom button
                    Container(
                      padding: EdgeInsets.only(
                        left: AppConstants.defaultPadding,
                        right: AppConstants.defaultPadding,
                        top: AppConstants.defaultPadding,
                        bottom: viewInsets + AppConstants.defaultPadding,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.cardBackgroundColor,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: hasChanges
                              ? () {
                                  // First filter out completely empty links (like Work Experience)
                                  final validLinks = socialLinks
                                      .where((link) {
                                        final title =
                                            link['title']?.toString().trim() ??
                                            '';
                                        final url =
                                            link['profile_url']
                                                ?.toString()
                                                .trim() ??
                                            '';
                                        return title.isNotEmpty &&
                                            url.isNotEmpty;
                                      })
                                      .map(_normalizeSocialLinkMap)
                                      .toList();

                                  // Only validate form if there are links after filtering
                                  // If all links were empty and filtered out, allow save (like Work Experience)
                                  if (validLinks.isNotEmpty) {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                  }

                                  bloc.add(
                                    UpdateProfileSocialLinksInlineEvent(
                                      socialLinks: validLinks,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasChanges
                                ? Colors.green
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                            elevation: hasChanges ? 2 : 0,
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Profile Sections
  Widget _buildProfileSections(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    return Column(
      children: [
        // General Information Section (First)
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'General Information',
          icon: Icons.info_outline,
          section: 'general_info',
          child: _buildGeneralInformationContent(state.userProfile),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Skills Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Skills & Expertise',
          icon: Icons.star_outline,
          section: 'skills',
          child: _buildSkillsContent(state.skills),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Education Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Education',
          icon: Icons.school_outlined,
          section: 'education',
          child: _buildEducationContent(state.education),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Experience Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Work Experience',
          icon: Icons.work_outline,
          section: 'experience',
          child: _buildExperienceContent(state.experience),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Contact Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Contact',
          icon: Icons.contact_page_outlined,
          section: 'contact',
          child: _buildContactContent(state.userProfile),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Social Links Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Socials',
          icon: Icons.link_outlined,
          section: 'social',
          child: _buildSocialLinksContent(context, state.userProfile),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Resume Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Resume',
          icon: Icons.description_outlined,
          section: 'resume',
          child: _buildResumeContent(context, state),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Certificates Section
        _buildModernSectionCard(
          context: context,
          state: state,
          title: 'Certificates',
          icon: Icons.folder_outlined,
          section: 'certificates',
          child: _buildCertificatesContent(context, state),
        ),
      ],
    );
  }

  /// Modern Section Card with Better UX
  Widget _buildModernSectionCard({
    required BuildContext context,
    required ProfileDetailsLoaded state,
    required String title,
    required IconData icon,
    required String section,
    required Widget child,
  }) {
    final isExpanded = state.sectionExpansionStates[section] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.read<ProfileBloc>().add(
                ToggleSectionEvent(section: section),
              ),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              child: Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppConstants.textSecondaryColor,
                      ),
                      onPressed: () => context.read<ProfileBloc>().add(
                        ToggleSectionEvent(section: section),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: AppConstants.primaryColor,
                        size: 18,
                      ),
                      onPressed: () => _showEditSectionSheet(
                        context: context,
                        section: section,
                        state: state,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.defaultPadding,
                0,
                AppConstants.defaultPadding,
                AppConstants.defaultPadding,
              ),
              child: child,
            ),
        ],
      ),
    );
  }

  /// Skills Content
  Widget _buildSkillsContent(List<String> skills) {
    if (skills.isEmpty) {
      return _buildEmptyState(
        icon: Icons.star_outline,
        title: 'No Skills Added',
        subtitle: 'Add your skills to showcase your expertise',
      );
    }

    return Wrap(
      spacing: AppConstants.smallPadding,
      runSpacing: AppConstants.smallPadding,
      children: skills.map((skill) => _buildSkillChip(skill)).toList(),
    );
  }

  /// Experience Content
  Widget _buildExperienceContent(List<Map<String, dynamic>> experience) {
    if (experience.isEmpty) {
      return _buildEmptyState(
        icon: Icons.work_outline,
        title: 'No Experience Added',
        subtitle: 'Add your work experience to build your profile',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: experience.map((exp) => _buildExperienceCard(exp)).toList(),
    );
  }

  /// Education Content
  Widget _buildEducationContent(List<Map<String, dynamic>> education) {
    // Filter out empty education entries (entries where qualification and institute are both empty)
    final validEducation = education.where((edu) {
      final qualification = (edu['qualification'] ?? '').toString().trim();
      final institute = (edu['institute'] ?? '').toString().trim();
      // Consider valid if at least qualification or institute is filled
      return qualification.isNotEmpty || institute.isNotEmpty;
    }).toList();

    if (validEducation.isEmpty) {
      return _buildEmptyState(
        icon: Icons.school_outlined,
        title: 'No Education Added',
        subtitle: 'Add your educational background',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: validEducation.map((edu) => _buildEducationCard(edu)).toList(),
    );
  }

  /// Certificates Content
  Widget _buildResumeContent(BuildContext context, ProfileDetailsLoaded state) {
    final resumeName = state.resumeFileName?.trim() ?? '';
    final updatedDate = state.lastResumeUpdatedDate?.trim() ?? '';

    if (resumeName.isEmpty) {
      return _buildEmptyState(
        icon: Icons.description_outlined,
        title: 'No Resume Uploaded',
        subtitle: 'Upload your resume to attract employers',
      );
    }

    return _buildDocumentCard(
      icon: Icons.description,
      title: 'Resume',
      fileName: resumeName,
      lastUpdated: updatedDate.isNotEmpty ? updatedDate : 'Unknown',
      onDownload: () => _downloadResume(context, state.resumeDownloadUrl),
    );
  }

  Widget _buildCertificatesContent(
    BuildContext context,
    ProfileDetailsLoaded state,
  ) {
    final certificates = state.certificates
        .where(
          (cert) => (cert['type'] ?? '').toString().toLowerCase() != 'resume',
        )
        .toList();

    return Column(
      children: [
        // Certificates
        if (certificates.isNotEmpty) ...[
          ...certificates.map(
            (cert) => _buildDocumentCard(
              icon: _getCertificateIcon(cert['type'] ?? ''),
              title: cert['name'] ?? 'Document',
              fileName: cert['name'] ?? 'Document',
              lastUpdated: cert['uploadDate'] ?? 'Unknown',
              onDownload: () => _downloadDocument(context, cert),
            ),
          ),
        ],

        if (certificates.isEmpty)
          _buildEmptyState(
            icon: Icons.folder_outlined,
            title: 'No Certificates Added',
            subtitle: 'Upload your certificates to showcase achievements',
          ),
      ],
    );
  }

  /// Contact Content
  Widget _buildContactContent(Map<String, dynamic> userProfile) {
    return Column(
      children: [
        // Info message about default contact info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppConstants.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  'By default, contact info is taken from account info. You can change it.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.primaryColor,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Contact Info - Email
        _buildContactItem(
          icon: Icons.email_outlined,
          label: 'Email',
          value: userProfile['contactEmail']?.toString().isNotEmpty == true
              ? userProfile['contactEmail']
              : (userProfile['email'] ?? 'Not provided'),
        ),
        // Contact Info - Phone
        _buildContactItem(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: userProfile['contactPhone']?.toString().isNotEmpty == true
              ? userProfile['contactPhone']
              : (userProfile['phone'] ?? 'Not provided'),
        ),
      ],
    );
  }

  /// General Information Content
  Widget _buildGeneralInformationContent(Map<String, dynamic> userProfile) {
    // Check if all fields are empty
    final hasGender =
        userProfile['gender'] != null &&
        userProfile['gender'].toString().trim().isNotEmpty;
    final hasDateOfBirth =
        userProfile['dateOfBirth'] != null &&
        userProfile['dateOfBirth'].toString().trim().isNotEmpty;
    final hasLanguages =
        userProfile['languages'] != null &&
        ((userProfile['languages'] is List &&
                (userProfile['languages'] as List).isNotEmpty) ||
            (userProfile['languages'] is String &&
                userProfile['languages'].toString().trim().isNotEmpty));
    final hasAadhar =
        userProfile['aadharNumber'] != null &&
        userProfile['aadharNumber'].toString().trim().isNotEmpty;

    // If all fields are empty, show empty state
    if (!hasGender && !hasDateOfBirth && !hasLanguages && !hasAadhar) {
      return _buildEmptyState(
        icon: Icons.info_outline,
        title: 'No Information Added',
        subtitle: 'Add your general information to complete your profile',
      );
    }

    // Show fields that have data
    return Column(
      children: [
        if (hasGender)
          _buildContactItem(
            icon: Icons.person_outline,
            label: 'Gender',
            value: _formatGender(userProfile['gender']?.toString() ?? ''),
          ),
        if (hasDateOfBirth)
          _buildContactItem(
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: userProfile['dateOfBirth'],
          ),
        if (hasLanguages) ...[
          _buildLanguagesContactItem(userProfile['languages']) ??
              const SizedBox.shrink(),
        ],
        if (hasAadhar)
          _buildContactItem(
            icon: Icons.badge_outlined,
            label: 'Aadhar Number',
            value: userProfile['aadharNumber'],
          ),
      ],
    );
  }

  /// Social Links Content
  Widget _buildSocialLinksContent(
    BuildContext context,
    Map<String, dynamic> userProfile,
  ) {
    // Get social links from array or build from individual fields
    List<Map<String, dynamic>> socialLinks = [];
    if (userProfile['socialLinks'] is List) {
      socialLinks = List<Map<String, dynamic>>.from(
        (userProfile['socialLinks'] as List).whereType<Map<String, dynamic>>(),
      );
    } else {
      // Fallback: Build from individual fields
      final portfolio = userProfile['portfolioLink']?.toString() ?? '';
      final linkedin = userProfile['linkedinUrl']?.toString() ?? '';
      final github = userProfile['githubUrl']?.toString() ?? '';
      final twitter = userProfile['twitterUrl']?.toString() ?? '';

      if (portfolio.isNotEmpty) {
        socialLinks.add({'title': 'Portfolio', 'profile_url': portfolio});
      }
      if (linkedin.isNotEmpty) {
        socialLinks.add({'title': 'LinkedIn', 'profile_url': linkedin});
      }
      if (github.isNotEmpty) {
        socialLinks.add({'title': 'GitHub', 'profile_url': github});
      }
      if (twitter.isNotEmpty) {
        socialLinks.add({'title': 'Twitter', 'profile_url': twitter});
      }
    }

    // Filter out empty links
    socialLinks = socialLinks.where((link) {
      final title = link['title']?.toString().trim() ?? '';
      final url = link['profile_url']?.toString().trim() ?? '';
      return title.isNotEmpty && url.isNotEmpty;
    }).toList();

    if (socialLinks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.link_outlined,
        title: 'No Social Links Added',
        subtitle: 'Add your portfolio and social media profiles',
      );
    }

    // Helper to get icon based on title
    IconData getIconForTitle(String title) {
      final lowerTitle = title.toLowerCase();
      if (lowerTitle.contains('portfolio') || lowerTitle.contains('website')) {
        return Icons.web_outlined;
      } else if (lowerTitle.contains('linkedin')) {
        return Icons.work_outline;
      } else if (lowerTitle.contains('github')) {
        return Icons.code_outlined;
      } else if (lowerTitle.contains('twitter')) {
        return Icons.alternate_email;
      } else if (lowerTitle.contains('facebook')) {
        return Icons.facebook;
      } else {
        return Icons.link_outlined;
      }
    }

    return Column(
      children: socialLinks.map((link) {
        final title = link['title']?.toString() ?? 'Link';
        final url = link['profile_url']?.toString() ?? '';
        return _buildSocialLinkItem(
          icon: getIconForTitle(title),
          label: title,
          value: url,
          onTap: () => _openUrl(context, url),
        );
      }).toList(),
    );
  }

  /// Helper Widgets
  Widget _buildDefaultProfileImage() {
    return Container(
      color: AppConstants.backgroundColor,
      child: const Icon(
        Icons.person,
        size: 36,
        color: AppConstants.textSecondaryColor,
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          color: AppConstants.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> exp) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exp['company'] ?? 'Company',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            exp['position'] ?? 'Position',
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${exp['startDate']} - ${exp['endDate'] ?? 'Present'}',
            style: const TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          if (exp['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              exp['description'],
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.textPrimaryColor,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationCard(Map<String, dynamic> edu) {
    // Get all fields
    final qualification = edu['qualification']?.toString() ?? '';
    final institute = edu['institute']?.toString() ?? '';
    final startYear = edu['startYear']?.toString() ?? '';
    final endYear = edu['endYear']?.toString() ?? '';
    final isPursuing =
        edu['isPursuing'] == true ||
        edu['isPursuing'] == 1 ||
        edu['isPursuing'] == '1' ||
        edu['isPursuing'] == 'true';
    final pursuingYear = edu['pursuingYear'];
    final cgpa = edu['cgpa']?.toString() ?? '';

    // Build year display - start date always shown, end date only if not pursuing
    String yearDisplay = '';
    if (isPursuing) {
      // Show start year - pursuing status (end date not shown)
      String pursuingText = '';
      if (pursuingYear != null) {
        final yearNum = pursuingYear is int
            ? pursuingYear
            : int.tryParse(pursuingYear.toString());
        if (yearNum != null && yearNum >= 1 && yearNum <= 4) {
          final yearText = yearNum == 1
              ? '1st Year'
              : yearNum == 2
              ? '2nd Year'
              : yearNum == 3
              ? '3rd Year'
              : '4th Year';
          pursuingText = 'Pursuing ($yearText)';
        } else {
          pursuingText = 'Pursuing';
        }
      } else {
        pursuingText = 'Pursuing';
      }

      // Combine start year with pursuing status
      if (startYear.isNotEmpty) {
        yearDisplay = '$startYear - $pursuingText';
      } else {
        yearDisplay = pursuingText;
      }
    } else {
      // Show start year - end year (not pursuing)
      if (startYear.isNotEmpty && endYear.isNotEmpty) {
        yearDisplay = '$startYear - $endYear';
      } else if (endYear.isNotEmpty) {
        yearDisplay = endYear;
      } else if (startYear.isNotEmpty) {
        yearDisplay = startYear;
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Qualification
          if (qualification.isNotEmpty)
            Text(
              qualification,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          // Institute
          if (institute.isNotEmpty) ...[
            if (qualification.isNotEmpty) const SizedBox(height: 4),
            Text(
              institute,
              style: const TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
          // Year and CGPA
          if (yearDisplay.isNotEmpty || cgpa.isNotEmpty) ...[
            if (qualification.isNotEmpty || institute.isNotEmpty)
              const SizedBox(height: 4),
            Row(
              children: [
                if (yearDisplay.isNotEmpty)
                  Text(
                    yearDisplay,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                if (yearDisplay.isNotEmpty && cgpa.isNotEmpty)
                  const Text(
                    ' • ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                if (cgpa.isNotEmpty)
                  Text(
                    'CGPA: $cgpa',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required IconData icon,
    required String title,
    required String fileName,
    required String lastUpdated,
    required VoidCallback onDownload,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 20),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                Text(
                  'Updated: $lastUpdated',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppConstants.primaryColor),
            onPressed: onDownload,
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: AppConstants.errorColor),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  Widget? _buildLanguagesContactItem(dynamic languages) {
    if (languages == null) return null;

    String languagesString = '';
    if (languages is List) {
      languagesString = languages.join(', ');
    } else if (languages is String) {
      languagesString = languages;
    }

    if (languagesString.isEmpty) return null;

    return _buildContactItem(
      icon: Icons.language_outlined,
      label: 'Languages',
      value: languagesString,
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    // Filter out coordinates for location field - show "Not provided" instead
    String displayValue = value;
    if (label.toLowerCase() == 'location' && _isCoordinates(value)) {
      displayValue = 'Not provided';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.textSecondaryColor, size: 20),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinkItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, color: AppConstants.textSecondaryColor, size: 20),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.launch, color: AppConstants.primaryColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppConstants.textSecondaryColor),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Reverse geocode coordinates to get city and state
  Future<String?> _reverseGeocode(double latitude, double longitude) async {
    try {
      debugPrint('🔵 Starting reverse geocoding for: $latitude, $longitude');

      // Using OpenStreetMap Nominatim API (free, no API key required)
      // Using zoom=18 for maximum detail and addressdetails=1 for full address components
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&addressdetails=1&zoom=18&accept-language=en',
      );

      debugPrint('🔵 Reverse geocoding URL: $url');

      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': 'JobsahiApp/1.0', // Required by Nominatim
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              debugPrint('⏱️ Reverse geocoding request timeout');
              throw TimeoutException('Reverse geocoding timeout');
            },
          );

      debugPrint(
        '🔵 Reverse geocoding response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          debugPrint('⚠️ Empty response from geocoding API');
          return null;
        }

        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        debugPrint('🔵 Geocoding data keys: ${data.keys.toList()}');

        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          debugPrint('🔵 Address keys: ${address.keys.toList()}');
          debugPrint('🔵 Full address data: $address');

          // Extract city - try multiple field names in priority order
          // For Indian locations, try district, city_district, county, etc.
          String city = '';

          // Priority order for city extraction (most specific first)
          final cityFields = [
            'city',
            'town',
            'district', // Common in India (e.g., Balaghat district)
            'city_district',
            'county',
            'village',
            'municipality',
            'suburb',
            'subdistrict',
            'neighbourhood',
          ];

          for (final field in cityFields) {
            final value = address[field]?.toString().trim();
            if (value != null && value.isNotEmpty) {
              city = value;
              debugPrint('🔵 Found city in field "$field": $city');
              break;
            }
          }

          // Extract state
          final state =
              (address['state'] ??
                      address['region'] ??
                      address['state_district'] ??
                      '')
                  .toString()
                  .trim();

          debugPrint('🔵 Extracted city: "$city", state: "$state"');

          // If we have both city and state, return them
          if (city.isNotEmpty && state.isNotEmpty) {
            final result = '$city, $state';
            debugPrint('✅ Reverse geocoding success: $result');
            return result;
          }

          // If only city found, try to get state from display_name
          if (city.isNotEmpty && state.isEmpty) {
            final displayName = data['display_name']?.toString() ?? '';
            if (displayName.isNotEmpty) {
              // Try to extract state from display name
              final parts = displayName.split(',');
              if (parts.length >= 2) {
                // Last part is usually country, second last might be state
                final possibleState = parts[parts.length - 2].trim();
                if (possibleState.isNotEmpty && possibleState != city) {
                  final result = '$city, $possibleState';
                  debugPrint(
                    '✅ Extracted city and state from display_name: $result',
                  );
                  return result;
                }
              }
            }
            debugPrint('✅ Reverse geocoding success (city only): $city');
            return city;
          }

          // If only state found, try to get city from display_name
          if (city.isEmpty && state.isNotEmpty) {
            final displayName = data['display_name']?.toString() ?? '';
            if (displayName.isNotEmpty) {
              // Try to extract city from display name
              final parts = displayName.split(',');
              if (parts.length >= 3) {
                // Try to find city before state in display name
                for (int i = 0; i < parts.length - 2; i++) {
                  final possibleCity = parts[i].trim();
                  if (possibleCity.isNotEmpty &&
                      possibleCity.length > 2 &&
                      !possibleCity.toLowerCase().contains('india')) {
                    final result = '$possibleCity, $state';
                    debugPrint(
                      '✅ Extracted city and state from display_name: $result',
                    );
                    return result;
                  }
                }
              }
            }
            debugPrint('✅ Reverse geocoding success (state only): $state');
            return state;
          }

          // Fallback to display name parsing
          final displayName = data['display_name']?.toString() ?? '';
          debugPrint('🔵 Using display_name fallback: $displayName');

          if (displayName.isNotEmpty) {
            // Parse display name to extract city and state
            final parts = displayName.split(',');
            debugPrint('🔵 Display name parts: $parts');

            if (parts.length >= 3) {
              // For format like "Balaghat, Madhya Pradesh, India"
              // Try to find city (usually first or second part) and state (usually second or third last)
              String? extractedCity;
              String? extractedState;

              // State is usually second last (before country)
              if (parts.length >= 2) {
                extractedState = parts[parts.length - 2].trim();
              }

              // City is usually first or second part
              for (int i = 0; i < parts.length - 1; i++) {
                final part = parts[i].trim();
                if (part.isNotEmpty &&
                    part.length > 2 &&
                    part != extractedState &&
                    !part.toLowerCase().contains('india') &&
                    !part.toLowerCase().contains('pin')) {
                  extractedCity = part;
                  break;
                }
              }

              if (extractedCity != null && extractedState != null) {
                final result = '$extractedCity, $extractedState';
                debugPrint('✅ Extracted from display_name: $result');
                return result;
              } else if (extractedCity != null) {
                debugPrint(
                  '✅ Extracted city from display_name: $extractedCity',
                );
                return extractedCity;
              } else if (extractedState != null) {
                debugPrint(
                  '✅ Extracted state from display_name: $extractedState',
                );
                return extractedState;
              }
            } else if (parts.length >= 2) {
              // Fallback: use last two parts
              final cityState =
                  '${parts[parts.length - 2].trim()}, ${parts[parts.length - 1].trim()}';
              debugPrint(
                '✅ Extracted from display_name (fallback): $cityState',
              );
              return cityState;
            }

            debugPrint('✅ Using full display_name: $displayName');
            return displayName;
          }
        } else {
          debugPrint('⚠️ No address data in response');
        }
      } else {
        debugPrint(
          '🔴 Reverse geocoding failed with status: ${response.statusCode}',
        );
        debugPrint('🔴 Response body: ${response.body}');
      }

      return null;
    } on TimeoutException {
      debugPrint('⏱️ Reverse geocoding timeout');
      return null;
    } catch (e) {
      debugPrint('🔴 Error in reverse geocoding: $e');
      debugPrint('🔴 Error type: ${e.runtimeType}');
      return null;
    }
  }

  /// Show dialog to get current location
  Future<bool?> _showGetCurrentLocationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.my_location, color: Color(0xFF58B248), size: 24),
              SizedBox(width: 12),
              Text(
                'Get Current Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          content: const Text(
            'Do you want to get your current location?',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58B248),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Get Current Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    if (url.isEmpty) {
      TopSnackBar.showError(context, message: 'Invalid URL');
      return;
    }

    try {
      // Ensure URL has a scheme (http:// or https://)
      String urlToLaunch = url.trim();
      if (!urlToLaunch.startsWith('http://') &&
          !urlToLaunch.startsWith('https://')) {
        urlToLaunch = 'https://$urlToLaunch';
      }

      final uri = Uri.parse(urlToLaunch);

      // Try launching URL directly - canLaunchUrl can be unreliable
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          // If external application mode fails, try platform default
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } catch (launchError) {
        // If both modes fail, show error
        if (context.mounted) {
          TopSnackBar.showError(
            context,
            message: 'Could not open link. Please try again.',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        TopSnackBar.showError(
          context,
          message: 'Error opening URL: ${e.toString()}',
        );
      }
    }
  }

  void _downloadResume(BuildContext context, String? url) {
    final message = url != null && url.isNotEmpty
        ? 'Opening resume: $url'
        : 'Downloading resume...';
    TopSnackBar.showInfo(context, message: message);
  }

  void _downloadDocument(BuildContext context, Map<String, dynamic> document) {
    TopSnackBar.showInfo(
      context,
      message: 'Downloading ${document['name'] ?? 'document'}...',
    );
  }

  IconData _getCertificateIcon(String type) {
    switch (type.toLowerCase()) {
      case 'certificate':
        return Icons.school;
      case 'license':
        return Icons.verified;
      case 'id proof':
        return Icons.badge;
      default:
        return Icons.description;
    }
  }
}
