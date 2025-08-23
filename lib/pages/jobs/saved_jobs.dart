/// Saved Jobs Screen

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import '../../widgets/feature_specific/job_card.dart';
import '../../data/job_data.dart';

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
            onTap: () => NavigationService.smartNavigate(
              routeName: RouteNames.jobDetails,
              arguments: job,
            ),
          );
        },
      ),
    );
  }
}
