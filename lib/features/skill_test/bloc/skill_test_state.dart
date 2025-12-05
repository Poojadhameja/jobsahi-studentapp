import 'package:equatable/equatable.dart';

/// Skill Test states
abstract class SkillTestState extends Equatable {
  const SkillTestState();
}

/// Initial skill test state
class SkillTestInitial extends SkillTestState {
  const SkillTestInitial();

  @override
  List<Object?> get props => [];
}

/// Skill test loading state
class SkillTestLoading extends SkillTestState {
  const SkillTestLoading();

  @override
  List<Object?> get props => [];
}

/// Skill tests loaded state
class SkillTestsLoaded extends SkillTestState {
  final List<Map<String, dynamic>> availableTests;
  final List<Map<String, dynamic>> userTestHistory;

  const SkillTestsLoaded({
    required this.availableTests,
    required this.userTestHistory,
  });

  @override
  List<Object?> get props => [availableTests, userTestHistory];
}

/// Test started state
class TestStartedState extends SkillTestState {
  final String testId;
  final List<Map<String, dynamic>> questions;
  final int totalQuestions;
  final int timeLimit; // in minutes
  final DateTime startTime;

  const TestStartedState({
    required this.testId,
    required this.questions,
    required this.totalQuestions,
    required this.timeLimit,
    required this.startTime,
  });

  @override
  List<Object?> get props => [
    testId,
    questions,
    totalQuestions,
    timeLimit,
    startTime,
  ];
}

/// Test in progress state
class TestInProgressState extends SkillTestState {
  final String testId;
  final List<Map<String, dynamic>> questions;
  final int currentQuestionIndex;
  final Map<String, String> answers;
  final int timeRemaining; // in seconds
  final DateTime startTime;

  const TestInProgressState({
    required this.testId,
    required this.questions,
    required this.currentQuestionIndex,
    required this.answers,
    required this.timeRemaining,
    required this.startTime,
  });

  @override
  List<Object?> get props => [
    testId,
    questions,
    currentQuestionIndex,
    answers,
    timeRemaining,
    startTime,
  ];

  /// Copy with method for immutable state updates
  TestInProgressState copyWith({
    String? testId,
    List<Map<String, dynamic>>? questions,
    int? currentQuestionIndex,
    Map<String, String>? answers,
    int? timeRemaining,
    DateTime? startTime,
  }) {
    return TestInProgressState(
      testId: testId ?? this.testId,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      startTime: startTime ?? this.startTime,
    );
  }
}

/// Test paused state
class TestPausedState extends SkillTestState {
  final String testId;
  final int currentQuestionIndex;
  final Map<String, String> answers;
  final int timeRemaining;

  const TestPausedState({
    required this.testId,
    required this.currentQuestionIndex,
    required this.answers,
    required this.timeRemaining,
  });

  @override
  List<Object?> get props => [
    testId,
    currentQuestionIndex,
    answers,
    timeRemaining,
  ];
}

/// Test submitted state
class TestSubmittedState extends SkillTestState {
  final String testId;
  final Map<String, String> answers;
  final int totalTimeSpent;

  const TestSubmittedState({
    required this.testId,
    required this.answers,
    required this.totalTimeSpent,
  });

  @override
  List<Object?> get props => [testId, answers, totalTimeSpent];
}

/// Test results loaded state
class TestResultsLoadedState extends SkillTestState {
  final String testId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeSpent; // in seconds
  final String grade;
  final List<Map<String, dynamic>> detailedResults;
  final DateTime completedAt;
  final int attemptedQuestions; // actual number of questions answered

  const TestResultsLoadedState({
    required this.testId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeSpent,
    required this.grade,
    required this.detailedResults,
    required this.completedAt,
    required this.attemptedQuestions,
  });

  @override
  List<Object?> get props => [
    testId,
    score,
    totalQuestions,
    correctAnswers,
    wrongAnswers,
    timeSpent,
    grade,
    detailedResults,
    completedAt,
    attemptedQuestions,
  ];
}

/// Skill test error state
class SkillTestError extends SkillTestState {
  final String message;

  const SkillTestError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Answer submitted state
class AnswerSubmittedState extends SkillTestState {
  final String questionId;
  final String answer;

  const AnswerSubmittedState({required this.questionId, required this.answer});

  @override
  List<Object?> get props => [questionId, answer];
}

/// Test ended state
class TestEndedState extends SkillTestState {
  final String testId;
  final String reason; // 'completed', 'timeout', 'abandoned'

  const TestEndedState({required this.testId, required this.reason});

  @override
  List<Object?> get props => [testId, reason];
}

/// Skill test details loaded state
class SkillTestDetailsLoaded extends SkillTestState {
  final Map<String, dynamic> job;
  final Map<String, dynamic> skillTest;
  final bool isBookmarked;

  const SkillTestDetailsLoaded({
    required this.job,
    required this.skillTest,
    required this.isBookmarked,
  });

  @override
  List<Object?> get props => [job, skillTest, isBookmarked];

  SkillTestDetailsLoaded copyWith({
    Map<String, dynamic>? job,
    Map<String, dynamic>? skillTest,
    bool? isBookmarked,
  }) {
    return SkillTestDetailsLoaded(
      job: job ?? this.job,
      skillTest: skillTest ?? this.skillTest,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

/// Test bookmark toggled state
class TestBookmarkToggled extends SkillTestState {
  final String testId;
  final bool isBookmarked;

  const TestBookmarkToggled({required this.testId, required this.isBookmarked});

  @override
  List<Object?> get props => [testId, isBookmarked];
}

/// Navigate to instructions state
class NavigateToInstructionsState extends SkillTestState {
  final String testId;

  const NavigateToInstructionsState({required this.testId});

  @override
  List<Object?> get props => [testId];
}

/// Navigate to FAQ state
class NavigateToFAQState extends SkillTestState {
  final String testId;

  const NavigateToFAQState({required this.testId});

  @override
  List<Object?> get props => [testId];
}
