import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../jobs/bloc/jobs_bloc.dart';
import '../../jobs/bloc/jobs_event.dart' as jobs_events;
import '../../jobs/bloc/jobs_state.dart' as jobs_states;
import '../../../shared/services/api_service.dart';

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

      // Load featured jobs from API
      List<Map<String, dynamic>> featuredJobs = [];
      try {
        final featuredResponse = await _apiService.getFeaturedJobs();
        featuredJobs = featuredResponse.data; // Data is already in Map format
        debugPrint('🔵 [Home] Loaded ${featuredJobs.length} featured jobs');
      } catch (e) {
        debugPrint('🔴 [Home] Failed to load featured jobs: $e');
        // Continue with empty featured jobs list
      }

      // Load jobs using JobsBloc
      _jobsBloc.add(const jobs_events.LoadJobsEvent());

      // Listen to JobsBloc state changes
      await for (final jobsState in _jobsBloc.stream) {
        if (jobsState is jobs_states.JobsLoaded) {
          final recommendedJobs = jobsState.allJobs;
          final filteredJobs = recommendedJobs;

          emit(
            HomeLoaded(
              recommendedJobs: recommendedJobs,
              filteredJobs: filteredJobs,
              featuredJobs: featuredJobs,
            ),
          );
          break; // Exit the stream after getting the data
        } else if (jobsState is jobs_states.JobsError) {
          emit(HomeError(message: jobsState.message));
          break;
        }
      }
    } catch (e) {
      emit(HomeError(message: 'Failed to load home data: ${e.toString()}'));
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
          final filteredJobs = searchResults.where((job) {
            final queryLower = event.query.toLowerCase();
            return queryLower.isEmpty ||
                job['title'].toString().toLowerCase().contains(queryLower) ||
                job['company'].toString().toLowerCase().contains(queryLower) ||
                job['location'].toString().toLowerCase().contains(queryLower);
          }).toList();

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
}
