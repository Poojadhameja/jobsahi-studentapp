/// Saved Jobs Screen

library;

import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../../../shared/widgets/cards/job_card.dart';
import '../../../shared/data/job_data.dart';

class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> savedJobs = JobData.savedJobs;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: const SimpleAppBar(title: 'Saved jobs', showBackButton: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: savedJobs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final job = savedJobs[index];
          return JobCard(
            job: job,
            isInitiallySaved: true,
            onTap: () => context.go(AppRoutes.jobDetailsWithId(job['id'])),
          );
        },
      ),
    );
  }
}
