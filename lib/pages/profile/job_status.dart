/// Job Status Screen

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../data/job_data.dart';

class JobStatusScreen extends StatefulWidget {
  const JobStatusScreen({super.key});

  @override
  State<JobStatusScreen> createState() => _JobStatusScreenState();
}

class _JobStatusScreenState extends State<JobStatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(),
            
            // Tab Bar
            _buildTabBar(),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAppliedJobsTab(),
                  _buildSavedJobsTab(),
                  _buildInterviewsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the custom app bar with back button and title
  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back,
                color: AppConstants.accentColor,
                size: 20,
              ),
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          ),
          
          const SizedBox(width: AppConstants.defaultPadding),
          
          // Title
          const Text(
            'Job Status',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the tab bar with three tabs
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppConstants.primaryColor,
              width: 3.0,
            ),
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: AppConstants.accentColor,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        tabs: const [
          Tab(text: 'Applied Job'),
          Tab(text: 'Saved Job'),
          Tab(text: 'Interview'),
        ],
      ),
    );
  }

  /// Builds the Applied Jobs tab content
  Widget _buildAppliedJobsTab() {
    return _buildJobList(JobData.appliedJobs, showStatus: true);
  }

  /// Builds the Saved Jobs tab content
  Widget _buildSavedJobsTab() {
    return _buildJobList(JobData.savedJobs, showStatus: false);
  }

  /// Builds the Interviews tab content
  Widget _buildInterviewsTab() {
    // Mock interview data - you can replace this with real data
    final interviewJobs = [
      {
        "id": "6",
        "title": "इलेक्ट्रिशियन अप्रेंटिस",
        "company": "PowerZone",
        "rating": 5.0,
        "tags": ["Full-Time", "Apprenticeship"],
        "location": "New York City, US",
        "logo": "assets/images/company/group.png",
        "status": "Interview Scheduled",
        "interviewDate": "2024-01-15",
        "interviewTime": "10:00 AM",
      },
      {
        "id": "7",
        "title": "इलेक्ट्रिशियन अप्रेंटिस",
        "company": "JobZilla",
        "rating": 3.0,
        "tags": ["Full-Time", "Apprenticeship"],
        "location": "Paris, France",
        "logo": "assets/images/company/group.png",
        "status": "Interview Pending",
        "interviewDate": "TBD",
        "interviewTime": "TBD",
      },
    ];
    
    return _buildJobList(interviewJobs, showStatus: true, isInterview: true);
  }

  /// Builds a list of job cards
  Widget _buildJobList(List<Map<String, dynamic>> jobs, {
    required bool showStatus,
    bool isInterview = false,
  }) {
    if (jobs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return _buildJobCard(jobs[index], showStatus, isInterview);
      },
    );
  }

  /// Builds an individual job card
  Widget _buildJobCard(Map<String, dynamic> job, bool showStatus, bool isInterview) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Header row with logo, job info, and bookmark
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company logo
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                    color: AppConstants.backgroundColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                    child: Image.asset(
                      job['logo'] ?? AppConstants.defaultCompanyLogo,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                const SizedBox(width: AppConstants.defaultPadding),
                
                // Job details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job title
                      Text(
                        job['title'] ?? 'Job Title',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Company name and rating
                      Row(
                        children: [
                          Text(
                            job['company'] ?? 'Company',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppConstants.successColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${job['rating'] ?? 0.0} Review',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Job tags
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: (job['tags'] as List<String>? ?? []).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppConstants.textPrimaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job['location'] ?? 'Location',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Bookmark icon
                Icon(
                  Icons.bookmark_border,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
            
            // Status section
            if (showStatus) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Interview details for interview tab
                  if (isInterview) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (job['interviewDate'] != 'TBD') ...[
                            Text(
                              'Interview Date: ${job['interviewDate']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                            Text(
                              'Time: ${job['interviewTime']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                          ] else ...[
                            Text(
                              'Interview details pending',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job['status'] ?? ''),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      job['status'] ?? 'Status',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Returns the appropriate color for different status types
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return const Color(0xFF4A90E2); // Light blue
      case 'under review':
        return AppConstants.accentColor;
      case 'rejected':
        return const Color(0xFFE74C3C); // Light red
      case 'pending':
        return const Color(0xFFF39C12); // Light orange
      case 'interview scheduled':
        return AppConstants.successColor;
      case 'interview pending':
        return AppConstants.warningColor;
      default:
        return AppConstants.textSecondaryColor;
    }
  }

  /// Builds empty state when no jobs are available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No jobs found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Start applying to jobs to see them here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
