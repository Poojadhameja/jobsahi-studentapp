/// Skills Test FAQ Screen
/// Displays multiple choice questions for skill tests with timer

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_constants.dart';
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
  /// Formats time as MM:SS
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
      if (state.answers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please answer at least one question before submitting.',
            ),
          ),
        );
        return;
      }
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
          _showResultDialog(context, state);
        } else if (state is SkillTestError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
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
            remainingTime = state.timeLimit * 60;
          }

          if (state is TestInProgressState) {
            questions = state.questions;
            remainingTime = state.timeRemaining;
            selectedAnswers = state.answers;
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
                  _buildSubmitButton(),
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

          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatTime(remainingTime),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
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
  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _submitTest,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5C9A24),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    final attemptedQuestions = result.correctAnswers + result.wrongAnswers;
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
                _buildResultRow(
                  label: 'Attempted Questions',
                  value: '$attemptedQuestions / $totalQuestions',
                  icon: Icons.task_alt,
                  color: AppConstants.successColor,
                ),
                const SizedBox(height: 12),
                _buildResultRow(
                  label: 'Correct Answers',
                  value: '${result.correctAnswers}',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF1A73E8),
                ),
                const SizedBox(height: 12),
                _buildResultRow(
                  label: 'Incorrect Answers',
                  value: '${result.wrongAnswers}',
                  icon: Icons.close_rounded,
                  color: Colors.redAccent,
                ),
                if (unAttempted > 0) ...[
                  const SizedBox(height: 12),
                  _buildResultRow(
                    label: 'Unattempted',
                    value: '$unAttempted',
                    icon: Icons.help_outline,
                    color: AppConstants.warningColor,
                  ),
                ],
                const SizedBox(height: 12),
                _buildResultRow(
                  label: 'Time Taken',
                  value: '${minutes}m ${seconds}s',
                  icon: Icons.schedule,
                  color: AppConstants.primaryColor,
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
