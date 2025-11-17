import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../bloc/interviews_bloc.dart';
import '../bloc/interviews_event.dart';
import '../bloc/interviews_state.dart';
import '../models/interview_detail.dart';

class InterviewDetailScreen extends StatefulWidget {
  final int interviewId;

  const InterviewDetailScreen({
    super.key,
    required this.interviewId,
  });

  @override
  State<InterviewDetailScreen> createState() => _InterviewDetailScreenState();
}

class _InterviewDetailScreenState extends State<InterviewDetailScreen> {
  /// Capitalizes the first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void initState() {
    super.initState();
    // Load interview detail when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InterviewsBloc>().add(
              LoadInterviewDetailEvent(interviewId: widget.interviewId),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppConstants.cardBackgroundColor,
        appBar: const SimpleAppBar(
          title: 'Interview Details',
          showBackButton: true,
        ),
        body: BlocBuilder<InterviewsBloc, InterviewsState>(
          builder: (context, state) {
            if (state is InterviewDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppConstants.successColor,
                ),
              );
            }

            if (state is InterviewDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final bloc = context.read<InterviewsBloc>();
                        bloc.add(LoadInterviewDetailEvent(interviewId: widget.interviewId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is InterviewDetailLoaded) {
              try {
                final detail = InterviewDetail.fromJson(state.interviewDetail);
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: _buildInterviewDetailContent(context, detail),
                );
              } catch (e) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to parse interview details: $e',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
            }

            return const SizedBox.shrink();
          },
        ),
    );
  }

  Widget _buildInterviewDetailContent(
    BuildContext context,
    InterviewDetail detail,
  ) {
    final isOnline = detail.mode.toLowerCase() == 'online';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Card
        _buildHeaderCard(detail),
        const SizedBox(height: AppConstants.defaultPadding),

        // Interview Information Card
        _buildInterviewInfoCard(detail, isOnline),
        const SizedBox(height: AppConstants.defaultPadding),

        // Job Information Card
        _buildJobInfoCard(detail),
        const SizedBox(height: AppConstants.defaultPadding),

        // Company Information Card
        _buildCompanyInfoCard(detail),
        const SizedBox(height: AppConstants.defaultPadding),

        // Panel Information Card
        if (detail.panel.isNotEmpty) ...[
          _buildPanelInfoCard(detail),
          const SizedBox(height: AppConstants.defaultPadding),
        ],

        // Application Information Card
        _buildApplicationInfoCard(detail),
      ],
    );
  }

  /// Builds the header card with job title and company
  Widget _buildHeaderCard(InterviewDetail detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppConstants.successColor,
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                ),
                child: const Icon(Icons.work, color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capitalizeFirst(detail.job.title),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _capitalizeFirst(detail.company.companyName),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppConstants.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(detail.interviewStatus),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  detail.interviewStatus[0].toUpperCase() +
                      detail.interviewStatus.substring(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the interview information card
  Widget _buildInterviewInfoCard(InterviewDetail detail, bool isOnline) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interview Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildInfoRow(
            Icons.calendar_today,
            'Date & Time',
            '${detail.formattedDate} at ${detail.formattedTime}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            isOnline ? Icons.video_call : Icons.business,
            'Mode',
            isOnline ? 'Online Interview' : 'On-site Interview',
          ),
          // For online: show platform with join meeting button
          if (isOnline) ...[
            if (detail.platformName != null && detail.platformName!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPlatformWithJoinButton(
                detail.platformName!,
                detail.interviewLink,
              ),
            ],
          ] else ...[
            // For offline: show location
            if (detail.interviewLocation != null && detail.interviewLocation!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.pin_drop,
                'Location',
                detail.interviewLocation!,
              ),
            ],
          ],
          // Show interview info (renamed from feedback)
          if (detail.interviewInfo != null && detail.interviewInfo!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.info_outline,
              'Interview Info',
              detail.interviewInfo!,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the job information card
  Widget _buildJobInfoCard(InterviewDetail detail) {
    final job = detail.job;
    final salaryText = job.salaryMin > 0 && job.salaryMax > 0
        ? '₹${job.salaryMin.toStringAsFixed(0)} - ₹${job.salaryMax.toStringAsFixed(0)}'
        : 'Not specified';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
          if (job.description.isNotEmpty) ...[
            Text(
              job.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            const Divider(),
            const SizedBox(height: AppConstants.defaultPadding),
          ],
          _buildInfoRow(Icons.location_on, 'Location', job.location),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.work, 'Job Type', job.jobType),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.currency_rupee, 'Salary', salaryText),
          if (job.experienceRequired.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.trending_up,
              'Experience',
              job.experienceRequired,
            ),
          ],
          if (job.skillsRequired.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.code,
              'Skills Required',
              job.skillsRequired,
            ),
          ],
          if (job.noOfVacancies > 0) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.people,
              'Vacancies',
              job.noOfVacancies.toString(),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the company information card
  Widget _buildCompanyInfoCard(InterviewDetail detail) {
    final company = detail.company;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
          _buildInfoRow(
            Icons.business,
            'Company Name',
            _capitalizeFirst(company.companyName),
          ),
          if (company.companyAddress.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on,
              'Address',
              company.companyAddress,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the panel information card
  Widget _buildPanelInfoCard(InterviewDetail detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interview Panel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ...detail.panel.map((panelist) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 18,
                            color: AppConstants.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              panelist.panelistName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.textPrimaryColor,
                              ),
                            ),
                          ),
                          if (panelist.rating != null)
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < panelist.rating!
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: Colors.orange,
                                  );
                                }),
                              ],
                            ),
                        ],
                      ),
                      if (panelist.feedback != null &&
                          panelist.feedback!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          panelist.feedback!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// Builds the application information card
  Widget _buildApplicationInfoCard(InterviewDetail detail) {
    final application = detail.application;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildInfoRow(
            Icons.description,
            'Application Status',
            application.status[0].toUpperCase() +
                application.status.substring(1),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Applied On',
            _formatDate(application.appliedAt),
          ),
          if (application.coverLetter != null &&
              application.coverLetter!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Your Cover Letter',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              application.coverLetter!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds an info row with icon and text
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppConstants.primaryColor),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              isLink
                  ? GestureDetector(
                      onTap: () => _launchUrl(value),
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.primaryColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds platform with join meeting button
  Widget _buildPlatformWithJoinButton(String platformName, String? meetingLink) {
    final hasMeetingLink = meetingLink != null && meetingLink.isNotEmpty;
    final link = meetingLink ?? '';
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.video_library,
          size: 18,
          color: AppConstants.primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Platform',
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    platformName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppConstants.textPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hasMeetingLink) ...[
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _launchUrl(link),
                      icon: const Icon(Icons.video_call, size: 16),
                      label: const Text('Join Meeting'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Launches a URL
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open: $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Gets status color based on interview status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppConstants.successColor;
      case 'completed':
        return AppConstants.primaryColor;
      case 'cancelled':
        return Colors.red;
      default:
        return AppConstants.textSecondaryColor;
    }
  }

  /// Formats date string
  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = _getMonthName(dateTime.month);
      final year = dateTime.year.toString();
      return '$day $month $year';
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

