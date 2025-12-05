import 'package:equatable/equatable.dart';

/// Home events
abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

/// Load home data event
class LoadHomeDataEvent extends HomeEvent {
  const LoadHomeDataEvent();

  @override
  List<Object?> get props => [];
}

/// Change selected tab event
class ChangeTabEvent extends HomeEvent {
  final int tabIndex;

  const ChangeTabEvent({required this.tabIndex});

  @override
  List<Object?> get props => [tabIndex];
}

/// Search jobs event
class SearchJobsEvent extends HomeEvent {
  final String query;

  const SearchJobsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Filter jobs event
class FilterJobsEvent extends HomeEvent {
  final int filterIndex;

  const FilterJobsEvent({required this.filterIndex});

  @override
  List<Object?> get props => [filterIndex];
}

/// Refresh home data event
class RefreshHomeDataEvent extends HomeEvent {
  const RefreshHomeDataEvent();

  @override
  List<Object?> get props => [];
}

/// Clear search event
class ClearSearchEvent extends HomeEvent {
  const ClearSearchEvent();

  @override
  List<Object?> get props => [];
}
