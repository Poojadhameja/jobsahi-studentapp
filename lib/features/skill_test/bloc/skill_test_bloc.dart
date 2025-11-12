import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'skill_test_event.dart';
import 'skill_test_state.dart';
import '../../../shared/data/user_data.dart';
import '../../../shared/services/api_service.dart';

/// Skill Test BLoC
/// Handles all skill test-related business logic
class SkillTestBloc extends Bloc<SkillTestEvent, SkillTestState> {
  final ApiService _apiService = ApiService();

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

      List<Map<String, dynamic>> questions = [];
      String? jobId = event.jobId?.trim();
      if (jobId == null || jobId.isEmpty) {
        jobId = event.jobPayload?['job_id']?.toString().trim();
      }
      if (jobId == null || jobId.isEmpty) {
        jobId = event.jobPayload?['id']?.toString().trim();
      }

      if (jobId != null && jobId.isNotEmpty) {
        try {
          final apiQuestions =
              await _apiService.getSkillTestQuestions(jobId: jobId);
          questions = _mapApiQuestions(apiQuestions);
        } catch (e) {
          debugPrint('🔴 [SkillTestBloc] Question fetch failed: $e');
        }
      }

      if (questions.isEmpty) {
        throw Exception('No questions available for this skill test.');
      }

      // Time limit is half of total questions (e.g., 6 questions = 3 minutes)
      // TODO: For testing, fixed to 10 seconds. Change back to: (questions.length / 2).ceil()
      final timeLimit = 1; // Keep as 1 minute for state compatibility
      final startTime = DateTime.now();
      
      // For testing: Set to 10 seconds
      const testTimeLimitSeconds = 10;

      emit(
        TestStartedState(
          testId: event.testId,
          questions: questions,
          totalQuestions: questions.length,
          timeLimit: timeLimit,
          startTime: startTime,
        ),
      );

      emit(
        TestInProgressState(
          testId: event.testId,
          questions: questions,
          currentQuestionIndex: 0,
          answers: <String, String>{},
          timeRemaining: testTimeLimitSeconds, // 10 seconds for testing
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
    final currentState = state;
    try {
      if (currentState is! TestInProgressState) {
        emit(const SkillTestError(message: 'No active test to submit.'));
        return;
      }

      final inProgress = currentState;
      final answers = event.answers.isNotEmpty ? event.answers : inProgress.answers;

      // Allow empty answers only for auto-submit (time expiry)
      if (answers.isEmpty && !event.isAutoSubmit) {
        emit(const SkillTestError(message: 'Please answer at least one question before submitting.'));
        return;
      }

      emit(const SkillTestLoading());

      int? parseInt(dynamic value) => _parseInt(value);
      bool parseBool(dynamic value) => _parseBool(value) ?? false;
      String? parseString(dynamic value) => _parseString(value);

      final questionsById = <String, Map<String, dynamic>>{};
      for (final question in inProgress.questions) {
        final questionId = question['id']?.toString();
        if (questionId != null) {
          questionsById[questionId] = question;
        }
      }

      final calculatedElapsed =
          DateTime.now().difference(inProgress.startTime).inSeconds;
      final totalTimeSpentRaw = event.totalTimeSpent > 0
          ? event.totalTimeSpent
          : calculatedElapsed;
      final totalTimeSpent = totalTimeSpentRaw < 0 ? 0 : totalTimeSpentRaw;

      final attempts = <Map<String, dynamic>>[];
      final numericTestId = parseInt(event.testId) ?? parseInt(inProgress.testId);
      int perQuestionTime = 0;
      if (answers.isNotEmpty) {
        final average = (totalTimeSpent / answers.length).round();
        perQuestionTime = average < 0 ? 0 : average;
      }

      answers.forEach((questionKey, selectedLabel) {
        final question = questionsById[questionKey];
        final numericQuestionId = question != null
            ? (parseInt(question['numericId']) ?? parseInt(question['raw']?['question_id']) ?? parseInt(question['raw']?['id']))
            : parseInt(questionKey);
        final questionTestId = question != null
            ? (parseInt(question['testId']) ??
                parseInt(question['raw']?['test_id']))
            : null;

        attempts.add({
          'test_id': numericTestId ?? questionTestId ?? event.testId,
          'question_id': numericQuestionId ?? questionKey,
          'selected_option': selectedLabel,
          'attempt_number': 1,
          'time_taken_seconds': perQuestionTime,
        });
      });

      // Handle empty attempts for auto-submit
      if (attempts.isEmpty) {
        if (event.isAutoSubmit) {
          // Auto-submit with no answers - create result with 0 score
          final totalQuestions = inProgress.questions.length;
      emit(
        TestResultsLoadedState(
          testId: inProgress.testId,
          score: 0,
          totalQuestions: totalQuestions,
          correctAnswers: 0,
          wrongAnswers: 0,
          timeSpent: totalTimeSpent,
          grade: 'F',
          detailedResults: const [],
          completedAt: DateTime.now(),
          attemptedQuestions: answers.length,
        ),
      );
          return;
        } else {
          throw Exception('No attempts to submit');
        }
      }

      final response =
          await _apiService.submitSkillTestAttempts(attempts: attempts);

      final bool isSuccess = response['success'] != false;
      if (!isSuccess) {
        final message = response['error_message']?.toString() ??
            response['message']?.toString() ??
            'Unable to submit your answers right now.';

        emit(SkillTestError(message: message));
        emit(inProgress.copyWith());
        return;
      }

      final attemptResultsRaw = response['attempt_results'];
      final scoreSummaryRaw = response['score_summary'];

      final attemptResults = attemptResultsRaw is List
          ? attemptResultsRaw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      final scoreSummary = scoreSummaryRaw is Map
          ? scoreSummaryRaw.map((key, value) => MapEntry(key.toString(), value))
          : <String, dynamic>{};

      final totalQuestions =
          parseInt(scoreSummary['total_questions']) ?? inProgress.questions.length;
      final correctAnswers = parseInt(scoreSummary['correct_answers']) ?? 0;
      final score = parseInt(scoreSummary['score']) ??
          ((totalQuestions == 0
                  ? 0
                  : (correctAnswers / totalQuestions) * 100)
              .round());
      final wrongAnswers =
          ((totalQuestions - correctAnswers).clamp(0, totalQuestions)).toInt();
      final grade = _calculateGrade(score);

      DateTime completedAt = DateTime.now();
      final completedAtRaw = parseString(scoreSummary['completed_at']);
      if (completedAtRaw != null && completedAtRaw.isNotEmpty) {
        try {
          completedAt = DateTime.parse(completedAtRaw);
        } catch (_) {}
      }

      String? _findOptionText(Map<String, dynamic>? question, String? label) {
        if (question == null || label == null) return null;
        final options = question['options'];
        if (options is List) {
          for (final option in options) {
            final optLabel = option['label']?.toString();
            if (optLabel == label) {
              return option['text']?.toString();
            }
          }
        }
        return null;
      }

      Map<String, dynamic>? _findQuestionByNumericId(int? id) {
        if (id == null) return null;
        for (final question in questionsById.values) {
          final numericId = parseInt(question['numericId']) ??
              parseInt(question['raw']?['question_id']) ??
              parseInt(question['raw']?['id']);
          if (numericId == id) {
            return question;
          }
        }
        return null;
      }

      final detailedResults = <Map<String, dynamic>>[];
      for (final result in attemptResults) {
        final numericQuestionId = parseInt(result['question_id']);
        final questionIdKey = numericQuestionId?.toString();
        Map<String, dynamic>? question =
            (questionIdKey != null ? questionsById[questionIdKey] : null) ??
                _findQuestionByNumericId(numericQuestionId);

        String? selectedLabel;
        if (question != null) {
          final key = question['id']?.toString();
          if (key != null && answers.containsKey(key)) {
            selectedLabel = answers[key];
          }
        }
        selectedLabel ??= answers[questionIdKey];

        final optionText = _findOptionText(question, selectedLabel);

        detailedResults.add({
          'questionId': question?['id'] ?? questionIdKey ?? numericQuestionId,
          'questionText': question?['question'],
          'selectedOption': selectedLabel,
          'selectedText': optionText,
          'isCorrect': parseBool(result['is_correct']),
          'attemptId': result['attempt_id'],
        });
      }

      emit(
        TestResultsLoadedState(
          testId: inProgress.testId,
          score: score,
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
          wrongAnswers: wrongAnswers,
          timeSpent: totalTimeSpent,
          grade: grade,
          detailedResults: detailedResults,
          completedAt: completedAt,
          attemptedQuestions: answers.length,
        ),
      );
    } catch (e) {
      final previousState = currentState is TestInProgressState
          ? currentState.copyWith()
          : null;
      final message = e.toString().startsWith('Exception: ')
          ? e.toString().substring('Exception: '.length)
          : e.toString();
      emit(SkillTestError(message: message));
      if (previousState != null) {
        emit(previousState);
      }
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
          attemptedQuestions: (testResult['detailedResults'] as List).length,
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
      final job = Map<String, dynamic>.from(event.job);
      final skillTest = _buildSkillTestMeta(job);

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

  List<Map<String, dynamic>> _mapApiQuestions(
    List<Map<String, dynamic>> apiQuestions,
  ) {
    const optionKeys = ['option_a', 'option_b', 'option_c', 'option_d'];

    return apiQuestions.asMap().entries.map((entry) {
      final question = Map<String, dynamic>.from(entry.value);
      final rawId = question['question_id'] ?? question['id'] ?? question['questionId'];
      final questionId = rawId?.toString() ?? 'question_${entry.key}';
      final numericId = _parseInt(rawId);
      final options = <Map<String, dynamic>>[];

      for (var i = 0; i < optionKeys.length; i++) {
        final key = optionKeys[i];
        final optionText = question[key]?.toString();
        if (optionText != null && optionText.trim().isNotEmpty) {
          options.add({
            'id': '${questionId}_opt_${i + 1}',
            'text': optionText.trim(),
            'label': _optionLabel(i),
          });
        }
      }

      return {
        'id': questionId,
        'numericId': numericId,
        'testId': question['test_id'],
        'question': question['question_text']?.toString() ?? 'Question text',
        'raw': question,
        'options': options,
      };
    }).toList();
  }

  Map<String, dynamic> _buildSkillTestMeta(Map<String, dynamic> job) {
    Map<String, dynamic>? _asMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map((key, v) => MapEntry(key.toString(), v));
      }
      return null;
    }

    final skillResponse = _asMap(job['skill_test_response']);
    final skillResponseData = skillResponse != null
        ? _asMap(skillResponse['data'])
        : null;
    final overview = _asMap(job['skill_test_overview']);
    final embeddedTest = _asMap(job['skill_test']);
    final meta = {
      ...?embeddedTest,
      ...?overview,
      ...?skillResponse,
      ...?skillResponseData,
    };

    dynamic instructionsRaw = meta['instructions'];
    instructionsRaw ??= job['instructions'];
    if (instructionsRaw == null && skillResponseData != null) {
      instructionsRaw = skillResponseData['instructions'];
    }
    List<String> instructions = const [];
    if (instructionsRaw is List) {
      instructions = instructionsRaw
          .map((e) => _parseString(e)?.trim())
          .whereType<String>()
          .where((e) => e.isNotEmpty)
          .toList();
    }

    String pickString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = _parseString(meta[key]) ?? _parseString(job[key]);
        if (value != null && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return fallback;
    }

    int pickInt(List<String> keys, {int fallback = 0}) {
      for (final key in keys) {
        final parsed = _parseInt(meta[key] ?? job[key]);
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    bool pickBool(List<String> keys, {bool fallback = false}) {
      for (final key in keys) {
        final parsed = _parseBool(meta[key] ?? job[key]);
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    final jobId = pickString(['job_id']);
    final fallbackJobId = jobId.isNotEmpty ? jobId : pickString(['id']);
    final testIdentifier = pickString(['test_id', 'skill_test_id', 'testId']);
    final title = pickString([
      'job_title',
      'title',
      'test_title',
      'skill_test_title',
    ], fallback: 'Skill Test');
    final provider = pickString([
      'company_name',
      'company',
      'provider',
      'recruiter_name',
    ]);
    final timeMinutes = pickInt([
      'time_limit',
      'time_limit_minutes',
      'time',
      'duration_minutes',
      'duration',
    ], fallback: 15);
    final totalQuestions = pickInt([
      'total_questions',
      'questions_count',
      'mcqs',
    ]);
    final passingMarks = pickInt([
      'passing_marks',
      'passing_percentage',
      'passing_score',
    ], fallback: 50);
    final attemptsAllowed = pickInt([
      'attempts_allowed',
      'attempts',
      'max_attempts',
    ], fallback: 1);
    final language = pickString([
      'language',
      'exam_language',
    ], fallback: 'Hindi');
    final resultsPrivateFlag = pickBool(['results_private'], fallback: true);
    final resultsPublicFlag = pickBool(['results_public']);
    final resultsPrivate = resultsPublicFlag == true
        ? false
        : resultsPrivateFlag;

    return {
      'id': testIdentifier.isNotEmpty
          ? testIdentifier
          : (jobId.isNotEmpty ? jobId : fallbackJobId),
      'job_id': jobId.isNotEmpty ? jobId : fallbackJobId,
      'testId': testIdentifier.isNotEmpty ? testIdentifier : null,
      'title': title,
      'provider': provider,
      'time': timeMinutes > 0 ? timeMinutes : 15,
      'mcqs': totalQuestions > 0 ? totalQuestions : null,
      'passingMarks': passingMarks > 0 ? passingMarks : 50,
      'attemptsAllowed': attemptsAllowed > 0 ? attemptsAllowed : 1,
      'language': language,
      'resultsPrivate': resultsPrivate,
      'instructions': instructions.isNotEmpty ? instructions : null,
    };
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final trimmed = value.trim();
      final parsed = int.tryParse(trimmed);
      if (parsed != null) return parsed;
      final digits = RegExp(r"-?\d+").firstMatch(trimmed);
      if (digits != null) {
        return int.tryParse(digits.group(0)!);
      }
    }
    return null;
  }

  bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (<String>['true', '1', 'yes', 'y'].contains(lower)) return true;
      if (<String>['false', '0', 'no', 'n'].contains(lower)) return false;
    }
    return null;
  }

  String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  String _optionLabel(int index) => String.fromCharCode(65 + index);
}
