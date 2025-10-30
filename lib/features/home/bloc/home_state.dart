import 'package:equatable/equatable.dart';

/// Home states
abstract class HomeState extends Equatable {
  const HomeState();
}

/// Initial home state
class HomeInitial extends HomeState {
  const HomeInitial();

  @override
  List<Object?> get props => [];
}

/// Home loading state
class HomeLoading extends HomeState {
  const HomeLoading();

  @override
  List<Object?> get props => [];
}

/// Home loaded state
class HomeLoaded extends HomeState {
  final int selectedTabIndex;
  final String searchQuery;
  final String selectedCategory;
  final bool showFilters;
  final Map<String, String?>
  activeFilters; // 'fields', 'salary', 'location' -> value
  final List<Map<String, dynamic>> recommendedJobs;
  final List<Map<String, dynamic>> filteredJobs;
  final List<Map<String, dynamic>> featuredJobs;
  final Set<String> savedJobIds;
  final List<Map<String, dynamic>> allJobs;

  const HomeLoaded({
    this.selectedTabIndex = 0,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.showFilters = false,
    this.activeFilters = const {},
    required this.recommendedJobs,
    required this.filteredJobs,
    required this.featuredJobs,
    this.savedJobIds = const {},
    this.allJobs = const [],
  });

  @override
  List<Object?> get props => [
    selectedTabIndex,
    searchQuery,
    selectedCategory,
    showFilters,
    activeFilters,
    recommendedJobs,
    filteredJobs,
    featuredJobs,
    savedJobIds,
    allJobs,
  ];

  /// Copy with method for immutable state updates
  HomeLoaded copyWith({
    int? selectedTabIndex,
    String? searchQuery,
    String? selectedCategory,
    bool? showFilters,
    Map<String, String?>? activeFilters,
    List<Map<String, dynamic>>? recommendedJobs,
    List<Map<String, dynamic>>? filteredJobs,
    List<Map<String, dynamic>>? featuredJobs,
    Set<String>? savedJobIds,
    List<Map<String, dynamic>>? allJobs,
  }) {
    return HomeLoaded(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showFilters: showFilters ?? this.showFilters,
      activeFilters: activeFilters ?? this.activeFilters,
      recommendedJobs: recommendedJobs ?? this.recommendedJobs,
      filteredJobs: filteredJobs ?? this.filteredJobs,
      featuredJobs: featuredJobs ?? this.featuredJobs,
      savedJobIds: savedJobIds ?? this.savedJobIds,
      allJobs: allJobs ?? this.allJobs,
    );
  }
}

/// Home error state
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
