/// Write Review Screen

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';

class WriteReviewScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  const WriteReviewScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JobsBloc()..add(LoadWriteReviewEvent(job: job)),
      child: _WriteReviewScreenView(job: job),
    );
  }
}

class _WriteReviewScreenView extends StatefulWidget {
  final Map<String, dynamic> job;

  const _WriteReviewScreenView({required this.job});

  @override
  State<_WriteReviewScreenView> createState() => _WriteReviewScreenViewState();
}

class _WriteReviewScreenViewState extends State<_WriteReviewScreenView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobsBloc, JobsState>(
      listener: (context, state) {
        if (state is ReviewSubmitted) {
          context.pop();
        }
      },
      child: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          Map<String, dynamic> job = widget.job;
          int rating = 4;
          String reviewText = '';

          if (state is WriteReviewLoaded) {
            job = state.job;
            rating = state.rating;
            reviewText = state.reviewText;
          }

          final String name = job['review_user_name'] ?? 'Avery Thompson';
          final String role = job['review_user_role'] ?? 'वेब डिज़ाइनर';
          final String location = job['location'] ?? 'Noida, India';

          return Scaffold(
            backgroundColor: AppConstants.cardBackgroundColor,
            appBar: const SimpleAppBar(
              title: 'Write Review',
              showBackButton: true,
            ),
            bottomNavigationBar: _buildSubmitButton(
              context,
              rating,
              reviewText,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppConstants.backgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          role,
                          style: const TextStyle(
                            color: AppConstants.textSecondaryColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 18,
                              color: AppConstants.textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                color: AppConstants.textSecondaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppConstants.defaultPadding),
                        const Center(
                          child: Text(
                            'Overall Rating',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            'आपकी रेटिंग: ${rating.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(child: _buildInteractiveStars(context, rating)),
                        const SizedBox(height: AppConstants.defaultPadding),
                        const Text(
                          'Write Review',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F7FD),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: _controller,
                            onChanged: (value) {
                              context.read<JobsBloc>().add(
                                UpdateReviewTextEvent(text: value),
                              );
                            },
                            maxLines: 6,
                            decoration: const InputDecoration(
                              hintText: 'Write your experience...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInteractiveStars(BuildContext context, int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final int starIndex = index + 1;
        return IconButton(
          iconSize: 40,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          constraints: const BoxConstraints(),
          onPressed: () {
            context.read<JobsBloc>().add(
              UpdateReviewRatingEvent(rating: starIndex),
            );
          },
          icon: Icon(
            starIndex <= rating ? Icons.star : Icons.star_border,
            color: AppConstants.warningColor,
          ),
        );
      }),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    int rating,
    String reviewText,
  ) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.defaultPadding,
          0,
          AppConstants.defaultPadding,
          AppConstants.defaultPadding,
        ),
        color: Colors.transparent,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            context.read<JobsBloc>().add(
              SubmitReviewEvent(
                reviewData: {
                  'rating': rating,
                  'text': reviewText,
                  'jobId': widget.job['id'],
                },
              ),
            );
          },
          child: const Text(
            'Submit Review',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
