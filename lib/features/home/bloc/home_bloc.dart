import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../../core/utils/network_error_helper.dart';
import '../../jobs/bloc/jobs_bloc.dart';
import '../../jobs/bloc/jobs_event.dart' as jobs_events;
import '../../jobs/bloc/jobs_state.dart' as jobs_states;
import '../../../shared/services/api_service.dart';
import '../../../shared/services/home_cache_service.dart';

/// Home BLoC
/// Handles all home screen related business logic
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final JobsBloc _jobsBloc;
  final ApiService _apiService;

  HomeBloc({JobsBloc? jobsBloc, ApiService? apiService})
    : _jobsBloc = jobsBloc ?? _createDefaultJobsBloc(),
      _apiService = apiService ?? ApiService(),
      super(const HomeInitial()) {
    // Register event handlers
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<ChangeTabEvent>(_onChangeTab);
    on<SearchJobsEvent>(_onSearchJobs);
    on<FilterJobsEvent>(_onFilterJobs);
    on<ToggleFiltersEvent>(_onToggleFilters);
    on<RefreshHomeDataEvent>(_onRefreshHomeData);
    on<ClearSearchEvent>(_onClearSearch);
    on<SaveJobEvent>(_onSaveJob);
    on<UnsaveJobEvent>(_onUnsaveJob);
    on<ApplyFilterEvent>(_onApplyFilter);
    on<ClearFilterEvent>(_onClearFilter);
    on<ClearAllFiltersEvent>(_onClearAllFilters);
  }

  /// Create default JobsBloc instance
  static JobsBloc _createDefaultJobsBloc() {
    // This will be injected via dependency injection
    throw UnimplementedError(
      'JobsBloc must be provided via dependency injection',
    );
  }

  /// Handle load home data
  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading());

      // Try to load from cache first for offline support
      final cacheService = HomeCacheService.instance;
      await cacheService.initialize();

      List<Map<String, dynamic>> featuredJobs = [];
      List<Map<String, dynamic>> allJobs = [];
      List<String> savedJobIds = [];
      bool loadedFromCache = false;

      // Load from cache if available
      final cachedData = await cacheService.getHomeData();
      if (cachedData != null && await cacheService.isCacheValid()) {
        try {
          allJobs = List<Map<String, dynamic>>.from(
            cachedData['allJobs'] ?? [],
          );
          featuredJobs = List<Map<String, dynamic>>.from(
            cachedData['featuredJobs'] ?? [],
          );
          savedJobIds = List<String>.from(cachedData['savedJobIds'] ?? []);
          loadedFromCache = true;
          debugPrint('🔵 [Home] Loaded data from cache');

          // Emit cached data immediately for offline support
          final sortedJobs = _sortJobsByFeaturedAndRecent(
            allJobs,
            featuredJobs,
          );
          emit(
            HomeLoaded(
              recommendedJobs: sortedJobs,
              filteredJobs: sortedJobs,
              featuredJobs: featuredJobs,
              savedJobIds: savedJobIds.toSet(),
              allJobs: sortedJobs,
            ),
          );
        } catch (e) {
          debugPrint('🔴 [Home] Error loading from cache: $e');
        }
      }

      // Try to load from API (will update cache if successful)
      try {
        final featuredResponse = await _apiService.getFeaturedJobs();
        featuredJobs = featuredResponse.data;
        debugPrint(
          '🔵 [Home] Loaded ${featuredJobs.length} featured jobs from API',
        );
      } catch (e) {
        debugPrint('🔴 [Home] Failed to load featured jobs from API: $e');
        // If no cache, continue with empty list
        if (!loadedFromCache) {
          featuredJobs = [];
        }
      }

      // Load jobs using JobsBloc
      _jobsBloc.add(const jobs_events.LoadJobsEvent());

      // Listen to JobsBloc state changes
      await for (final jobsState in _jobsBloc.stream) {
        if (jobsState is jobs_states.JobsLoaded) {
          allJobs = jobsState.allJobs;
          savedJobIds = jobsState.savedJobIds.toList();

          // Sort jobs: Featured jobs first (by recent), then non-featured jobs (by recent)
          final sortedJobs = _sortJobsByFeaturedAndRecent(
            allJobs,
            featuredJobs,
          );

          final recommendedJobs = sortedJobs;
          final filteredJobs = sortedJobs;

          // Store in cache for offline use
          try {
            await cacheService.storeHomeData(
              allJobs: allJobs,
              featuredJobs: featuredJobs,
              savedJobIds: savedJobIds,
            );
            debugPrint('🔵 [Home] Stored data in cache');
          } catch (e) {
            debugPrint('🔴 [Home] Failed to store in cache: $e');
          }

          emit(
            HomeLoaded(
              recommendedJobs: recommendedJobs,
              filteredJobs: filteredJobs,
              featuredJobs: featuredJobs,
              savedJobIds: savedJobIds.toSet(),
              allJobs: sortedJobs,
            ),
          );
          break; // Exit the stream after getting the data
        } else if (jobsState is jobs_states.JobsError) {
          // If we have cached data, use it even if API fails
          if (loadedFromCache) {
            debugPrint('🔵 [Home] API failed but using cached data');
            break;
          }
          emit(HomeError(message: jobsState.message));
          break;
        }
      }
    } catch (e) {
      // Try to load from cache as fallback
      try {
        final cacheService = HomeCacheService.instance;
        await cacheService.initialize();
        final cachedData = await cacheService.getHomeData();
        if (cachedData != null) {
          final allJobs = List<Map<String, dynamic>>.from(
            cachedData['allJobs'] ?? [],
          );
          final featuredJobs = List<Map<String, dynamic>>.from(
            cachedData['featuredJobs'] ?? [],
          );
          final savedJobIds = List<String>.from(
            cachedData['savedJobIds'] ?? [],
          );

          final sortedJobs = _sortJobsByFeaturedAndRecent(
            allJobs,
            featuredJobs,
          );
          emit(
            HomeLoaded(
              recommendedJobs: sortedJobs,
              filteredJobs: sortedJobs,
              featuredJobs: featuredJobs,
              savedJobIds: savedJobIds.toSet(),
              allJobs: sortedJobs,
            ),
          );
          return;
        }
      } catch (cacheError) {
        debugPrint('🔴 [Home] Cache fallback also failed: $cacheError');
      }

      _handleHomeError(e, emit, defaultMessage: 'Failed to load home data');
    }
  }

  /// Handle tab change
  void _onChangeTab(ChangeTabEvent event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(selectedTabIndex: event.tabIndex));
    }
  }

  /// Handle search jobs
  Future<void> _onSearchJobs(
    SearchJobsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      // Use JobsBloc to search jobs
      _jobsBloc.add(jobs_events.SearchJobsEvent(query: event.query));

      // Listen to JobsBloc state changes
      await for (final jobsState in _jobsBloc.stream) {
        if (jobsState is jobs_states.JobsLoaded) {
          final searchResults = jobsState.filteredJobs;

          // Apply search query to jobs
          var filteredJobs = searchResults.where((job) {
            final queryLower = event.query.toLowerCase();
            return queryLower.isEmpty ||
                job['title'].toString().toLowerCase().contains(queryLower) ||
                job['company'].toString().toLowerCase().contains(queryLower) ||
                job['location'].toString().toLowerCase().contains(queryLower);
          }).toList();

          // Apply active filters on top of search results
          if (currentState.activeFilters.isNotEmpty) {
            filteredJobs = _applyMultipleFilters(
              filteredJobs,
              currentState.activeFilters,
            );
          }

          // Ensure sorting is maintained (featured first, then by recent)
          filteredJobs = _sortJobsByFeaturedAndRecent(
            filteredJobs,
            currentState.featuredJobs,
          );

          emit(
            currentState.copyWith(
              searchQuery: event.query,
              filteredJobs: filteredJobs,
            ),
          );
          break; // Exit the stream after getting the data
        } else if (jobsState is jobs_states.JobsError) {
          emit(HomeError(message: jobsState.message));
          break;
        }
      }
    }
  }

  /// Handle refresh home data
  Future<void> _onRefreshHomeData(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Reload home data
    add(const LoadHomeDataEvent());
  }

  /// Handle clear search
  void _onClearSearch(ClearSearchEvent event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      // recommendedJobs is already sorted, so just use it directly
      emit(
        currentState.copyWith(
          searchQuery: '',
          filteredJobs: currentState.recommendedJobs,
        ),
      );
    }
  }

  /// Handle filter jobs
  Future<void> _onFilterJobs(
    FilterJobsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;
    final filteredJobs = _filterJobs(
      currentState.recommendedJobs,
      event.category,
    );

    emit(
      currentState.copyWith(
        filteredJobs: filteredJobs,
        selectedCategory: event.category,
      ),
    );
  }

  /// Handle toggle filters
  Future<void> _onToggleFilters(
    ToggleFiltersEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;
    final newShowFilters = !currentState.showFilters;

    emit(
      currentState.copyWith(
        showFilters: newShowFilters,
        selectedCategory: newShowFilters
            ? currentState.selectedCategory
            : 'All',
        filteredJobs: newShowFilters
            ? currentState.filteredJobs
            : currentState.recommendedJobs,
      ),
    );
  }

  /// Handle save job
  Future<void> _onSaveJob(SaveJobEvent event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      debugPrint('🔵 [HomeBloc] Saving job with ID: ${event.jobId}');

      // Call JobsBloc to save job via API
      _jobsBloc.add(jobs_events.SaveJobEvent(jobId: event.jobId));

      // Update local state immediately for better UX
      final newSavedJobIds = Set<String>.from(currentState.savedJobIds);
      newSavedJobIds.add(event.jobId);

      emit(currentState.copyWith(savedJobIds: newSavedJobIds));

      debugPrint('✅ [HomeBloc] Job save event dispatched to JobsBloc');
    } catch (e) {
      debugPrint('🔴 [HomeBloc] Error saving job: $e');
      // Revert state if error occurs
      emit(currentState);
    }
  }

  /// Handle unsave job
  Future<void> _onUnsaveJob(
    UnsaveJobEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    try {
      debugPrint('🔵 [HomeBloc] Unsaving job with ID: ${event.jobId}');

      // Call JobsBloc to unsave job (if API supports it, otherwise just update local state)
      _jobsBloc.add(jobs_events.UnsaveJobEvent(jobId: event.jobId));

      // Update local state immediately
      final newSavedJobIds = Set<String>.from(currentState.savedJobIds);
      newSavedJobIds.remove(event.jobId);

      emit(currentState.copyWith(savedJobIds: newSavedJobIds));

      debugPrint('✅ [HomeBloc] Job unsave event dispatched');
    } catch (e) {
      debugPrint('🔴 [HomeBloc] Error unsaving job: $e');
      // Revert state if error occurs
      emit(currentState);
    }
  }

  /// Handle apply filter
  void _onApplyFilter(ApplyFilterEvent event, Emitter<HomeState> emit) {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    // Start with recommended jobs or search results
    var baseJobs = currentState.searchQuery.isNotEmpty
        ? currentState.recommendedJobs.where((job) {
            final queryLower = currentState.searchQuery.toLowerCase();
            return job['title'].toString().toLowerCase().contains(queryLower) ||
                job['company'].toString().toLowerCase().contains(queryLower) ||
                job['location'].toString().toLowerCase().contains(queryLower);
          }).toList()
        : currentState.recommendedJobs;

    // If clicking the same filter again with same value, clear it
    final currentValue = currentState.activeFilters[event.filterType];
    if (currentValue == event.filterValue) {
      // Clear this specific filter
      final newFilters = Map<String, String?>.from(currentState.activeFilters);
      newFilters.remove(event.filterType);

      // Reapply remaining filters on base jobs
      var filteredJobs = _applyMultipleFilters(baseJobs, newFilters);

      // Ensure sorting is maintained (featured first, then by recent)
      filteredJobs = _sortJobsByFeaturedAndRecent(
        filteredJobs,
        currentState.featuredJobs,
      );

      emit(
        currentState.copyWith(
          activeFilters: newFilters,
          filteredJobs: filteredJobs,
        ),
      );
      return;
    }

    // Apply the filter
    final newFilters = Map<String, String?>.from(currentState.activeFilters);
    newFilters[event.filterType] = event.filterValue;

    // Apply filters on base jobs
    var filteredJobs = _applyMultipleFilters(baseJobs, newFilters);

    // Ensure sorting is maintained (featured first, then by recent)
    filteredJobs = _sortJobsByFeaturedAndRecent(
      filteredJobs,
      currentState.featuredJobs,
    );

    emit(
      currentState.copyWith(
        activeFilters: newFilters,
        filteredJobs: filteredJobs,
      ),
    );
  }

  /// Handle clear specific filter
  void _onClearFilter(ClearFilterEvent event, Emitter<HomeState> emit) {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;
    final newFilters = Map<String, String?>.from(currentState.activeFilters);
    newFilters.remove(event.filterType);

    // Start with recommended jobs or search results
    var baseJobs = currentState.searchQuery.isNotEmpty
        ? currentState.recommendedJobs.where((job) {
            final queryLower = currentState.searchQuery.toLowerCase();
            return job['title'].toString().toLowerCase().contains(queryLower) ||
                job['company'].toString().toLowerCase().contains(queryLower) ||
                job['location'].toString().toLowerCase().contains(queryLower);
          }).toList()
        : currentState.recommendedJobs;

    // Apply remaining filters on base jobs
    var filteredJobs = _applyMultipleFilters(baseJobs, newFilters);

    // Ensure sorting is maintained (featured first, then by recent)
    filteredJobs = _sortJobsByFeaturedAndRecent(
      filteredJobs,
      currentState.featuredJobs,
    );

    emit(
      currentState.copyWith(
        activeFilters: newFilters,
        filteredJobs: filteredJobs,
      ),
    );
  }

  /// Handle clear all filters
  void _onClearAllFilters(ClearAllFiltersEvent event, Emitter<HomeState> emit) {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    // If search query exists, show search results; otherwise show all jobs
    var filteredJobs = currentState.searchQuery.isNotEmpty
        ? currentState.recommendedJobs.where((job) {
            final queryLower = currentState.searchQuery.toLowerCase();
            return job['title'].toString().toLowerCase().contains(queryLower) ||
                job['company'].toString().toLowerCase().contains(queryLower) ||
                job['location'].toString().toLowerCase().contains(queryLower);
          }).toList()
        : currentState.recommendedJobs;

    // Ensure sorting is maintained (featured first, then by recent)
    filteredJobs = _sortJobsByFeaturedAndRecent(
      filteredJobs,
      currentState.featuredJobs,
    );

    emit(currentState.copyWith(activeFilters: {}, filteredJobs: filteredJobs));
  }

  /// Apply multiple filters to jobs list in combination
  List<Map<String, dynamic>> _applyMultipleFilters(
    List<Map<String, dynamic>> jobs,
    Map<String, String?> filters,
  ) {
    if (filters.isEmpty) {
      return jobs;
    }

    var filteredJobs = jobs;

    for (final entry in filters.entries) {
      final filterType = entry.key;
      final filterValue = entry.value;

      if (filterValue == null || filterValue.isEmpty) {
        continue;
      }

      filteredJobs = _applyFilter(filteredJobs, filterType, filterValue);
    }

    return filteredJobs;
  }

  /// Apply filter to jobs list
  List<Map<String, dynamic>> _applyFilter(
    List<Map<String, dynamic>> jobs,
    String filterType,
    String? filterValue,
  ) {
    if (filterValue == null || filterValue.isEmpty) {
      return jobs;
    }

    switch (filterType) {
      case 'fields':
        return jobs.where((job) {
          final title = job['title']?.toString().toLowerCase() ?? '';
          final description =
              job['description']?.toString().toLowerCase() ?? '';
          final filterLower = filterValue.toLowerCase();
          return title.contains(filterLower) ||
              description.contains(filterLower);
        }).toList();

      case 'salary':
        return jobs.where((job) {
          final salary = job['salary']?.toString() ?? '';
          final filterLower = filterValue.toLowerCase();
          return salary.toLowerCase().contains(filterLower);
        }).toList();

      case 'location':
        return jobs.where((job) {
          final location = job['location']?.toString().toLowerCase() ?? '';
          final filterLower = filterValue.toLowerCase();
          return location.contains(filterLower);
        }).toList();

      case 'job_type':
        return jobs.where((job) {
          final jobType =
              job['job_type_display']?.toString() ??
              job['job_type']?.toString() ??
              '';
          final normalizedType = jobType.toLowerCase();
          final filterLower = filterValue.toLowerCase();

          if (filterLower == 'full-time') {
            return normalizedType.contains('full');
          } else if (filterLower == 'part-time') {
            return normalizedType.contains('part');
          } else if (filterLower == 'internship') {
            return normalizedType.contains('intern');
          }
          return false;
        }).toList();

      case 'work_mode':
        return jobs.where((job) {
          final isRemote = job['is_remote'] ?? false;
          final filterLower = filterValue.toLowerCase();

          if (filterLower == 'remote') {
            return isRemote;
          } else if (filterLower == 'on-site') {
            return !isRemote;
          }
          return false;
        }).toList();

      default:
        return jobs;
    }
  }

  /// Filter jobs by category
  List<Map<String, dynamic>> _filterJobs(
    List<Map<String, dynamic>> jobs,
    String category,
  ) {
    if (category == 'All') {
      return jobs;
    }

    return jobs.where((job) {
      final jobCategory = job['category']?.toString().toLowerCase() ?? '';
      return jobCategory.contains(category.toLowerCase());
    }).toList();
  }

  /// Sort jobs: Featured jobs first (sorted by recent), then non-featured jobs (sorted by recent), closed jobs at the end
  List<Map<String, dynamic>> _sortJobsByFeaturedAndRecent(
    List<Map<String, dynamic>> jobs,
    List<Map<String, dynamic>> featuredJobs,
  ) {
    // Create a set of featured job IDs for quick lookup
    final featuredJobIds = featuredJobs.map((featuredJob) {
      final id = featuredJob['id'];
      return id is int ? id.toString() : id?.toString() ?? '';
    }).toSet();

    // Separate jobs into: featured open, featured closed, non-featured open, non-featured closed
    final List<Map<String, dynamic>> featuredOpenJobs = [];
    final List<Map<String, dynamic>> featuredClosedJobs = [];
    final List<Map<String, dynamic>> nonFeaturedOpenJobs = [];
    final List<Map<String, dynamic>> nonFeaturedClosedJobs = [];

    for (final job in jobs) {
      final jobId = job['id'] is int
          ? job['id'].toString()
          : job['id']?.toString() ?? '';

      final isFeatured = featuredJobIds.contains(jobId);
      final isClosed = _isJobClosed(job);

      if (isFeatured) {
        if (isClosed) {
          featuredClosedJobs.add(job);
        } else {
          featuredOpenJobs.add(job);
        }
      } else {
        if (isClosed) {
          nonFeaturedClosedJobs.add(job);
        } else {
          nonFeaturedOpenJobs.add(job);
        }
      }
    }

    // Sort all lists by created_at (most recent first)
    final sortedFeaturedOpen = _sortJobsByDate(featuredOpenJobs);
    final sortedFeaturedClosed = _sortJobsByDate(featuredClosedJobs);
    final sortedNonFeaturedOpen = _sortJobsByDate(nonFeaturedOpenJobs);
    final sortedNonFeaturedClosed = _sortJobsByDate(nonFeaturedClosedJobs);

    // Combine: featured open first, then non-featured open, then featured closed, then non-featured closed
    return [
      ...sortedFeaturedOpen,
      ...sortedNonFeaturedOpen,
      ...sortedFeaturedClosed,
      ...sortedNonFeaturedClosed,
    ];
  }

  /// Check if a job is closed
  bool _isJobClosed(Map<String, dynamic> job) {
    // Check status
    final jobStatus = job['status']?.toString().toLowerCase() ?? '';
    final isStatusClosed = jobStatus == 'closed' || jobStatus == 'expired';

    // Check if deadline has passed
    bool isDeadlinePassed = false;
    final deadline = job['application_deadline'];
    if (deadline != null) {
      try {
        final deadlineDate = DateTime.parse(deadline.toString());
        final now = DateTime.now();
        isDeadlinePassed = deadlineDate.difference(now).isNegative;
      } catch (e) {
        // If parsing fails, assume deadline is not passed
        isDeadlinePassed = false;
      }
    }

    return isStatusClosed || isDeadlinePassed;
  }

  /// Sort jobs by created_at date (most recent first)
  List<Map<String, dynamic>> _sortJobsByDate(List<Map<String, dynamic>> jobs) {
    return List<Map<String, dynamic>>.from(jobs)..sort((a, b) {
      final dateA = _parseDate(a['created_at']);
      final dateB = _parseDate(b['created_at']);

      // Most recent first (descending order)
      return dateB.compareTo(dateA);
    });
  }

  /// Parse date string to DateTime
  DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime(1970); // Very old date for null values
    }

    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      }
    } catch (e) {
      debugPrint('🔴 [Home] Error parsing date: $dateValue, error: $e');
    }

    return DateTime(1970); // Very old date for invalid values
  }

  /// Helper method to handle errors and emit appropriate error state
  /// Detects network errors and formats messages accordingly
  void _handleHomeError(
    dynamic error,
    Emitter<HomeState> emit, {
    String? defaultMessage,
  }) {
    final errorMessage = NetworkErrorHelper.isNetworkError(error)
        ? NetworkErrorHelper.getNetworkErrorMessage(error)
        : NetworkErrorHelper.extractErrorMessage(
            error,
            defaultMessage: defaultMessage,
          );

    emit(HomeError(message: errorMessage));
  }
}
