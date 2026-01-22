/// Campus Drive List Screen
/// Shows all live campus drives

library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/top_snackbar.dart';
import '../../../shared/widgets/common/empty_state_widget.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../bloc/campus_drive_bloc.dart';
import '../bloc/campus_drive_event.dart';
import '../bloc/campus_drive_state.dart';
import '../models/campus_drive.dart';
import 'my_applications_list.dart';

class CampusDriveListScreen extends StatefulWidget {
  const CampusDriveListScreen({super.key});

  @override
  State<CampusDriveListScreen> createState() => _CampusDriveListScreenState();
}

class _CampusDriveListScreenState extends State<CampusDriveListScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  bool _isBannerLoading = true;
  bool _isUserHolding = false;

  // Campus Drive banner images
  final List<String> _bannerImages = [
    'assets/images/banner/banner1.jpg',
    'assets/images/banner/banner2.jpg',
    'assets/images/banner/banner3.jpg',
    'assets/images/banner/banner4.jpg',
    'assets/images/banner/banner5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    // Load live drives when screen initializes
    _loadDrives();
    // Start banner timer after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isBannerLoading = false;
        });
        _startBannerTimer();
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isUserHolding && mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % _bannerImages.length;
        });
      }
    });
  }

  void _pauseBannerTimer() {
    if (!_isUserHolding) {
      setState(() {
        _isUserHolding = true;
      });
    }
  }

  void _resumeBannerTimer() {
    if (_isUserHolding) {
      setState(() {
        _isUserHolding = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload drives when app comes to foreground
      _loadDrives();
    }
  }

  void _loadDrives() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CampusDriveBloc>().add(const LoadLiveDrivesEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner Section
        _buildBanner(),
        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppConstants.secondaryColor,
            unselectedLabelColor: AppConstants.textSecondaryColor,
            indicatorColor: AppConstants.secondaryColor,
            tabs: const [
              Tab(text: 'All Drives'),
              Tab(text: 'My Applications'),
            ],
          ),
        ),
        // Tab View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllDrivesTab(),
              const MyApplicationsList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.defaultPadding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: _isBannerLoading
            ? Border.all(color: Colors.grey.withOpacity(0.2), width: 1)
            : null,
        boxShadow: _isBannerLoading
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: GestureDetector(
          onTapDown: (_) => _pauseBannerTimer(),
          onTapUp: (_) => _resumeBannerTimer(),
          onTapCancel: () => _resumeBannerTimer(),
          child: Stack(
            children: [
              // Banner loading indicator
              if (_isBannerLoading)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[100],
                  child: Center(
                    child: CircularProgressIndicator(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              // Banner Image
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                  return Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: Image.asset(
                  _bannerImages[_currentBannerIndex],
                  key: ValueKey<int>(_currentBannerIndex),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded || frame != null) {
                      return child;
                    }
                    return Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppConstants.secondaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
                    );
                  },
                ),
              ),
              // Page indicators
              if (!_isBannerLoading)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _bannerImages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentBannerIndex == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentBannerIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllDrivesTab() {
    return BlocConsumer<CampusDriveBloc, CampusDriveState>(
      listener: (context, state) {
        if (state.status == CampusDriveStatus.failure &&
            state.errorMessage != null) {
          TopSnackBar.showError(context, message: state.errorMessage!);
        }
      },
      builder: (context, state) {
        if (state.isLiveDrivesLoading && state.liveDrives.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.secondaryColor,
              ),
            ),
          );
        }

        if (state.status == CampusDriveStatus.failure &&
            state.liveDrives.isEmpty) {
          return NoInternetWidget(
            message:
                state.errorMessage ??
                'Failed to load campus drives. Please check your connection.',
            onRefresh: () {
              context.read<CampusDriveBloc>().add(const LoadLiveDrivesEvent());
            },
          );
        }

        if (state.liveDrives.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.calendar_today_outlined,
            title: 'No Campus Drives Available',
            subtitle: 'There are no live campus drives at the moment.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<CampusDriveBloc>().add(const RefreshLiveDrivesEvent());
          },
          color: AppConstants.secondaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: state.liveDrives.length,
            itemBuilder: (context, index) {
              final drive = state.liveDrives[index];
              return _CampusDriveCard(
                drive: drive,
                onTap: () {
                  context.push(
                    AppRoutes.campusDriveDetailsWithId(drive.id.toString()),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// Campus Drive Card Widget
class _CampusDriveCard extends StatelessWidget {
  final CampusDrive drive;
  final VoidCallback onTap;

  const _CampusDriveCard({required this.drive, required this.onTap});

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  // Left side - Green icon container
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppConstants.successColor,
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallBorderRadius,
                      ),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  // Title and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drive.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (drive.organizer.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            drive.organizer,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppConstants.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: drive.status == 'live'
                          ? AppConstants.successColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      drive.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: drive.status == 'live'
                            ? AppConstants.successColor
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.smallPadding),

              // Drive info
              _buildDriveInfo(),
              const SizedBox(height: AppConstants.smallPadding),

              // Companies and Applications count
              _buildStatsRow(),
              const SizedBox(height: AppConstants.smallPadding),

              // Green button
              _buildActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriveInfo() {
    return Column(
      children: [
        // Venue and City
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: AppConstants.textSecondaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${drive.venue}, ${drive.city}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Dates
        Row(
          children: [
            const Icon(
              Icons.date_range,
              size: 16,
              color: AppConstants.textSecondaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Last Date: ${_formatDate(drive.endDate)}',
              style: const TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // Companies count
        _buildStatItem(
          Icons.business,
          '${drive.totalCompanies ?? 0} Companies',
        ),
        const SizedBox(width: 16),
        // Applications count (if available)
        _buildStatItem(
          Icons.people_outline,
          '${drive.totalApplications ?? 0} Applicants',
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppConstants.textSecondaryColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.successColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: const Text(
          'Apply Now',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
