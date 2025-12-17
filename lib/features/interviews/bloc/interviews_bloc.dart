import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'interviews_event.dart';
import 'interviews_state.dart';
import '../repositories/interviews_repository.dart';

/// Interviews BLoC
/// Handles all interview-related business logic
class InterviewsBloc extends Bloc<InterviewsEvent, InterviewsState> {
  final InterviewsRepository _interviewsRepository;

  InterviewsBloc({InterviewsRepository? interviewsRepository})
    : _interviewsRepository =
          interviewsRepository ?? _createDefaultRepository(),
      super(const InterviewsInitial()) {
    // Register event handlers
    on<LoadInterviewsEvent>(_onLoadInterviews);
    on<RefreshInterviewsEvent>(_onRefreshInterviews);
    on<LoadInterviewDetailEvent>(_onLoadInterviewDetail);
  }

  /// Create default repository instance
  static InterviewsRepository _createDefaultRepository() {
    // This will be injected via dependency injection
    throw UnimplementedError(
      'InterviewsRepository must be provided via dependency injection',
    );
  }

  /// Handle load interviews
  Future<void> _onLoadInterviews(
    LoadInterviewsEvent event,
    Emitter<InterviewsState> emit,
  ) async {
    try {
      emit(const InterviewsLoading());

      debugPrint('🔵 [InterviewsBloc] Loading interviews...');
      debugPrint('🔵 Status filter: ${event.status}');
      debugPrint('🔵 Type filter: ${event.type}');

      // Call the repository to fetch interviews via API
      final interviewsResponse = await _interviewsRepository.getInterviews(
        status: event.status,
        type: event.type,
      );

      if (interviewsResponse.status) {
        // Convert Interview objects to Map format for UI compatibility
        final interviews = interviewsResponse.data
            .map((interview) => interview.toMap())
            .toList();

        debugPrint(
          '✅ [InterviewsBloc] Loaded ${interviews.length} interviews successfully',
        );

        emit(InterviewsLoaded(interviews: interviews));
      } else {
        debugPrint(
          '🔴 [InterviewsBloc] Failed to load interviews: ${interviewsResponse.message}',
        );
        emit(
          InterviewsError(
            message: interviewsResponse.message.isNotEmpty
                ? interviewsResponse.message
                : 'Failed to load interviews',
          ),
        );
      }
    } catch (e) {
      debugPrint('🔴 [InterviewsBloc] Error loading interviews: $e');

      // Check if it's an authentication error
      final errorMessage = e.toString();
      if (errorMessage.contains('User must be logged in') ||
          errorMessage.contains('Unauthorized') ||
          errorMessage.contains('No token provided')) {
        debugPrint(
          'ℹ️ [InterviewsBloc] User not authenticated, showing empty state',
        );
        // Show empty state when user is not authenticated
        emit(const InterviewsLoaded(interviews: []));
      } else {
        emit(
          InterviewsError(
            message: e.toString().startsWith('Exception: ')
                ? e.toString().substring('Exception: '.length)
                : 'Failed to load interviews: ${e.toString()}',
          ),
        );
      }
    }
  }

  /// Handle refresh interviews
  Future<void> _onRefreshInterviews(
    RefreshInterviewsEvent event,
    Emitter<InterviewsState> emit,
  ) async {
    // Reload interviews with same filters
    add(LoadInterviewsEvent(status: event.status, type: event.type));
  }

  /// Handle load interview detail
  Future<void> _onLoadInterviewDetail(
    LoadInterviewDetailEvent event,
    Emitter<InterviewsState> emit,
  ) async {
    try {
      emit(const InterviewDetailLoading());

      debugPrint(
        '🔵 [InterviewsBloc] Loading interview detail for ID: ${event.interviewId}',
      );

      final interviewDetailResponse = await _interviewsRepository
          .getInterviewDetail(event.interviewId);

      if (interviewDetailResponse.status) {
        // Convert InterviewDetail to Map format for UI compatibility
        // Use the raw JSON data from API response for better compatibility
        final responseData = interviewDetailResponse.data;
        final interviewDetailMap = {
          'interview_id': responseData.interviewId,
          'application_id': responseData.applicationId,
          'scheduled_at': responseData.scheduledAt,
          'mode': responseData.mode,
          'interview_location': responseData.interviewLocation,
          'interview_status': responseData.interviewStatus,
          'interview_info': responseData.interviewInfo,
          'platform_name': responseData.platformName,
          'interview_link': responseData.interviewLink,
          'interview_created_at': responseData.interviewCreatedAt,
          'admin_action': responseData.adminAction,
          'panel': responseData.panel
              .map(
                (p) => {
                  'id': p.id,
                  'panelist_name': p.panelistName,
                  'feedback': p.feedback,
                  'rating': p.rating,
                },
              )
              .toList(),
          'application': {
            'id': responseData.application.id,
            'student_id': responseData.application.studentId,
            'status': responseData.application.status,
            'applied_at': responseData.application.appliedAt,
            'cover_letter': responseData.application.coverLetter,
          },
          'job': {
            'id': responseData.job.id,
            'title': responseData.job.title,
            'description': responseData.job.description,
            'location': responseData.job.location,
            'job_type': responseData.job.jobType,
            'salary_min': responseData.job.salaryMin,
            'salary_max': responseData.job.salaryMax,
            'experience_required': responseData.job.experienceRequired,
            'skills_required': responseData.job.skillsRequired,
            'application_deadline': responseData.job.applicationDeadline,
            'is_remote': responseData.job.isRemote,
            'no_of_vacancies': responseData.job.noOfVacancies,
          },
          'company': {
            'id': responseData.company.id,
            'company_name': responseData.company.companyName,
            'company_address': responseData.company.companyAddress,
            'company_logo': responseData.company.companyLogo,
          },
        };

        debugPrint('✅ [InterviewsBloc] Interview detail loaded successfully');

        emit(InterviewDetailLoaded(interviewDetail: interviewDetailMap));
      } else {
        debugPrint(
          '🔴 [InterviewsBloc] Failed to load interview detail: ${interviewDetailResponse.message}',
        );
        emit(
          InterviewDetailError(
            message: interviewDetailResponse.message.isNotEmpty
                ? interviewDetailResponse.message
                : 'Failed to load interview detail',
          ),
        );
      }
    } catch (e) {
      debugPrint('🔴 [InterviewsBloc] Error loading interview detail: $e');

      emit(
        InterviewDetailError(
          message: e.toString().startsWith('Exception: ')
              ? e.toString().substring('Exception: '.length)
              : 'Failed to load interview detail: ${e.toString()}',
        ),
      );
    }
  }
}
