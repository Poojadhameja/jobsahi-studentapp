/// Saved Jobs Screen

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../../../shared/widgets/cards/job_card.dart';
import '../../../core/di/injection_container.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';

class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<JobsBloc>()..add(const LoadSavedJobsEvent()),
      child: const _SavedJobsScreenView(),
    );
  }
}

class _SavedJobsScreenView extends StatelessWidget {
  const _SavedJobsScreenView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobsBloc, JobsState>(
      listener: (context, state) {
        if (state is SavedJobRemoved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Job removed from saved jobs: ${state.jobId}'),
              backgroundColor: AppConstants.successColor,
            ),
          );
          // Reload saved jobs after removal
          context.read<JobsBloc>().add(const LoadSavedJobsEvent());
        } else if (state is JobUnsavedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Job unsaved successfully'),
              backgroundColor: AppConstants.successColor,
            ),
          );
          // Reload saved jobs after unsaving
          context.read<JobsBloc>().add(const LoadSavedJobsEvent());
        }
      },
      child: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          // Show loading state
          if (state is JobsLoading) {
            return Scaffold(
              backgroundColor: AppConstants.backgroundColor,
              appBar: const SimpleAppBar(
                title: 'Saved jobs',
                showBackButton: true,
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Show error state
          if (state is JobsError) {
            return Scaffold(
              backgroundColor: AppConstants.backgroundColor,
              appBar: const SimpleAppBar(
                title: 'Saved jobs',
                showBackButton: true,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppConstants.textSecondaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppConstants.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<JobsBloc>().add(const LoadSavedJobsEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Get saved jobs from state
          List<Map<String, dynamic>> savedJobs = [];

          if (state is SavedJobsLoaded) {
            savedJobs = state.savedJobs;
          }

          return Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            appBar: const SimpleAppBar(
              title: 'Saved jobs',
              showBackButton: true,
            ),
            body: savedJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No saved jobs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Save jobs to view them here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      context.read<JobsBloc>().add(const LoadSavedJobsEvent());
                      // Wait a bit for the state to update
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      itemCount: savedJobs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final job = savedJobs[index];
                        return JobCard(
                          job: job,
                          onTap: () => context.go(
                            AppRoutes.jobDetailsWithId(job['id']?.toString() ?? ''),
                          ),
                          onSaveToggle: () {
                            // Handle unsave job
                            final jobId = job['id']?.toString();
                            if (jobId != null) {
                              context.read<JobsBloc>().add(
                                    UnsaveJobEvent(jobId: jobId),
                                  );
                              // Reload saved jobs after unsaving
                              context.read<JobsBloc>().add(
                                    const LoadSavedJobsEvent(),
                                  );
                            }
                          },
                          isSaved: true,
                        );
                      },
                    ),
                  ),
          );
        },
      ),
    );
  }
}
