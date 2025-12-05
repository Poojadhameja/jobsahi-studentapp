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
        }
      },
      child: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
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
                ? const Center(
                    child: Text(
                      'No saved jobs found',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: savedJobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final job = savedJobs[index];
                      return JobCard(
                        job: job,
                        onTap: () =>
                            context.go(AppRoutes.jobDetailsWithId(job['id'])),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
