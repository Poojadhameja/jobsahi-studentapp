import 'package:equatable/equatable.dart';

/// Feedback states
abstract class FeedbackState extends Equatable {
  const FeedbackState();
}

/// Initial feedback state
class FeedbackInitial extends FeedbackState {
  const FeedbackInitial();

  @override
  List<Object?> get props => [];
}

/// Feedback submitting state
class FeedbackSubmitting extends FeedbackState {
  const FeedbackSubmitting();

  @override
  List<Object?> get props => [];
}

/// Feedback submitted successfully state
class FeedbackSubmittedSuccess extends FeedbackState {
  final String message;
  final int? feedbackId;

  const FeedbackSubmittedSuccess({
    required this.message,
    this.feedbackId,
  });

  @override
  List<Object?> get props => [message, feedbackId];
}

/// Feedback error state
class FeedbackError extends FeedbackState {
  final String message;
  final bool isRateLimitError;
  final String? messageEn;
  final int? submissionsInWindow;
  final String? windowStartDate;
  final String? resetDate;
  final int? remainingDays;

  const FeedbackError({
    required this.message,
    this.isRateLimitError = false,
    this.messageEn,
    this.submissionsInWindow,
    this.windowStartDate,
    this.resetDate,
    this.remainingDays,
  });

  @override
  List<Object?> get props => [
        message,
        isRateLimitError,
        messageEn,
        submissionsInWindow,
        windowStartDate,
        resetDate,
        remainingDays,
      ];
}

