import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/home/bloc/home_bloc.dart';
import '../../../features/home/bloc/home_event.dart';
import '../../../features/home/bloc/home_state.dart';

/// Reusable Search and Filter Bar Widget
/// Combines search field with animated filter toggle button
class SearchFilterBar extends StatefulWidget {
  /// Search hint text
  final String searchHint;

  /// Controller for search field
  final TextEditingController? searchController;

  /// Callback when search text changes
  final Function(String)? onSearchChanged;

  /// Callback when search is cleared
  final Function()? onSearchCleared;

  /// Callback when filter toggle is pressed
  final Function(bool)? onFilterToggle;

  /// Whether filters are currently visible
  final bool showFilters;

  /// Whether to show filter button
  final bool showFilterButton;

  /// Initial search value to populate the field
  final String? initialValue;

  const SearchFilterBar({
    super.key,
    this.searchHint = 'नौकरी खोजें',
    this.searchController,
    this.onSearchChanged,
    this.onSearchCleared,
    this.onFilterToggle,
    this.showFilters = false,
    this.showFilterButton = true,
    this.initialValue,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.searchController ??
        TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(SearchFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller text if initialValue changed
    if (oldWidget.initialValue != widget.initialValue &&
        widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    if (widget.searchController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(22.5),
                border: Border.all(color: AppConstants.borderColor, width: 1),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  final isEnabled = widget.onSearchChanged != null;
                  return TextField(
                    controller: _controller,
                    enabled: isEnabled,
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      hintStyle: TextStyle(
                        color: isEnabled
                            ? AppConstants.textSecondaryColor
                            : AppConstants.textSecondaryColor.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isEnabled
                            ? AppConstants.textSecondaryColor
                            : AppConstants.textSecondaryColor.withOpacity(0.5),
                        size: 20,
                      ),
                      suffixIcon: _controller.text.isNotEmpty && widget.onSearchCleared != null
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppConstants.textSecondaryColor,
                                size: 20,
                              ),
                              onPressed: () {
                                _controller.clear();
                                setState(() {});
                                widget.onSearchCleared?.call();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(
                      color: isEnabled
                          ? AppConstants.textPrimaryColor
                          : AppConstants.textPrimaryColor.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    onChanged: (value) {
                      setState(() {}); // Local rebuild for suffixIcon
                      widget.onSearchChanged?.call(value);
                    },
                  );
                },
              ),
            ),
          ),
          if (widget.showFilterButton) ...[
            const SizedBox(width: 8),
            _buildFilterButton(
              context,
              widget.showFilters,
              widget.onFilterToggle,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the filter toggle button with animation
  Widget _buildFilterButton(
    BuildContext context,
    bool isFilterVisible,
    Function(bool)? onFilterToggle,
  ) {
    final isEnabled = onFilterToggle != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? () => onFilterToggle(!isFilterVisible) : null,
        borderRadius: BorderRadius.circular(22.5),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: isFilterVisible
                  ? AppConstants.primaryColor
                  : AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(22.5),
              border: Border.all(color: AppConstants.borderColor, width: 1),
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
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Search Filter Bar with HomeBloc Integration
/// Automatically connects to HomeBloc for state management
class SearchFilterBarWithBloc extends StatelessWidget {
  /// Search hint text
  final String searchHint;

  const SearchFilterBarWithBloc({super.key, this.searchHint = 'नौकरी खोजें'});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Show search bar even during loading, but disable interactions
        final isFilterVisible = state is HomeLoaded ? state.showFilters : false;
        final searchQuery = state is HomeLoaded ? state.searchQuery : '';
        final isLoading = state is HomeLoading;

        return SearchFilterBar(
          searchHint: searchHint,
          showFilters: isFilterVisible,
          initialValue: searchQuery,
          onSearchChanged: isLoading
              ? null
              : (value) {
                  context.read<HomeBloc>().add(SearchJobsEvent(query: value));
                },
          onSearchCleared: isLoading
              ? null
              : () {
                  context.read<HomeBloc>().add(const ClearSearchEvent());
                },
          onFilterToggle: isLoading
              ? null
              : (showFilters) {
                  if (state is HomeLoaded) {
                    final bloc = context.read<HomeBloc>();
                    if (showFilters && state.activeFilters.isNotEmpty) {
                      bloc.add(const ClearAllFiltersEvent());
                    }
                    bloc.add(const ToggleFiltersEvent());
                  }
                },
        );
      },
    );
  }
}
