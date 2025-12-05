import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'jobs_event.dart';
import 'jobs_state.dart';
import '../../../shared/data/job_data.dart';
import '../../../shared/data/user_data.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/home_cache_service.dart';
import '../../../core/utils/network_error_helper.dart';
import '../repositories/jobs_repository.dart';
import '../models/job.dart' hide CompanyInfo, JobStatistics;
import '../models/job_detail_models.dart';
import '../../profile/models/student_profile.dart';
import '../../interviews/repositories/interviews_repository.dart';

/// Jobs BLoC
/// Handles all job-related business logic
class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final JobsRepository _jobsRepository;
  final ApiService _apiService;
  final InterviewsRepository? _interviewsRepository;

  static const List<String> _monthNames = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  JobsBloc({
    JobsRepository? jobsRepository,
    ApiService? apiService,
    InterviewsRepository? interviewsRepository,
  }) : _jobsRepository = jobsRepository ?? _createDefaultRepository(),
       _apiService = apiService ?? ApiService(),
       _interviewsRepository = interviewsRepository,
       super(const JobsInitial()) {
    // Register event handlers
    on<LoadJobsEvent>(_onLoadJobs);
    on<SearchJobsEvent>(_onSearchJobs);
    on<FilterJobsEvent>(_onFilterJobs);
    on<ToggleFiltersEvent>(_onToggleFilters);
    on<SaveJobEvent>(_onSaveJob);
    on<UnsaveJobEvent>(_onUnsaveJob);
    on<ApplyForJobEvent>(_onApplyForJob);
    on<LoadSavedJobsEvent>(_onLoadSavedJobs);
    on<LoadAppliedJobsEvent>(_onLoadAppliedJobs);
    on<RefreshJobsEvent>(_onRefreshJobs);
    on<ClearSearchEvent>(_onClearSearch);
    on<LoadJobDetailsEvent>(_onLoadJobDetails);
    on<ToggleJobBookmarkEvent>(_onToggleJobBookmark);
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
      // Preserve tracker data from current state if it exists
      List<Map<String, dynamic>>? preservedTrackerApplied;
      List<Map<String, dynamic>>? preservedTrackerInterviews;
      
      if (state is JobsLoaded) {
        final currentState = state as JobsLoaded;
        preservedTrackerApplied = currentState.trackerAppliedJobs;
        preservedTrackerInterviews = currentState.trackerInterviewJobs;
        debugPrint('🔵 [Jobs] Preserving tracker data: ${preservedTrackerApplied?.length ?? 0} applied, ${preservedTrackerInterviews?.length ?? 0} interviews');
      } else if (state is ApplicationTrackerLoaded) {
        final currentState = state as ApplicationTrackerLoaded;
        preservedTrackerApplied = currentState.appliedJobs;
        preservedTrackerInterviews = currentState.interviewJobs;
        debugPrint('🔵 [Jobs] Preserving tracker data from ApplicationTrackerLoaded: ${preservedTrackerApplied.length} applied, ${preservedTrackerInterviews.length} interviews');
      }
      
      emit(const JobsLoading());

      // Load featured jobs from API
      List<Map<String, dynamic>> featuredJobs = [];
      try {
        final featuredResponse = await _apiService.getFeaturedJobs();
        featuredJobs = featuredResponse.data; // Data is already in Map format
        debugPrint('🔵 [Jobs] Loaded ${featuredJobs.length} featured jobs');
      } catch (e) {
        debugPrint('🔴 [Jobs] Failed to load featured jobs: $e');
        // Continue with empty featured jobs list
      }

      // Fetch jobs from API
      final jobsResponse = await _jobsRepository.getJobs();

      if (jobsResponse.status) {
        // Convert Job objects to Map format for compatibility with existing UI
        final allJobs = jobsResponse.data.map((job) => _jobToMap(job)).toList();

        // Load saved jobs from API automatically
        List<Map<String, dynamic>> savedJobs = [];
        Set<String> savedJobIds = <String>{};

        try {
          debugPrint('🔵 [Jobs] Loading saved jobs from API...');
          final savedJobsResponse = await _jobsRepository.getSavedJobs();

          if (savedJobsResponse.status) {
            // Convert SavedJobItem to Map format - toMap() already handles deep conversion
            savedJobs = savedJobsResponse.data
                .map((item) => item.toMap())
                .toList();

            // Extract saved job IDs
            savedJobIds = savedJobsResponse.data
                .map((item) => item.jobId.toString())
                .toSet();

            debugPrint(
              '✅ [Jobs] Loaded ${savedJobs.length} saved jobs from API',
            );
          } else {
            debugPrint(
              '⚠️ [Jobs] Saved jobs API returned status false: ${savedJobsResponse.message}',
            );
            // Fallback to mock data
            savedJobs = JobData.savedJobs;
            savedJobIds = UserData.savedJobIds.toSet();
          }
        } catch (e) {
          debugPrint(
            '⚠️ [Jobs] Failed to load saved jobs from API: $e, using fallback',
          );
          // Fallback to mock data if API fails
          savedJobs = JobData.savedJobs;
          savedJobIds = UserData.savedJobIds.toSet();
        }

        final appliedJobs =
            JobData.appliedJobs; // Keep existing applied jobs for now

        emit(
          JobsLoaded(
            allJobs: allJobs,
            filteredJobs: allJobs,
            savedJobs: savedJobs,
            appliedJobs: appliedJobs,
            savedJobIds: savedJobIds,
            featuredJobs: featuredJobs,
            trackerAppliedJobs: preservedTrackerApplied,
            trackerInterviewJobs: preservedTrackerInterviews,
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

        // Try to load saved jobs even in fallback mode (might work if partially authenticated)
        List<Map<String, dynamic>> savedJobs = JobData.savedJobs;
        Set<String> savedJobIds = UserData.savedJobIds.toSet();

        try {
          final savedJobsResponse = await _jobsRepository.getSavedJobs();
          if (savedJobsResponse.status) {
            savedJobs = savedJobsResponse.data
                .map((item) => item.toMap())
                .toList();
            savedJobIds = savedJobsResponse.data
                .map((item) => item.jobId.toString())
                .toSet();
            debugPrint('✅ Loaded saved jobs even in fallback mode');
          }
        } catch (savedJobsError) {
          debugPrint(
            '⚠️ Could not load saved jobs in fallback: $savedJobsError',
          );
        }

        final appliedJobs = JobData.appliedJobs;
        
        // Preserve tracker data from current state if it exists
        List<Map<String, dynamic>>? preservedTrackerApplied;
        List<Map<String, dynamic>>? preservedTrackerInterviews;
        
        if (state is JobsLoaded) {
          final currentState = state as JobsLoaded;
          preservedTrackerApplied = currentState.trackerAppliedJobs;
          preservedTrackerInterviews = currentState.trackerInterviewJobs;
        }

        emit(
          JobsLoaded(
            allJobs: allJobs,
            filteredJobs: allJobs,
            savedJobs: savedJobs,
            appliedJobs: appliedJobs,
            savedJobIds: savedJobIds,
            featuredJobs: [],
            trackerAppliedJobs: preservedTrackerApplied,
            trackerInterviewJobs: preservedTrackerInterviews,
          ),
        );
      } else {
        _handleJobsError(e, emit, defaultMessage: 'Failed to load jobs');
      }
    }
  }

  /// Convert Job object to Map format for UI compatibility
  Map<String, dynamic> _jobToMap(Job job) {
    return {
      'id': job.id.toString(),
      'title': job.title,
      'company': job.companyName ?? 'Company Name', // Use company_name from API
      'rating': 4.5, // Default rating
      'tags': [job.jobTypeDisplay, job.isRemote ? 'Remote' : 'On-site'],
      'job_type_display': job.jobTypeDisplay,
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
      'company_name':
          job.companyName, // Add company_name field for direct access
    };
  }

  /// Convert JobDetailResponse to Map format for UI compatibility
  Map<String, dynamic> _jobDetailResponseToMap(JobDetailResponse response) {
    final jobInfo = response.data.jobInfo;
    final companyInfo = response.data.companyInfo;
    final statistics = response.data.statistics;

    return {
      'id': jobInfo.id.toString(),
      'title': jobInfo.title,
      'company': companyInfo.companyName,
      'company_name': companyInfo.companyName,
      'company_logo': companyInfo.companyLogo,
      'company_industry': companyInfo.industry,
      'company_website': companyInfo.website,
      'company_location': companyInfo.location,
      'rating': 4.5, // Default rating
      'tags': [jobInfo.jobType, jobInfo.isRemote ? 'Remote' : 'On-site'],
      'job_type_display': jobInfo.jobType.isEmpty
          ? 'Full-Time'
          : jobInfo.jobType,
      'salary':
          '₹${(jobInfo.salaryMin / 1000).toStringAsFixed(1)}K - ₹${(jobInfo.salaryMax / 1000).toStringAsFixed(1)}K',
      'salary_min': jobInfo.salaryMin,
      'salary_max': jobInfo.salaryMax,
      'location': jobInfo.location,
      'time': _formatTimeAgo(jobInfo.createdAt),
      'logo': 'assets/images/company/group.png',
      'review_user_name': 'User Name',
      'review_user_role': jobInfo.title,
      'description': jobInfo.description,
      'requirements': jobInfo.skillsRequired,
      'skills_required': jobInfo.skillsRequired,
      'is_saved': jobInfo.isSaved,
      'is_applied': jobInfo.isApplied,
      'benefits': [
        'Competitive salary',
        'Health insurance',
        'Professional development',
        'Work-life balance',
      ],
      'experience_required': jobInfo.experienceRequired,
      'application_deadline': jobInfo.applicationDeadline,
      'no_of_vacancies': jobInfo.noOfVacancies,
      'is_remote': jobInfo.isRemote,
      'status': jobInfo.status,
      'admin_action': jobInfo.adminAction,
      'created_at': jobInfo.createdAt,
      'views': statistics.totalViews,
      'total_applications': statistics.totalApplications,
      'pending_applications': statistics.pendingApplications,
      'shortlisted_applications': statistics.shortlistedApplications,
      'selected_applications': statistics.selectedApplications,
      'times_saved': statistics.timesSaved,
      'recruiter_id': companyInfo.recruiterId,
    };
  }

  /// Convert CompanyInfo to Map format
  Map<String, dynamic> _companyInfoToMap(CompanyInfo companyInfo) {
    return {
      'recruiter_id': companyInfo.recruiterId,
      'company_name': companyInfo.companyName,
      'company_logo': companyInfo.companyLogo,
      'industry': companyInfo.industry,
      'website': companyInfo.website,
      'location': companyInfo.location,
    };
  }

  /// Convert JobStatistics to Map format
  Map<String, dynamic> _statisticsToMap(JobStatistics statistics) {
    return {
      'total_views': statistics.totalViews,
      'total_applications': statistics.totalApplications,
      'pending_applications': statistics.pendingApplications,
      'shortlisted_applications': statistics.shortlistedApplications,
      'selected_applications': statistics.selectedApplications,
      'times_saved': statistics.timesSaved,
    };
  }

  /// Format time ago string
  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} दिन पहले';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} घंटे पहले';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} मिनट पहले';
      } else {
        return 'अभी';
      }
    } catch (e) {
      return 'Unknown';
    }
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
            featuredJobs: [],
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
              featuredJobs: [],
            ),
          );
        }
      } else {
        emit(JobsError(message: 'Failed to search jobs: ${e.toString()}'));
      }
    }
  }

  /// Handle filter jobs
  Future<void> _onFilterJobs(
    FilterJobsEvent event,
    Emitter<JobsState> emit,
  ) async {
    if (state is! JobsLoaded) return;

    final currentState = state as JobsLoaded;
    final filteredJobs = _filterJobs(currentState.allJobs, event.category);

    emit(
      currentState.copyWith(
        filteredJobs: filteredJobs,
        selectedCategory: event.category,
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

  /// Handle toggle filters
  Future<void> _onToggleFilters(
    ToggleFiltersEvent event,
    Emitter<JobsState> emit,
  ) async {
    if (state is! JobsLoaded) return;

    final currentState = state as JobsLoaded;
    final newShowFilters = !currentState.showFilters;

    emit(
      currentState.copyWith(
        showFilters: newShowFilters,
        selectedCategory: newShowFilters
            ? currentState.selectedCategory
            : 'All',
        filteredJobs: newShowFilters
            ? currentState.filteredJobs
            : currentState.allJobs,
      ),
    );
  }

  /// Handle save job
  Future<void> _onSaveJob(SaveJobEvent event, Emitter<JobsState> emit) async {
    try {
      debugPrint('🔵 [JobsBloc] Saving job with ID: ${event.jobId}');

      // Parse jobId to int
      final jobIdInt = int.tryParse(event.jobId);
      if (jobIdInt == null) {
        emit(JobsError(message: 'Invalid job ID: ${event.jobId}'));
        return;
      }

      // Call the repository to save the job via API
      final saveJobResponse = await _jobsRepository.saveJob(jobIdInt);

      // Handle different response scenarios
      if (saveJobResponse.isSuccess) {
        // Job saved successfully - update local state
        if (state is JobsLoaded) {
          final currentState = state as JobsLoaded;
          final updatedSavedJobIds = Set<String>.from(currentState.savedJobIds);
          updatedSavedJobIds.add(event.jobId);

          // Find the job to add to saved jobs
          final jobToSave = currentState.allJobs.firstWhere(
            (job) => job['id']?.toString() == event.jobId,
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
          } else {
            // Update saved job IDs even if job not found in current list
            emit(currentState.copyWith(savedJobIds: updatedSavedJobIds));
          }

          // Update job details state immediately if on job details screen (before emitting success state)
          final currentStateBeforeEmit = state;
          if (currentStateBeforeEmit is JobDetailsLoaded) {
            final jobDetailsState = currentStateBeforeEmit;
            final jobId = jobDetailsState.job['id']?.toString() ?? '';
            if (jobId == event.jobId) {
              // Update the job map with is_saved = true immediately
              final updatedJob = Map<String, dynamic>.from(jobDetailsState.job);
              updatedJob['is_saved'] = true;

              emit(
                JobDetailsLoaded(
                  job: updatedJob,
                  isBookmarked: true,
                  companyInfo: jobDetailsState.companyInfo,
                  statistics: jobDetailsState.statistics,
                ),
              );

              // Reload in background to sync with server
              add(LoadJobDetailsEvent(jobId: jobId));
            }
          }

          // Emit success state
          emit(JobSavedState(jobId: event.jobId));
          debugPrint('✅ [JobsBloc] Job saved successfully');
        } else {
          // Update job details state immediately if on job details screen (before emitting success state)
          final currentStateBeforeEmit = state;
          if (currentStateBeforeEmit is JobDetailsLoaded) {
            final jobDetailsState = currentStateBeforeEmit;
            final jobId = jobDetailsState.job['id']?.toString() ?? '';
            if (jobId == event.jobId) {
              // Update the job map with is_saved = true immediately
              final updatedJob = Map<String, dynamic>.from(jobDetailsState.job);
              updatedJob['is_saved'] = true;

              emit(
                JobDetailsLoaded(
                  job: updatedJob,
                  isBookmarked: true,
                  companyInfo: jobDetailsState.companyInfo,
                  statistics: jobDetailsState.statistics,
                ),
              );

              // Reload in background to sync with server
              add(LoadJobDetailsEvent(jobId: jobId));
            }
          }

          // Emit success state even if not in JobsLoaded state
          emit(JobSavedState(jobId: event.jobId));
        }
      } else if (saveJobResponse.isAlreadySaved) {
        // Job is already saved - treat as success but show appropriate message
        debugPrint('ℹ️ [JobsBloc] Job is already saved');
        if (state is JobsLoaded) {
          final currentState = state as JobsLoaded;
          final updatedSavedJobIds = Set<String>.from(currentState.savedJobIds);
          updatedSavedJobIds.add(event.jobId);

          emit(currentState.copyWith(savedJobIds: updatedSavedJobIds));
        }
        // Update job details state immediately if on job details screen (before emitting success state)
        final currentStateBeforeEmit = state;
        if (currentStateBeforeEmit is JobDetailsLoaded) {
          final jobDetailsState = currentStateBeforeEmit;
          final jobId = jobDetailsState.job['id']?.toString() ?? '';
          if (jobId == event.jobId) {
            // Update the job map with is_saved = true immediately
            final updatedJob = Map<String, dynamic>.from(jobDetailsState.job);
            updatedJob['is_saved'] = true;

            emit(
              JobDetailsLoaded(
                job: updatedJob,
                isBookmarked: true,
                companyInfo: jobDetailsState.companyInfo,
                statistics: jobDetailsState.statistics,
              ),
            );

            // Reload in background to sync with server
            add(LoadJobDetailsEvent(jobId: jobId));
          }
        }

        emit(JobSavedState(jobId: event.jobId));
      } else if (saveJobResponse.isJobNotFound) {
        // Job not found
        emit(
          JobsError(
            message: saveJobResponse.message.isNotEmpty
                ? saveJobResponse.message
                : 'Job not found or not available for saving',
          ),
        );
      } else if (saveJobResponse.isInvalidToken) {
        // Invalid token - authentication issue
        emit(
          JobsError(
            message: saveJobResponse.message.isNotEmpty
                ? saveJobResponse.message
                : 'Authentication failed. Please login again.',
          ),
        );
      } else {
        // Other error
        emit(
          JobsError(
            message: saveJobResponse.message.isNotEmpty
                ? saveJobResponse.message
                : 'Failed to save job',
          ),
        );
      }
    } catch (e) {
      debugPrint('🔴 [JobsBloc] Error saving job: $e');
      emit(JobsError(message: 'Failed to save job: ${e.toString()}'));
    }
  }

  /// Handle unsave job
  Future<void> _onUnsaveJob(
    UnsaveJobEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      debugPrint('🔵 [JobsBloc] Unsaving job with ID: ${event.jobId}');

      // Parse jobId to int
      final jobIdInt = int.tryParse(event.jobId);
      if (jobIdInt == null) {
        emit(JobsError(message: 'Invalid job ID: ${event.jobId}'));
        return;
      }

      // Call the repository to unsave the job via API
      final unsaveJobResponse = await _jobsRepository.unsaveJob(jobIdInt);

      // Handle different response scenarios
      if (unsaveJobResponse.isSuccess) {
        // Job unsaved successfully - update local state
        if (state is JobsLoaded) {
          final currentState = state as JobsLoaded;
          final updatedSavedJobIds = Set<String>.from(currentState.savedJobIds);
          updatedSavedJobIds.remove(event.jobId);

          final updatedSavedJobs = currentState.savedJobs
              .where((job) => job['id']?.toString() != event.jobId)
              .toList();

          emit(
            currentState.copyWith(
              savedJobs: updatedSavedJobs,
              savedJobIds: updatedSavedJobIds,
            ),
          );
        }

        // Update job details state immediately if on job details screen (before emitting success state)
        final currentStateBeforeEmit = state;
        if (currentStateBeforeEmit is JobDetailsLoaded) {
          final jobDetailsState = currentStateBeforeEmit;
          final jobId = jobDetailsState.job['id']?.toString() ?? '';
          if (jobId == event.jobId) {
            // Update the job map with is_saved = false immediately
            final updatedJob = Map<String, dynamic>.from(jobDetailsState.job);
            updatedJob['is_saved'] = false;

            emit(
              JobDetailsLoaded(
                job: updatedJob,
                isBookmarked: false,
                companyInfo: jobDetailsState.companyInfo,
                statistics: jobDetailsState.statistics,
              ),
            );

            // Reload in background to sync with server
            add(LoadJobDetailsEvent(jobId: jobId));
          }
        }

        // Emit success state
        emit(JobUnsavedState(jobId: event.jobId));
        debugPrint('✅ [JobsBloc] Job unsaved successfully');
      } else if (unsaveJobResponse.isJobNotSaved) {
        // Job is not saved or doesn't exist
        debugPrint('⚠️ [JobsBloc] Job is not saved or doesn\'t exist');

        // Still update local state to remove from saved list
        if (state is JobsLoaded) {
          final currentState = state as JobsLoaded;
          final updatedSavedJobIds = Set<String>.from(currentState.savedJobIds);
          updatedSavedJobIds.remove(event.jobId);

          final updatedSavedJobs = currentState.savedJobs
              .where((job) => job['id']?.toString() != event.jobId)
              .toList();

          emit(
            currentState.copyWith(
              savedJobs: updatedSavedJobs,
              savedJobIds: updatedSavedJobIds,
            ),
          );
        }

        // Update job details state immediately if on job details screen (before emitting success state)
        final currentStateBeforeEmit = state;
        if (currentStateBeforeEmit is JobDetailsLoaded) {
          final jobDetailsState = currentStateBeforeEmit;
          final jobId = jobDetailsState.job['id']?.toString() ?? '';
          if (jobId == event.jobId) {
            // Update the job map with is_saved = false immediately
            final updatedJob = Map<String, dynamic>.from(jobDetailsState.job);
            updatedJob['is_saved'] = false;

            emit(
              JobDetailsLoaded(
                job: updatedJob,
                isBookmarked: false,
                companyInfo: jobDetailsState.companyInfo,
                statistics: jobDetailsState.statistics,
              ),
            );

            // Reload in background to sync with server
            add(LoadJobDetailsEvent(jobId: jobId));
          }
        }

        emit(JobUnsavedState(jobId: event.jobId));
      } else {
        // Other error
        emit(
          JobsError(
            message: unsaveJobResponse.message.isNotEmpty
                ? unsaveJobResponse.message
                : 'Failed to unsave job',
          ),
        );
      }
    } catch (e) {
      debugPrint('🔴 [JobsBloc] Error unsaving job: $e');
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
      // Try to load from cache first for offline support
      final cacheService = HomeCacheService.instance;
      await cacheService.initialize();

      List<Map<String, dynamic>> savedJobs = [];
      bool loadedFromCache = false;

      // Load from cache if available
      final cachedSavedJobs = await cacheService.getSavedJobs();
      if (cachedSavedJobs != null && cachedSavedJobs.isNotEmpty) {
        savedJobs = cachedSavedJobs;
        loadedFromCache = true;
        debugPrint(
          '🔵 [JobsBloc] Loaded ${savedJobs.length} saved jobs from cache',
        );

        // Emit cached data immediately for offline support
        emit(SavedJobsLoaded(savedJobs: savedJobs));
      } else {
        emit(const JobsLoading());
      }

      debugPrint('🔵 [JobsBloc] Loading saved jobs from API...');

      // Try to load from API (will update cache if successful)
      try {
        final savedJobsResponse = await _jobsRepository.getSavedJobs(
          limit: event.limit,
          offset: event.offset,
        );

        if (savedJobsResponse.status) {
          // Convert SavedJobItem to Map format - toMap() already handles deep conversion
          savedJobs = savedJobsResponse.data
              .map((item) => item.toMap())
              .toList();

          debugPrint(
            '✅ [JobsBloc] Loaded ${savedJobs.length} saved jobs successfully from API',
          );

          // Store in cache for offline use
          try {
            await cacheService.storeSavedJobs(savedJobs);
            debugPrint('🔵 [JobsBloc] Stored saved jobs in cache');
          } catch (e) {
            debugPrint('🔴 [JobsBloc] Failed to store saved jobs in cache: $e');
          }

          emit(
            SavedJobsLoaded(
              savedJobs: savedJobs,
              pagination: savedJobsResponse.pagination,
            ),
          );
        } else {
          debugPrint(
            '🔴 [JobsBloc] Failed to load saved jobs: ${savedJobsResponse.message}',
          );

          // If we have cached data, use it even if API fails
          if (loadedFromCache && savedJobs.isNotEmpty) {
            debugPrint('🔵 [JobsBloc] API failed but using cached data');
            return;
          }

          emit(
            JobsError(
              message: savedJobsResponse.message.isNotEmpty
                  ? savedJobsResponse.message
                  : 'Failed to load saved jobs',
            ),
          );
        }
      } catch (e) {
        debugPrint('🔴 [JobsBloc] Error loading saved jobs from API: $e');

        // If we have cached data, use it even if API fails
        if (loadedFromCache && savedJobs.isNotEmpty) {
          debugPrint('🔵 [JobsBloc] API error but using cached data');
          return;
        }

        // Check if it's an authentication error
        final errorMessage = e.toString();
        if (errorMessage.contains('User must be logged in') ||
            errorMessage.contains('Unauthorized') ||
            errorMessage.contains('No token provided')) {
          debugPrint(
            'ℹ️ [JobsBloc] User not authenticated, using mock data as fallback',
          );
          // Use mock data as fallback when user is not authenticated
          savedJobs = JobData.savedJobs;

          // Store mock data in cache
          try {
            await cacheService.storeSavedJobs(savedJobs);
          } catch (cacheError) {
            debugPrint(
              '🔴 [JobsBloc] Failed to store mock data in cache: $cacheError',
            );
          }

          emit(SavedJobsLoaded(savedJobs: savedJobs));
        } else {
          emit(
            JobsError(message: 'Failed to load saved jobs: ${e.toString()}'),
          );
        }
      }
    } catch (e) {
      debugPrint('🔴 [JobsBloc] Unexpected error loading saved jobs: $e');

      // Try to load from cache as final fallback
      try {
        final cacheService = HomeCacheService.instance;
        await cacheService.initialize();
        final cachedSavedJobs = await cacheService.getSavedJobs();
        if (cachedSavedJobs != null && cachedSavedJobs.isNotEmpty) {
          emit(SavedJobsLoaded(savedJobs: cachedSavedJobs));
          return;
        }
      } catch (cacheError) {
        debugPrint('🔴 [JobsBloc] Cache fallback also failed: $cacheError');
      }

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
          featuredJobs: [],
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
      emit(
        currentState.copyWith(
          searchQuery: '',
          filteredJobs: currentState.allJobs,
        ),
      );
    }
  }

  /// Handle load job details
  Future<void> _onLoadJobDetails(
    LoadJobDetailsEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      emit(const JobsLoading());

      // Fetch comprehensive job details from API
      final jobId = int.tryParse(event.jobId);
      if (jobId == null) {
        emit(const JobsError(message: 'Invalid job ID'));
        return;
      }

      debugPrint('🔵 [BLoC] Loading job details for ID: $jobId');

      // Use the new comprehensive job details API
      final jobDetailsResponse = await _jobsRepository.getJobDetails(jobId);

      if (jobDetailsResponse.status) {
        // Convert JobDetailResponse to Map for UI compatibility
        final jobMap = _jobDetailResponseToMap(jobDetailsResponse);
        // Use is_saved from API response (preferred) or fallback to UserData check
        final isBookmarked = jobDetailsResponse.data.jobInfo.isSaved;

        // Extract company info and statistics separately
        final companyInfoMap = _companyInfoToMap(
          jobDetailsResponse.data.companyInfo,
        );
        final statisticsMap = _statisticsToMap(
          jobDetailsResponse.data.statistics,
        );

        debugPrint('🔵 [BLoC] Job details loaded successfully');
        debugPrint('🔵 [BLoC] Job Title: ${jobMap['title']}');
        debugPrint('🔵 [BLoC] Job ID: ${jobMap['id']}');
        debugPrint('🔵 [BLoC] Company: ${companyInfoMap['company_name']}');
        debugPrint('🔵 [BLoC] Is Saved: $isBookmarked');

        emit(
          JobDetailsLoaded(
            job: jobMap,
            isBookmarked: isBookmarked,
            companyInfo: companyInfoMap,
            statistics: statisticsMap,
          ),
        );
      } else {
        emit(JobsError(message: jobDetailsResponse.message));
      }
    } catch (e) {
      debugPrint('🔴 [BLoC] Error loading job details: $e');
      emit(JobsError(message: 'Failed to load job details: ${e.toString()}'));
    }
  }

  /// Handle toggle job bookmark
  Future<void> _onToggleJobBookmark(
    ToggleJobBookmarkEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      // Check current bookmark state from multiple sources
      bool isCurrentlyBookmarked = false;

      // Priority 1: Check JobDetailsLoaded state (for job details screen)
      if (state is JobDetailsLoaded) {
        final currentState = state as JobDetailsLoaded;
        // Check both isBookmarked and is_saved in job data
        isCurrentlyBookmarked =
            currentState.isBookmarked ||
            (currentState.job['is_saved'] == true) ||
            (currentState.job['is_saved'] == 1);
      }
      // Priority 2: Check JobsLoaded state (for job list screen)
      else if (state is JobsLoaded) {
        final currentState = state as JobsLoaded;
        isCurrentlyBookmarked = currentState.savedJobIds.contains(event.jobId);
      }
      // Priority 3: Check JobSavedState/JobUnsavedState (recently saved/unsaved)
      else if (state is JobSavedState) {
        // If job was just saved, it should be bookmarked
        final savedState = state as JobSavedState;
        isCurrentlyBookmarked = savedState.jobId == event.jobId;
      } else if (state is JobUnsavedState) {
        // If job was just unsaved, it should not be bookmarked
        isCurrentlyBookmarked = false;
      }
      // Priority 4: Check JobBookmarkToggled state (immediate toggle state)
      else if (state is JobBookmarkToggled) {
        // Use the current toggle state (since we're checking before toggling)
        final toggledState = state as JobBookmarkToggled;
        isCurrentlyBookmarked = toggledState.jobId == event.jobId
            ? toggledState.isBookmarked
            : false;
      }
      // Priority 5: Fallback to UserData check (read-only)
      else {
        isCurrentlyBookmarked = UserData.savedJobIds.contains(event.jobId);
      }

      // Emit toggle state immediately for better UX
      emit(
        JobBookmarkToggled(
          jobId: event.jobId,
          isBookmarked: !isCurrentlyBookmarked,
        ),
      );

      // Call appropriate API based on current state
      if (isCurrentlyBookmarked) {
        // Call unsave job API
        add(UnsaveJobEvent(jobId: event.jobId));
      } else {
        // Call save job API
        add(SaveJobEvent(jobId: event.jobId));
      }
    } catch (e) {
      debugPrint('🔴 [JobsBloc] Error toggling bookmark: $e');
      emit(JobsError(message: 'Failed to toggle bookmark: ${e.toString()}'));
    }
  }

  /// Handle load search results
  void _onLoadSearchResults(
    LoadSearchResultsEvent event,
    Emitter<JobsState> emit,
  ) {
    try {
      final queryLower = event.searchQuery.toLowerCase();
      final filteredJobs = JobData.recommendedJobs.where((job) {
        return queryLower.isEmpty ||
            job['title'].toString().toLowerCase().contains(queryLower) ||
            job['company'].toString().toLowerCase().contains(queryLower) ||
            job['location'].toString().toLowerCase().contains(queryLower);
      }).toList();

      emit(
        SearchResultsLoaded(
          searchQuery: event.searchQuery,
          filteredJobs: filteredJobs,
        ),
      );
    } catch (e) {
      emit(
        JobsError(message: 'Failed to load search results: ${e.toString()}'),
      );
    }
  }

  /// Handle load application tracker
  Future<void> _onLoadApplicationTracker(
    LoadApplicationTrackerEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      // Check if we have cached tracker data in current state
      List<Map<String, dynamic>>? cachedApplied;
      List<Map<String, dynamic>>? cachedInterviews;
      bool hasCachedData = false;
      
      if (state is JobsLoaded) {
        final currentState = state as JobsLoaded;
        if (currentState.trackerAppliedJobs != null && 
            currentState.trackerInterviewJobs != null &&
            (currentState.trackerAppliedJobs!.isNotEmpty || 
             currentState.trackerInterviewJobs!.isNotEmpty)) {
          cachedApplied = currentState.trackerAppliedJobs;
          cachedInterviews = currentState.trackerInterviewJobs;
          hasCachedData = true;
        }
      } else if (state is ApplicationTrackerLoaded) {
        final currentState = state as ApplicationTrackerLoaded;
        if (currentState.appliedJobs.isNotEmpty || 
            currentState.interviewJobs.isNotEmpty) {
          cachedApplied = currentState.appliedJobs;
          cachedInterviews = currentState.interviewJobs;
          hasCachedData = true;
        }
      }
      
      // If we have cached data with actual items, emit it immediately (no loading state)
      if (hasCachedData && 
          cachedApplied != null && 
          cachedInterviews != null &&
          (cachedApplied.isNotEmpty || cachedInterviews.isNotEmpty)) {
        emit(
          ApplicationTrackerLoaded(
            appliedJobs: List.from(cachedApplied),
            interviewJobs: List.from(cachedInterviews),
            offerJobs: const [],
          ),
        );
      } else {
        // Emit loading state for first load or when cache is empty
        emit(const JobsLoading());
      }

      // Store reference to current JobsLoaded state BEFORE making API call
      // We need to capture it now because state might change during async operations
      JobsLoaded? jobsLoadedStateSnapshot;
      final currentStateBeforeApi = state;
      if (currentStateBeforeApi is JobsLoaded) {
        jobsLoadedStateSnapshot = currentStateBeforeApi;
      }
      
      final applications = await _apiService.getStudentAppliedJobs();

      final appliedJobs = <Map<String, dynamic>>[];
      final interviewJobs = <Map<String, dynamic>>[];
      final offerJobs = <Map<String, dynamic>>[];

      // Process applied jobs (for Applied tab)
      for (final application in applications) {
        final normalized = _normalizeApplicationForTracker(application);
        final statusKey =
            normalized.remove('raw_status')?.toString().toLowerCase() ?? '';

        if (_isOfferStatus(statusKey)) {
          offerJobs.add(normalized);
        } else {
          appliedJobs.add(normalized);
        }
      }

      // Fetch interviews separately for Shortlisted tab (ONLY from interview API)
      final interviewsRepo = _interviewsRepository;
      if (interviewsRepo != null) {
        try {
          debugPrint('🔵 [Jobs] Fetching interviews for Shortlisted tab...');
          final interviewsResponse = await interviewsRepo.getInterviews();
          if (interviewsResponse.status) {
            for (final interview in interviewsResponse.data) {
              // Convert interview to map format for UI
              final interviewMap = interview.toMap();

              // Add status as "Shortlisted" for all interviews
              interviewMap['status'] = 'Shortlisted';

              // Ensure all required fields are present
              interviewMap['title'] = interview.jobTitle;
              interviewMap['company_name'] = interview.companyName;
              interviewMap['company'] = interview.companyName;

              debugPrint(
                '🔵 [Jobs] ✅ Added interview to Shortlisted tab - interview_id: ${interview.interviewId}, job_title: ${interview.jobTitle}',
              );

              interviewJobs.add(interviewMap);
            }
            debugPrint(
              '🔵 [Jobs] Loaded ${interviewJobs.length} interviews for Shortlisted tab',
            );
          } else {
            debugPrint('🔴 [Jobs] Interviews API returned status: false');
          }
        } catch (e) {
          debugPrint('🔴 [Jobs] Failed to fetch interviews: $e');
          // Continue without interview data
        }
      } else {
        debugPrint(
          '🔴 [Jobs] InterviewsRepository is null, cannot fetch interviews',
        );
      }

      // First emit ApplicationTrackerLoaded for immediate UI update
      emit(
        ApplicationTrackerLoaded(
          appliedJobs: appliedJobs,
          interviewJobs: interviewJobs,
          offerJobs: offerJobs,
        ),
      );
      
      // CRITICAL: Store tracker data back in JobsLoaded state for persistence
      // This ensures cache is available on next visit
      if (jobsLoadedStateSnapshot != null) {
        // Restore the JobsLoaded state with updated tracker data
        // Using addPostFrameCallback to ensure ApplicationTrackerLoaded is processed first
        await Future.delayed(const Duration(milliseconds: 100));
        if (!emit.isDone) {
          emit(
            jobsLoadedStateSnapshot.copyWith(
              trackerAppliedJobs: appliedJobs,
              trackerInterviewJobs: interviewJobs,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('🔴 [Jobs] Failed to load application tracker: $e');
      emit(
        JobsError(
          message: e.toString().startsWith('Exception: ')
              ? e.toString().substring('Exception: '.length)
              : 'Failed to load application tracker: ${e.toString()}',
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

  Map<String, dynamic> _normalizeApplicationForTracker(
    Map<String, dynamic> application,
  ) {
    final statusRaw = application['status']?.toString().toLowerCase() ?? '';
    final statusLabel = _mapApplicationStatusLabel(statusRaw);
    final jobType = application['job_type']?.toString() ?? '';
    final salaryText = _formatSalaryRange(
      application['salary_min'],
      application['salary_max'],
    );
    final appliedDate = _formatApplicationDate(
      application['applied_at']?.toString(),
    );
    final applicationId = application['application_id']?.toString() ?? '';
    final jobId = application['job_id']?.toString() ?? '';

    // Extract company name - prioritize company_name from API response
    String companyName = 'Company';
    final companyNameValue = application['company_name'];
    if (companyNameValue != null) {
      final companyNameStr = companyNameValue.toString().trim();
      if (companyNameStr.isNotEmpty) {
        companyName = companyNameStr;
      }
    }
    if (companyName == 'Company') {
      final companyValue = application['company'];
      if (companyValue != null) {
        final companyStr = companyValue.toString().trim();
        if (companyStr.isNotEmpty) {
          companyName = companyStr;
        }
      }
    }

    // Extract location from API response
    final locationValue = application['location'];
    final location =
        (locationValue != null && locationValue.toString().trim().isNotEmpty)
        ? locationValue.toString().trim()
        : 'Location';

    // Extract experience - if not available, format from job_type or default to Fresher
    final experienceRequired =
        application['experience_required']?.toString() ?? '';
    String experienceDisplay = 'Fresher';
    if (experienceRequired.isNotEmpty) {
      experienceDisplay = experienceRequired;
    } else if (jobType.isNotEmpty) {
      experienceDisplay = _formatJobType(jobType) ?? 'Fresher';
    }

    // Extract deadline if available (may not be in API response)
    final deadline = _formatApplicationDate(
      application['application_deadline']?.toString(),
    );

    // Handle interview-specific fields from interview API
    final scheduledAt = application['scheduled_at']?.toString() ?? '';
    final interviewMode = application['mode']?.toString() ?? '';
    final interviewLocation = application['location']?.toString() ?? '';
    final interviewStatus = application['status']?.toString() ?? '';
    final interviewId = application['interview_id']?.toString() ?? '';

    // Format interview date/time if available
    String formattedInterviewDate = '';
    String formattedInterviewTime = '';
    if (scheduledAt.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(scheduledAt);
        formattedInterviewDate = _formatApplicationDate(scheduledAt);
        final hour = dateTime.hour;
        final minute = dateTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        formattedInterviewTime = '$displayHour:$minute $period';
      } catch (e) {
        formattedInterviewDate = scheduledAt;
      }
    }

    return <String, dynamic>{
      'id': applicationId.isNotEmpty ? applicationId : interviewId,
      'application_id': applicationId,
      'interview_id': interviewId,
      'job_id': jobId,
      'title': (application['job_title']?.toString() ?? 'Job Title').trim(),
      'company_name': companyName,
      'company': companyName,
      'location': interviewLocation.isNotEmpty
          ? interviewLocation.trim()
          : location,
      'experience': experienceDisplay,
      'type': _formatJobType(jobType) ?? 'Full-time',
      'skills': experienceRequired.isNotEmpty
          ? 'Experience: $experienceRequired'
          : (_formatJobType(jobType) ?? 'Full-time'),
      'appliedDate': appliedDate,
      'applied_at': application['applied_at']?.toString() ?? '',
      'interviewDate': formattedInterviewDate.isNotEmpty
          ? formattedInterviewDate
          : appliedDate,
      'interviewTime': formattedInterviewTime,
      'scheduled_at': scheduledAt,
      'mode': interviewMode,
      'interviewStatus': interviewStatus.isNotEmpty
          ? interviewStatus
          : statusRaw,
      'positions': deadline.isNotEmpty && deadline != 'Recently'
          ? 'Deadline: $deadline'
          : (jobId.isNotEmpty
                ? 'Job ID: $jobId'
                : 'Application ID: #$applicationId'),
      'status': statusLabel,
      'salary': salaryText,
      'salary_min': application['salary_min']?.toString() ?? '',
      'salary_max': application['salary_max']?.toString() ?? '',
      'job_type': jobType,
      'raw_status': statusRaw,
    };
  }

  String _mapApplicationStatusLabel(String status) {
    switch (status) {
      case 'applied':
        return 'Applied';
      case 'shortlisted':
      case 'interview':
      case 'interview_scheduled':
      case 'interview scheduled':
        return 'Shortlisted';
      case 'offer':
      case 'offer_received':
      case 'offer accepted':
      case 'hired':
      case 'selected':
        return 'Offer Received';
      default:
        if (status.isEmpty) return 'Applied';
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  bool _isOfferStatus(String status) {
    return status == 'offer' ||
        status == 'offer_received' ||
        status == 'offer accepted' ||
        status == 'hired' ||
        status == 'selected';
  }

  String _formatApplicationDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Recently';
    }

    try {
      final date = DateTime.parse(dateString);
      final day = date.day.toString().padLeft(2, '0');
      final month = _monthNames[date.month - 1];
      final year = date.year.toString();
      return '$day $month $year';
    } catch (_) {
      return dateString;
    }
  }

  String _formatSalaryRange(dynamic minValue, dynamic maxValue) {
    final double? min = _toDouble(minValue);
    final double? max = _toDouble(maxValue);

    if (min == null && max == null) {
      return 'Salary not disclosed';
    }

    String formatValue(double value) {
      if (value >= 100000) {
        return '₹${(value / 100000).toStringAsFixed(1)}L';
      }
      if (value >= 1000) {
        return '₹${(value / 1000).toStringAsFixed(1)}K';
      }
      return '₹${value.toStringAsFixed(0)}';
    }

    if (min != null && max != null) {
      return '${formatValue(min)} - ${formatValue(max)}';
    }

    final single = min ?? max!;
    return formatValue(single);
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  String? _formatJobType(String? jobType) {
    if (jobType == null || jobType.isEmpty) return null;
    final normalized = jobType.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) return null;
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  /// Handle remove saved job
  void _onRemoveSavedJob(RemoveSavedJobEvent event, Emitter<JobsState> emit) {
    try {
      // Update saved jobs list - remove the job from the list
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
  Future<void> _onLoadJobApplicationForm(
    LoadJobApplicationFormEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      final fallbackUser = UserData.currentUser;
      final formData = <String, String>{
        'name': fallbackUser['name']?.toString() ?? '',
        'email': fallbackUser['email']?.toString() ?? '',
        'phone': fallbackUser['phone']?.toString() ?? '',
      };
      PlatformFile? resumeFile;

      try {
        final profileResponse = await _apiService.getStudentProfile();
        final profiles = profileResponse.data.profiles;

        if (profiles.isNotEmpty) {
          StudentProfile selectedProfile = profiles.first;
          final fallbackId = fallbackUser['id']?.toString();
          if (fallbackId != null && fallbackId.isNotEmpty) {
            final matchingProfile = profiles.firstWhere(
              (profile) => profile.userId.toString() == fallbackId,
              orElse: () => selectedProfile,
            );
            selectedProfile = matchingProfile;
          }

          final personalInfo = selectedProfile.personalInfo;
          if (personalInfo.userName.isNotEmpty) {
            formData['name'] = personalInfo.userName;
          }
          if (personalInfo.email.isNotEmpty) {
            formData['email'] = personalInfo.email;
          }
          if (personalInfo.phoneNumber.isNotEmpty) {
            formData['phone'] = personalInfo.phoneNumber;
          }

          final resumePath = selectedProfile.documents.resume;
          if (resumePath.isNotEmpty) {
            final resumeName = resumePath.split('/').last;
            resumeFile = PlatformFile(
              name: resumeName,
              size: 0,
              path: resumePath,
            );
          }
        }
      } catch (e) {
        debugPrint('⚠️ [Jobs] Failed to load profile for job application: $e');
      }

      emit(
        JobApplicationFormLoaded(
          job: event.job,
          formData: formData,
          resumeFile: resumeFile,
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
      _handleJobsError(e, emit, defaultMessage: 'Failed to submit review');
    }
  }

  /// Helper method to handle errors and emit appropriate error state
  /// Detects network errors and formats messages accordingly
  void _handleJobsError(
    dynamic error,
    Emitter<JobsState> emit, {
    String? defaultMessage,
  }) {
    final errorMessage = NetworkErrorHelper.isNetworkError(error)
        ? NetworkErrorHelper.getNetworkErrorMessage(error)
        : NetworkErrorHelper.extractErrorMessage(
            error,
            defaultMessage: defaultMessage,
          );

    emit(JobsError(message: errorMessage));
  }
}
