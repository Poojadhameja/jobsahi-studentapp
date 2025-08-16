/// Job Details Screen

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import 'job_step1.dart';

class JobDetailsScreen extends StatelessWidget {
  /// Job data to display
  final Map<String, dynamic> job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(
        title: 'Job Details',
        showBackButton: true,
      ),
      bottomNavigationBar: _buildApplyButton(),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Job header section
            _buildJobHeader(),
            
            // Tab bar
            _buildTabBar(),
            
            // Tab content
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the job header section
  Widget _buildJobHeader() {
    return Container(
      color: AppConstants.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 12),
      child: Row(
        children: [
          // Company logo
          const CircleAvatar(
            backgroundColor: Color(0xFFD7EDFF),
            radius: 26,
            child: Icon(Icons.contact_mail_rounded, color: AppConstants.accentColor, size: 28),
          ),
          const SizedBox(width: 12),
          
          // Job title and company
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'] ?? 'Job Title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job['company'] ?? 'Company Name',
                  style: const TextStyle(fontSize: 14, color: AppConstants.successColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the tab bar
  Widget _buildTabBar() {
    return Container(
      color: AppConstants.backgroundColor,
      child: const TabBar(
        labelColor: AppConstants.textPrimaryColor,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        indicatorColor: AppConstants.textPrimaryColor,
        tabs: [
          Tab(text: 'Description'),
          Tab(text: 'Requirements'),
          Tab(text: 'Benefits'),
        ],
      ),
    );
  }

  /// Builds the tab content
  Widget _buildTabContent() {
    return TabBarView(
      children: [
        // Description tab
        _buildDescriptionTab(),
        
        // Requirements tab
        _buildRequirementsTab(),
        
        // Benefits tab
        _buildBenefitsTab(),
      ],
    );
  }

  /// Builds the description tab
  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job tags
          _buildJobTags(),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Salary information
          _buildSalaryInfo(),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Location and time
          _buildLocationAndTime(),
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Job description
          _buildJobDescription(),
        ],
      ),
    );
  }

  /// Builds the requirements tab
  Widget _buildRequirementsTab() {
    final requirements = job['requirements'] as List<dynamic>? ?? [];
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: requirements.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppConstants.successColor,
                size: 20,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  requirements[index].toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the benefits tab
  Widget _buildBenefitsTab() {
    final benefits = job['benefits'] as List<dynamic>? ?? [];
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.star,
                color: AppConstants.warningColor,
                size: 20,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  benefits[index].toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the job tags section
  Widget _buildJobTags() {
    final tags = job['tags'] as List<dynamic>? ?? [];
    
    return Wrap(
      spacing: 8,
      children: tags.map((tag) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppConstants.accentColor.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.all(Radius.circular(AppConstants.largeBorderRadius)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            tag.toString(),
            style: const TextStyle(color: AppConstants.accentColor),
          ),
        ),
      )).toList(),
    );
  }

  /// Builds the salary information section
  Widget _buildSalaryInfo() {
    return Row(
      children: [
        const Icon(Icons.attach_money, color: AppConstants.successColor),
        const SizedBox(width: 8),
        Text(
          job['salary'] ?? 'Salary not specified',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppConstants.successColor,
          ),
        ),
      ],
    );
  }

  /// Builds the location and time section
  Widget _buildLocationAndTime() {
    return Row(
      children: [
        const Icon(Icons.location_on, color: AppConstants.textSecondaryColor),
        const SizedBox(width: 8),
        Text(
          job['location'] ?? 'Location not specified',
          style: const TextStyle(color: AppConstants.textSecondaryColor),
        ),
        const Spacer(),
        Text(
          job['time'] ?? 'Time not specified',
          style: const TextStyle(color: AppConstants.textSecondaryColor),
        ),
      ],
    );
  }

  /// Builds the job description section
  Widget _buildJobDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          job['description'] ?? 'No description available.',
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  /// Builds the apply button at the bottom
  Widget _buildApplyButton() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          // Navigate to job application step 1
          NavigationService.smartNavigate(destination: JobStep1Screen(job: job));
        },
        child: const Text(
          AppConstants.applyJobText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
