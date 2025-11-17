import 'package:equatable/equatable.dart';

/// Feedback events
abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();
}

/// Submit feedback event
class SubmitFeedbackEvent extends FeedbackEvent {
  final String feedback;
  final String? subject;

  const SubmitFeedbackEvent({
    required this.feedback,
    this.subject,
  });

  @override
  List<Object?> get props => [feedback, subject];
}

/// Clear feedback form event
class ClearFeedbackFormEvent extends FeedbackEvent {
  const ClearFeedbackFormEvent();

  @override
  List<Object?> get props => [];
}

/// Clear feedback error event
class ClearFeedbackErrorEvent extends FeedbackEvent {
  const ClearFeedbackErrorEvent();

  @override
  List<Object?> get props => [];
}

