import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'courses_event.dart';
import 'courses_state.dart';
import '../../../core/utils/network_error_helper.dart';
import '../repository/courses_repository.dart';
import '../../../shared/services/courses_cache_service.dart';

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
    // Declare variables outside try block for catch block access
    bool loadedFromCache = false;
    List<Map<String, dynamic>> allCourses = [];
    List<Map<String, dynamic>> savedCourses = [];
    Set<String> savedCourseIds = <String>{};

    try {
      // Try to load from cache first for offline support (like jobs section)
      final cacheService = CoursesCacheService.instance;
      await cacheService.initialize();

      // Always try to load from cache first (even on force refresh)
      // This shows cached data immediately while fresh data loads in background
      final cachedData = await cacheService.getCoursesData();
      if (cachedData != null && await cacheService.isCacheValid()) {
        try {
          allCourses = List<Map<String, dynamic>>.from(
            cachedData['allCourses'] ?? [],
          );
          savedCourses = List<Map<String, dynamic>>.from(
            cachedData['savedCourses'] ?? [],
          );
          savedCourseIds = Set<String>.from(cachedData['savedCourseIds'] ?? []);
          loadedFromCache = true;
          debugPrint('🔵 [Courses] Loaded data from cache');

          // Emit cached data immediately for offline support (no loading state)
          // This prevents reload on first time - shows cached data while fresh data loads
          emit(
            CoursesLoaded(
              allCourses: allCourses,
              filteredCourses: allCourses,
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
          debugPrint('🔴 [Courses] Error loading from cache: $e');
        }
      }

      // Only show loading if we don't have cached data
      if (!loadedFromCache) {
        if (state is CoursesInitial) {
          emit(const CoursesLoading());
        } else if (state is! CoursesLoaded && !event.forceRefresh) {
          emit(const CoursesLoading());
        }
      }

      // Fetch courses from API (force refresh if requested)
      final courses = await _coursesRepository.getCourses(
        forceRefresh: event.forceRefresh,
      );

      // Convert API courses to UI format (update existing variables)
      allCourses = courses.map((course) => course.toUIMap()).toList();

      // Fetch saved courses and hydrate saved flags (update existing variables)
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

      // Sort courses by created_at (most recent first)
      allCourses = _sortCoursesByRecent(allCourses);

      // Initialize enrolled placeholders (no API yet)
      final enrolledCourses = <Map<String, dynamic>>[];
      final enrolledCourseIds = <String>{};

      // Store in cache for offline use
      try {
        await cacheService.storeCoursesData(
          allCourses: allCourses,
          savedCourses: savedCourses,
          savedCourseIds: savedCourseIds,
        );
        debugPrint('🔵 [Courses] Stored data in cache');
      } catch (e) {
        debugPrint('🔴 [Courses] Failed to store in cache: $e');
      }

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
      // If API fails but we have cached data, use it
      if (loadedFromCache) {
        debugPrint('🔵 [Courses] API failed but using cached data');
        return;
      }

      // Try to load from cache as fallback
      try {
        final cacheService = CoursesCacheService.instance;
        await cacheService.initialize();
        final cachedData = await cacheService.getCoursesData();
        if (cachedData != null) {
          final fallbackAllCourses = List<Map<String, dynamic>>.from(
            cachedData['allCourses'] ?? [],
          );
          final fallbackSavedCourses = List<Map<String, dynamic>>.from(
            cachedData['savedCourses'] ?? [],
          );
          final fallbackSavedCourseIds = Set<String>.from(
            cachedData['savedCourseIds'] ?? [],
          );

          emit(
            CoursesLoaded(
              allCourses: fallbackAllCourses,
              filteredCourses: fallbackAllCourses,
              savedCourses: fallbackSavedCourses,
              enrolledCourses: [],
              savedCourseIds: fallbackSavedCourseIds,
              enrolledCourseIds: <String>{},
              selectedCategory: 'All',
              selectedLevel: 'All',
              selectedDuration: 'All',
              selectedInstitute: 'All',
            ),
          );
          return;
        }
      } catch (cacheError) {
        debugPrint('🔴 [Courses] Cache fallback also failed: $cacheError');
      }

      // Emit error if API fails and no cache available
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
        // Handle both string and int course IDs
        final updatedAllCourses = currentState.allCourses.map((course) {
          final courseId = course['id']?.toString();
          if (courseId == event.courseId || courseId == event.courseId.toString()) {
            return {...course, 'isSaved': true};
          }
          return course;
        }).toList();

        // Find the course to add to saved courses from updated list
        // Handle both string and int course IDs
        final courseToSave = updatedAllCourses.firstWhere(
          (course) {
            final courseId = course['id']?.toString();
            return courseId == event.courseId || courseId == event.courseId.toString();
          },
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

          // Don't emit CourseSavedState here - it causes white page in courses list
          // CourseSavedState is only needed for course details page
        }
      } else if (state is CourseDetailsLoaded) {
        // Handle save from course details page
        final detailsState = state as CourseDetailsLoaded;
        await _coursesRepository.saveCourse(event.courseId);
        final updatedCourse = {...detailsState.course, 'isSaved': true};
        emit(CourseDetailsLoaded(course: updatedCourse));
        emit(CourseSavedState(courseId: event.courseId));
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

        // Don't emit CourseUnsavedState here - it causes white page in courses list
        // CourseUnsavedState is only needed for course details page
      } else if (state is CourseDetailsLoaded) {
        // Handle unsave from course details page
        final detailsState = state as CourseDetailsLoaded;
        await _coursesRepository.unsaveCourse(event.courseId);
        final updatedCourse = {...detailsState.course, 'isSaved': false};
        emit(CourseDetailsLoaded(course: updatedCourse));
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

      final saved = await _coursesRepository.getSavedCourses();
      var savedCourses = saved.courses;
      final savedCourseIds = saved.savedCourseIds;

      // Sort saved courses by created_at (most recent first)
      savedCourses = _sortCoursesByRecent(savedCourses);

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
    // Reload courses with force refresh
    add(const LoadCoursesEvent(forceRefresh: true));
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

    // Sort filtered courses by created_at (most recent first)
    return _sortCoursesByRecent(filteredCourses);
  }

  /// Sort courses by created_at date (most recent first)
  /// If created_at is not available, sort by ID in descending order (higher ID = newer)
  List<Map<String, dynamic>> _sortCoursesByRecent(
    List<Map<String, dynamic>> courses,
  ) {
    return List<Map<String, dynamic>>.from(courses)..sort((a, b) {
      final dateA = _parseDate(a['created_at']);
      final dateB = _parseDate(b['created_at']);

      // If both have valid dates, sort by date (most recent first)
      if (dateA != null && dateB != null) {
        return dateB.compareTo(dateA);
      }

      // If only one has a date, prioritize it
      if (dateA != null) return -1;
      if (dateB != null) return 1;

      // If neither has a date, sort by ID (higher ID = newer, assuming auto-increment)
      final idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
      final idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
      return idB.compareTo(idA);
    });
  }

  /// Parse date string to DateTime
  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null || dateValue.toString().isEmpty) {
      return null;
    }

    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      }
    } catch (e) {
      debugPrint('🔴 [Courses] Error parsing date: $dateValue, error: $e');
    }

    return null;
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
        
        // Check if course is saved by checking savedCourseIds from current state
        final courseIdString = event.courseId.toString();
        bool isSaved = false;
        
        // Check savedCourseIds from current state if available
        if (state is CoursesLoaded) {
          final currentState = state as CoursesLoaded;
          isSaved = currentState.savedCourseIds.contains(courseIdString);
        } else {
          // Also check saved courses from repository
          try {
            final saved = await _coursesRepository.getSavedCourses();
            isSaved = saved.savedCourseIds.contains(courseIdString);
          } catch (e) {
            debugPrint('⚠️ [CoursesBloc] Failed to check saved courses: $e');
          }
        }
        
        // Update isSaved flag in course map
        courseMap['isSaved'] = isSaved;
        
        debugPrint('🔵 [CoursesBloc] Loaded course details: ID=$courseIdString, isSaved=$isSaved');
        
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
  void _handleCoursesError(
    dynamic error,
    Emitter<CoursesState> emit, {
    String? defaultMessage,
  }) {
    final errorMessage = NetworkErrorHelper.isNetworkError(error)
        ? NetworkErrorHelper.getNetworkErrorMessage(error)
        : NetworkErrorHelper.extractErrorMessage(
            error,
            defaultMessage: defaultMessage,
          );

    emit(CoursesError(message: errorMessage));
  }
}
