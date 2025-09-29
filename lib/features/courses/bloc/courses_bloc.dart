import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'courses_event.dart';
import 'courses_state.dart';
import '../repository/courses_repository.dart';

/// Courses BLoC
/// Handles all course-related business logic
class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  final CoursesRepository _coursesRepository;

  CoursesBloc({required CoursesRepository coursesRepository})
    : _coursesRepository = coursesRepository,
      super(const CoursesInitial()) {
    // Register event handlers
    on<LoadCoursesEvent>(_onLoadCourses);
    on<SearchCoursesEvent>(_onSearchCourses);
    on<FilterCoursesEvent>(_onFilterCourses);
    on<SaveCourseEvent>(_onSaveCourse);
    on<UnsaveCourseEvent>(_onUnsaveCourse);
    on<EnrollInCourseEvent>(_onEnrollInCourse);
    on<LoadSavedCoursesEvent>(_onLoadSavedCourses);
    on<LoadEnrolledCoursesEvent>(_onLoadEnrolledCourses);
    on<RefreshCoursesEvent>(_onRefreshCourses);
    on<ClearSearchEvent>(_onClearSearch);
    on<LoadCourseDetailsEvent>(_onLoadCourseDetails);
  }

  /// Handle load courses
  Future<void> _onLoadCourses(
    LoadCoursesEvent event,
    Emitter<CoursesState> emit,
  ) async {
    try {
      emit(const CoursesLoading());

      // Fetch courses from API
      final courses = await _coursesRepository.getCourses();

      // Convert API courses to UI format
      final allCourses = courses.map((course) => course.toUIMap()).toList();

      // Initialize empty saved and enrolled courses (will be managed by API when endpoints are available)
      final savedCourses = <Map<String, dynamic>>[];
      final enrolledCourses = <Map<String, dynamic>>[];
      final savedCourseIds = <String>{};
      final enrolledCourseIds = <String>{};

      emit(
        CoursesLoaded(
          allCourses: allCourses,
          filteredCourses: allCourses,
          savedCourses: savedCourses,
          enrolledCourses: enrolledCourses,
          savedCourseIds: savedCourseIds,
          enrolledCourseIds: enrolledCourseIds,
        ),
      );
    } catch (e) {
      // Emit error if API fails - no fallback to mock data
      emit(CoursesError(message: 'Failed to load courses: ${e.toString()}'));
    }
  }

  /// Handle search courses
  void _onSearchCourses(SearchCoursesEvent event, Emitter<CoursesState> emit) {
    if (state is CoursesLoaded) {
      final currentState = state as CoursesLoaded;
      final filteredCourses = _filterCourses(
        currentState.allCourses,
        event.query,
        currentState.selectedCategory,
      );

      emit(
        currentState.copyWith(
          searchQuery: event.query,
          filteredCourses: filteredCourses,
        ),
      );
    }
  }

  /// Handle filter courses
  void _onFilterCourses(FilterCoursesEvent event, Emitter<CoursesState> emit) {
    if (state is CoursesLoaded) {
      final currentState = state as CoursesLoaded;
      final filteredCourses = _filterCourses(
        currentState.allCourses,
        currentState.searchQuery,
        event.category,
      );

      emit(
        currentState.copyWith(
          selectedCategory: event.category,
          filteredCourses: filteredCourses,
        ),
      );
    }
  }

  /// Handle save course
  Future<void> _onSaveCourse(
    SaveCourseEvent event,
    Emitter<CoursesState> emit,
  ) async {
    try {
      if (state is CoursesLoaded) {
        final currentState = state as CoursesLoaded;

        // Call repository to save course
        await _coursesRepository.saveCourse(event.courseId);

        final updatedSavedCourseIds = Set<String>.from(
          currentState.savedCourseIds,
        );
        updatedSavedCourseIds.add(event.courseId);

        // Find the course to add to saved courses
        final courseToSave = currentState.allCourses.firstWhere(
          (course) => course['id'] == event.courseId,
          orElse: () => {},
        );

        if (courseToSave.isNotEmpty) {
          final updatedSavedCourses = List<Map<String, dynamic>>.from(
            currentState.savedCourses,
          );
          updatedSavedCourses.add(courseToSave);

          emit(
            currentState.copyWith(
              savedCourses: updatedSavedCourses,
              savedCourseIds: updatedSavedCourseIds,
            ),
          );

          // Emit success state
          emit(CourseSavedState(courseId: event.courseId));
        }
      }
    } catch (e) {
      emit(CoursesError(message: 'Failed to save course: ${e.toString()}'));
    }
  }

  /// Handle unsave course
  Future<void> _onUnsaveCourse(
    UnsaveCourseEvent event,
    Emitter<CoursesState> emit,
  ) async {
    try {
      if (state is CoursesLoaded) {
        final currentState = state as CoursesLoaded;

        // Call repository to unsave course
        await _coursesRepository.unsaveCourse(event.courseId);

        final updatedSavedCourseIds = Set<String>.from(
          currentState.savedCourseIds,
        );
        updatedSavedCourseIds.remove(event.courseId);

        final updatedSavedCourses = currentState.savedCourses
            .where((course) => course['id'] != event.courseId)
            .toList();

        emit(
          currentState.copyWith(
            savedCourses: updatedSavedCourses,
            savedCourseIds: updatedSavedCourseIds,
          ),
        );

        // Emit success state
        emit(CourseUnsavedState(courseId: event.courseId));
      }
    } catch (e) {
      emit(CoursesError(message: 'Failed to unsave course: ${e.toString()}'));
    }
  }

  /// Handle enroll in course
  Future<void> _onEnrollInCourse(
    EnrollInCourseEvent event,
    Emitter<CoursesState> emit,
  ) async {
    try {
      emit(const CoursesLoading());

      // Call repository to enroll in course
      await _coursesRepository.enrollInCourse(event.courseId);

      if (state is CoursesLoaded) {
        final currentState = state as CoursesLoaded;
        final updatedEnrolledCourseIds = Set<String>.from(
          currentState.enrolledCourseIds,
        );
        updatedEnrolledCourseIds.add(event.courseId);

        // Find the course to add to enrolled courses
        final courseToEnroll = currentState.allCourses.firstWhere(
          (course) => course['id'] == event.courseId,
          orElse: () => {},
        );

        if (courseToEnroll.isNotEmpty) {
          final updatedEnrolledCourses = List<Map<String, dynamic>>.from(
            currentState.enrolledCourses,
          );
          updatedEnrolledCourses.add({
            ...courseToEnroll,
            'enrollmentDate': DateTime.now().toIso8601String().split('T')[0],
            'progress': 0,
            'status': 'In Progress',
          });

          emit(
            currentState.copyWith(
              enrolledCourses: updatedEnrolledCourses,
              enrolledCourseIds: updatedEnrolledCourseIds,
            ),
          );
        }
      }

      // Emit success state
      emit(CourseEnrollmentSuccessState(courseId: event.courseId));
    } catch (e) {
      emit(
        CoursesError(message: 'Failed to enroll in course: ${e.toString()}'),
      );
    }
  }

  /// Handle load saved courses
  Future<void> _onLoadSavedCourses(
    LoadSavedCoursesEvent event,
    Emitter<CoursesState> emit,
  ) async {
    try {
      emit(const CoursesLoading());

      // TODO: Implement saved courses API call when endpoint is available
      await Future.delayed(const Duration(milliseconds: 300));

      // For now, return empty saved courses
      final savedCourses = <Map<String, dynamic>>[];
      final savedCourseIds = <String>{};

      emit(
        CoursesLoaded(
          allCourses: [],
          filteredCourses: savedCourses,
          savedCourses: savedCourses,
          enrolledCourses: [],
          savedCourseIds: savedCourseIds,
          enrolledCourseIds: <String>{},
        ),
      );
    } catch (e) {
      emit(
        CoursesError(message: 'Failed to load saved courses: ${e.toString()}'),
      );
    }
  }

  /// Handle load enrolled courses
  Future<void> _onLoadEnrolledCourses(
    LoadEnrolledCoursesEvent event,
    Emitter<CoursesState> emit,
  ) async {
    try {
      emit(const CoursesLoading());

      // TODO: Implement enrolled courses API call when endpoint is available
      await Future.delayed(const Duration(milliseconds: 300));

      // For now, return empty enrolled courses
      final enrolledCourses = <Map<String, dynamic>>[];

      emit(
        CoursesLoaded(
          allCourses: [],
          filteredCourses: enrolledCourses,
          savedCourses: [],
          enrolledCourses: enrolledCourses,
          savedCourseIds: <String>{},
          enrolledCourseIds: <String>{},
        ),
      );
    } catch (e) {
      emit(
        CoursesError(
          message: 'Failed to load enrolled courses: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle refresh courses
  Future<void> _onRefreshCourses(
    RefreshCoursesEvent event,
    Emitter<CoursesState> emit,
  ) async {
    // Reload courses
    add(const LoadCoursesEvent());
  }

  /// Handle clear search
  void _onClearSearch(ClearSearchEvent event, Emitter<CoursesState> emit) {
    if (state is CoursesLoaded) {
      final currentState = state as CoursesLoaded;
      final filteredCourses = _filterCourses(
        currentState.allCourses,
        '',
        currentState.selectedCategory,
      );

      emit(
        currentState.copyWith(
          searchQuery: '',
          filteredCourses: filteredCourses,
        ),
      );
    }
  }

  /// Filter courses based on search query and category
  List<Map<String, dynamic>> _filterCourses(
    List<Map<String, dynamic>> courses,
    String query,
    String category,
  ) {
    List<Map<String, dynamic>> filteredCourses = List.from(courses);

    // Apply search filter
    if (query.isNotEmpty) {
      filteredCourses = filteredCourses.where((course) {
        final title = course['title']?.toString().toLowerCase() ?? '';
        final instructor = course['instructor']?.toString().toLowerCase() ?? '';
        final description =
            course['description']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return title.contains(searchQuery) ||
            instructor.contains(searchQuery) ||
            description.contains(searchQuery);
      }).toList();
    }

    // Apply category filter
    if (category != 'All') {
      filteredCourses = filteredCourses.where((course) {
        final courseCategory = course['category']?.toString() ?? '';
        return courseCategory == category;
      }).toList();
    }

    return filteredCourses;
  }

  /// Handle load course details
  Future<void> _onLoadCourseDetails(
    LoadCourseDetailsEvent event,
    Emitter<CoursesState> emit,
  ) async {
    try {
      emit(const CoursesLoading());

      // Fetch course details from API
      final course = await _coursesRepository.getCourseById(event.courseId);

      if (course != null) {
        // Convert Course object to UI format
        final courseMap = course.toUIMap();
        emit(CourseDetailsLoaded(course: courseMap));
      } else {
        emit(const CoursesError(message: 'Course not found'));
      }
    } catch (e) {
      // Check if it's an authentication error
      final errorMessage = e.toString();
      if (errorMessage.contains('User must be logged in') ||
          errorMessage.contains('Unauthorized') ||
          errorMessage.contains('No token provided')) {
        // Use mock data as fallback when user is not authenticated
        debugPrint(
          '🔵 User not authenticated, using mock data for course details',
        );
        final mockCourse = {
          'id': event.courseId.toString(),
          'title': 'Course ${event.courseId}',
          'titleEnglish': 'Course ${event.courseId}',
          'description':
              'This is a detailed description for course ${event.courseId}. It covers all the essential topics and provides hands-on experience.',
          'duration': '4 weeks',
          'fees': 0.0,
          'category': 'General',
          'rating': 4.0,
          'totalRatings': 0,
          'institute': 'Institute ${event.courseId}',
          'level': 'Beginner',
          'isSaved': false,
          'imageUrl': 'assets/images/courses/default.png',
          'benefits': [
            'Professional training',
            'Industry certification',
            'Practical hands-on experience',
            'Career guidance',
          ],
        };
        emit(CourseDetailsLoaded(course: mockCourse));
      } else {
        emit(
          CoursesError(
            message: 'Failed to load course details: ${e.toString()}',
          ),
        );
      }
    }
  }
}
