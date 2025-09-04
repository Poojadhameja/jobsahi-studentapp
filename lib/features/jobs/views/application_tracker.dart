import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/profile_navigation_app_bar.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';

class ApplicationTrackerScreen extends StatelessWidget {
  /// Whether this screen is opened from profile navigation
  final bool isFromProfile;

  const ApplicationTrackerScreen({super.key, this.isFromProfile = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JobsBloc()..add(const LoadApplicationTrackerEvent()),
      child: _ApplicationTrackerScreenView(isFromProfile: isFromProfile),
    );
  }
}

class _ApplicationTrackerScreenView extends StatelessWidget {
  final bool isFromProfile;

  const _ApplicationTrackerScreenView({required this.isFromProfile});
  @override
  Widget build(BuildContext context) {
    return BlocListener<JobsBloc, JobsState>(
      listener: (context, state) {
        if (state is ApplicationViewed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewing application: ${state.applicationId}'),
              backgroundColor: AppConstants.successColor,
            ),
          );
        } else if (state is ApplyForMoreJobsState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Apply for more jobs functionality will be implemented here',
              ),
              backgroundColor: AppConstants.successColor,
            ),
          );
        }
      },
      child: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          List<Map<String, dynamic>> appliedJobs = [];
          List<Map<String, dynamic>> interviewJobs = [];
          List<Map<String, dynamic>> offerJobs = [];

          if (state is ApplicationTrackerLoaded) {
            appliedJobs = state.appliedJobs;
            interviewJobs = state.interviewJobs;
            offerJobs = state.offerJobs;
          }

          return DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: AppConstants.backgroundColor,
              appBar: isFromProfile
                  ? ProfileNavigationAppBar(title: 'Application Tracker')
                  : null,
              body: Column(
                children: [
                  if (!isFromProfile) _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildAppliedTab(context, appliedJobs),
                        _buildInterviewTab(context, interviewJobs),
                        _buildOffersTab(context, offerJobs),
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

  /// Builds the tab bar similar to learning center
  Widget _buildTabBar() {
    return Container(
      color: AppConstants.cardBackgroundColor,
      child: TabBar(
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        indicatorColor: AppConstants.primaryColor,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Applied'),
          Tab(text: 'Interview Scheduled'),
          Tab(text: 'Offers'),
        ],
      ),
    );
  }

  /// Builds the applied tab content
  Widget _buildAppliedTab(
    BuildContext context,
    List<Map<String, dynamic>> appliedJobs,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: _buildAppliedCard(context, appliedJobs),
    );
  }

  /// Builds the interview tab content
  Widget _buildInterviewTab(
    BuildContext context,
    List<Map<String, dynamic>> interviewJobs,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: _buildInterviewCards(context, interviewJobs),
    );
  }

  /// Builds the offers tab content
  Widget _buildOffersTab(
    BuildContext context,
    List<Map<String, dynamic>> offerJobs,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: _buildOffersCard(context, offerJobs),
    );
  }

  /// Builds the applied job cards
  Widget _buildAppliedCard(
    BuildContext context,
    List<Map<String, dynamic>> appliedJobs,
  ) {
    if (appliedJobs.isEmpty) {
      return const Center(
        child: Text(
          'No applied jobs found',
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: appliedJobs.length,
      itemBuilder: (context, index) {
        final job = appliedJobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildAppliedJobCard(
            context: context,
            jobTitle: job['title'] ?? 'Job Title',
            companyName: job['company'] ?? 'Company Name',
            location: job['location'] ?? 'Location',
            experience: job['experience'] ?? 'Fresher',
            appliedDate: job['appliedDate'] ?? 'Applied Date',
            positions: job['positions'] ?? 'Positions',
            applicationId: job['id'] ?? '${index}',
          ),
        );
      },
    );
  }

  /// Builds a job detail row with icon and text
  Widget _buildJobDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0B537D)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0B537D)),
        ),
      ],
    );
  }

  /// Builds an individual applied job card
  Widget _buildAppliedJobCard({
    required BuildContext context,
    required String jobTitle,
    required String companyName,
    required String location,
    required String experience,
    required String appliedDate,
    required String positions,
    required String applicationId,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job title and status
          Row(
            children: [
              Expanded(
                child: Text(
                  jobTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B537D), // Dark blue color
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B537D),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'Applied',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Company name
          Text(
            companyName,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF0B537D),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Job details
          _buildJobDetail(Icons.location_on, location),
          const SizedBox(height: 6),
          _buildJobDetail(Icons.work, experience),
          const SizedBox(height: 12),

          // Application date
          Text(
            'Applied on $appliedDate',
            style: const TextStyle(fontSize: 13, color: Color(0xFF0B537D)),
          ),
          const SizedBox(height: 6),

          // Number of positions
          Text(
            positions,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0B537D)),
          ),
          const SizedBox(height: 16),

          // View Application button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<JobsBloc>().add(
                  ViewApplicationEvent(applicationId: applicationId),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C9A24),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'View Application',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the interview cards
  Widget _buildInterviewCards(
    BuildContext context,
    List<Map<String, dynamic>> interviewJobs,
  ) {
    if (interviewJobs.isEmpty) {
      return const Center(
        child: Text(
          'No interview scheduled',
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Interview cards list
        Expanded(
          child: ListView.builder(
            itemCount: interviewJobs.length,
            itemBuilder: (context, index) {
              final job = interviewJobs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Company Logo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Job Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job Title
                          Text(
                            job['title'] ?? 'इलेक्ट्रीशियन अप्रेंटिस',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B537D), // Dark blue color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Company Name
                          Text(
                            job['company'] ?? 'Ashok Leyland',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF5C9A24), // Light green color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Location
                          Text(
                            job['location'] ?? 'Location Bhopal',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0B537D), // Dark grey color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Interview Date
                          Text(
                            'Interview: ${job['interviewDate'] ?? '25 July 2025'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0B537D), // Dark grey color
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Interview Type
                    const Text(
                      'Interview:\nWalk-In',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF0B537D), // Dark blue color
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the offers card
  Widget _buildOffersCard(
    BuildContext context,
    List<Map<String, dynamic>> offerJobs,
  ) {
    if (offerJobs.isEmpty) {
      return const Center(
        child: Text(
          'No job offers received',
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Job offer cards
        Expanded(
          child: ListView.builder(
            itemCount: offerJobs.length,
            itemBuilder: (context, index) {
              final job = offerJobs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Company Logo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 59, 153),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          (job['company'] ?? 'W').substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Job Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job Title
                          Text(
                            job['title'] ?? 'इलेक्ट्रीशियन अप्रेंटिस',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B537D), // Dark blue color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Company Name
                          Text(
                            job['company'] ?? 'Ashok Leyland',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF5C9A24), // Light green color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Job Type
                          Text(
                            job['type'] ?? 'Full Time',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0B537D), // Dark grey color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Skills
                          Text(
                            'Skills: ${job['skills'] ?? 'Drilling, Measuring'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0B537D), // Dark grey color
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right side content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Offer status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: job['status'] == 'Offer Accepted'
                                ? const Color(0xFF5C9A24)
                                : const Color(0xFF0B537D),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            job['status'] ?? 'Offer Received',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Salary
                        Text(
                          job['salary'] ?? '₹18,000',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0B537D), // Dark grey color
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom Apply For More Job button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16),
          child: ElevatedButton(
            onPressed: () {
              context.read<JobsBloc>().add(const ApplyForMoreJobsEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Apply For More Job',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
