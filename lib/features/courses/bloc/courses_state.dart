import 'package:equatable/equatable.dart';

/// Courses states
abstract class CoursesState extends Equatable {
  const CoursesState();
}

/// Initial courses state
class CoursesInitial extends CoursesState {
  const CoursesInitial();

  @override
  List<Object?> get props => [];
}

/// Courses loading state
class CoursesLoading extends CoursesState {
  const CoursesLoading();

  @override
  List<Object?> get props => [];
}

/// Courses loaded state
class CoursesLoaded extends CoursesState {
  final List<Map<String, dynamic>> allCourses;
  final List<Map<String, dynamic>> filteredCourses;
  final List<Map<String, dynamic>> savedCourses;
  final List<Map<String, dynamic>> enrolledCourses;
  final String searchQuery;
  final String selectedCategory;
  final Set<String> savedCourseIds;
  final Set<String> enrolledCourseIds;

  const CoursesLoaded({
    required this.allCourses,
    required this.filteredCourses,
    required this.savedCourses,
    required this.enrolledCourses,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    required this.savedCourseIds,
    required this.enrolledCourseIds,
  });

  @override
  List<Object?> get props => [
    allCourses,
    filteredCourses,
    savedCourses,
    enrolledCourses,
    searchQuery,
    selectedCategory,
    savedCourseIds,
    enrolledCourseIds,
  ];

  /// Copy with method for immutable state updates
  CoursesLoaded copyWith({
    List<Map<String, dynamic>>? allCourses,
    List<Map<String, dynamic>>? filteredCourses,
    List<Map<String, dynamic>>? savedCourses,
    List<Map<String, dynamic>>? enrolledCourses,
    String? searchQuery,
    String? selectedCategory,
    Set<String>? savedCourseIds,
    Set<String>? enrolledCourseIds,
  }) {
    return CoursesLoaded(
      allCourses: allCourses ?? this.allCourses,
      filteredCourses: filteredCourses ?? this.filteredCourses,
      savedCourses: savedCourses ?? this.savedCourses,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      savedCourseIds: savedCourseIds ?? this.savedCourseIds,
      enrolledCourseIds: enrolledCourseIds ?? this.enrolledCourseIds,
    );
  }
}

/// Courses error state
class CoursesError extends CoursesState {
  final String message;

  const CoursesError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Course saved state
class CourseSavedState extends CoursesState {
  final String courseId;

  const CourseSavedState({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Course unsaved state
class CourseUnsavedState extends CoursesState {
  final String courseId;

  const CourseUnsavedState({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Course enrollment success state
class CourseEnrollmentSuccessState extends CoursesState {
  final String courseId;

  const CourseEnrollmentSuccessState({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}



