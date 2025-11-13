/// Job Details Screen

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../../../shared/data/job_data.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';

import 'write_review.dart';
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
        final appliedJobId = appliedJob['job_id']?.toString() ?? 
                             appliedJob['id']?.toString();
        
        // Check multiple possible fields for application ID
        final applicationId = appliedJob['application_id']?.toString() ??
                             appliedJob['id']?.toString();
        
        // Match job ID (try both string and int comparison)
        final jobIdMatch = appliedJobId == jobId || 
                          appliedJobId == jobId.toString() ||
                          (int.tryParse(appliedJobId ?? '')?.toString() == jobId) ||
                          (int.tryParse(jobId)?.toString() == appliedJobId);
        
        if (jobIdMatch && applicationId != null && applicationId.isNotEmpty) {
          if (mounted) {
            setState(() {
              _applicationId = applicationId;
            });
          }
          debugPrint('✅ [JobDetailsScreen] Found application ID: $applicationId for job: $jobId');
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'पुनः प्रयास करें',
                textColor: Colors.white,
                onPressed: () {
                  context.read<JobsBloc>().add(
                    LoadJobDetailsEvent(jobId: widget.job['id'] ?? ''),
                  );
                },
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        Map<String, dynamic> currentJob = widget.job;
        bool isBookmarked = false;
        Map<String, dynamic>? companyInfo;
        Map<String, dynamic>? statistics;
        bool isLoading = false;

        if (state is JobsLoading) {
          isLoading = true;
        } else if (state is JobDetailsLoaded) {
          currentJob = state.job;
          isBookmarked = state.isBookmarked;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const SimpleAppBar(
            title: 'Job Details',
            showBackButton: true,
          ),
          bottomNavigationBar: isLoading ? null : _buildApplyButton(context, currentJob),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppConstants.secondaryColor,
                  ),
                )
              : Stack(
                  children: [
                    DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          // Job header section
                          _buildJobHeader(
                            context,
                            currentJob,
                            isBookmarked,
                            companyInfo,
                          ),

                          // Tab bar
                          _buildTabBar(),

                          // Tab content
                          Expanded(
                            child: _buildTabContent(
                              currentJob,
                              companyInfo,
                              statistics,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  /// Builds the job header section
  Widget _buildJobHeader(
    BuildContext context,
    Map<String, dynamic> currentJob,
    bool isBookmarked,
    Map<String, dynamic>? companyInfo,
  ) {
    return Container(
      color: AppConstants.backgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Company logo
              CircleAvatar(
                backgroundColor: const Color(0xFFD7EDFF),
                radius: 26,
                backgroundImage: companyInfo?['company_logo'] != null
                    ? NetworkImage(companyInfo!['company_logo'])
                    : null,
                child: companyInfo?['company_logo'] == null
                    ? const Icon(
                        Icons.contact_mail_rounded,
                        color: AppConstants.accentColor,
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentJob['title'] ?? 'Job Title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Tooltip(
                      message: 'Tap to view company details',
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to company details page
                          final companyName = companyInfo?['company_name'];

                          if (companyName != null &&
                              JobData.companies.containsKey(companyName)) {
                            // Navigate directly to AboutCompanyScreen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AboutCompanyScreen(
                                  company: JobData.companies[companyName]!,
                                ),
                              ),
                            );
                          } else {
                            // Show a message if company data is not available
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Company details for "$companyName" not available',
                                ),
                                backgroundColor: AppConstants.errorColor,
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              companyInfo?['company_name'] ?? 'Company Name',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppConstants.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppConstants.successColor,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bookmark button
              IconButton(
                onPressed: () {
                  context.read<JobsBloc>().add(
                    ToggleJobBookmarkEvent(jobId: currentJob['id'] ?? ''),
                  );
                },
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? AppConstants.warningColor : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          // Chips (Full-Time, Apprenticeship, On-site, etc.)
          _buildJobTags(currentJob),

          const SizedBox(height: AppConstants.defaultPadding),
          // Salary and time row (to match screenshot)
          _buildSalaryAndTimeRow(currentJob),
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
          Tab(text: 'About'),
          Tab(text: 'Company'),
          Tab(text: 'Review'),
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
          const Text(
            'About the role',
            style: TextStyle(
              fontSize: 18,
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
              fontSize: 16,
              height: 1.5,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          const Divider(),
          const SizedBox(height: AppConstants.defaultPadding),

          // Job Information Section
          const Text(
            'Job Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildSimpleJobInformation(currentJob),

          const SizedBox(height: AppConstants.defaultPadding),
          const Divider(),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text(
            'मुख्य जिम्मेदारियाँ (Key Responsibilities)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildKeyResponsibilities(currentJob),
        ],
      ),
    );
  }

  /// Builds simple job information section
  Widget _buildSimpleJobInformation(Map<String, dynamic> currentJob) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Job Type
        if (currentJob['tags'] != null &&
            (currentJob['tags'] as List).isNotEmpty)
          _buildSimpleInfoRow(
            'Job Type',
            (currentJob['tags'] as List).first.toString(),
          ),

        // Experience Required
        if (currentJob['experience_required'] != null &&
            currentJob['experience_required'].toString().isNotEmpty)
          _buildSimpleInfoRow(
            'Experience Required',
            currentJob['experience_required'].toString(),
          ),

        // Skills Required
        if (currentJob['requirements'] != null &&
            (currentJob['requirements'] as List).isNotEmpty)
          _buildSimpleInfoRow(
            'Skills Required',
            (currentJob['requirements'] as List).join(', '),
          ),

        // Vacancies
        if (currentJob['no_of_vacancies'] != null &&
            currentJob['no_of_vacancies'] > 0)
          _buildSimpleInfoRow(
            'Number of Vacancies',
            currentJob['no_of_vacancies'].toString(),
          ),

        // Status
        if (currentJob['status'] != null &&
            currentJob['status'].toString().isNotEmpty)
          _buildSimpleInfoRow('Status', currentJob['status'].toString()),

        // Application Deadline
        if (currentJob['application_deadline'] != null &&
            currentJob['application_deadline'].toString().isNotEmpty)
          _buildSimpleInfoRow(
            'Application Deadline',
            _formatSimpleDeadline(currentJob['application_deadline']),
          ),

        // Views
        if (currentJob['views'] != null && currentJob['views'] > 0)
          _buildSimpleInfoRow('Views', currentJob['views'].toString()),
      ],
    );
  }

  /// Builds a simple info row
  Widget _buildSimpleInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
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

  /// Builds the Company tab
  Widget _buildCompanyTab(
    Map<String, dynamic> currentJob,
    Map<String, dynamic>? companyInfo,
  ) {
    // Use only API company info - no static fallback data
    final String? aboutCompany =
        companyInfo?['about'] ?? companyInfo?['company_about'];

    final String? website = companyInfo?['website'];

    final String? headquarters = companyInfo?['location'];

    final String? industry = companyInfo?['industry'];

    // These fields are not in the API response, so we'll only show them if available
    final String? founded = currentJob['company_founded'];
    final String? size = currentJob['company_size']?.toString();
    final String? revenue = currentJob['company_revenue'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only show "About Company" section if we have company description
          if (aboutCompany != null && aboutCompany.isNotEmpty) ...[
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
                fontSize: 15,
                height: 1.5,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            const Divider(),
            const SizedBox(height: AppConstants.defaultPadding),
          ],

          // Only show company info rows if we have data from API
          if (website != null && website.isNotEmpty)
            _buildCompanyInfoRow(
              Icons.public,
              'Website',
              website,
              isClickable: true,
            ),
          if (website != null && website.isNotEmpty)
            const SizedBox(height: AppConstants.defaultPadding),

          if (headquarters != null && headquarters.isNotEmpty)
            _buildCompanyInfoRow(
              Icons.location_on_outlined,
              'Headquarters',
              headquarters,
            ),
          if (headquarters != null && headquarters.isNotEmpty)
            const SizedBox(height: AppConstants.defaultPadding),

          if (industry != null && industry.isNotEmpty)
            _buildCompanyInfoRow(Icons.business, 'Industry', industry),
          if (industry != null && industry.isNotEmpty)
            const SizedBox(height: AppConstants.defaultPadding),

          if (founded != null && founded.isNotEmpty)
            _buildCompanyInfoRow(Icons.event_outlined, 'Founded', founded),
          if (founded != null && founded.isNotEmpty)
            const SizedBox(height: AppConstants.defaultPadding),

          if (size != null && size.isNotEmpty)
            _buildCompanyInfoRow(Icons.group_outlined, 'Size', size),
          if (size != null && size.isNotEmpty)
            const SizedBox(height: AppConstants.defaultPadding),

          if (revenue != null && revenue.isNotEmpty)
            _buildCompanyInfoRow(Icons.attach_money, 'Revenue', revenue),

          // Show message if no company data is available
          if (aboutCompany == null &&
              website == null &&
              headquarters == null &&
              industry == null &&
              founded == null &&
              size == null &&
              revenue == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Text(
                      'No company information available',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Reusable row for a company info item
  Widget _buildCompanyInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isClickable = false,
  }) {
    // Don't show the row if value is empty
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Icon(icon, color: AppConstants.textSecondaryColor),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: AppConstants.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (isClickable && value.startsWith('http'))
          GestureDetector(
            onTap: () {
              // Handle website click - you can implement URL launcher here
              debugPrint('Opening website: $value');
            },
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        else
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
      ],
    );
  }

  /// Builds the Review tab
  Widget _buildReviewsTab(Map<String, dynamic> currentJob) {
    final double rating = (currentJob['rating'] is num)
        ? (currentJob['rating'] as num).toDouble()
        : 4.5;
    final int reviewsCount = currentJob['reviews_count'] is num
        ? (currentJob['reviews_count'] as num).toInt()
        : 2700;
    final Map<int, double> breakdown = (currentJob['rating_breakdown'] is Map)
        ? (currentJob['rating_breakdown'] as Map).map<int, double>(
            (key, value) => MapEntry(
              int.parse(key.toString()),
              (value is num) ? value.toDouble() : 0.0,
            ),
          )
        : {5: 0.9, 4: 0.8, 3: 0.5, 2: 0.3, 1: 0.2};
    final List<Map<String, dynamic>> reviews =
        (currentJob['reviews'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [
          {
            'rating': 5.0,
            'name': 'Kim Shine',
            'time': '2 hr ago',
            'text':
                'एक सहयोगी और सकारात्मक कार्य वातावरण मिलता है जहाँ कार्य और निजी जीवन का संतुलन बना रहता है। हालांकि, ग्रोथ के मौके सीमित हैं क्योंकि संसाधन और टीम का आकार छोटा है',
          },
          {
            'rating': 3.0,
            'name': 'Avery Thompson',
            'time': '3 days ago',
            'text':
                'ग्राहक इंटरैक्शन के साथ डीलिंग का शानदार अनुभव। काम कभी-कभी चुनौतीपूर्ण कामकाज वाला हो सकता है, खासकर पीक सीजन में, लेकिन टीम अच्‍छी है',
          },
          {
            'rating': 4.0,
            'name': 'Jordan Mitchell',
            'time': '2 month ago',
            'text': 'कुल मिलाकर अच्छा अनुभव रहा। सीखने के बहुत मौके मिले।',
          },
        ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewSummaryCard(rating, reviewsCount, breakdown),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              const Text(
                'Review',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const Spacer(),
              Builder(
                builder: (context) => TextButton(
                  onPressed: () {
                    // Navigate to write review screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            WriteReviewScreen(job: currentJob),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppConstants.secondaryColor,
                  ),
                  child: const Text('Add Review'),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Row(
                children: const [
                  Text(
                    'Recent',
                    style: TextStyle(color: AppConstants.textSecondaryColor),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.expand_more,
                    size: 18,
                    color: AppConstants.textSecondaryColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          ...reviews.map(_buildReviewCard),
        ],
      ),
    );
  }

  Widget _buildReviewSummaryCard(
    double rating,
    int reviewsCount,
    Map<int, double> breakdown,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '/5',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${(reviewsCount / 1000).toStringAsFixed(1)}k Review',
                  style: const TextStyle(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStarRow(rating),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              children: [
                for (int i = 5; i >= 1; i--)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text(
                            '$i Star',
                            style: const TextStyle(
                              color: AppConstants.textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: breakdown[i] ?? 0.0,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE2E8F0),
                              color: AppConstants.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRow(double rating) {
    final int fullStars = rating.floor();
    final bool hasHalf = (rating - fullStars) >= 0.5;
    return Row(
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            i <= fullStars
                ? Icons.star
                : (i == fullStars + 1 && hasHalf)
                ? Icons.star_half
                : Icons.star_border,
            size: 20,
            color: AppConstants.warningColor,
          ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final double rating = (review['rating'] is num)
        ? (review['rating'] as num).toDouble()
        : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: AppConstants.warningColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Text(
                  review['name']?.toString() ?? 'Anonymous',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
              ),
              Text(
                review['time']?.toString() ?? '',
                style: const TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            review['text']?.toString() ?? '',
            style: const TextStyle(
              color: AppConstants.textSecondaryColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the job tags section
  Widget _buildJobTags(Map<String, dynamic> currentJob) {
    final tags = currentJob['tags'] as List<dynamic>? ?? [];

    return Wrap(
      spacing: 8,
      children: tags
          .map(
            (tag) => DecoratedBox(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(5),

                border: Border.all(color: Color.fromARGB(47, 0, 38, 84)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  tag.toString(),
                  style: const TextStyle(
                    color: AppConstants.textPrimaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// Builds the salary and time row (matches screenshot layout)
  Widget _buildSalaryAndTimeRow(Map<String, dynamic> currentJob) {
    return Row(
      children: [
        Expanded(
          child: Text(
            currentJob['salary'] ?? 'Salary not specified',
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          currentJob['time'] ?? '',
          style: const TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  // Location/time row from previous design is intentionally removed to match screenshot

  /// Key responsibilities list (falls back to available lists)
  Widget _buildKeyResponsibilities(Map<String, dynamic> currentJob) {
    final List<dynamic> responsibilities =
        (currentJob['responsibilities'] as List<dynamic>?) ??
        (currentJob['requirements'] as List<dynamic>?) ??
        (currentJob['benefits'] as List<dynamic>?) ??
        [];

    if (responsibilities.isEmpty) {
      return const Text(
        'Details will be provided during the interview process.',
        style: TextStyle(color: AppConstants.textSecondaryColor),
      );
    }

    return Column(
      children: responsibilities
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.circle,
                      size: 8,
                      color: AppConstants.accentColor,
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppConstants.textPrimaryColor,
                        height: 1.45,
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
  Widget _buildApplyButton(BuildContext context, Map<String, dynamic> currentJob) {
    // Check if user has already applied for this job
    final applicationData = currentJob['application'] is Map<String, dynamic>
        ? currentJob['application'] as Map<String, dynamic>
        : null;
  
    final applicationIdRaw = _applicationId ??
        currentJob['application_id']?.toString() ??
        applicationData?['application_id']?.toString() ??
        applicationData?['id']?.toString() ??
        currentJob['applicationId']?.toString();
  
    final hasApplied = applicationIdRaw != null && applicationIdRaw.isNotEmpty;
    final applicationId = hasApplied ? applicationIdRaw : '';

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
              backgroundColor: AppConstants.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.smallBorderRadius,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              if (hasApplied) {
                // Navigate to application detail page
                _navigateToApplicationDetail(context, applicationId, currentJob);
              } else {
                // Navigate directly to job application step
                _navigateToJobStep(context);
              }
            },
            child: Text(
              hasApplied ? 'Track Application' : AppConstants.applyJobText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to determine job ID for application.'),
          backgroundColor: Colors.red,
        ),
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
