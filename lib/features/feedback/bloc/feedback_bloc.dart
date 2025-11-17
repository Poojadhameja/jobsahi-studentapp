import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'feedback_event.dart';
import 'feedback_state.dart';
import '../repository/feedback_repository.dart';
import '../repository/feedback_repository.dart' as feedback_repo;

/// Feedback BLoC
/// Handles all feedback-related business logic
class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackRepository _feedbackRepository;

  FeedbackBloc({required FeedbackRepository feedbackRepository})
      : _feedbackRepository = feedbackRepository,
        super(const FeedbackInitial()) {
    // Register event handlers
    on<SubmitFeedbackEvent>(_onSubmitFeedback);
    on<ClearFeedbackFormEvent>(_onClearFeedbackForm);
    on<ClearFeedbackErrorEvent>(_onClearFeedbackError);
  }

  /// Handle submit feedback
  Future<void> _onSubmitFeedback(
    SubmitFeedbackEvent event,
    Emitter<FeedbackState> emit,
  ) async {
    try {
      // Validate subject
      if (event.subject == null || event.subject!.trim().isEmpty) {
        emit(const FeedbackError(
          message: 'Subject is required',
        ));
        return;
      }

      // Validate subject minimum length
      if (event.subject!.trim().length < 5) {
        emit(const FeedbackError(
          message: 'Subject must be at least 5 characters long',
        ));
        return;
      }

      // Validate feedback
      if (event.feedback.trim().isEmpty) {
        emit(const FeedbackError(
          message: 'Feedback text is required',
        ));
        return;
      }

      // Validate feedback minimum length
      if (event.feedback.trim().length < 15) {
        emit(const FeedbackError(
          message: 'Feedback must be at least 15 characters long',
        ));
        return;
      }

      emit(const FeedbackSubmitting());

      debugPrint('🔵 Submitting feedback: ${event.feedback}');

      final response = await _feedbackRepository.submitFeedback(
        feedback: event.feedback.trim(),
        subject: event.subject?.trim() ?? '',
      );

      debugPrint('✅ Feedback submitted successfully: ${response.message}');

      emit(
        FeedbackSubmittedSuccess(
          message: response.message,
          feedbackId: response.feedbackId,
        ),
      );
    } on feedback_repo.RateLimitException catch (e) {
      debugPrint('🔴 Rate limit error: ${e.message}');
      emit(
        FeedbackError(
          message: e.message,
          isRateLimitError: true,
          messageEn: e.messageEn,
          submissionsInWindow: e.submissionsInWindow,
          windowStartDate: e.windowStartDate,
          resetDate: e.resetDate,
          remainingDays: e.remainingDays,
        ),
      );
    } catch (e) {
      debugPrint('🔴 Error submitting feedback: $e');
      String errorMessage = 'Failed to submit feedback. Please try again.';

      // Extract error message from exception
      if (e.toString().contains('Bad request:')) {
        errorMessage = e.toString().replaceFirst('Exception: Bad request: ', '');
      } else if (e.toString().contains('Unauthorized:')) {
        errorMessage = 'Session expired. Please login again.';
      } else if (e.toString().contains('Not found:')) {
        errorMessage = e.toString().replaceFirst('Exception: Not found: ', '');
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }

      emit(FeedbackError(message: errorMessage));
    }
  }

  /// Handle clear feedback form
  void _onClearFeedbackForm(
    ClearFeedbackFormEvent event,
    Emitter<FeedbackState> emit,
  ) {
    emit(const FeedbackInitial());
  }

  /// Handle clear feedback error
  void _onClearFeedbackError(
    ClearFeedbackErrorEvent event,
    Emitter<FeedbackState> emit,
  ) {
    if (state is FeedbackError) {
      emit(const FeedbackInitial());
    }
  }
}

