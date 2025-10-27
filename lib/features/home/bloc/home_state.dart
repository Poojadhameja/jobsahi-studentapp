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
  final List<Map<String, dynamic>> recommendedJobs;
  final List<Map<String, dynamic>> filteredJobs;
  final List<Map<String, dynamic>> featuredJobs;

  const HomeLoaded({
    this.selectedTabIndex = 0,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.showFilters = false,
    required this.recommendedJobs,
    required this.filteredJobs,
    required this.featuredJobs,
  });

  @override
  List<Object?> get props => [
    selectedTabIndex,
    searchQuery,
    selectedCategory,
    showFilters,
    recommendedJobs,
    filteredJobs,
    featuredJobs,
  ];

  /// Copy with method for immutable state updates
  HomeLoaded copyWith({
    int? selectedTabIndex,
    String? searchQuery,
    String? selectedCategory,
    bool? showFilters,
    List<Map<String, dynamic>>? recommendedJobs,
    List<Map<String, dynamic>>? filteredJobs,
    List<Map<String, dynamic>>? featuredJobs,
  }) {
    return HomeLoaded(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showFilters: showFilters ?? this.showFilters,
      recommendedJobs: recommendedJobs ?? this.recommendedJobs,
      filteredJobs: filteredJobs ?? this.filteredJobs,
      featuredJobs: featuredJobs ?? this.featuredJobs,
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
