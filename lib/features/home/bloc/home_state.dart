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
  final int selectedFilterIndex;
  final String searchQuery;
  final List<Map<String, dynamic>> recommendedJobs;
  final List<Map<String, dynamic>> filteredJobs;

  const HomeLoaded({
    this.selectedTabIndex = 0,
    this.selectedFilterIndex = 0,
    this.searchQuery = '',
    required this.recommendedJobs,
    required this.filteredJobs,
  });

  @override
  List<Object?> get props => [
    selectedTabIndex,
    selectedFilterIndex,
    searchQuery,
    recommendedJobs,
    filteredJobs,
  ];

  /// Copy with method for immutable state updates
  HomeLoaded copyWith({
    int? selectedTabIndex,
    int? selectedFilterIndex,
    String? searchQuery,
    List<Map<String, dynamic>>? recommendedJobs,
    List<Map<String, dynamic>>? filteredJobs,
  }) {
    return HomeLoaded(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      recommendedJobs: recommendedJobs ?? this.recommendedJobs,
      filteredJobs: filteredJobs ?? this.filteredJobs,
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
