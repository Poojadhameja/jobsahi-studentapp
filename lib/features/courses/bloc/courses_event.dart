import 'package:equatable/equatable.dart';

/// Courses events
abstract class CoursesEvent extends Equatable {
  const CoursesEvent();
}

/// Load courses event
class LoadCoursesEvent extends CoursesEvent {
  final bool forceRefresh;
  const LoadCoursesEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Search courses event
class SearchCoursesEvent extends CoursesEvent {
  final String query;

  const SearchCoursesEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Filter courses event
class FilterCoursesEvent extends CoursesEvent {
  final String? category;
  final String? level;
  final String? duration;
  final String? institute;

  const FilterCoursesEvent({
    this.category,
    this.level,
    this.duration,
    this.institute,
  });

  @override
  List<Object?> get props => [category, level, duration, institute];
}

/// Clear all filters event
class ClearAllFiltersEvent extends CoursesEvent {
  const ClearAllFiltersEvent();

  @override
  List<Object?> get props => [];
}

/// Save course event
class SaveCourseEvent extends CoursesEvent {
  final String courseId;

  const SaveCourseEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Unsave course event
class UnsaveCourseEvent extends CoursesEvent {
  final String courseId;

  const UnsaveCourseEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Enroll in course event
class EnrollInCourseEvent extends CoursesEvent {
  final String courseId;

  const EnrollInCourseEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Load saved courses event
class LoadSavedCoursesEvent extends CoursesEvent {
  const LoadSavedCoursesEvent();

  @override
  List<Object?> get props => [];
}

/// Load enrolled courses event
class LoadEnrolledCoursesEvent extends CoursesEvent {
  const LoadEnrolledCoursesEvent();

  @override
  List<Object?> get props => [];
}

/// Refresh courses event
class RefreshCoursesEvent extends CoursesEvent {
  const RefreshCoursesEvent();

  @override
  List<Object?> get props => [];
}

/// Clear search event
class ClearSearchEvent extends CoursesEvent {
  const ClearSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Toggle filters event
class ToggleFiltersEvent extends CoursesEvent {
  const ToggleFiltersEvent();

  @override
  List<Object?> get props => [];
}

/// Load course details event
class LoadCourseDetailsEvent extends CoursesEvent {
  final int courseId;

  const LoadCourseDetailsEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}
