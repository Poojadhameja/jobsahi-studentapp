import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/di/injection_container.dart';
import '../../../shared/widgets/common/top_snackbar.dart';
import '../../feedback/bloc/feedback_bloc.dart';
import '../../feedback/bloc/feedback_event.dart';
import '../../feedback/bloc/feedback_state.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FeedbackBloc>(),
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppConstants.textPrimaryColor,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Column(
                        children: const [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Color(0xFFE0E7EF),
                            child: Icon(
                              Icons.feedback_outlined,
                              size: 45,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Feedback",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Tell us what you like and how we can improve",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4F789B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Feedback',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.secondaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppConstants.largePadding),

                      // Subject
                      TextField(
                        controller: _subjectController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF212121),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Subject *',
                          hintText: 'e.g., Course Feedback, App Suggestion',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 15,
                          ),
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          helperText:
                              'Minimum 5 characters required  •  Chars: ${_subjectController.text.trim().length}/5',
                          helperStyle: TextStyle(
                            color: _subjectController.text.trim().length < 5
                                ? Colors.grey[600]
                                : Colors.green[600],
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppConstants.secondaryColor,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),

                      // Feedback
                      TextField(
                        controller: _feedbackController,
                        maxLines: 8,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF212121),
                        ),
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Feedback *',
                          hintText: 'Enter your feedback here...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 15,
                          ),
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          helperText:
                              'Minimum 15 characters required  •  Chars: ${_feedbackController.text.trim().length}/15',
                          helperStyle: TextStyle(
                            color: _feedbackController.text.trim().length < 15
                                ? Colors.grey[600]
                                : Colors.green[600],
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppConstants.secondaryColor,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: AppConstants.largePadding),
                    ],
                  ),
                ),
              ),

              // Submit button
              BlocConsumer<FeedbackBloc, FeedbackState>(
                listener: (context, state) {
                  if (state is FeedbackSubmittedSuccess) {
                    TopSnackBar.showSuccess(
                      context,
                      message: state.message,
                      duration: const Duration(seconds: 3),
                    );
                    _subjectController.clear();
                    _feedbackController.clear();
                    setState(() {});
                    context.read<FeedbackBloc>().add(
                      const ClearFeedbackFormEvent(),
                    );
                  } else if (state is FeedbackError) {
                    String errorMessage = state.message;
                    if (state.isRateLimitError) {
                      if (state.messageEn != null) {
                        errorMessage += '\n${state.messageEn}';
                      }
                      if (state.resetDate != null) {
                        errorMessage +=
                            '\n\nPlease try again after ${state.resetDate}';
                      }
                    }
                    TopSnackBar.showError(
                      context,
                      message: errorMessage,
                      duration: const Duration(seconds: 5),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is FeedbackSubmitting;
                  final subjectText = _subjectController.text.trim();
                  final feedbackText = _feedbackController.text.trim();
                  final isEnabled =
                      subjectText.length >= 5 &&
                      feedbackText.length >= 15 &&
                      !isLoading;

                  return Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: AppConstants.cardBackgroundColor,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isEnabled
                            ? () {
                                context.read<FeedbackBloc>().add(
                                  SubmitFeedbackEvent(
                                    feedback: _feedbackController.text.trim(),
                                    subject: _subjectController.text.trim(),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                          elevation: 2,
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Submit Feedback',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
