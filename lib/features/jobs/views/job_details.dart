/// Job Details Screen

library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../../../shared/widgets/common/top_snackbar.dart';
import '../../../shared/data/job_data.dart';
import '../../../shared/data/user_data.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';

import 'about_company.dart';
import '../../../shared/services/api_service.dart';

class JobDetailsScreen extends StatefulWidget {
  /// Job data to display
  final Map<String, dynamic> job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  String? _applicationId;
  bool _isCheckingApplication = false;

  // Store current job data and bookmark state to persist across state changes
  Map<String, dynamic>? _currentJobData;
  Map<String, dynamic>? _currentCompanyInfo;
  Map<String, dynamic>? _currentStatistics;
  bool? _currentBookmarkState;

  /// Capitalizes the first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void initState() {
    super.initState();
    // Load job details when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Use the job ID from the URL parameter, not from the static job data
        final jobId = widget.job['id']?.toString() ?? '';
        debugPrint('🔵 [JobDetailsScreen] Widget job data: ${widget.job}');
        debugPrint('🔵 [JobDetailsScreen] Extracted job ID: $jobId');
        debugPrint('🔵 [JobDetailsScreen] Loading job details for ID: $jobId');
        context.read<JobsBloc>().add(LoadJobDetailsEvent(jobId: jobId));

        // Check if user has already applied for this job
        if (jobId.isNotEmpty) {
          _checkIfApplied(jobId);
        }
      }
    });
  }

  /// Check if user has already applied for this job
  Future<void> _checkIfApplied(String jobId) async {
    if (_isCheckingApplication || jobId.isEmpty) return;

    setState(() {
      _isCheckingApplication = true;
    });

    try {
      final api = ApiService();
      final appliedJobs = await api.getStudentAppliedJobs();

      // Find application for this job
      for (final appliedJob in appliedJobs) {
        // Check multiple possible fields for job ID
        final appliedJobId =
            appliedJob['job_id']?.toString() ?? appliedJob['id']?.toString();

        // Check multiple possible fields for application ID
        final applicationId =
            appliedJob['application_id']?.toString() ??
            appliedJob['id']?.toString();

        // Match job ID (try both string and int comparison)
        final jobIdMatch =
            appliedJobId == jobId ||
            appliedJobId == jobId.toString() ||
            (int.tryParse(appliedJobId ?? '')?.toString() == jobId) ||
            (int.tryParse(jobId)?.toString() == appliedJobId);

        if (jobIdMatch && applicationId != null && applicationId.isNotEmpty) {
          if (mounted) {
            setState(() {
              _applicationId = applicationId;
            });
          }
          debugPrint(
            '✅ [JobDetailsScreen] Found application ID: $applicationId for job: $jobId',
          );
          break;
        }
      }
    } catch (e) {
      debugPrint('🔴 [JobDetailsScreen] Error checking application: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingApplication = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JobsBloc, JobsState>(
      listener: (context, state) {
        // Show snackbar on error but keep showing basic job info
        if (state is JobsError) {
          TopSnackBar.showError(
            context,
            message: '${state.message} (पुनः प्रयास करें)',
          );
        }
        // Removed snackbars for JobSavedState and JobUnsavedState
      },
      builder: (context, state) {
        // Initialize with widget data or stored data
        Map<String, dynamic> currentJob = _currentJobData ?? widget.job;
        bool isBookmarked = false;
        Map<String, dynamic>? companyInfo = _currentCompanyInfo;
        Map<String, dynamic>? statistics = _currentStatistics;
        bool isLoading = false;

        // Get job ID for bookmark check
        final jobId = currentJob['id']?.toString() ?? '';

        if (state is JobsLoading) {
          isLoading = true;
          // Keep bookmark state from stored data or UserData
          isBookmarked =
              _currentBookmarkState ?? UserData.savedJobIds.contains(jobId);
        } else if (state is JobDetailsLoaded) {
          // Store the loaded data
          currentJob = state.job;
          isBookmarked = state.isBookmarked;
          companyInfo = state.companyInfo;
          statistics = state.statistics;

          // Persist data to state variables
          _currentJobData = currentJob;
          _currentCompanyInfo = companyInfo;
          _currentStatistics = statistics;
          _currentBookmarkState = isBookmarked;
        } else if (state is JobBookmarkToggled) {
          // Update bookmark state when toggled - this state is emitted immediately
          isBookmarked = state.isBookmarked;
          _currentBookmarkState = isBookmarked;
          // Keep stored job data - don't change them, just update bookmark
        } else if (state is JobSavedState) {
          // Job was saved - update bookmark
          isBookmarked = true;
          _currentBookmarkState = true;
          // Keep stored job data
        } else if (state is JobUnsavedState) {
          // Job was unsaved - update bookmark
          isBookmarked = false;
          _currentBookmarkState = false;
          // Keep stored job data
        } else {
          // For any other state, use stored data or fallback to UserData
          if (_currentJobData != null) {
            currentJob = _currentJobData!;
            companyInfo = _currentCompanyInfo;
            statistics = _currentStatistics;
            isBookmarked =
                _currentBookmarkState ?? UserData.savedJobIds.contains(jobId);
          } else {
            // Fallback to widget data and UserData check
            currentJob = widget.job;
            isBookmarked = UserData.savedJobIds.contains(jobId);
          }
        }

        return PopScope(
          canPop: context.canPop(),
          onPopInvoked: (didPop) {
            if (didPop) {
              // Natural pop happened - nothing to do
              return;
            }
            // If can't pop naturally, navigate to home instead of exiting
            if (!context.canPop()) {
              context.go('/home');
            }
          },
          child: Scaffold(
            backgroundColor: AppConstants.cardBackgroundColor,
            appBar: const SimpleAppBar(
              title: 'Job Details',
              showBackButton: true,
            ),
            bottomNavigationBar: isLoading
                ? null
                : _buildApplyButton(context, currentJob),
            body: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppConstants.secondaryColor,
                    ),
                  )
                : RefreshIndicator(
                    color: AppConstants.secondaryColor,
                    onRefresh: () async {
                      final jobId = currentJob['id']?.toString() ?? '';
                      if (jobId.isNotEmpty) {
                        context.read<JobsBloc>().add(
                          LoadJobDetailsEvent(jobId: jobId),
                        );
                      }
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            // Job header section with card
                            Padding(
                              padding: const EdgeInsets.all(
                                AppConstants.defaultPadding,
                              ),
                              child: _buildJobHeaderCard(
                                context,
                                currentJob,
                                isBookmarked,
                                companyInfo,
                              ),
                            ),

                            // Tab bar (fixed at bottom of header)
                            _buildTabBar(),

                            // Tab content with fixed height based on screen
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height -
                                  MediaQuery.of(context).padding.top -
                                  kToolbarHeight -
                                  200,
                              child: _buildTabContent(
                                currentJob,
                                companyInfo,
                                statistics,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// Builds the job header card (simple - icon, name, company, save, job ID)
  Widget _buildJobHeaderCard(
    BuildContext context,
    Map<String, dynamic> currentJob,
    bool isBookmarked,
    Map<String, dynamic>? companyInfo,
  ) {
    final title = _capitalizeFirst(
      currentJob['title']?.toString() ?? 'Job Title',
    );
    final companyName =
        companyInfo?['company_name']?.toString() ?? 'Company Name';

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Job icon (matching job card style)
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppConstants.successColor,
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
            ),
            child: const Icon(Icons.work, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          // Right side - Job details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Bookmark in a Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              final name = companyInfo?['company_name'];
                              if (name != null &&
                                  JobData.companies.containsKey(name)) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AboutCompanyScreen(
                                      company: JobData.companies[name]!,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              _capitalizeFirst(companyName),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppConstants.successColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bookmark button
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () {
                          context.read<JobsBloc>().add(
                            ToggleJobBookmarkEvent(
                              jobId: currentJob['id']?.toString() ?? '',
                            ),
                          );
                        },
                        customBorder: const CircleBorder(),
                        splashColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade200,
                        radius: 20,
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isBookmarked
                                ? AppConstants.successColor
                                : Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (currentJob['id'] != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Job ID: ${currentJob['id']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: const TabBar(
        labelColor: AppConstants.textPrimaryColor,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        indicatorColor: AppConstants.primaryColor,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'About'),
          Tab(text: 'Company'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  /// Builds the tab content
  Widget _buildTabContent(
    Map<String, dynamic> currentJob,
    Map<String, dynamic>? companyInfo,
    Map<String, dynamic>? statistics,
  ) {
    return TabBarView(
      children: [
        // Description tab
        _buildAboutTab(currentJob),

        // Requirements tab
        _buildCompanyTab(currentJob, companyInfo),

        // Benefits tab
        _buildReviewsTab(currentJob),
      ],
    );
  }

  /// Builds the description tab
  Widget _buildAboutTab(Map<String, dynamic> currentJob) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About the role section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About the role',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  currentJob['about'] ??
                      (currentJob['description'] ??
                          'An Electrician Apprentice assists in installing, maintaining, and repairing electrical systems. This is an apprenticeship or training role with exposure to on-field work under supervision.'),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Job Information Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Job Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildSimpleJobInformation(currentJob),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Key Responsibilities Section
          if ((currentJob['responsibilities'] != null &&
                  (currentJob['responsibilities'] as List).isNotEmpty) ||
              (currentJob['requirements'] != null &&
                  (currentJob['requirements'] as List).isNotEmpty) ||
              (currentJob['skills_required'] != null &&
                  (currentJob['skills_required'] as List).isNotEmpty)) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Key Requirements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  _buildKeyResponsibilities(currentJob),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds simple job information section with icons
  Widget _buildSimpleJobInformation(Map<String, dynamic> currentJob) {
    final salary = currentJob['salary']?.toString() ?? 'Salary not specified';
    final location =
        currentJob['location']?.toString() ?? 'Location not specified';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Salary
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInfoItemWithIcon(Icons.currency_rupee, 'Salary', salary),
        ),

        // Location
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInfoItemWithIcon(
            Icons.location_on,
            'Location',
            location,
          ),
        ),

        // Experience Required
        if (currentJob['experience_required'] != null &&
            currentJob['experience_required'].toString().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInfoItemWithIcon(
              Icons.trending_up,
              'Experience Required',
              currentJob['experience_required'].toString(),
            ),
          ),

        // Job Type
        if (currentJob['job_type'] != null &&
            currentJob['job_type'].toString().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInfoItemWithIcon(
              Icons.work_outline,
              'Job Type',
              currentJob['job_type'].toString(),
            ),
          ),

        // Vacancies
        if (currentJob['no_of_vacancies'] != null &&
            currentJob['no_of_vacancies'] > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInfoItemWithIcon(
              Icons.people_outline,
              'Number of Vacancies',
              currentJob['no_of_vacancies'].toString(),
            ),
          ),

        // Application Deadline
        if (currentJob['application_deadline'] != null &&
            currentJob['application_deadline'].toString().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInfoItemWithIcon(
              Icons.calendar_today,
              'Application Deadline',
              _formatSimpleDeadline(currentJob['application_deadline']),
            ),
          ),

        // Views
        if (currentJob['views'] != null && currentJob['views'] > 0)
          _buildInfoItemWithIcon(
            Icons.visibility_outlined,
            'Total Views',
            currentJob['views'].toString(),
          ),
      ],
    );
  }

  /// Builds an info item with icon (similar to skill test instruction items)
  Widget _buildInfoItemWithIcon(
    IconData icon,
    String label,
    String value, {
    bool isClickable = false,
  }) {
    final isWebsite = label.toLowerCase() == 'website';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: AppConstants.successColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                isWebsite || isClickable
                    ? GestureDetector(
                        onTap: () => _launchUrl(value),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.open_in_new,
                              size: 14,
                              color: AppConstants.primaryColor,
                            ),
                          ],
                        ),
                      )
                    : Text(
                        value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;

    try {
      String urlToLaunch = url.trim();
      if (!urlToLaunch.startsWith('http://') &&
          !urlToLaunch.startsWith('https://')) {
        urlToLaunch = 'https://$urlToLaunch';
      }

      final uri = Uri.parse(urlToLaunch);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        TopSnackBar.showError(
          context,
          message: 'Could not open website: ${e.toString()}',
        );
      }
    }
  }

  /// Formats deadline in simple way
  String _formatSimpleDeadline(dynamic deadline) {
    if (deadline == null) return '';

    try {
      final date = DateTime.parse(deadline.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return deadline.toString();
    }
  }

  /// Builds the Company tab with card layout
  Widget _buildCompanyTab(
    Map<String, dynamic> currentJob,
    Map<String, dynamic>? companyInfo,
  ) {
    // Use only API company info - no static fallback data
    final String? aboutCompany =
        companyInfo?['about'] ?? companyInfo?['company_about'];

    final String? website =
        companyInfo?['website'] ?? companyInfo?['company_website'];

    final String? headquarters =
        companyInfo?['location'] ?? companyInfo?['company_location'];

    final String? industry =
        companyInfo?['industry'] ?? companyInfo?['company_industry'];

    // These fields are not in the API response, so we'll only show them if available
    final String? founded = currentJob['company_founded'];
    final String? size = currentJob['company_size']?.toString();
    final String? revenue = currentJob['company_revenue'];

    final hasAnyData =
        aboutCompany != null ||
        website != null ||
        headquarters != null ||
        industry != null ||
        founded != null ||
        size != null ||
        revenue != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About Company card
          if (aboutCompany != null && aboutCompany.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Company',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    aboutCompany,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
          ],

          // Company Information card
          if (website != null ||
              headquarters != null ||
              industry != null ||
              founded != null ||
              size != null ||
              revenue != null) ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Company Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  if (website != null && website.isNotEmpty) ...[
                    _buildInfoItemWithIcon(
                      Icons.public,
                      'Website',
                      website,
                      isClickable: true,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (headquarters != null && headquarters.isNotEmpty) ...[
                    _buildInfoItemWithIcon(
                      Icons.location_on_outlined,
                      'Headquarters',
                      headquarters,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (industry != null && industry.isNotEmpty) ...[
                    _buildInfoItemWithIcon(
                      Icons.business,
                      'Industry',
                      industry,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (founded != null && founded.isNotEmpty) ...[
                    _buildInfoItemWithIcon(
                      Icons.event_outlined,
                      'Founded',
                      founded,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (size != null && size.isNotEmpty) ...[
                    _buildInfoItemWithIcon(Icons.group_outlined, 'Size', size),
                    const SizedBox(height: 12),
                  ],
                  if (revenue != null && revenue.isNotEmpty)
                    _buildInfoItemWithIcon(
                      Icons.attach_money,
                      'Revenue',
                      revenue,
                    ),
                ],
              ),
            ),
          ],

          // Show message if no company data is available
          if (!hasAnyData)
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No company information available',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the Review tab
  Widget _buildReviewsTab(Map<String, dynamic> currentJob) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 80,
            color: AppConstants.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'We are working on this feature. It will be available soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Key responsibilities list with icons (similar to skill test instructions)
  Widget _buildKeyResponsibilities(Map<String, dynamic> currentJob) {
    // Get skills_required first, then requirements, then fallback
    final List<dynamic> skills =
        currentJob['skills_required'] as List<dynamic>? ?? [];
    final List<dynamic> requirements =
        currentJob['requirements'] as List<dynamic>? ?? [];
    final List<dynamic> responsibilities =
        currentJob['responsibilities'] as List<dynamic>? ?? [];

    final List<dynamic> items = skills.isNotEmpty
        ? skills
        : (requirements.isNotEmpty ? requirements : responsibilities);

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text(
          'Details will be provided during the interview process.',
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      children: items
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: AppConstants.successColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.textPrimaryColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  /// Builds the apply button at the bottom
  Widget _buildApplyButton(
    BuildContext context,
    Map<String, dynamic> currentJob,
  ) {
    // Check if user has already applied for this job
    final applicationData = currentJob['application'] is Map<String, dynamic>
        ? currentJob['application'] as Map<String, dynamic>
        : null;

    final applicationIdRaw =
        _applicationId ??
        currentJob['application_id']?.toString() ??
        applicationData?['application_id']?.toString() ??
        applicationData?['id']?.toString() ??
        currentJob['applicationId']?.toString();

    final hasApplied = applicationIdRaw != null && applicationIdRaw.isNotEmpty;
    final applicationId = hasApplied ? applicationIdRaw : '';

    // Check if job is closed
    final jobStatus = currentJob['status']?.toString().toLowerCase() ?? '';
    final isStatusClosed = jobStatus == 'closed' || jobStatus == 'expired';

    // Check if deadline has passed
    bool isDeadlinePassed = false;
    final deadline = currentJob['application_deadline'];
    if (deadline != null) {
      try {
        final deadlineDate = DateTime.parse(deadline.toString());
        final now = DateTime.now();
        isDeadlinePassed = deadlineDate.difference(now).isNegative;
      } catch (e) {
        // If parsing fails, assume deadline is not passed
        isDeadlinePassed = false;
      }
    }

    final isJobClosed = isStatusClosed || isDeadlinePassed;

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 20),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(
          AppConstants.defaultPadding,
          0,
          AppConstants.defaultPadding,
          AppConstants.defaultPadding,
        ),
        child: Builder(
          builder: (context) => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isJobClosed
                  ? Colors.grey
                  : AppConstants.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.smallBorderRadius,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              disabledBackgroundColor: Colors.grey,
            ),
            onPressed: isJobClosed
                ? null
                : () {
                    if (hasApplied) {
                      // Navigate to application detail page
                      _navigateToApplicationDetail(
                        context,
                        applicationId,
                        currentJob,
                      );
                    } else {
                      // Navigate directly to job application step
                      _navigateToJobStep(context);
                    }
                  },
            child: Text(
              isJobClosed
                  ? 'Closed'
                  : (hasApplied
                        ? 'Track Application'
                        : AppConstants.applyJobText),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isJobClosed ? Colors.white70 : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Navigates to application detail page
  void _navigateToApplicationDetail(
    BuildContext context,
    String applicationId,
    Map<String, dynamic> currentJob,
  ) {
    final jobPayload = Map<String, dynamic>.from(currentJob);
    jobPayload['application_id'] = applicationId;
    jobPayload['_navigation_source'] = 'job_details'; // Track navigation source

    context.pushNamed(
      'studentApplicationDetail',
      pathParameters: {'id': applicationId},
      extra: jobPayload,
    );
  }

  /// Navigates to job step screen
  void _navigateToJobStep(BuildContext context) {
    // Get current job from BLoC state
    final currentState = context.read<JobsBloc>().state;
    Map<String, dynamic> currentJob = widget.job;

    if (currentState is JobDetailsLoaded) {
      currentJob = currentState.job;
    }

    final jobId = currentJob['id']?.toString();
    if (jobId == null || jobId.isEmpty) {
      TopSnackBar.showError(
        context,
        message: 'Unable to determine job ID for application.',
      );
      return;
    }

    final jobPayload = Map<String, dynamic>.from(currentJob);
    jobPayload['id'] = jobId;

    context.pushNamed(
      'jobStep',
      pathParameters: {'id': jobId},
      extra: jobPayload,
    );
  }
}
