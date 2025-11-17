import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'courses_event.dart';
import 'courses_state.dart';
import '../../../core/utils/network_error_helper.dart';
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
    on<ClearAllFiltersEvent>(_onClearAllFilters);
    on<SaveCourseEvent>(_onSaveCourse);
    on<UnsaveCourseEvent>(_onUnsaveCourse);
    on<EnrollInCourseEvent>(_onEnrollInCourse);
    on<LoadSavedCoursesEvent>(_onLoadSavedCourses);
    on<LoadEnrolledCoursesEvent>(_onLoadEnrolledCourses);
    on<RefreshCoursesEvent>(_onRefreshCourses);
    on<ClearSearchEvent>(_onClearSearch);
    on<LoadCourseDetailsEvent>(_onLoadCourseDetails);
    on<ToggleFiltersEvent>(_onToggleFilters);
  }

  /// Handle load courses
  Future<void> _onLoadCourses(
    LoadCoursesEvent event,
    Emitter<CoursesState> emit,
  ) async {
    try {
      // Only show loading if we don't have any data
      if (state is! CoursesLoaded) {
        emit(const CoursesLoading());
      }

      // Fetch courses from API (will use cache if available)
      final courses = await _coursesRepository.getCourses();

      // Convert API courses to UI format
      var allCourses = courses.map((course) => course.toUIMap()).toList();

      // Fetch saved courses and hydrate saved flags
      Set<String> savedCourseIds = <String>{};
      List<Map<String, dynamic>> savedCourses = <Map<String, dynamic>>[];
      try {
        final saved = await _coursesRepository.getSavedCourses();
        savedCourseIds = saved.savedCourseIds;
        savedCourses = saved.courses;
      } catch (e) {
        debugPrint('⚠️ Failed to load saved courses: $e');
      }

      // Mark isSaved on allCourses using savedCourseIds
      allCourses = allCourses.map((c) {
        final id = c['id']?.toString();
        if (id != null && savedCourseIds.contains(id)) {
          return {...c, 'isSaved': true};
        }
        return {...c, 'isSaved': c['isSaved'] == true};
      }).toList();

      // Initialize enrolled placeholders (no API yet)
      final enrolledCourses = <Map<String, dynamic>>[];
      final enrolledCourseIds = <String>{};

      emit(
        CoursesLoaded(
          allCourses: allCourses,
          filteredCourses: allCourses,
          savedCourses: savedCourses,
          enrolledCourses: enrolledCourses,
          savedCourseIds: savedCourseIds,
          enrolledCourseIds: enrolledCourseIds,
          selectedCategory: 'All',
          selectedLevel: 'All',
          selectedDuration: 'All',
          selectedInstitute: 'All',
        ),
      );
    } catch (e) {
      // Emit error if API fails - no fallback to mock data
      _handleCoursesError(e, emit, defaultMessage: 'Failed to load courses');
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
        currentState.selectedLevel,
        currentState.selectedDuration,
        currentState.selectedInstitute,
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

      // Update selected filters (keep existing if new one is not provided)
      final updatedCategory = event.category ?? currentState.selectedCategory;
      final updatedLevel = event.level ?? currentState.selectedLevel;
      final updatedDuration = event.duration ?? currentState.selectedDuration;
      final updatedInstitute =
          event.institute ?? currentState.selectedInstitute;

      final filteredCourses = _filterCourses(
        currentState.allCourses,
        currentState.searchQuery,
        updatedCategory,
        updatedLevel,
        updatedDuration,
        updatedInstitute,
      );

      emit(
        currentState.copyWith(
          selectedCategory: updatedCategory,
          selectedLevel: updatedLevel,
          selectedDuration: updatedDuration,
          selectedInstitute: updatedInstitute,
          filteredCourses: filteredCourses,
        ),
      );
    }
  }

  /// Handle clear all filters
  void _onClearAllFilters(
    ClearAllFiltersEvent event,
    Emitter<CoursesState> emit,
  ) {
    if (state is CoursesLoaded) {
      final currentState = state as CoursesLoaded;
      final filteredCourses = _filterCourses(
        currentState.allCourses,
        currentState.searchQuery,
        'All',
        'All',
        'All',
        'All',
      );

      emit(
        currentState.copyWith(
          selectedCategory: 'All',
          selectedLevel: 'All',
          selectedDuration: 'All',
          selectedInstitute: 'All',
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

        // Update isSaved flag in allCourses and filteredCourses
        final updatedAllCourses = currentState.allCourses.map((course) {
          if (course['id'] == event.courseId) {
            return {...course, 'isSaved': true};
          }
          return course;
        }).toList();

        // Find the course to add to saved courses from updated list
        final courseToSave = updatedAllCourses.firstWhere(
          (course) => course['id'] == event.courseId,
          orElse: () => {},
        );

        if (courseToSave.isNotEmpty) {
          final updatedSavedCourses = List<Map<String, dynamic>>.from(
            currentState.savedCourses,
          );
          updatedSavedCourses.add(courseToSave);

          // Rebuild filteredCourses with updated isSaved flag
          final updatedFilteredCourses = _filterCourses(
            updatedAllCourses,
            currentState.searchQuery,
            currentState.selectedCategory,
            currentState.selectedLevel,
            currentState.selectedDuration,
            currentState.selectedInstitute,
          );

          emit(
            currentState.copyWith(
              allCourses: updatedAllCourses,
              filteredCourses: updatedFilteredCourses,
              savedCourses: updatedSavedCourses,
              savedCourseIds: updatedSavedCourseIds,
            ),
          );
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

        // Update isSaved flag in allCourses and filteredCourses
        final updatedAllCourses = currentState.allCourses.map((course) {
          if (course['id'] == event.courseId) {
            return {...course, 'isSaved': false};
          }
          return course;
        }).toList();

        // Rebuild filteredCourses with updated isSaved flag
        final updatedFilteredCourses = _filterCourses(
          updatedAllCourses,
          currentState.searchQuery,
          currentState.selectedCategory,
          currentState.selectedLevel,
          currentState.selectedDuration,
          currentState.selectedInstitute,
        );

        emit(
          currentState.copyWith(
            allCourses: updatedAllCourses,
            filteredCourses: updatedFilteredCourses,
            savedCourses: updatedSavedCourses,
            savedCourseIds: updatedSavedCourseIds,
          ),
        );
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

      final saved = await _coursesRepository.getSavedCourses();
      final savedCourses = saved.courses;
      final savedCourseIds = saved.savedCourseIds;

      emit(
        CoursesLoaded(
          allCourses: [],
          filteredCourses: savedCourses,
          savedCourses: savedCourses,
          enrolledCourses: [],
          savedCourseIds: savedCourseIds,
          enrolledCourseIds: <String>{},
          selectedCategory: 'All',
          selectedLevel: 'All',
          selectedDuration: 'All',
          selectedInstitute: 'All',
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
          selectedCategory: 'All',
          selectedLevel: 'All',
          selectedDuration: 'All',
          selectedInstitute: 'All',
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
        currentState.selectedLevel,
        currentState.selectedDuration,
        currentState.selectedInstitute,
      );

      emit(
        currentState.copyWith(
          searchQuery: '',
          filteredCourses: filteredCourses,
        ),
      );
    }
  }

  /// Filter courses based on search query and all filters
  /// All filters work together in combination with search
  List<Map<String, dynamic>> _filterCourses(
    List<Map<String, dynamic>> courses,
    String query,
    String category,
    String level,
    String duration,
    String institute,
  ) {
    List<Map<String, dynamic>> filteredCourses = List.from(courses);

    // Apply search filter - searches across multiple fields including filter-related fields
    if (query.isNotEmpty) {
      final searchQuery = query.toLowerCase().trim();
      filteredCourses = filteredCourses.where((course) {
        // Search in title fields
        final title = course['title']?.toString().toLowerCase() ?? '';
        final titleEnglish =
            course['titleEnglish']?.toString().toLowerCase() ?? '';

        // Search in description
        final description =
            course['description']?.toString().toLowerCase() ?? '';

        // Search in instructor
        final instructor = course['instructor']?.toString().toLowerCase() ?? '';

        // Search in category (filter field)
        final courseCategory =
            course['category']?.toString().toLowerCase() ?? '';

        // Search in level (filter field)
        final courseLevel = course['level']?.toString().toLowerCase() ?? '';

        // Search in duration (filter field)
        final courseDuration =
            course['duration']?.toString().toLowerCase() ?? '';

        // Search in institute (filter field)
        final courseInstitute =
            course['institute']?.toString().toLowerCase() ?? '';

        // Return true if search query matches any field
        return title.contains(searchQuery) ||
            titleEnglish.contains(searchQuery) ||
            description.contains(searchQuery) ||
            instructor.contains(searchQuery) ||
            courseCategory.contains(searchQuery) ||
            courseLevel.contains(searchQuery) ||
            courseDuration.contains(searchQuery) ||
            courseInstitute.contains(searchQuery);
      }).toList();
    }

    // Apply category filter (works with search)
    if (category != 'All') {
      filteredCourses = filteredCourses.where((course) {
        final courseCategory = course['category']?.toString() ?? '';
        return courseCategory == category;
      }).toList();
    }

    // Apply level filter (works with search and category)
    if (level != 'All') {
      filteredCourses = filteredCourses.where((course) {
        final courseLevel = course['level']?.toString() ?? '';
        return courseLevel == level;
      }).toList();
    }

    // Apply duration filter (works with search, category, and level)
    if (duration != 'All') {
      filteredCourses = filteredCourses.where((course) {
        final courseDuration = course['duration']?.toString() ?? '';
        return courseDuration == duration;
      }).toList();
    }

    // Apply institute filter (works with all previous filters and search)
    if (institute != 'All') {
      filteredCourses = filteredCourses.where((course) {
        final courseInstitute = course['institute']?.toString() ?? '';
        return courseInstitute == institute;
      }).toList();
    }

    // All filters and search work together in combination
    // Result: courses that match search query AND category AND level AND duration AND institute
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

  /// Handle toggle filters event
  void _onToggleFilters(ToggleFiltersEvent event, Emitter<CoursesState> emit) {
    if (state is CoursesLoaded) {
      final currentState = state as CoursesLoaded;
      final newShowFilters = !currentState.showFilters;

      // If closing filters, clear all active filters
      if (!newShowFilters && currentState.hasActiveFilters()) {
        final filteredCourses = _filterCourses(
          currentState.allCourses,
          currentState.searchQuery,
          'All',
          'All',
          'All',
          'All',
        );

        emit(
          currentState.copyWith(
            showFilters: newShowFilters,
            selectedCategory: 'All',
            selectedLevel: 'All',
            selectedDuration: 'All',
            selectedInstitute: 'All',
            filteredCourses: filteredCourses,
          ),
        );
      } else {
        // Just toggle visibility if opening or if no active filters
        emit(currentState.copyWith(showFilters: newShowFilters));
      }
    }
  }

  /// Helper method to handle errors and emit appropriate error state
  /// Detects network errors and formats messages accordingly
  void _handleCoursesError(dynamic error, Emitter<CoursesState> emit, {String? defaultMessage}) {
    final errorMessage = NetworkErrorHelper.isNetworkError(error)
        ? NetworkErrorHelper.getNetworkErrorMessage(error)
        : NetworkErrorHelper.extractErrorMessage(error, defaultMessage: defaultMessage);
    
    emit(CoursesError(message: errorMessage));
  }
}
