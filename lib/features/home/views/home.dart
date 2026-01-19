import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/widgets/common/navigation_helper.dart';
import '../../../shared/widgets/common/empty_state_widget.dart';
import '../../../shared/widgets/common/custom_tab_structure.dart';
import '../../../shared/widgets/cards/job_card.dart';
import '../../../shared/widgets/activity_tracker.dart';
import '../../../shared/services/home_cache_service.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load home data when screen initializes
    context.read<HomeBloc>().add(const LoadHomeDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return ActivityTracker(
      child: KeyboardDismissWrapper(
        child: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) {
            // Only rebuild if state type changes
            return previous.runtimeType != current.runtimeType;
          },
          builder: (context, state) {
            if (state is HomeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(const LoadHomeDataEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else {
              // Show HomePage content (including during loading)
              return const HomePage();
            }
          },
        ),
      ),
    );
  }
}

/// Home Page Widget
/// The main content of the home screen showing job listings
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? _tabController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  bool _isBannerLoading = true;
  late AnimationController _skeletonController;
  bool _allImagesPreloaded = false;
  bool _isUserHolding = false;

  // Banner images from assets (default, will be loaded from cache if available)
  List<String> _bannerImages = [
    'assets/images/banner/banner1.jpg',
    'assets/images/banner/banner2.jpg',
    'assets/images/banner/banner3.jpg',
    'assets/images/banner/banner4.jpg',
    'assets/images/banner/banner5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 400),
    );

    _skeletonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Load banner images from cache or use default
    _loadBannerImages();
    // Timer will start after first image loads (see frameBuilder)

    // Removed auto-loading saved jobs on tab switch to avoid redundant API calls
  }

  /// Load banner images from cache or use default
  Future<void> _loadBannerImages() async {
    try {
      final cacheService = HomeCacheService.instance;
      await cacheService.initialize();

      // Check if banners are already loaded from cache
      final isBannerLoaded = await cacheService.isBannerLoaded();

      // Try to load from cache
      final cachedBanners = await cacheService.getBannerImages();
      if (cachedBanners != null && cachedBanners.isNotEmpty) {
        if (mounted) {
          setState(() {
            _bannerImages = cachedBanners;
          });
        }
        debugPrint(
          '🔵 [Home] Loaded ${_bannerImages.length} banner images from cache',
        );

        // If banners are already loaded, mark as preloaded to skip reload
        if (isBannerLoaded) {
          if (mounted) {
            setState(() {
              _allImagesPreloaded = true;
              _isBannerLoading = false;
            });
          }
          // Start timer if not already running
          if (mounted && (_bannerTimer == null || !_bannerTimer!.isActive)) {
            _startBannerTimer();
          }
          debugPrint(
            '🔵 [Home] Banners already loaded from cache, skipping preload',
          );
          return; // Skip preloading if already loaded
        }
      } else {
        // Store default banner images in cache for first time
        await cacheService.storeBannerImages(_bannerImages);
        debugPrint('🔵 [Home] Stored default banner images in cache');
      }
    } catch (e) {
      debugPrint('🔴 [Home] Error loading banner images from cache: $e');
    }

    // Only preload if banners haven't been loaded before
    if (!_allImagesPreloaded) {
      _preloadAllBannerImages();
    }
  }

  /// Preload all banner images to ensure smooth transitions
  void _preloadAllBannerImages() {
    // Only preload once - if already preloaded, don't reload
    if (_allImagesPreloaded) {
      debugPrint('🔵 [Home] Banner images already preloaded, skipping');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && !_allImagesPreloaded) {
        // Preload all images and ensure they are fully loaded and decoded
        final List<Future<void>> loadFutures = [];

        for (int i = 0; i < _bannerImages.length; i++) {
          final imagePath = _bannerImages[i];
          final imageProvider = AssetImage(imagePath);

          // Create a future that ensures image is fully loaded and decoded
          final loadFuture = precacheImage(imageProvider, context)
              .then((_) async {
                // Additional step: Resolve the image to ensure it's fully decoded
                final resolved = imageProvider.resolve(
                  ImageConfiguration(
                    size: Size(MediaQuery.of(context).size.width, 180),
                  ),
                );

                // Wait for the image to be fully decoded
                final completer = Completer<void>();
                final listener = ImageStreamListener(
                  (ImageInfo info, bool synchronousCall) {
                    if (!completer.isCompleted) {
                      completer.complete();
                    }
                  },
                  onError: (exception, stackTrace) {
                    if (!completer.isCompleted) {
                      completer.complete();
                    }
                  },
                );

                resolved.addListener(listener);

                // Wait for image to load with timeout
                try {
                  await completer.future.timeout(
                    const Duration(seconds: 5),
                    onTimeout: () {
                      if (!completer.isCompleted) {
                        completer.complete();
                      }
                    },
                  );
                } catch (e) {
                  if (!completer.isCompleted) {
                    completer.complete();
                  }
                } finally {
                  resolved.removeListener(listener);
                }
              })
              .catchError((error) {
                // Continue even if image fails to load
              });

          loadFutures.add(loadFuture);
        }

        // Wait for all images to be fully loaded and decoded
        try {
          await Future.wait(loadFutures);

          // Store banner images in cache after successful load
          final cacheService = HomeCacheService.instance;
          await cacheService.initialize();
          await cacheService.storeBannerImages(_bannerImages);
          debugPrint('🔵 [Home] Stored banner images in cache after load');
        } catch (e) {
          // Continue even if some images fail
          debugPrint('🔴 [Home] Error storing banner images in cache: $e');
        }

        if (mounted && !_allImagesPreloaded) {
          setState(() {
            _allImagesPreloaded = true;
          });

          // Additional delay to ensure all images are in memory and ready
          await Future.delayed(const Duration(milliseconds: 150));

          if (mounted && (_bannerTimer == null || !_bannerTimer!.isActive)) {
            _startBannerTimer();
          }
        }
      }
    });
  }

  void _startBannerTimer() {
    // Only start timer if not already running
    if (_bannerTimer != null && _bannerTimer!.isActive) {
      debugPrint('🔵 [Home] Banner timer already running, skipping restart');
      return;
    }

    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isUserHolding && mounted) {
        setState(() {
          _currentBannerIndex =
              (_currentBannerIndex + 1) % _bannerImages.length;
        });
      }
    });
  }

  /// Pause banner auto-scroll when user holds
  void _pauseBannerTimer() {
    if (!_isUserHolding) {
      setState(() {
        _isUserHolding = true;
      });
    }
  }

  /// Resume banner auto-scroll when user releases
  void _resumeBannerTimer() {
    if (_isUserHolding) {
      setState(() {
        _isUserHolding = false;
      });
      // Timer will automatically resume since _isUserHolding is now false
      // No need to restart timer as it's still running
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _skeletonController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  TabController get tabController {
    _tabController ??= TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 400),
    );
    return _tabController!;
  }

  @override
  bool get wantKeepAlive => true; // Keep widget alive to maintain banner timer

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) {
        // Rebuild only on relevant state changes
        if (previous is HomeLoading && current is HomeLoaded) return true;
        if (previous is HomeLoaded && current is HomeError) return true;
        if (current is HomeError) return true;
        if (previous is! HomeLoaded || current is! HomeLoaded) return true;
        // For HomeLoaded states, check if data actually changed
        final prevLoaded = previous as HomeLoaded;
        final currLoaded = current as HomeLoaded;
        return prevLoaded.filteredJobs != currLoaded.filteredJobs ||
            prevLoaded.recommendedJobs != currLoaded.recommendedJobs ||
            prevLoaded.savedJobIds != currLoaded.savedJobIds ||
            prevLoaded.showFilters != currLoaded.showFilters;
      },
      builder: (context, state) {
        final isLoading = state is HomeLoading;
        final homeLoaded = state is HomeLoaded ? state : null;

        if (state is HomeError) {
          return NoInternetErrorWidget(
            errorMessage: state.message,
            onRetry: () {
              context.read<HomeBloc>().add(const LoadHomeDataEvent());
            },
            showImage: true,
            enablePullToRefresh: true,
          );
        }

        return SafeArea(
          child: KeyboardDismissWrapper(
            child: Container(
              color: Colors.white,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    // Banner Sliver - scrollable (not sticky)
                    SliverToBoxAdapter(child: _buildBanner()),
                  ];
                },
                body: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppConstants.secondaryColor,
                        ),
                      )
                    : homeLoaded != null
                    ? DefaultTabController(
                        length: 2,
                        child: Builder(
                          builder: (innerContext) {
                            return Stack(
                              children: [
                                // Main content structure (same as courses section)
                                CustomTabStructure(
                                  tabs: const [
                                    TabConfig(title: 'All Jobs'),
                                    TabConfig(title: 'Saved Jobs'),
                                  ],
                                  tabContents: [
                                    _buildAllJobsTab(),
                                    _buildSavedJobsTab(),
                                  ],
                                ),
                                // Filter chips overlay - positioned right after tab bar (same as courses section)
                                Positioned(
                                  top:
                                      56, // Tab bar height (48px) + bottom padding (8px) = 56px
                                  left: 0,
                                  right: 0,
                                  child: BlocBuilder<HomeBloc, HomeState>(
                                    builder: (context, state) {
                                      if (state is HomeLoaded) {
                                        final showFilters = state.showFilters;
                                        return TweenAnimationBuilder<double>(
                                          tween: Tween(
                                            begin: 0.0,
                                            end: showFilters ? 1.0 : 0.0,
                                          ),
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                          builder: (context, value, child) {
                                            return ClipRect(
                                              child: Transform.translate(
                                                offset: Offset(
                                                  0,
                                                  -80 * (1 - value),
                                                ),
                                                child: Opacity(
                                                  opacity: value,
                                                  child: child,
                                                ),
                                              ),
                                            );
                                          },
                                          child: _buildFiltersSection(),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: AppConstants.secondaryColor,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Handle save toggle for a job
  void _handleSaveToggle(Map<String, dynamic> job) {
    final jobId = job['id']?.toString();
    if (jobId == null) return;

    final currentState = context.read<HomeBloc>().state;
    if (currentState is HomeLoaded) {
      final isCurrentlySaved = currentState.savedJobIds.contains(jobId);

      if (isCurrentlySaved) {
        context.read<HomeBloc>().add(UnsaveJobEvent(jobId: jobId));
      } else {
        context.read<HomeBloc>().add(SaveJobEvent(jobId: jobId));
      }
    }
  }

  /// Builds a single banner image widget
  Widget _buildBannerImage(int index) {
    // Calculate cache dimensions based on screen width for better performance
    final screenWidth = MediaQuery.of(context).size.width;
    final cacheWidth = (screenWidth * MediaQuery.of(context).devicePixelRatio)
        .round();
    final cacheHeight = (180 * MediaQuery.of(context).devicePixelRatio).round();

    return SizedBox.expand(
      key: ValueKey('banner_$index'),
      child: Image.asset(
        _bannerImages[index],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        alignment: Alignment.center,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          // If image is already loaded (precached), show it immediately
          if (wasSynchronouslyLoaded || frame != null) {
            // Update loading state only for the first image
            if (index == 0 && _isBannerLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _isBannerLoading) {
                  setState(() {
                    _isBannerLoading = false;
                  });
                }
              });
            }
            return child;
          }
          // If image is not loaded yet, show a placeholder that matches the image background
          // This prevents white flash during transitions
          return Container(color: Colors.grey.shade300, child: child);
        },
        errorBuilder: (context, error, stackTrace) {
          if (index == _currentBannerIndex && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isBannerLoading = false;
                });
              }
            });
          }
          return Container(
            color: AppConstants.primaryColor,
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 64,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the banner carousel
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
            ? Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1)
            : null,
        boxShadow: _isBannerLoading
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
              // Skeleton loader with green loader in center
              if (_isBannerLoading)
                SizedBox.expand(
                  child: AnimatedBuilder(
                    animation: _skeletonController,
                    builder: (context, child) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(
                              -1.0 - _skeletonController.value * 2,
                              0.0,
                            ),
                            end: Alignment(
                              1.0 - _skeletonController.value * 2,
                              0.0,
                            ),
                            colors: [
                              Colors.white,
                              Colors.grey[50]!,
                              Colors.white,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppConstants.secondaryColor,
                            strokeWidth: 3,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // Stack-based cross-fade transition to prevent white space
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                layoutBuilder:
                    (Widget? currentChild, List<Widget> previousChildren) {
                      return Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          // Keep previous images visible during fade out
                          ...previousChildren,
                          // Show current image fading in
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                child: _buildBannerImage(_currentBannerIndex),
              ),
              // Page indicators (small dots)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _bannerImages.length,
                    (index) => Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentBannerIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
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

  /// Builds the All Jobs tab
  Widget _buildAllJobsTab() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded) {
          return _buildRecommendedJobsSection(state.filteredJobs);
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Builds the Saved Jobs tab
  /// Replica of All Jobs tab - just filters by savedJobIds
  Widget _buildSavedJobsTab() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded) {
          // Filter jobs by savedJobIds - same as All Jobs but filtered
          final savedJobs = state.allJobs.where((job) {
            final jobId = job['id'] is int
                ? job['id'].toString()
                : job['id']?.toString() ?? '';
            return state.savedJobIds.contains(jobId);
          }).toList();

          // Apply search and filters if active (same as All Jobs tab)
          var filteredSavedJobs = savedJobs;

          // Apply search query if exists
          if (state.searchQuery.isNotEmpty) {
            filteredSavedJobs = filteredSavedJobs.where((job) {
              final queryLower = state.searchQuery.toLowerCase();
              return job['title'].toString().toLowerCase().contains(
                    queryLower,
                  ) ||
                  job['company'].toString().toLowerCase().contains(
                    queryLower,
                  ) ||
                  job['location'].toString().toLowerCase().contains(queryLower);
            }).toList();
          }

          // Apply active filters if exists
          if (state.activeFilters.isNotEmpty) {
            filteredSavedJobs = _applyFiltersToJobs(
              filteredSavedJobs,
              state.activeFilters,
            );
          }

          // Use the same recommended jobs section builder (replica of All Jobs)
          return _buildRecommendedJobsSection(filteredSavedJobs);
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Apply filters to jobs list (helper method for saved jobs tab)
  List<Map<String, dynamic>> _applyFiltersToJobs(
    List<Map<String, dynamic>> jobs,
    Map<String, String?> filters,
  ) {
    if (filters.isEmpty) return jobs;

    var filteredJobs = jobs;

    for (final entry in filters.entries) {
      final filterType = entry.key;
      final filterValue = entry.value;

      if (filterValue == null || filterValue.isEmpty) continue;

      filteredJobs = filteredJobs.where((job) {
        switch (filterType) {
          case 'fields':
            final title = job['title']?.toString().toLowerCase() ?? '';
            final description =
                job['description']?.toString().toLowerCase() ?? '';
            final filterLower = filterValue.toLowerCase();
            return title.contains(filterLower) ||
                description.contains(filterLower);

          case 'salary':
            final salary = job['salary']?.toString() ?? '';
            return salary.toLowerCase().contains(filterValue.toLowerCase());

          case 'location':
            final location = job['location']?.toString().toLowerCase() ?? '';
            return location.contains(filterValue.toLowerCase());

          case 'job_type':
            final jobType =
                job['job_type_display']?.toString() ??
                job['job_type']?.toString() ??
                '';
            final normalizedType = jobType.toLowerCase();
            final filterLower = filterValue.toLowerCase();

            if (filterLower == 'full-time') {
              return normalizedType.contains('full');
            } else if (filterLower == 'part-time') {
              return normalizedType.contains('part');
            } else if (filterLower == 'internship') {
              return normalizedType.contains('intern');
            }
            return false;

          case 'work_mode':
            final isRemote = job['is_remote'] ?? false;
            final filterLower = filterValue.toLowerCase();

            if (filterLower == 'remote') {
              return isRemote;
            } else if (filterLower == 'on-site') {
              return !isRemote;
            }
            return false;

          default:
            return true;
        }
      }).toList();
    }

    return filteredJobs;
  }

  /// Builds the recommended jobs section
  Widget _buildRecommendedJobsSection(List<Map<String, dynamic>> jobs) {
    return RefreshIndicator(
      color: AppConstants.successColor,
      onRefresh: () async {
        context.read<HomeBloc>().add(const LoadHomeDataEvent());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // Check if jobs are empty and show empty state
          if (jobs.isEmpty) {
            final hasActiveFilters =
                state is HomeLoaded &&
                (state.searchQuery.isNotEmpty ||
                    state.activeFilters.isNotEmpty);

            return RefreshIndicator(
              color: AppConstants.successColor,
              onRefresh: () async {
                context.read<HomeBloc>().add(const LoadHomeDataEvent());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: EmptyStateWidget(
                    icon: Icons.search_off,
                    title: 'No jobs found',
                    subtitle: 'Try adjusting your search or filters',
                    actionButton: hasActiveFilters
                        ? ElevatedButton(
                            onPressed: () {
                              final bloc = context.read<HomeBloc>();
                              bloc.add(const ClearSearchEvent());
                              bloc.add(const ClearAllFiltersEvent());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadius,
                                ),
                              ),
                            ),
                            child: const Text('Clear All'),
                          )
                        : null,
                  ),
                ),
              ),
            );
          }

          final filterPadding = (state is HomeLoaded && state.showFilters)
              ? 92.0
              : 12.0;

          return CustomScrollView(
            slivers: [
              // Animated spacing at top (same as courses section)
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: filterPadding - 12,
                ),
              ),
              // Job list as SliverList
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.defaultPadding,
                  12,
                  AppConstants.defaultPadding,
                  0,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final job = jobs[index];
                    final currentState = BlocProvider.of<HomeBloc>(
                      context,
                    ).state;
                    final homeLoaded = currentState is HomeLoaded
                        ? currentState
                        : null;

                    // Check if this job is featured
                    final jobId = job['id'] is int
                        ? job['id'].toString()
                        : job['id']?.toString() ?? '';
                    final isFeatured =
                        homeLoaded != null &&
                        homeLoaded.featuredJobs.any((featuredJob) {
                          final featuredJobId = featuredJob['id'] is int
                              ? featuredJob['id'].toString()
                              : featuredJob['id']?.toString() ?? '';
                          return featuredJobId == jobId;
                        });

                    return RepaintBoundary(
                      child: JobCard(
                        job: job,
                        onTap: () {
                          if (jobId.isNotEmpty) {
                            NavigationHelper.navigateTo(
                              AppRoutes.jobDetailsWithId(jobId),
                            );
                          }
                        },
                        onSaveToggle: () {
                          _handleSaveToggle(job);
                        },
                        isSaved:
                            homeLoaded != null &&
                            homeLoaded.savedJobIds.contains(jobId),
                        isFeatured: isFeatured,
                      ),
                    );
                  }, childCount: jobs.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the filters section
  Widget _buildFiltersSection() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();

        return GestureDetector(
          onHorizontalDragUpdate: (_) {
            // Consume horizontal drag gestures to prevent tab switching
          },
          child: Container(
            height: 80.0, // Full height to capture all gestures
            decoration: const BoxDecoration(
              color: AppConstants.cardBackgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey, width: 0.5),
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Container(
                height: 70.0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: AppConstants.defaultPadding),
                      _buildFilterChip(
                        context,
                        state,
                        'fields',
                        'Fields',
                        Icons.category_outlined,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        state,
                        'salary',
                        'Salary',
                        Icons.attach_money_outlined,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        state,
                        'location',
                        'Location',
                        Icons.location_on_outlined,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        state,
                        'job_type',
                        'Job Type',
                        Icons.work_outline,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        state,
                        'work_mode',
                        'Work Mode',
                        Icons.business,
                      ),
                      SizedBox(width: AppConstants.defaultPadding),
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

  /// Builds a filter chip button
  Widget _buildFilterChip(
    BuildContext context,
    HomeLoaded state,
    String filterType,
    String label,
    IconData icon,
  ) {
    final isActive =
        state.activeFilters.containsKey(filterType) &&
        state.activeFilters[filterType] != null;
    final activeValue = state.activeFilters[filterType];

    return InkWell(
      onTap: () {
        // Show filter modal
        _showFilterModal(context, filterType, label);
      },
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 8 : 12,
          vertical: AppConstants.smallPadding,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppConstants.primaryColor : Colors.transparent,
          border: Border.all(
            color: isActive
                ? AppConstants.primaryColor
                : AppConstants.primaryColor.withOpacity(0.5),
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              icon,
              color: isActive ? Colors.white : AppConstants.primaryColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            // Text - show active value if available, otherwise show label
            // Truncate to 15 characters with ellipsis
            Flexible(
              child: Text(
                _truncateText(activeValue ?? label, 15),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? Colors.white : AppConstants.primaryColor,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            // Right side: Cross icon (only when active)
            if (isActive) ...[
              const SizedBox(width: 6),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.read<HomeBloc>().add(
                      ClearFilterEvent(filterType: filterType),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Truncate text to max length with ellipsis
  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  /// Shows filter modal for selecting filter value
  void _showFilterModal(BuildContext context, String filterType, String label) {
    final state = context.read<HomeBloc>().state;
    if (state is! HomeLoaded) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _FilterModalContent(
          filterType: filterType,
          label: label,
          currentValue: state.activeFilters[filterType],
          jobs: state.recommendedJobs,
        );
      },
    );
  }
}

/// Job List Widget
/// Displays a list of job cards
class JobList extends StatelessWidget {
  /// List of jobs to display
  final List<Map<String, dynamic>> jobs;

  /// Callback when save button is toggled
  final Function(Map<String, dynamic>)? onSaveToggle;

  /// Function to check if a job is saved
  final bool Function(Map<String, dynamic>)? isSaved;

  /// List of featured jobs to check against
  final List<Map<String, dynamic>>? featuredJobs;

  const JobList({
    super.key,
    required this.jobs,
    this.onSaveToggle,
    this.isSaved,
    this.featuredJobs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: jobs.map<Widget>((job) {
        final jobId = job['id'] is int
            ? job['id'].toString()
            : job['id']?.toString() ?? '';
        final isFeatured =
            featuredJobs != null &&
            featuredJobs!.any((featuredJob) {
              final featuredJobId = featuredJob['id'] is int
                  ? featuredJob['id'].toString()
                  : featuredJob['id']?.toString() ?? '';
              return featuredJobId == jobId;
            });

        return RepaintBoundary(
          child: JobCard(
            job: job,
            onTap: () {
              if (jobId.isNotEmpty) {
                NavigationHelper.navigateTo(AppRoutes.jobDetailsWithId(jobId));
              }
            },
            onSaveToggle: onSaveToggle != null
                ? () => onSaveToggle!(job)
                : null,
            isSaved: isSaved != null ? isSaved!(job) : false,
            isFeatured: isFeatured,
          ),
        );
      }).toList(),
    );
  }
}

/// Filter Modal Content Widget
class _FilterModalContent extends StatefulWidget {
  final String filterType;
  final String label;
  final String? currentValue;
  final List<Map<String, dynamic>> jobs;

  const _FilterModalContent({
    required this.filterType,
    required this.label,
    this.currentValue,
    required this.jobs,
  });

  @override
  State<_FilterModalContent> createState() => _FilterModalContentState();
}

class _FilterModalContentState extends State<_FilterModalContent> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.currentValue;
  }

  List<String> getFilterOptions() {
    final Set<String> options = {};

    for (final job in widget.jobs) {
      switch (widget.filterType) {
        case 'fields':
          // Get unique job titles
          final title = job['title']?.toString();
          if (title != null && title.isNotEmpty) {
            options.add(title);
          }
          break;
        case 'salary':
          // Get unique salary ranges
          final salary = job['salary']?.toString();
          if (salary != null && salary.isNotEmpty) {
            options.add(salary);
          }
          break;
        case 'location':
          // Get unique locations
          final location = job['location']?.toString();
          if (location != null && location.isNotEmpty) {
            options.add(location);
          }
          break;
        case 'job_type':
          // Get unique job types (Full-Time, Part-Time, Internship)
          final jobType =
              job['job_type_display']?.toString() ??
              job['job_type']?.toString() ??
              '';
          if (jobType.isNotEmpty) {
            // Normalize job types
            final normalizedType = jobType.toLowerCase();
            if (normalizedType.contains('full')) {
              options.add('Full-Time');
            } else if (normalizedType.contains('part')) {
              options.add('Part-Time');
            } else if (normalizedType.contains('intern')) {
              options.add('Internship');
            }
          }
          break;
        case 'work_mode':
          // Get work mode (Remote, On-site)
          final isRemote = job['is_remote'] ?? false;
          if (isRemote) {
            options.add('Remote');
          } else {
            options.add('On-site');
          }
          break;
      }
    }

    return options.toList()..sort();
  }

  List<String> getPredefinedOptions() {
    // Return predefined options based on filter type (same as courses section pattern)
    switch (widget.filterType) {
      case 'job_type':
        return ['All', 'Full-Time', 'Part-Time', 'Internship'];
      case 'work_mode':
        return ['All', 'Remote', 'On-site'];
      default:
        // For dynamic filters (fields, salary, location), use getFilterOptions
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use predefined options if available, otherwise use dynamic options
    final predefinedOptions = getPredefinedOptions();
    final dynamicOptions = getFilterOptions();
    final options = predefinedOptions.isNotEmpty
        ? predefinedOptions
        : ['All', ...dynamicOptions];

    final currentSelectedValue = selectedValue ?? widget.currentValue;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        24,
        AppConstants.defaultPadding,
        32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select ${widget.label}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected =
                    option == currentSelectedValue ||
                    (option == 'All' && currentSelectedValue == null);

                return InkWell(
                  onTap: () {
                    final valueToApply = option == 'All' ? null : option;
                    context.read<HomeBloc>().add(
                      ApplyFilterEvent(
                        filterType: widget.filterType,
                        filterValue: valueToApply,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppConstants.primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppConstants.primaryColor
                              : AppConstants.textSecondaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected
                                  ? AppConstants.primaryColor
                                  : AppConstants.textPrimaryColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom Navigation Screen Widgets
/// These are placeholder screens for the bottom navigation tabs
