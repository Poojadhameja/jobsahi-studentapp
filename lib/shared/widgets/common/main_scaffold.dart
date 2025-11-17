import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'bottom_navigation.dart';
import 'tab_navigation_manager.dart';
import 'custom_app_bar.dart';
import 'tab_app_bar.dart';
import 'search_filter_bar.dart';
import '../../../features/courses/bloc/courses_bloc.dart';
import '../../../features/courses/bloc/courses_event.dart';
import '../../../features/courses/bloc/courses_state.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late TabNavigationManager _navigationManager;

  @override
  void initState() {
    super.initState();
    _navigationManager = TabNavigationManager.instance;
    _navigationManager.addListener(_onNavigationChanged);
  }

  @override
  void dispose() {
    _navigationManager.removeListener(_onNavigationChanged);
    super.dispose();
  }

  void _onNavigationChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current location to determine active tab
    final state = GoRouterState.of(context);
    final String location = state.uri.path;
    final bool fromProfileParam =
        state.uri.queryParameters['fromProfile'] == 'true';
    final int currentIndex = _getCurrentIndex(location);

    // Update navigation manager's current tab only if different
    if (_navigationManager.currentTabIndex != currentIndex) {
      _navigationManager.setCurrentTab(currentIndex);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPress(context, currentIndex);
        }
      },
      child: Scaffold(
        backgroundColor: AppConstants.cardBackgroundColor,
        appBar: _buildAppBar(
          _navigationManager.currentTabIndex,
          hideForFromProfile: fromProfileParam &&
              location.startsWith('/application-tracker'),
        ),
        body: widget.child,
        bottomNavigationBar: CustomBottomNavigation(
          currentIndex: _navigationManager.currentTabIndex,
          onTap: (index) => _onTabSelected(context, index),
        ),
      ),
    );
  }

  /// Build appropriate app bar based on current tab
  PreferredSizeWidget? _buildAppBar(int currentIndex,
      {bool hideForFromProfile = false}) {
    if (hideForFromProfile) return null;
    switch (currentIndex) {
      case 0:
        // Home tab - show hamburger menu, search, and filter icon
        return CustomAppBar(
          showMenuButton: true,
          customTitle: _buildHomeAppBarTitle(context),
        );
      case 1:
        // Learning tab - show search bar with back and filter buttons
        return _buildLearningCenterAppBar(context, currentIndex);
      case 2:
        // Application Tracker tab - show title with back button
        return TabAppBar(
          title: 'Application Tracker',
          onBackPressed: () => _handleBackPress(context, currentIndex),
        );
      case 3:
        // Messages tab - show title with back button
        return TabAppBar(
          title: 'Messages',
          onBackPressed: () => _handleBackPress(context, currentIndex),
        );
      case 4:
        // Profile tab - show title with back button
        return TabAppBar(
          title: 'Profile Details',
          onBackPressed: () => _handleBackPress(context, currentIndex),
        );
      default:
        return null;
    }
  }

  /// Get current tab index based on route path
  int _getCurrentIndex(String path) {
    int index = 0;
    if (path.startsWith('/home'))
      index = 0;
    else if (path.startsWith('/learning'))
      index = 1;
    else if (path.startsWith('/application-tracker'))
      index = 2;
    else if (path.startsWith('/messages'))
      index = 3;
    else if (path.startsWith('/profile'))
      index = 4;
    else
      index = 0; // Default to home

    print('📍 Path: $path -> Tab Index: $index');
    return index;
  }

  /// Handle tab selection with stack navigation
  void _onTabSelected(BuildContext context, int index) {
    _navigationManager.switchToTab(index);
  }

  /// Handle back press with stack navigation logic
  void _handleBackPress(BuildContext context, int currentIndex) {
    final handled = _navigationManager.handleBackNavigation();

    if (!handled && currentIndex == 0) {
      // On home tab and no navigation history - show exit confirmation
      _showExitConfirmation(context);
    }
  }

  /// Show exit confirmation dialog
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  /// Build home app bar title with search and filter
  Widget _buildHomeAppBarTitle(BuildContext context) {
    return SearchFilterBarWithBloc();
  }

  /// Build Learning Center app bar with search box and filter button
  PreferredSizeWidget _buildLearningCenterAppBar(
    BuildContext context,
    int currentIndex,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 16), // Same as jobs section
      child: AppBar(
        backgroundColor: AppConstants.cardBackgroundColor, // Same as jobs section
        elevation: 0,
        toolbarHeight: kToolbarHeight + 16, // Same as jobs section (56 + 16 = 72)
        titleSpacing: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
        ),
        leading: IconButton(
          onPressed: () => _handleBackPress(context, currentIndex),
          icon: const Icon(
            Icons.arrow_back,
            color: AppConstants.primaryColor,
            size: 24,
          ),
        ),
        title: _buildSearchAndFilterRow(context),
        centerTitle: false,
      ),
    );
  }

  /// Build search box and filter button row
  Widget _buildSearchAndFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8), // Same as jobs section
      child: Row(
        children: [
          Expanded(
            child: _LearningCenterSearchBox(),
          ),
          const SizedBox(width: 8), // Same spacing as jobs section
          // Filter Button with clicking effect and animation
          BlocBuilder<CoursesBloc, CoursesState>(
            builder: (context, state) {
              final isFilterVisible =
                  state is CoursesLoaded && state.showFilters;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.read<CoursesBloc>().add(const ToggleFiltersEvent());
                  },
                  borderRadius: BorderRadius.circular(22.5), // Same as jobs section
                  child: Container(
                    width: 45, // Same as jobs section
                    height: 45, // Same as jobs section
                    decoration: BoxDecoration(
                      color: isFilterVisible
                          ? AppConstants.primaryColor
                          : AppConstants.backgroundColor, // Same as jobs section
                      borderRadius: BorderRadius.circular(22.5), // Same as jobs section
                      border: Border.all(
                        color: AppConstants.borderColor, // Same as jobs section
                        width: 1,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: Icon(
                        isFilterVisible ? Icons.close : Icons.tune,
                        key: ValueKey(isFilterVisible),
                        color: isFilterVisible
                            ? Colors.white
                            : AppConstants.textSecondaryColor,
                        size: 24, // Same as jobs section
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Search box widget for Learning Center app bar
class _LearningCenterSearchBox extends StatefulWidget {
  @override
  State<_LearningCenterSearchBox> createState() =>
      _LearningCenterSearchBoxState();
}

class _LearningCenterSearchBoxState extends State<_LearningCenterSearchBox> {
  late TextEditingController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesBloc, CoursesState>(
      builder: (context, state) {
        // Get bloc from context
        final bloc = context.read<CoursesBloc>();

        // Initialize controller text from state if not already initialized
        if (!_isInitialized && state is CoursesLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _controller.text != state.searchQuery) {
              _controller.text = state.searchQuery;
            }
          });
          _isInitialized = true;
        }

        // Sync controller when search query changes from outside
        if (state is CoursesLoaded && _isInitialized) {
          final currentQuery = state.searchQuery;
          if (_controller.text != currentQuery) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _controller.text = currentQuery;
              }
            });
          }
        }

        return Container(
          height: 45, // Same as jobs section
          decoration: BoxDecoration(
            color: AppConstants.backgroundColor, // Same as jobs section
            borderRadius: BorderRadius.circular(22.5), // Same as jobs section
            border: Border.all(
              color: AppConstants.borderColor, // Same as jobs section
              width: 1,
            ),
          ),
          child: TextField(
            controller: _controller,
            style: const TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 14, // Same as jobs section
            ),
            decoration: const InputDecoration(
              hintText: 'कोर्स खोजें',
              hintStyle: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 14, // Same as jobs section
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppConstants.textSecondaryColor,
                size: 20,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12, // Same as jobs section
              ),
            ),
            onChanged: (value) {
              // Dispatch search event to bloc
              if (value.isEmpty) {
                bloc.add(ClearSearchEvent());
              } else {
                bloc.add(SearchCoursesEvent(query: value));
              }
            },
          ),
        );
      },
    );
  }
}
