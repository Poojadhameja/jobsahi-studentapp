import 'package:flutter/material.dart';
import 'repositories/jobs_repository.dart';
import '../../../core/di/injection_container.dart';

class JobsApiTest {
  static Future<void> testJobsApi() async {
    try {
      debugPrint('🧪 Starting Jobs API Test...');

      // Initialize dependency injection first
      await initializeDependencies();

      // Get repository from service locator
      final jobsRepository = sl<JobsRepository>();

      // Test fetching jobs
      debugPrint('🔵 Testing getJobs()...');
      final jobsResponse = await jobsRepository.getJobs();

      debugPrint('✅ Jobs API Test Results:');
      debugPrint('   Status: ${jobsResponse.status}');
      debugPrint('   Message: ${jobsResponse.message}');
      debugPrint('   Count: ${jobsResponse.count}');
      debugPrint('   Jobs fetched: ${jobsResponse.data.length}');

      if (jobsResponse.data.isNotEmpty) {
        final firstJob = jobsResponse.data.first;
        debugPrint('   First Job:');
        debugPrint('     ID: ${firstJob.id}');
        debugPrint('     Title: ${firstJob.title}');
        debugPrint('     Location: ${firstJob.location}');
        debugPrint('     Salary: ${firstJob.formattedSalary}');
        debugPrint('     Skills: ${firstJob.skillsList.join(', ')}');
        debugPrint('     Remote: ${firstJob.isRemote}');
        debugPrint('     Time Ago: ${firstJob.timeAgo}');
      }

      // Test searching jobs
      debugPrint('🔵 Testing searchJobs()...');
      final searchResults = await jobsRepository.searchJobs(query: 'developer');
      debugPrint('   Search results: ${searchResults.length} jobs found');

      debugPrint('✅ Jobs API Test Completed Successfully!');
    } catch (e) {
      debugPrint('❌ Jobs API Test Failed: $e');
    }
  }
}
