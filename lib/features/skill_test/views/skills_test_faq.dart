/// Skills Test FAQ Screen
/// Displays multiple choice questions for skill tests with timer

library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/top_snackbar.dart';
import '../bloc/skill_test_bloc.dart';
import '../bloc/skill_test_event.dart';
import '../bloc/skill_test_state.dart';

class SkillsTestFAQScreen extends StatelessWidget {
  /// Job data for context
  final Map<String, dynamic> job;

  /// Test data to display information
  final Map<String, dynamic> test;

  const SkillsTestFAQScreen({super.key, required this.job, required this.test});

  @override
  Widget build(BuildContext context) {
    final skillTestResponseRaw = job['skill_test_response'];
    String? skillTestResponseTestId;
    if (skillTestResponseRaw is Map<String, dynamic>) {
      skillTestResponseTestId = skillTestResponseRaw['test_id']
          ?.toString()
          .trim();
    }

    final resolvedJobId =
        job['job_id']?.toString() ??
        job['id']?.toString() ??
        test['job_id']?.toString();

    final resolvedTestId =
        test['testId']?.toString() ??
        test['test_id']?.toString() ??
        test['id']?.toString() ??
        skillTestResponseTestId ??
        resolvedJobId ??
        'test_1';

    final jobPayloadId =
        resolvedJobId ??
        test['job_id']?.toString() ??
        test['id']?.toString() ??
        skillTestResponseTestId ??
        '';

    return BlocProvider(
      create: (context) => SkillTestBloc()
        ..add(
          StartTestEvent(
            testId: resolvedTestId,
            jobId: resolvedJobId,
            jobPayload: {
              'id': jobPayloadId,
              'job_id': resolvedJobId ?? jobPayloadId,
              'test_id': resolvedTestId,
              'title':
                  job['title']?.toString() ??
                  test['job_title']?.toString() ??
                  '',
              'category':
                  job['category']?.toString() ??
                  job['job_type']?.toString() ??
                  test['job_type']?.toString() ??
                  'general',
              'company':
                  job['company']?.toString() ??
                  test['company_name']?.toString() ??
                  '',
            },
          ),
        ),
      child: _SkillsTestFAQScreenView(job: job, test: test),
    );
  }
}

class _SkillsTestFAQScreenView extends StatefulWidget {
  final Map<String, dynamic> job;
  final Map<String, dynamic> test;

  const _SkillsTestFAQScreenView({required this.job, required this.test});

  @override
  State<_SkillsTestFAQScreenView> createState() =>
      _SkillsTestFAQScreenViewState();
}

class _SkillsTestFAQScreenViewState extends State<_SkillsTestFAQScreenView> {
  Timer? _timer;
  DateTime? _testStartTime;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Formats time as MM:SS
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Starts the timer for auto-submit
  void _startTimer(DateTime startTime, int timeLimitSeconds) {
    _testStartTime = startTime;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final currentState = context.read<SkillTestBloc>().state;
      if (currentState is! TestInProgressState) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(startTime).inSeconds;
      final remaining = (timeLimitSeconds - elapsed).clamp(0, timeLimitSeconds);

      // Update UI to show remaining time
      setState(() {});

      // Auto-submit when time runs out
      if (remaining <= 0) {
        timer.cancel();
        _autoSubmitTest();
      }
    });
  }

  /// Auto-submits the test when time expires (doesn't check if all questions answered)
  void _autoSubmitTest() {
    final bloc = context.read<SkillTestBloc>();
    final state = bloc.state;
    if (state is TestInProgressState) {
      final elapsedSeconds = DateTime.now()
          .difference(state.startTime)
          .inSeconds;

      TopSnackBar.showInfo(
        context,
        message: 'Time is up! Test submitted automatically.',
        duration: const Duration(seconds: 2),
      );

      bloc.add(
        SubmitTestEvent(
          testId: state.testId,
          answers: state.answers,
          totalTimeSpent: elapsedSeconds > 0 ? elapsedSeconds : 0,
          isAutoSubmit: true,
        ),
      );
    }
  }

  /// Handles answer selection
  void _selectAnswer(String questionId, String optionLabel) {
    context.read<SkillTestBloc>().add(
      SubmitAnswerEvent(
        questionId: questionId,
        answer: optionLabel,
        timeSpent: 0,
      ),
    );
  }

  /// Submits the test
  void _submitTest() {
    final bloc = context.read<SkillTestBloc>();
    final state = bloc.state;
    if (state is TestInProgressState) {
      final totalQuestions = state.questions.length;
      final answeredCount = state.answers.length;

      if (answeredCount < totalQuestions) {
        final remaining = totalQuestions - answeredCount;
        TopSnackBar.showInfo(
          context,
          message:
              'Please answer all questions before submitting. $remaining question${remaining > 1 ? 's' : ''} remaining.',
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Cancel timer when manually submitting
      _timer?.cancel();

      final elapsedSeconds = DateTime.now()
          .difference(state.startTime)
          .inSeconds;
      bloc.add(
        SubmitTestEvent(
          testId: state.testId,
          answers: state.answers,
          totalTimeSpent: elapsedSeconds > 0 ? elapsedSeconds : 0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SkillTestBloc, SkillTestState>(
      listener: (context, state) {
        if (state is TestResultsLoadedState) {
          _timer?.cancel();
          _showResultDialog(context, state);
        } else if (state is SkillTestError) {
          _timer?.cancel();
          TopSnackBar.showError(context, message: state.message);
        }
      },
      child: BlocBuilder<SkillTestBloc, SkillTestState>(
        builder: (context, state) {
          final defaultTimeLimit = _parseInt(widget.test['time']) ?? 15;
          int remainingTime = defaultTimeLimit * 60;
          Map<String, String> selectedAnswers = {};
          List<Map<String, dynamic>> questions = const [];

          if (state is SkillTestLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is SkillTestError) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is TestStartedState) {
            questions = state.questions;
            // TODO: For testing, fixed to 10 seconds. Change back to: state.timeLimit * 60
            const testTimeLimitSeconds = 10; // Testing: 10 seconds
            final timeLimitSeconds = testTimeLimitSeconds;
            remainingTime = timeLimitSeconds;
            // Start timer when test starts
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startTimer(state.startTime, timeLimitSeconds);
            });
          }

          if (state is TestInProgressState) {
            questions = state.questions;
            selectedAnswers = state.answers;

            // TODO: For testing, fixed to 10 seconds. Change back to: (questions.length / 2).ceil() * 60
            const testTimeLimitSeconds = 10; // Testing: 10 seconds
            final timeLimitSeconds = testTimeLimitSeconds;

            // Calculate remaining time based on elapsed time
            final elapsed = DateTime.now()
                .difference(state.startTime)
                .inSeconds;
            remainingTime = (timeLimitSeconds - elapsed).clamp(
              0,
              timeLimitSeconds,
            );

            // Start timer if not already started
            if (_testStartTime == null || _testStartTime != state.startTime) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _startTimer(state.startTime, timeLimitSeconds);
              });
            }
          }

          final totalQuestions = questions.length;
          final answeredCount = selectedAnswers.length;
          final title =
              widget.test['title']?.toString() ??
              widget.test['job_title']?.toString() ??
              widget.job['job_title']?.toString() ??
              widget.job['title']?.toString() ??
              'Skill Test';
          final provider =
              widget.test['provider']?.toString() ??
              widget.test['company_name']?.toString() ??
              widget.job['company']?.toString() ??
              widget.job['company_name']?.toString() ??
              'JobSahi';

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Skills Test/टेस्ट FAQ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: false,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Course/Test Information Section with Timer
                  _buildCourseInfoSection(
                    remainingTime,
                    title: title,
                    provider: provider,
                    totalQuestions: totalQuestions,
                    answeredQuestions: answeredCount,
                    leadingLetter: _resolveLeadingLetter(title, provider),
                  ),

                  // Progress indicator
                  _buildProgressIndicator(
                    answeredCount: answeredCount,
                    totalQuestions: totalQuestions,
                  ),

                  // Questions list
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Questions
                          if (questions.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(32),
                              alignment: Alignment.center,
                              child: const Text(
                                'No questions available for this skill test yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          else
                            ...questions.asMap().entries.map((entry) {
                              final index = entry.key;
                              final question = entry.value;
                              return _buildQuestionCard(
                                question,
                                selectedAnswers,
                                questionNumber: index + 1,
                              );
                            }),

                          const SizedBox(
                            height: 100,
                          ), // Space for submit button
                        ],
                      ),
                    ),
                  ),

                  // Submit button
                  _buildSubmitButton(
                    totalQuestions: totalQuestions,
                    answeredCount: answeredCount,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the progress indicator
  Widget _buildProgressIndicator({
    required int answeredCount,
    required int totalQuestions,
  }) {
    final progress = totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: $answeredCount/$totalQuestions',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  /// Builds the timer widget with dynamic colors and bell icon
  Widget _buildTimerWidget(int remainingTime) {
    Color timerColor;
    Color backgroundColor;
    bool showBell = false;

    if (remainingTime <= 10) {
      // Red for last 10 seconds
      timerColor = Colors.red;
      backgroundColor = Colors.red.shade50;
      showBell = true;
    } else if (remainingTime <= 30) {
      // Orange for last 30 seconds
      timerColor = Colors.orange;
      backgroundColor = Colors.orange.shade50;
      showBell = true;
    } else {
      // Green for normal time
      timerColor = Colors.black;
      backgroundColor = const Color(0xFFE8F5E8);
      showBell = false;
    }

    Widget timerContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: timerColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBell) ...[
            Icon(Icons.notifications_active, color: timerColor, size: 18),
            const SizedBox(width: 6),
          ] else ...[
            Icon(Icons.access_time, color: timerColor, size: 18),
            const SizedBox(width: 6),
          ],
          Text(
            _formatTime(remainingTime),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: timerColor,
            ),
          ),
        ],
      ),
    );

    return timerContent;
  }

  /// Builds the course information section with timer
  Widget _buildCourseInfoSection(
    int remainingTime, {
    required String title,
    required String provider,
    required int totalQuestions,
    required int answeredQuestions,
    required String leadingLetter,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Blue wave-like logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                leadingLetter,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Course details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'By $provider',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Progress: $answeredQuestions/$totalQuestions',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),

          // Timer with dynamic color and bell icon
          _buildTimerWidget(remainingTime),
        ],
      ),
    );
  }

  /// Builds a single question card
  Widget _buildQuestionCard(
    Map<String, dynamic> question,
    Map<String, String> selectedAnswers, {
    required int questionNumber,
  }) {
    final questionId = question['id']?.toString() ?? 'question_$questionNumber';
    final options = question['options'] as List<Map<String, dynamic>>;
    final isAnswered = selectedAnswers.containsKey(questionId);
    final questionText = question['question']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAnswered ? Colors.green.shade300 : Colors.grey.shade200,
          width: isAnswered ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header with status
          Row(
            children: [
              Expanded(
                child: Text(
                  '$questionNumber. $questionText',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ),
              if (isAnswered)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Answered',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Options grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.0,
            ),
            itemCount: options.length,
            itemBuilder: (context, optionIndex) {
              final option = options[optionIndex];
              final optionText = option['text']?.toString() ?? '';
              final optionLabel =
                  option['label']?.toString() ?? _optionLabel(optionIndex);
              final isSelected = selectedAnswers[questionId] == optionLabel;

              return GestureDetector(
                onTap: () => _selectAnswer(questionId, optionLabel),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            optionText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected ? Colors.blue : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      // Selected indicator
                      if (isSelected)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the submit button
  Widget _buildSubmitButton({
    required int totalQuestions,
    required int answeredCount,
  }) {
    final allQuestionsAnswered =
        answeredCount >= totalQuestions && totalQuestions > 0;
    final remaining = totalQuestions - answeredCount;

    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: allQuestionsAnswered ? _submitTest : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: allQuestionsAnswered
                ? const Color(0xFF5C9A24)
                : Colors.grey.shade400,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey.shade400,
            disabledForegroundColor: Colors.white,
          ),
          child: Text(
            allQuestionsAnswered
                ? 'Submit Test'
                : 'Answer All Questions ($remaining remaining)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  String _resolveLeadingLetter(String title, String provider) {
    final source = title.trim().isNotEmpty ? title : provider;
    final trimmed = source.trim();
    if (trimmed.isEmpty) return 'S';
    return trimmed.substring(0, 1).toUpperCase();
  }

  String _optionLabel(int index) => String.fromCharCode(65 + index);

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  void _showResultDialog(BuildContext context, TestResultsLoadedState result) {
    final totalQuestions = result.totalQuestions;
    // Use attemptedQuestions from result state which tracks actual answered questions
    final attemptedQuestions = result.attemptedQuestions;
    final unAttempted = (totalQuestions - attemptedQuestions).clamp(
      0,
      totalQuestions,
    );
    final scoreColor = result.score >= 80
        ? AppConstants.successColor
        : result.score >= 50
        ? AppConstants.warningColor
        : Colors.redAccent;
    final duration = Duration(seconds: result.timeSpent);
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(sheetContext).viewInsets.bottom,
            top: 24,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: scoreColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              color: scoreColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Skill Test Summary',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppConstants.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'You scored ${result.score}%. Great effort!',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppConstants.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                      },
                      icon: const Icon(Icons.close, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppConstants.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${result.score}%',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: scoreColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Overall Score',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Build and display result cards based on even/odd count
                Builder(
                  builder: (context) {
                    // Build result cards list
                    final resultCards = <Widget>[
                      _buildResultRow(
                        label: 'Attempted Questions',
                        value: '$attemptedQuestions / $totalQuestions',
                        icon: Icons.task_alt,
                        color: AppConstants.successColor,
                      ),
                      _buildResultRow(
                        label: 'Correct Answers',
                        value: '${result.correctAnswers}',
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFF1A73E8),
                      ),
                      _buildResultRow(
                        label: 'Incorrect Answers',
                        value: '${result.wrongAnswers}',
                        icon: Icons.close_rounded,
                        color: Colors.redAccent,
                      ),
                      if (unAttempted > 0)
                        _buildResultRow(
                          label: 'Unattempted',
                          value: '$unAttempted',
                          icon: Icons.help_outline,
                          color: AppConstants.warningColor,
                        ),
                      _buildResultRow(
                        label: 'Time Taken',
                        value: '${minutes}m ${seconds}s',
                        icon: Icons.schedule,
                        color: AppConstants.primaryColor,
                      ),
                    ];

                    // Display cards based on even/odd count
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = (constraints.maxWidth - 12) / 2;
                        final totalCards = resultCards.length;
                        final isEven = totalCards % 2 == 0;

                        if (isEven) {
                          // Even count: all cards in 2 columns
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: resultCards.map((card) {
                              return SizedBox(width: itemWidth, child: card);
                            }).toList(),
                          );
                        } else {
                          // Odd count: first (count-1) in 2 columns, last one full width
                          final gridCards = resultCards.sublist(
                            0,
                            totalCards - 1,
                          );
                          final lastCard = resultCards.last;

                          return Column(
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: gridCards.map((card) {
                                  return SizedBox(
                                    width: itemWidth,
                                    child: card,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              lastCard, // Full width
                            ],
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _navigateToJobDetails(context);
    });
  }

  Widget _buildResultRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToJobDetails(BuildContext context) {
    final jobId =
        widget.job['job_id']?.toString() ??
        widget.job['id']?.toString() ??
        widget.test['job_id']?.toString() ??
        widget.test['id']?.toString();

    if (jobId == null || jobId.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final payload = Map<String, dynamic>.from(widget.job);
    payload['id'] = jobId;
    payload['job_id'] = jobId;

    context.goNamed(
      'jobDetails',
      pathParameters: {'id': jobId},
      extra: payload,
    );
  }
}
