import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'jobs_event.dart';
import 'jobs_state.dart';
import '../../../shared/data/job_data.dart';
import '../../../shared/data/user_data.dart';
import '../repositories/jobs_repository.dart';
import '../models/job.dart';

/// Jobs BLoC
/// Handles all job-related business logic
class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final JobsRepository _jobsRepository;

  JobsBloc({JobsRepository? jobsRepository})
    : _jobsRepository = jobsRepository ?? _createDefaultRepository(),
      super(const JobsInitial()) {
    // Register event handlers
    on<LoadJobsEvent>(_onLoadJobs);
    on<SearchJobsEvent>(_onSearchJobs);
    on<FilterJobsEvent>(_onFilterJobs);
    on<SaveJobEvent>(_onSaveJob);
    on<UnsaveJobEvent>(_onUnsaveJob);
    on<ApplyForJobEvent>(_onApplyForJob);
    on<LoadSavedJobsEvent>(_onLoadSavedJobs);
    on<LoadAppliedJobsEvent>(_onLoadAppliedJobs);
    on<RefreshJobsEvent>(_onRefreshJobs);
    on<ClearSearchEvent>(_onClearSearch);
    on<LoadJobDetailsEvent>(_onLoadJobDetails);
    on<LoadDetailedJobEvent>(_onLoadDetailedJob);
    on<ToggleJobBookmarkEvent>(_onToggleJobBookmark);
    on<UpdateSearchResultsFilterEvent>(_onUpdateSearchResultsFilter);
    on<LoadSearchResultsEvent>(_onLoadSearchResults);
    on<LoadApplicationTrackerEvent>(_onLoadApplicationTracker);
    on<ViewApplicationEvent>(_onViewApplication);
    on<ApplyForMoreJobsEvent>(_onApplyForMoreJobs);
    on<RemoveSavedJobEvent>(_onRemoveSavedJob);
    on<LoadJobApplicationFormEvent>(_onLoadJobApplicationForm);
    on<UpdateJobApplicationFormEvent>(_onUpdateJobApplicationForm);
    on<PickResumeFileEvent>(_onPickResumeFile);
    on<RemoveResumeFileEvent>(_onRemoveResumeFile);
    on<SubmitJobApplicationEvent>(_onSubmitJobApplication);
    on<LoadCalendarViewEvent>(_onLoadCalendarView);
    on<ChangeCalendarMonthEvent>(_onChangeCalendarMonth);
    on<SelectCalendarDateEvent>(_onSelectCalendarDate);
    on<LoadWriteReviewEvent>(_onLoadWriteReview);
    on<UpdateReviewRatingEvent>(_onUpdateReviewRating);
    on<UpdateReviewTextEvent>(_onUpdateReviewText);
    on<SubmitReviewEvent>(_onSubmitReview);
  }

  /// Create default repository instance
  static JobsRepository _createDefaultRepository() {
    // This will be injected via dependency injection
    throw UnimplementedError(
      'JobsRepository must be provided via dependency injection',
    );
  }

  /// Handle load jobs
  Future<void> _onLoadJobs(LoadJobsEvent event, Emitter<JobsState> emit) async {
    try {
      emit(const JobsLoading());

      // Fetch jobs from API
      final jobsResponse = await _jobsRepository.getJobs();

      if (jobsResponse.status) {
        // Convert Job objects to Map format for compatibility with existing UI
        final allJobs = jobsResponse.data.map((job) => _jobToMap(job)).toList();
        final savedJobs = JobData.savedJobs; // Keep existing saved jobs for now
        final appliedJobs =
            JobData.appliedJobs; // Keep existing applied jobs for now
        final savedJobIds = UserData.savedJobIds.toSet();

        emit(
          JobsLoaded(
            allJobs: allJobs,
            filteredJobs: allJobs,
            savedJobs: savedJobs,
            appliedJobs: appliedJobs,
            savedJobIds: savedJobIds,
          ),
        );
      } else {
        emit(JobsError(message: jobsResponse.message));
      }
    } catch (e) {
      // Check if it's an authentication error
      final errorMessage = e.toString();
      if (errorMessage.contains('User must be logged in') ||
          errorMessage.contains('Unauthorized') ||
          errorMessage.contains('No token provided')) {
        // Use mock data as fallback when user is not authenticated
        debugPrint('🔵 User not authenticated, using mock data as fallback');
        final allJobs = JobData.recommendedJobs;
        final savedJobs = JobData.savedJobs;
        final appliedJobs = JobData.appliedJobs;
        final savedJobIds = UserData.savedJobIds.toSet();

        emit(
          JobsLoaded(
            allJobs: allJobs,
            filteredJobs: allJobs,
            savedJobs: savedJobs,
            appliedJobs: appliedJobs,
            savedJobIds: savedJobIds,
          ),
        );
      } else {
        emit(JobsError(message: 'Failed to load jobs: ${e.toString()}'));
      }
    }
  }

  /// Convert Job object to Map format for UI compatibility
  Map<String, dynamic> _jobToMap(Job job) {
    return {
      'id': job.id.toString(),
      'title': job.title,
      'company':
          'Company Name', // API doesn't provide company name, using placeholder
      'rating': 4.5, // Default rating
      'tags': [job.jobTypeDisplay, job.isRemote ? 'Remote' : 'On-site'],
      'salary': job.formattedSalary,
      'location': job.location,
      'time': job.timeAgo,
      'logo': 'assets/images/company/group.png',
      'review_user_name': 'User Name',
      'review_user_role': job.title,
      'description': job.description,
      'requirements': job.skillsList,
      'benefits': [
        'Competitive salary',
        'Health insurance',
        'Professional development',
        'Work-life balance',
      ],
      'experience_required': job.experienceRequired,
      'application_deadline': job.applicationDeadline,
      'no_of_vacancies': job.noOfVacancies,
      'is_remote': job.isRemote,
      'status': job.status,
      'created_at': job.createdAt,
      'views': job.views,
    };
  }

  /// Handle search jobs
  Future<void> _onSearchJobs(
    SearchJobsEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      emit(const JobsLoading());

      // Use repository to search jobs
      final searchResults = await _jobsRepository.searchJobs(
        query: event.query,
        location: null,
        jobType: null,
        experienceLevel: null,
        salaryRange: null,
      );

      // Convert Job objects to Map format
      final filteredJobs = searchResults.map((job) => _jobToMap(job)).toList();

      if (state is JobsLoaded) {
        final currentState = state as JobsLoaded;
        emit(
          currentState.copyWith(
            searchQuery: event.query,
            filteredJobs: filteredJobs,
          ),
        );
      } else {
        // If no current state, create a new one
        emit(
          JobsLoaded(
            allJobs: filteredJobs,
            filteredJobs: filteredJobs,
            savedJobs: [],
            appliedJobs: [],
            savedJobIds: UserData.savedJobIds.toSet(),
            searchQuery: event.query,
          ),
        );
      }
    } catch (e) {
      // Check if it's an authentication error
      final errorMessage = e.toString();
      if (errorMessage.contains('User must be logged in') ||
          errorMessage.contains('Unauthorized') ||
          errorMessage.contains('No token provided')) {
        // Use mock data as fallback when user is not authenticated
        debugPrint('🔵 User not authenticated, using mock data for search');
        final searchResults = JobData.recommendedJobs.where((job) {
          final queryLower = event.query.toLowerCase();
          return job['title'].toString().toLowerCase().contains(queryLower) ||
              job['company'].toString().toLowerCase().contains(queryLower) ||
              job['location'].toString().toLowerCase().contains(queryLower);
        }).toList();

        if (state is JobsLoaded) {
          final currentState = state as JobsLoaded;
          emit(
            currentState.copyWith(
              searchQuery: event.query,
              filteredJobs: searchResults,
            ),
          );
        } else {
          emit(
            JobsLoaded(
              allJobs: searchResults,
              filteredJobs: searchResults,
              savedJobs: [],
              appliedJobs: [],
              savedJobIds: UserData.savedJobIds.toSet(),
              searchQuery: event.query,
            ),
          );
        }
      } else {
        emit(JobsError(message: 'Failed to search jobs: ${e.toString()}'));
      }
    }
  }

  /// Handle filter jobs
  void _onFilterJobs(FilterJobsEvent event, Emitter<JobsState> emit) {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      final filteredJobs = _filterJobs(
        currentState.allJobs,
        currentState.searchQuery,
        event.categoryIndex,
        event.filterIndex,
      );

      emit(
        currentState.copyWith(
          selectedCategoryIndex: event.categoryIndex,
          selectedFilterIndex: event.filterIndex,
          filteredJobs: filteredJobs,
        ),
      );
    }
  }

  /// Handle save job
  Future<void> _onSaveJob(SaveJobEvent event, Emitter<JobsState> emit) async {
    try {
      if (state is JobsLoaded) {
        final currentState = state as JobsLoaded;
        final updatedSavedJobIds = Set<String>.from(currentState.savedJobIds);
        updatedSavedJobIds.add(event.jobId);

        // Find the job to add to saved jobs
        final jobToSave = currentState.allJobs.firstWhere(
          (job) => job['id'] == event.jobId,
          orElse: () => {},
        );

        if (jobToSave.isNotEmpty) {
          final updatedSavedJobs = List<Map<String, dynamic>>.from(
            currentState.savedJobs,
          );
          updatedSavedJobs.add(jobToSave);

          emit(
            currentState.copyWith(
              savedJobs: updatedSavedJobs,
              savedJobIds: updatedSavedJobIds,
            ),
          );

          // Emit success state
          emit(JobSavedState(jobId: event.jobId));
        }
      }
    } catch (e) {
      emit(JobsError(message: 'Failed to save job: ${e.toString()}'));
    }
  }

  /// Handle unsave job
  Future<void> _onUnsaveJob(
    UnsaveJobEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      if (state is JobsLoaded) {
        final currentState = state as JobsLoaded;
        final updatedSavedJobIds = Set<String>.from(currentState.savedJobIds);
        updatedSavedJobIds.remove(event.jobId);

        final updatedSavedJobs = currentState.savedJobs
            .where((job) => job['id'] != event.jobId)
            .toList();

        emit(
          currentState.copyWith(
            savedJobs: updatedSavedJobs,
            savedJobIds: updatedSavedJobIds,
          ),
        );

        // Emit success state
        emit(JobUnsavedState(jobId: event.jobId));
      }
    } catch (e) {
      emit(JobsError(message: 'Failed to unsave job: ${e.toString()}'));
    }
  }

  /// Handle apply for job
  Future<void> _onApplyForJob(
    ApplyForJobEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      emit(const JobsLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      if (state is JobsLoaded) {
        final currentState = state as JobsLoaded;

        // Find the job to add to applied jobs
        final jobToApply = currentState.allJobs.firstWhere(
          (job) => job['id'] == event.jobId,
          orElse: () => {},
        );

        if (jobToApply.isNotEmpty) {
          final updatedAppliedJobs = List<Map<String, dynamic>>.from(
            currentState.appliedJobs,
          );
          updatedAppliedJobs.add({
            ...jobToApply,
            'applicationDate': DateTime.now().toIso8601String().split('T')[0],
            'status': 'Under Review',
          });

          emit(currentState.copyWith(appliedJobs: updatedAppliedJobs));
        }
      }

      // Emit success state
      emit(JobApplicationSuccessState(jobId: event.jobId));
    } catch (e) {
      emit(JobsError(message: 'Failed to apply for job: ${e.toString()}'));
    }
  }

  /// Handle load saved jobs
  Future<void> _onLoadSavedJobs(
    LoadSavedJobsEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      emit(const JobsLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Load saved jobs from mock data
      final savedJobs = JobData.savedJobs;
      final savedJobIds = UserData.savedJobIds.toSet();

      emit(
        JobsLoaded(
          allJobs: [],
          filteredJobs: savedJobs,
          savedJobs: savedJobs,
          appliedJobs: [],
          savedJobIds: savedJobIds,
        ),
      );
    } catch (e) {
      emit(JobsError(message: 'Failed to load saved jobs: ${e.toString()}'));
    }
  }

  /// Handle load applied jobs
  Future<void> _onLoadAppliedJobs(
    LoadAppliedJobsEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      emit(const JobsLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Load applied jobs from mock data
      final appliedJobs = JobData.appliedJobs;

      emit(
        JobsLoaded(
          allJobs: [],
          filteredJobs: appliedJobs,
          savedJobs: [],
          appliedJobs: appliedJobs,
          savedJobIds: UserData.savedJobIds.toSet(),
        ),
      );
    } catch (e) {
      emit(JobsError(message: 'Failed to load applied jobs: ${e.toString()}'));
    }
  }

  /// Handle refresh jobs
  Future<void> _onRefreshJobs(
    RefreshJobsEvent event,
    Emitter<JobsState> emit,
  ) async {
    // Reload jobs
    add(const LoadJobsEvent());
  }

  /// Handle clear search
  void _onClearSearch(ClearSearchEvent event, Emitter<JobsState> emit) {
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;
      final filteredJobs = _filterJobs(
        currentState.allJobs,
        '',
        currentState.selectedCategoryIndex,
        currentState.selectedFilterIndex,
      );

      emit(currentState.copyWith(searchQuery: '', filteredJobs: filteredJobs));
    }
  }

  /// Filter jobs based on search query, category, and filter
  List<Map<String, dynamic>> _filterJobs(
    List<Map<String, dynamic>> jobs,
    String query,
    int categoryIndex,
    int filterIndex,
  ) {
    List<Map<String, dynamic>> filteredJobs = List.from(jobs);

    // Apply search filter
    if (query.isNotEmpty) {
      filteredJobs = filteredJobs.where((job) {
        final title = job['title']?.toString().toLowerCase() ?? '';
        final company = job['company']?.toString().toLowerCase() ?? '';
        final location = job['location']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return title.contains(searchQuery) ||
            company.contains(searchQuery) ||
            location.contains(searchQuery);
      }).toList();
    }

    // Apply category filter
    if (categoryIndex > 0 && categoryIndex < JobData.jobCategories.length) {
      final selectedCategory = JobData.jobCategories[categoryIndex];
      if (selectedCategory != 'All Jobs') {
        filteredJobs = filteredJobs.where((job) {
          final title = job['title']?.toString().toLowerCase() ?? '';
          return title.contains(selectedCategory.toLowerCase());
        }).toList();
      }
    }

    // Apply additional filters
    if (filterIndex > 0 && filterIndex < JobData.filterOptions.length) {
      final selectedFilter = JobData.filterOptions[filterIndex];
      if (selectedFilter != 'All Jobs') {
        filteredJobs = filteredJobs.where((job) {
          final tags = job['tags'] as List<dynamic>? ?? [];
          return tags.any((tag) => tag.toString().contains(selectedFilter));
        }).toList();
      }
    }

    return filteredJobs;
  }

  /// Handle load job details
  Future<void> _onLoadJobDetails(
    LoadJobDetailsEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      emit(const JobsLoading());

      // Fetch job by ID from API
      final jobId = int.tryParse(event.jobId);
      if (jobId == null) {
        emit(const JobsError(message: 'Invalid job ID'));
        return;
      }

      final job = await _jobsRepository.getJobById(jobId);

      if (job != null) {
        final jobMap = _jobToMap(job);
        final isBookmarked = UserData.savedJobIds.contains(event.jobId);
        emit(JobDetailsLoaded(job: jobMap, isBookmarked: isBookmarked));
      } else {
        emit(const JobsError(message: 'Job not found'));
      }
    } catch (e) {
      emit(JobsError(message: 'Failed to load job details: ${e.toString()}'));
    }
  }

  /// Handle load detailed job information
  Future<void> _onLoadDetailedJob(
    LoadDetailedJobEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      emit(const JobsLoading());

      debugPrint('🔵 Loading detailed job information for ID: ${event.jobId}');

      // Fetch detailed job information from API
      final jobDetailResponse = await _jobsRepository.getJobDetails(
        event.jobId,
      );

      debugPrint(
        '🔵 Job detail response received: ${jobDetailResponse.status}',
      );

      if (jobDetailResponse.status) {
        // Convert the response data to maps for the state
        final jobInfoMap = jobDetailResponse.data.jobInfo.toJson();
        final companyInfoMap = jobDetailResponse.data.companyInfo.toJson();
        final statisticsMap = jobDetailResponse.data.statistics.toJson();

        // Check if job is bookmarked
        final isBookmarked = UserData.savedJobIds.contains(
          event.jobId.toString(),
        );

        emit(
          DetailedJobLoaded(
            jobInfo: jobInfoMap,
            companyInfo: companyInfoMap,
            statistics: statisticsMap,
            isBookmarked: isBookmarked,
          ),
        );

        debugPrint('🔵 Detailed job information loaded successfully');
      } else {
        emit(
          JobsError(
            message: jobDetailResponse.message.isNotEmpty
                ? jobDetailResponse.message
                : 'Failed to load job details',
          ),
        );
      }
    } catch (e) {
      debugPrint('🔴 Error loading detailed job information: $e');
      emit(JobsError(message: 'Failed to load job details: ${e.toString()}'));
    }
  }

  /// Handle toggle job bookmark
  void _onToggleJobBookmark(
    ToggleJobBookmarkEvent event,
    Emitter<JobsState> emit,
  ) {
    try {
      final isCurrentlyBookmarked = UserData.savedJobIds.contains(event.jobId);

      if (isCurrentlyBookmarked) {
        UserData.savedJobIds.remove(event.jobId);
      } else {
        UserData.savedJobIds.add(event.jobId);
      }

      emit(
        JobBookmarkToggled(
          jobId: event.jobId,
          isBookmarked: !isCurrentlyBookmarked,
        ),
      );
    } catch (e) {
      emit(JobsError(message: 'Failed to toggle bookmark: ${e.toString()}'));
    }
  }

  /// Handle update search results filter
  void _onUpdateSearchResultsFilter(
    UpdateSearchResultsFilterEvent event,
    Emitter<JobsState> emit,
  ) {
    if (state is SearchResultsLoaded) {
      final currentState = state as SearchResultsLoaded;
      final filteredJobs = _filterJobsByQueryAndFilter(
        currentState.searchQuery,
        event.filterIndex,
      );
      emit(
        currentState.copyWith(
          selectedFilterIndex: event.filterIndex,
          filteredJobs: filteredJobs,
        ),
      );
    }
  }

  /// Handle load search results
  void _onLoadSearchResults(
    LoadSearchResultsEvent event,
    Emitter<JobsState> emit,
  ) {
    try {
      final filteredJobs = _filterJobsByQueryAndFilter(event.searchQuery, 0);
      emit(
        SearchResultsLoaded(
          searchQuery: event.searchQuery,
          filteredJobs: filteredJobs,
          selectedFilterIndex: 0,
        ),
      );
    } catch (e) {
      emit(
        JobsError(message: 'Failed to load search results: ${e.toString()}'),
      );
    }
  }

  /// Helper method to filter jobs by query and filter
  List<Map<String, dynamic>> _filterJobsByQueryAndFilter(
    String query,
    int filterIndex,
  ) {
    final queryLower = query.toLowerCase();
    final filterOptions = JobData.filterOptions;
    final selectedFilter = filterIndex < filterOptions.length
        ? filterOptions[filterIndex]
        : 'All Jobs';

    var filteredJobs = JobData.recommendedJobs.where((job) {
      // Filter by search query
      final matchesQuery =
          queryLower.isEmpty ||
          job['title'].toString().toLowerCase().contains(queryLower) ||
          job['company'].toString().toLowerCase().contains(queryLower) ||
          job['location'].toString().toLowerCase().contains(queryLower);

      return matchesQuery;
    }).toList();

    // Apply filter
    if (selectedFilter != 'All Jobs') {
      filteredJobs = filteredJobs.where((job) {
        final tags = job['tags'] as List<dynamic>? ?? [];
        return tags.any((tag) => tag.toString().contains(selectedFilter));
      }).toList();
    }

    return filteredJobs;
  }

  /// Handle load application tracker
  void _onLoadApplicationTracker(
    LoadApplicationTrackerEvent event,
    Emitter<JobsState> emit,
  ) {
    try {
      // Load application tracker data from mock data
      final appliedJobs = JobData.appliedJobs;
      final interviewJobs = JobData.appliedJobs.where((job) {
        return job['status'] == 'Interview Scheduled' ||
            job['status'] == 'Interview Pending';
      }).toList();
      final offerJobs = JobData.appliedJobs.where((job) {
        return job['status'] == 'Offer Received' ||
            job['status'] == 'Offer Accepted';
      }).toList();

      emit(
        ApplicationTrackerLoaded(
          appliedJobs: appliedJobs,
          interviewJobs: interviewJobs,
          offerJobs: offerJobs,
        ),
      );
    } catch (e) {
      emit(
        JobsError(
          message: 'Failed to load application tracker: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle view application
  void _onViewApplication(ViewApplicationEvent event, Emitter<JobsState> emit) {
    try {
      emit(ApplicationViewed(applicationId: event.applicationId));
    } catch (e) {
      emit(JobsError(message: 'Failed to view application: ${e.toString()}'));
    }
  }

  /// Handle apply for more jobs
  void _onApplyForMoreJobs(
    ApplyForMoreJobsEvent event,
    Emitter<JobsState> emit,
  ) {
    try {
      emit(const ApplyForMoreJobsState());
    } catch (e) {
      emit(
        JobsError(message: 'Failed to apply for more jobs: ${e.toString()}'),
      );
    }
  }

  /// Handle remove saved job
  void _onRemoveSavedJob(RemoveSavedJobEvent event, Emitter<JobsState> emit) {
    try {
      // Remove from saved job IDs
      UserData.savedJobIds.remove(event.jobId);

      // Update saved jobs list
      final updatedSavedJobs = JobData.savedJobs
          .where((job) => job['id'] != event.jobId)
          .toList();

      emit(SavedJobsLoaded(savedJobs: updatedSavedJobs));
      emit(SavedJobRemoved(jobId: event.jobId));
    } catch (e) {
      emit(JobsError(message: 'Failed to remove saved job: ${e.toString()}'));
    }
  }

  /// Handle load job application form
  void _onLoadJobApplicationForm(
    LoadJobApplicationFormEvent event,
    Emitter<JobsState> emit,
  ) {
    try {
      // Load user data and existing resume
      final formData = {
        'name': 'Rahul Kumar',
        'email': 'rahul.kumar@email.com',
        'phone': '+91 98765 43210',
      };

      // Mock existing resume file
      final existingResume = PlatformFile(
        name: 'Rahul_Kumar_Resume_CV.pdf',
        size: 398336, // 389 KB
        path: '/path/to/existing/resume_cv.pdf',
      );

      emit(
        JobApplicationFormLoaded(
          job: event.job,
          formData: formData,
          resumeFile: existingResume,
        ),
      );
    } catch (e) {
      emit(
        JobsError(
          message: 'Failed to load job application form: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle update job application form
  void _onUpdateJobApplicationForm(
    UpdateJobApplicationFormEvent event,
    Emitter<JobsState> emit,
  ) {
    try {
      if (state is JobApplicationFormLoaded) {
        final currentState = state as JobApplicationFormLoaded;
        final updatedFormData = Map<String, String>.from(currentState.formData);
        updatedFormData[event.field] = event.value;

        emit(currentState.copyWith(formData: updatedFormData));
      }
    } catch (e) {
      emit(JobsError(message: 'Failed to update form: ${e.toString()}'));
    }
  }

  /// Handle pick resume file
  Future<void> _onPickResumeFile(
    PickResumeFileEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      // This would typically use FilePicker.platform.pickFiles()
      // For now, we'll simulate the file picking
      final mockFile = PlatformFile(
        name: 'New_Resume.pdf',
        size: 256000, // 250 KB
        path: '/path/to/new/resume.pdf',
      );

      emit(ResumeFilePicked(resumeFile: mockFile));

      // Update the form state with the new file
      if (state is JobApplicationFormLoaded) {
        final currentState = state as JobApplicationFormLoaded;
        emit(currentState.copyWith(resumeFile: mockFile));
      }
    } catch (e) {
      emit(JobsError(message: 'Failed to pick resume file: ${e.toString()}'));
    }
  }

  /// Handle remove resume file
  void _onRemoveResumeFile(
    RemoveResumeFileEvent event,
    Emitter<JobsState> emit,
  ) {
    try {
      emit(const ResumeFileRemoved());

      // Update the form state to remove the file
      if (state is JobApplicationFormLoaded) {
        final currentState = state as JobApplicationFormLoaded;
        emit(currentState.copyWith(resumeFile: null));
      }
    } catch (e) {
      emit(JobsError(message: 'Failed to remove resume file: ${e.toString()}'));
    }
  }

  /// Handle submit job application
  Future<void> _onSubmitJobApplication(
    SubmitJobApplicationEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      emit(const JobApplicationSubmitting());

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Generate mock application ID
      final applicationId = 'APP_${DateTime.now().millisecondsSinceEpoch}';

      emit(JobApplicationSubmitted(applicationId: applicationId));
    } catch (e) {
      emit(JobsError(message: 'Failed to submit application: ${e.toString()}'));
    }
  }

  /// Handle load calendar view
  void _onLoadCalendarView(
    LoadCalendarViewEvent event,
    Emitter<JobsState> emit,
  ) {
    try {
      final selectedDate = DateTime(2025, 7, 25); // July 25, 2025
      final focusedDate = DateTime(2025, 7, 1); // July 1, 2025

      emit(
        CalendarViewLoaded(
          selectedDate: selectedDate,
          focusedDate: focusedDate,
        ),
      );
    } catch (e) {
      emit(JobsError(message: 'Failed to load calendar view: ${e.toString()}'));
    }
  }

  /// Handle change calendar month
  void _onChangeCalendarMonth(
    ChangeCalendarMonthEvent event,
    Emitter<JobsState> emit,
  ) {
    try {
      if (state is CalendarViewLoaded) {
        final currentState = state as CalendarViewLoaded;
        emit(currentState.copyWith(focusedDate: event.newFocusedDate));
      }
    } catch (e) {
      emit(
        JobsError(message: 'Failed to change calendar month: ${e.toString()}'),
      );
    }
  }

  /// Handle select calendar date
  void _onSelectCalendarDate(
    SelectCalendarDateEvent event,
    Emitter<JobsState> emit,
  ) {
    try {
      if (state is CalendarViewLoaded) {
        final currentState = state as CalendarViewLoaded;
        emit(currentState.copyWith(selectedDate: event.selectedDate));
      }
    } catch (e) {
      emit(
        JobsError(message: 'Failed to select calendar date: ${e.toString()}'),
      );
    }
  }

  /// Handle load write review
  void _onLoadWriteReview(LoadWriteReviewEvent event, Emitter<JobsState> emit) {
    try {
      emit(WriteReviewLoaded(job: event.job, rating: 4, reviewText: ''));
    } catch (e) {
      emit(JobsError(message: 'Failed to load write review: ${e.toString()}'));
    }
  }

  /// Handle update review rating
  void _onUpdateReviewRating(
    UpdateReviewRatingEvent event,
    Emitter<JobsState> emit,
  ) {
    try {
      if (state is WriteReviewLoaded) {
        final currentState = state as WriteReviewLoaded;
        emit(currentState.copyWith(rating: event.rating));
      }
    } catch (e) {
      emit(
        JobsError(message: 'Failed to update review rating: ${e.toString()}'),
      );
    }
  }

  /// Handle update review text
  void _onUpdateReviewText(
    UpdateReviewTextEvent event,
    Emitter<JobsState> emit,
  ) {
    try {
      if (state is WriteReviewLoaded) {
        final currentState = state as WriteReviewLoaded;
        emit(currentState.copyWith(reviewText: event.text));
      }
    } catch (e) {
      emit(JobsError(message: 'Failed to update review text: ${e.toString()}'));
    }
  }

  /// Handle submit review
  Future<void> _onSubmitReview(
    SubmitReviewEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Generate mock review ID
      final reviewId = 'REV_${DateTime.now().millisecondsSinceEpoch}';

      emit(ReviewSubmitted(reviewId: reviewId));
    } catch (e) {
      emit(JobsError(message: 'Failed to submit review: ${e.toString()}'));
    }
  }
}
