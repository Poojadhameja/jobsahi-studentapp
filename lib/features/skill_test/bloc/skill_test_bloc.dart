import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'skill_test_event.dart';
import 'skill_test_state.dart';
import '../../../shared/data/user_data.dart';

/// Skill Test BLoC
/// Handles all skill test-related business logic
class SkillTestBloc extends Bloc<SkillTestEvent, SkillTestState> {
  SkillTestBloc() : super(const SkillTestInitial()) {
    // Register event handlers
    on<LoadSkillTestsEvent>(_onLoadSkillTests);
    on<StartTestEvent>(_onStartTest);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<SubmitTestEvent>(_onSubmitTest);
    on<LoadTestResultsEvent>(_onLoadTestResults);
    on<LoadUserTestHistoryEvent>(_onLoadUserTestHistory);
    on<RetakeTestEvent>(_onRetakeTest);
    on<PauseTestEvent>(_onPauseTest);
    on<ResumeTestEvent>(_onResumeTest);
    on<EndTestEvent>(_onEndTest);
    on<RefreshSkillTestsEvent>(_onRefreshSkillTests);
    on<LoadSkillTestDetailsEvent>(_onLoadSkillTestDetails);
    on<ToggleTestBookmarkEvent>(_onToggleTestBookmark);
    on<ViewTestInstructionsEvent>(_onViewTestInstructions);
    on<ViewTestFAQEvent>(_onViewTestFAQ);
  }

  /// Handle load skill tests
  Future<void> _onLoadSkillTests(
    LoadSkillTestsEvent event,
    Emitter<SkillTestState> emit,
  ) async {
    try {
      emit(const SkillTestLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Load available tests and user test history
      final availableTests = UserData.availableSkillTests;
      final userTestHistory = UserData.userTestHistory;

      emit(
        SkillTestsLoaded(
          availableTests: availableTests,
          userTestHistory: userTestHistory,
        ),
      );
    } catch (e) {
      emit(
        SkillTestError(message: 'Failed to load skill tests: ${e.toString()}'),
      );
    }
  }

  /// Handle start test
  Future<void> _onStartTest(
    StartTestEvent event,
    Emitter<SkillTestState> emit,
  ) async {
    try {
      emit(const SkillTestLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Load test questions (mock data)
      final questions = [
        {
          'id': 'q1',
          'question': 'What is the primary purpose of a circuit breaker?',
          'options': [
            'To control voltage',
            'To protect circuits from overload',
            'To increase current flow',
            'To store electrical energy',
          ],
          'correctAnswer': 'To protect circuits from overload',
          'explanation':
              'Circuit breakers are designed to automatically interrupt electrical flow when a fault is detected.',
        },
        {
          'id': 'q2',
          'question': 'Which tool is essential for electrical safety?',
          'options': [
            'Screwdriver',
            'Multimeter',
            'Insulated gloves',
            'Wire stripper',
          ],
          'correctAnswer': 'Insulated gloves',
          'explanation':
              'Insulated gloves provide protection against electrical shock.',
        },
        {
          'id': 'q3',
          'question': 'What does AC stand for in electrical terms?',
          'options': [
            'Alternating Current',
            'Automatic Control',
            'Advanced Circuit',
            'Ampere Current',
          ],
          'correctAnswer': 'Alternating Current',
          'explanation':
              'AC refers to Alternating Current, where the direction of current flow changes periodically.',
        },
      ];

      final timeLimit = 15; // 15 minutes
      final startTime = DateTime.now();

      emit(
        TestStartedState(
          testId: event.testId,
          questions: questions,
          totalQuestions: questions.length,
          timeLimit: timeLimit,
          startTime: startTime,
        ),
      );

      // Start the test in progress
      emit(
        TestInProgressState(
          testId: event.testId,
          questions: questions,
          currentQuestionIndex: 0,
          answers: {},
          timeRemaining: timeLimit * 60, // Convert to seconds
          startTime: startTime,
        ),
      );
    } catch (e) {
      emit(SkillTestError(message: 'Failed to start test: ${e.toString()}'));
    }
  }

  /// Handle submit answer
  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<SkillTestState> emit,
  ) async {
    try {
      if (state is TestInProgressState) {
        final currentState = state as TestInProgressState;
        final updatedAnswers = Map<String, String>.from(currentState.answers);
        updatedAnswers[event.questionId] = event.answer;

        // Calculate time remaining
        final elapsedTime = DateTime.now()
            .difference(currentState.startTime)
            .inSeconds;
        final timeRemaining = (currentState.timeRemaining - elapsedTime).clamp(
          0,
          currentState.timeRemaining,
        );

        emit(
          currentState.copyWith(
            answers: updatedAnswers,
            timeRemaining: timeRemaining,
          ),
        );

        // Emit answer submitted state
        emit(
          AnswerSubmittedState(
            questionId: event.questionId,
            answer: event.answer,
          ),
        );
      }
    } catch (e) {
      emit(SkillTestError(message: 'Failed to submit answer: ${e.toString()}'));
    }
  }

  /// Handle submit test
  Future<void> _onSubmitTest(
    SubmitTestEvent event,
    Emitter<SkillTestState> emit,
  ) async {
    try {
      emit(const SkillTestLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Calculate score and results
      final questions = [
        {'id': 'q1', 'correctAnswer': 'To protect circuits from overload'},
        {'id': 'q2', 'correctAnswer': 'Insulated gloves'},
        {'id': 'q3', 'correctAnswer': 'Alternating Current'},
      ];

      int correctAnswers = 0;
      final detailedResults = <Map<String, dynamic>>[];

      for (final question in questions) {
        final userAnswer = event.answers[question['id']];
        final isCorrect = userAnswer == question['correctAnswer'];
        if (isCorrect) correctAnswers++;

        detailedResults.add({
          'questionId': question['id'],
          'userAnswer': userAnswer,
          'correctAnswer': question['correctAnswer'],
          'isCorrect': isCorrect,
        });
      }

      final totalQuestions = questions.length;
      final wrongAnswers = totalQuestions - correctAnswers;
      final score = ((correctAnswers / totalQuestions) * 100).round();
      final grade = _calculateGrade(score);

      emit(
        TestResultsLoadedState(
          testId: event.testId,
          score: score,
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
          wrongAnswers: wrongAnswers,
          timeSpent: event.totalTimeSpent,
          grade: grade,
          detailedResults: detailedResults,
          completedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(SkillTestError(message: 'Failed to submit test: ${e.toString()}'));
    }
  }

  /// Handle load test results
  Future<void> _onLoadTestResults(
    LoadTestResultsEvent event,
    Emitter<SkillTestState> emit,
  ) async {
    try {
      emit(const SkillTestLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Load test results (mock data)
      final testResult = {
        'testId': event.testId,
        'score': 85,
        'totalQuestions': 3,
        'correctAnswers': 2,
        'wrongAnswers': 1,
        'timeSpent': 720, // 12 minutes
        'grade': 'B+',
        'detailedResults': [
          {
            'questionId': 'q1',
            'userAnswer': 'To protect circuits from overload',
            'correctAnswer': 'To protect circuits from overload',
            'isCorrect': true,
          },
          {
            'questionId': 'q2',
            'userAnswer': 'Multimeter',
            'correctAnswer': 'Insulated gloves',
            'isCorrect': false,
          },
          {
            'questionId': 'q3',
            'userAnswer': 'Alternating Current',
            'correctAnswer': 'Alternating Current',
            'isCorrect': true,
          },
        ],
        'completedAt': DateTime.now().subtract(const Duration(hours: 2)),
      };

      emit(
        TestResultsLoadedState(
          testId: testResult['testId'] as String,
          score: testResult['score'] as int,
          totalQuestions: testResult['totalQuestions'] as int,
          correctAnswers: testResult['correctAnswers'] as int,
          wrongAnswers: testResult['wrongAnswers'] as int,
          timeSpent: testResult['timeSpent'] as int,
          grade: testResult['grade'] as String,
          detailedResults:
              testResult['detailedResults'] as List<Map<String, dynamic>>,
          completedAt: testResult['completedAt'] as DateTime,
        ),
      );
    } catch (e) {
      emit(
        SkillTestError(message: 'Failed to load test results: ${e.toString()}'),
      );
    }
  }

  /// Handle load user test history
  Future<void> _onLoadUserTestHistory(
    LoadUserTestHistoryEvent event,
    Emitter<SkillTestState> emit,
  ) async {
    try {
      emit(const SkillTestLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Load user test history
      final availableTests = UserData.availableSkillTests;
      final userTestHistory = UserData.userTestHistory;

      emit(
        SkillTestsLoaded(
          availableTests: availableTests,
          userTestHistory: userTestHistory,
        ),
      );
    } catch (e) {
      emit(
        SkillTestError(message: 'Failed to load test history: ${e.toString()}'),
      );
    }
  }

  /// Handle retake test
  Future<void> _onRetakeTest(
    RetakeTestEvent event,
    Emitter<SkillTestState> emit,
  ) async {
    // Start the test again
    add(StartTestEvent(testId: event.testId));
  }

  /// Handle pause test
  Future<void> _onPauseTest(
    PauseTestEvent event,
    Emitter<SkillTestState> emit,
  ) async {
    if (state is TestInProgressState) {
      final currentState = state as TestInProgressState;
      final elapsedTime = DateTime.now()
          .difference(currentState.startTime)
          .inSeconds;
      final timeRemaining = (currentState.timeRemaining - elapsedTime).clamp(
        0,
        currentState.timeRemaining,
      );

      emit(
        TestPausedState(
          testId: currentState.testId,
          currentQuestionIndex: currentState.currentQuestionIndex,
          answers: currentState.answers,
          timeRemaining: timeRemaining,
        ),
      );
    }
  }

  /// Handle resume test
  Future<void> _onResumeTest(
    ResumeTestEvent event,
    Emitter<SkillTestState> emit,
  ) async {
    if (state is TestPausedState) {
      final currentState = state as TestPausedState;
      final startTime = DateTime.now();

      emit(
        TestInProgressState(
          testId: currentState.testId,
          questions: [], // This would be loaded from the paused state
          currentQuestionIndex: currentState.currentQuestionIndex,
          answers: currentState.answers,
          timeRemaining: currentState.timeRemaining,
          startTime: startTime,
        ),
      );
    }
  }

  /// Handle end test
  Future<void> _onEndTest(
    EndTestEvent event,
    Emitter<SkillTestState> emit,
  ) async {
    if (state is TestInProgressState) {
      final currentState = state as TestInProgressState;
      emit(TestEndedState(testId: currentState.testId, reason: 'abandoned'));
    }
  }

  /// Handle refresh skill tests
  Future<void> _onRefreshSkillTests(
    RefreshSkillTestsEvent event,
    Emitter<SkillTestState> emit,
  ) async {
    // Reload skill tests
    add(const LoadSkillTestsEvent());
  }

  /// Calculate grade based on score
  String _calculateGrade(int score) {
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B+';
    if (score >= 60) return 'B';
    if (score >= 50) return 'C+';
    if (score >= 40) return 'C';
    return 'F';
  }

  /// Handle load skill test details
  void _onLoadSkillTestDetails(
    LoadSkillTestDetailsEvent event,
    Emitter<SkillTestState> emit,
  ) {
    try {
      final jobCategory = event.job['category'] ?? 'Electrician';
      Map<String, dynamic> skillTest;

      // Return test related to the job category
      switch (jobCategory.toLowerCase()) {
        case 'electrician':
          skillTest = {
            'title': 'इलेक्ट्रीशियन स्किल टेस्ट',
            'subtitle': 'Comprehensive Test',
            'icon': Icons.electrical_services,
            'color': Colors.blue,
            'mcqs': 20,
            'time': 25,
            'passingMarks': 50,
            'attempts': 1,
            'isPrivate': true,
            'provider': 'Satpuda ITI',
          };
          break;
        case 'fitter':
          skillTest = {
            'title': 'फिटर स्किल टेस्ट',
            'subtitle': 'Comprehensive Test',
            'icon': Icons.handyman,
            'color': Colors.green,
            'mcqs': 18,
            'time': 20,
            'passingMarks': 50,
            'attempts': 1,
            'isPrivate': true,
            'provider': 'Satpuda ITI',
          };
          break;
        default:
          skillTest = {
            'title': 'सामान्य स्किल टेस्ट',
            'subtitle': 'General Test',
            'icon': Icons.quiz,
            'color': Colors.orange,
            'mcqs': 15,
            'time': 15,
            'passingMarks': 50,
            'attempts': 1,
            'isPrivate': false,
            'provider': 'JobSahi',
          };
      }

      emit(
        SkillTestDetailsLoaded(
          job: event.job,
          skillTest: skillTest,
          isBookmarked: false, // Mock bookmark status
        ),
      );
    } catch (e) {
      emit(
        SkillTestError(
          message: 'Failed to load skill test details: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle toggle test bookmark
  void _onToggleTestBookmark(
    ToggleTestBookmarkEvent event,
    Emitter<SkillTestState> emit,
  ) {
    try {
      if (state is SkillTestDetailsLoaded) {
        final currentState = state as SkillTestDetailsLoaded;
        final newBookmarkStatus = !currentState.isBookmarked;

        emit(currentState.copyWith(isBookmarked: newBookmarkStatus));
        emit(
          TestBookmarkToggled(
            testId: event.testId,
            isBookmarked: newBookmarkStatus,
          ),
        );
      }
    } catch (e) {
      emit(
        SkillTestError(message: 'Failed to toggle bookmark: ${e.toString()}'),
      );
    }
  }

  /// Handle view test instructions
  void _onViewTestInstructions(
    ViewTestInstructionsEvent event,
    Emitter<SkillTestState> emit,
  ) {
    try {
      emit(NavigateToInstructionsState(testId: event.testId));
    } catch (e) {
      emit(
        SkillTestError(
          message: 'Failed to navigate to instructions: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle view test FAQ
  void _onViewTestFAQ(ViewTestFAQEvent event, Emitter<SkillTestState> emit) {
    try {
      emit(NavigateToFAQState(testId: event.testId));
    } catch (e) {
      emit(
        SkillTestError(message: 'Failed to navigate to FAQ: ${e.toString()}'),
      );
    }
  }
}
