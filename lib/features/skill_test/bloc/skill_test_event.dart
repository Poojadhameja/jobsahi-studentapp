import 'package:equatable/equatable.dart';

/// Skill Test events
abstract class SkillTestEvent extends Equatable {
  const SkillTestEvent();
}

/// Load skill tests event
class LoadSkillTestsEvent extends SkillTestEvent {
  const LoadSkillTestsEvent();

  @override
  List<Object?> get props => [];
}

/// Start test event
class StartTestEvent extends SkillTestEvent {
  final String testId;

  const StartTestEvent({required this.testId});

  @override
  List<Object?> get props => [testId];
}

/// Submit answer event
class SubmitAnswerEvent extends SkillTestEvent {
  final String questionId;
  final String answer;
  final int timeSpent; // in seconds

  const SubmitAnswerEvent({
    required this.questionId,
    required this.answer,
    required this.timeSpent,
  });

  @override
  List<Object?> get props => [questionId, answer, timeSpent];
}

/// Submit test event
class SubmitTestEvent extends SkillTestEvent {
  final String testId;
  final Map<String, String> answers;
  final int totalTimeSpent; // in seconds

  const SubmitTestEvent({
    required this.testId,
    required this.answers,
    required this.totalTimeSpent,
  });

  @override
  List<Object?> get props => [testId, answers, totalTimeSpent];
}

/// Load test results event
class LoadTestResultsEvent extends SkillTestEvent {
  final String testId;

  const LoadTestResultsEvent({required this.testId});

  @override
  List<Object?> get props => [testId];
}

/// Load user test history event
class LoadUserTestHistoryEvent extends SkillTestEvent {
  const LoadUserTestHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Retake test event
class RetakeTestEvent extends SkillTestEvent {
  final String testId;

  const RetakeTestEvent({required this.testId});

  @override
  List<Object?> get props => [testId];
}

/// Pause test event
class PauseTestEvent extends SkillTestEvent {
  const PauseTestEvent();

  @override
  List<Object?> get props => [];
}

/// Resume test event
class ResumeTestEvent extends SkillTestEvent {
  const ResumeTestEvent();

  @override
  List<Object?> get props => [];
}

/// End test event
class EndTestEvent extends SkillTestEvent {
  const EndTestEvent();

  @override
  List<Object?> get props => [];
}

/// Refresh skill tests event
class RefreshSkillTestsEvent extends SkillTestEvent {
  const RefreshSkillTestsEvent();

  @override
  List<Object?> get props => [];
}

/// Load skill test details event
class LoadSkillTestDetailsEvent extends SkillTestEvent {
  final Map<String, dynamic> job;

  const LoadSkillTestDetailsEvent({required this.job});

  @override
  List<Object?> get props => [job];
}

/// Toggle test bookmark event
class ToggleTestBookmarkEvent extends SkillTestEvent {
  final String testId;

  const ToggleTestBookmarkEvent({required this.testId});

  @override
  List<Object?> get props => [testId];
}

/// View test instructions event
class ViewTestInstructionsEvent extends SkillTestEvent {
  final String testId;

  const ViewTestInstructionsEvent({required this.testId});

  @override
  List<Object?> get props => [testId];
}

/// View test FAQ event
class ViewTestFAQEvent extends SkillTestEvent {
  final String testId;

  const ViewTestFAQEvent({required this.testId});

  @override
  List<Object?> get props => [testId];
}
