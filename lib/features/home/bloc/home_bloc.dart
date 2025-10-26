import 'package:bloc/bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../jobs/bloc/jobs_bloc.dart';
import '../../jobs/bloc/jobs_event.dart' as jobs_events;
import '../../jobs/bloc/jobs_state.dart' as jobs_states;

/// Home BLoC
/// Handles all home screen related business logic
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final JobsBloc _jobsBloc;

  HomeBloc({JobsBloc? jobsBloc})
    : _jobsBloc = jobsBloc ?? _createDefaultJobsBloc(),
      super(const HomeInitial()) {
    // Register event handlers
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<ChangeTabEvent>(_onChangeTab);
    on<SearchJobsEvent>(_onSearchJobs);
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
}
