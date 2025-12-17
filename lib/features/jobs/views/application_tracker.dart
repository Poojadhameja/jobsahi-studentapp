import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/profile_navigation_app_bar.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/widgets/common/empty_state_widget.dart';
import '../../../shared/widgets/common/top_snackbar.dart';
import '../../../shared/widgets/cards/shortlisted_job_card.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';

class ApplicationTrackerScreen extends StatefulWidget {
  /// Whether this screen is opened from profile navigation
  final bool isFromProfile;

  const ApplicationTrackerScreen({super.key, this.isFromProfile = false});

  @override
  State<ApplicationTrackerScreen> createState() =>
      _ApplicationTrackerScreenState();
}

class _ApplicationTrackerScreenState extends State<ApplicationTrackerScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch event after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<JobsBloc>().add(const LoadApplicationTrackerEvent());
        } catch (e) {
          debugPrint('Error dispatching LoadApplicationTrackerEvent: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ApplicationTrackerScreenView(isFromProfile: widget.isFromProfile);
  }
}

class _ApplicationTrackerScreenView extends StatefulWidget {
  final bool isFromProfile;

  const _ApplicationTrackerScreenView({required this.isFromProfile});

  @override
  State<_ApplicationTrackerScreenView> createState() =>
      _ApplicationTrackerScreenViewState();
}

class _ApplicationTrackerScreenViewState
    extends State<_ApplicationTrackerScreenView>
    with TickerProviderStateMixin {
  TabController? _tabController;

  // Cache the last loaded data to prevent showing empty state during reload
  List<Map<String, dynamic>> _cachedAppliedJobs = [];
  List<Map<String, dynamic>> _cachedInterviewJobs = [];
  List<Map<String, dynamic>> _cachedHiredJobs = [];
  bool _cacheInitialized = false;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize cache from BLoC state if available (only once, before first build)
    if (!_cacheInitialized) {
      _initializeCacheFromBloC();
      _cacheInitialized = true;
    }
  }

  /// Initialize cache from existing BLoC state if available
  void _initializeCacheFromBloC() {
    try {
      final currentState = context.read<JobsBloc>().state;

      if (currentState is ApplicationTrackerLoaded) {
        _cachedAppliedJobs = List.from(currentState.appliedJobs);
        _cachedInterviewJobs = List.from(currentState.interviewJobs);
        _cachedHiredJobs = List.from(currentState.hiredJobs);
        _hasLoadedOnce = true; // Mark as loaded if cache exists
      }
      // Check JobsLoaded state for cached tracker data
      else if (currentState is JobsLoaded) {
        if (currentState.trackerAppliedJobs != null &&
            currentState.trackerInterviewJobs != null &&
            (currentState.trackerAppliedJobs!.isNotEmpty ||
                currentState.trackerInterviewJobs!.isNotEmpty ||
                (currentState.trackerHiredJobs != null &&
                    currentState.trackerHiredJobs!.isNotEmpty))) {
          _cachedAppliedJobs = List.from(currentState.trackerAppliedJobs!);
          _cachedInterviewJobs = List.from(currentState.trackerInterviewJobs!);
          _cachedHiredJobs = List.from(currentState.trackerHiredJobs ?? []);
          _hasLoadedOnce = true; // Mark as loaded if cache exists
        }
      }
    } catch (e) {
      debugPrint('Error initializing tracker cache: $e');
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  /// Capitalizes the first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Safely extracts company name from job data
  /// Handles both string and nested map formats
  String _getCompanyName(Map<String, dynamic> job, [String fallback = '']) {
    String companyName = '';

    // First try company_name (flat string from SavedJobItem.toMap())
    if (job['company_name'] != null) {
      final name = job['company_name'];
      if (name is String && name.isNotEmpty) {
        companyName = name;
      } else if (name != null) {
        companyName = name.toString();
      }
    }

    // Then try company as string
    if (companyName.isEmpty) {
      final company = job['company'];
      if (company != null) {
        // If company is a Map/LinkedMap, extract company_name
        if (company is Map) {
          final companyNameValue = company['company_name'];
          if (companyNameValue != null) {
            if (companyNameValue is String && companyNameValue.isNotEmpty) {
              companyName = companyNameValue;
            } else {
              companyName = companyNameValue.toString();
            }
          }
        } else if (company is String) {
          companyName = company;
        } else {
          companyName = company.toString();
        }
      }
    }

    // Fallback
    if (companyName.isEmpty) {
      companyName = fallback.isNotEmpty ? fallback : '';
    }

    // Capitalize first letter before returning
    return companyName.isNotEmpty ? _capitalizeFirst(companyName) : companyName;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        // Handle system back button - navigate back to menu if from profile
        if (widget.isFromProfile) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.profile);
          }
        } else {
          // Normal navigation for bottom nav
          if (context.canPop()) {
            context.pop();
          }
        }
      },
      child: BlocListener<JobsBloc, JobsState>(
        listener: (context, state) {
          if (state is ApplicationViewed) {
            TopSnackBar.showSuccess(
              context,
              message: 'Viewing application: ${state.applicationId}',
            );
          } else if (state is ApplyForMoreJobsState) {
            TopSnackBar.showInfo(
              context,
              message:
                  'Apply for more jobs functionality will be implemented here',
            );
          } else if (state is JobsError) {
            TopSnackBar.showError(context, message: state.message);
          }
        },
        child: KeyboardDismissWrapper(
          child: Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            appBar: widget.isFromProfile
                ? ProfileNavigationAppBar(title: 'Job Status')
                : null,
            body: BlocBuilder<JobsBloc, JobsState>(
              buildWhen: (previous, current) {
                // Always rebuild for these states
                if (current is ApplicationTrackerLoaded) return true;
                if (current is JobsError) return true;
                if (current is JobsLoading && previous is! JobsLoading)
                  return true;

                // Rebuild when JobsLoaded has tracker data
                if (current is JobsLoaded) {
                  // If we're on the tracker screen and JobsLoaded has tracker data, rebuild
                  if (current.trackerAppliedJobs != null ||
                      current.trackerInterviewJobs != null) {
                    // Check if tracker data actually changed
                    if (previous is JobsLoaded) {
                      return previous.trackerAppliedJobs !=
                              current.trackerAppliedJobs ||
                          previous.trackerInterviewJobs !=
                              current.trackerInterviewJobs;
                    }
                    // First time seeing JobsLoaded with tracker data
                    return true;
                  }
                }

                // Don't rebuild for other state changes
                return false;
              },
              builder: (context, state) {
                // Get data from state and update cache when data is available
                List<Map<String, dynamic>> appliedJobs = _cachedAppliedJobs;
                List<Map<String, dynamic>> interviewJobs = _cachedInterviewJobs;
                List<Map<String, dynamic>> hiredJobs = _cachedHiredJobs;

                if (state is ApplicationTrackerLoaded) {
                  // Mark as loaded at least once
                  _hasLoadedOnce = true;
                  // Update cache with latest data only if different
                  if (_cachedAppliedJobs != state.appliedJobs ||
                      _cachedInterviewJobs != state.interviewJobs ||
                      _cachedHiredJobs != state.hiredJobs) {
                    _cachedAppliedJobs = List.from(state.appliedJobs);
                    _cachedInterviewJobs = List.from(state.interviewJobs);
                    _cachedHiredJobs = List.from(state.hiredJobs);
                  }
                  appliedJobs = state.appliedJobs;
                  interviewJobs = state.interviewJobs;
                  hiredJobs = state.hiredJobs;
                }
                // Also check JobsLoaded for tracker data
                else if (state is JobsLoaded &&
                    state.trackerAppliedJobs != null &&
                    state.trackerInterviewJobs != null) {
                  // Mark as loaded since we have data from JobsLoaded
                  if (!_hasLoadedOnce &&
                      (state.trackerAppliedJobs!.isNotEmpty ||
                          state.trackerInterviewJobs!.isNotEmpty ||
                          (state.trackerHiredJobs != null &&
                              state.trackerHiredJobs!.isNotEmpty))) {
                    _hasLoadedOnce = true;
                  }

                  // Update cache with tracker data from JobsLoaded only if different
                  if (_cachedAppliedJobs != state.trackerAppliedJobs! ||
                      _cachedInterviewJobs != state.trackerInterviewJobs! ||
                      _cachedHiredJobs != (state.trackerHiredJobs ?? [])) {
                    _cachedAppliedJobs = List.from(state.trackerAppliedJobs!);
                    _cachedInterviewJobs = List.from(
                      state.trackerInterviewJobs!,
                    );
                    _cachedHiredJobs = List.from(state.trackerHiredJobs ?? []);
                  }
                  appliedJobs = state.trackerAppliedJobs!;
                  interviewJobs = state.trackerInterviewJobs!;
                  hiredJobs = state.trackerHiredJobs ?? [];
                }

                // Determine if we should show loading state inside tabs
                // (instead of replacing entire widget with loading spinner)
                final hasAnyCachedData =
                    _cachedAppliedJobs.isNotEmpty ||
                    _cachedInterviewJobs.isNotEmpty ||
                    _cachedHiredJobs.isNotEmpty;
                final isCurrentlyLoading =
                    state is JobsLoading || state is JobsInitial;

                // Check if this is first load with no cache
                final isFirstLoad =
                    isCurrentlyLoading && !_hasLoadedOnce && !hasAnyCachedData;

                // Always show tabs structure - show loading inside tabs if needed
                return Column(
                  children: [
                    if (!widget.isFromProfile) _buildTabBar(),
                    Expanded(
                      child: isFirstLoad
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppConstants.secondaryColor,
                              ),
                            )
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildAppliedTab(context, appliedJobs),
                                _buildInterviewTab(context, interviewJobs),
                                _buildHiredTab(context, hiredJobs),
                              ],
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the tab bar similar to learning center
  Widget _buildTabBar() {
    return Container(
      color: AppConstants.cardBackgroundColor,
      child: TabBar(
        controller: _tabController,
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        indicatorColor: AppConstants.primaryColor,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Applied'),
          Tab(text: 'Shortlisted'),
          Tab(text: 'Hired'),
        ],
      ),
    );
  }

  /// Builds the applied tab content
  Widget _buildAppliedTab(
    BuildContext context,
    List<Map<String, dynamic>> appliedJobs,
  ) {
    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        // Update appliedJobs from state if available
        List<Map<String, dynamic>> currentAppliedJobs = appliedJobs;
        if (state is ApplicationTrackerLoaded) {
          currentAppliedJobs = state.appliedJobs;
        }

        return RefreshIndicator(
          color: AppConstants.successColor,
          onRefresh: () async {
            context.read<JobsBloc>().add(const LoadApplicationTrackerEvent());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: _buildAppliedCard(context, currentAppliedJobs),
          ),
        );
      },
    );
  }

  /// Builds the interview tab content
  Widget _buildInterviewTab(
    BuildContext context,
    List<Map<String, dynamic>> interviewJobs,
  ) {
    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        // Get latest data from state
        List<Map<String, dynamic>> currentInterviewJobs = interviewJobs;
        if (state is ApplicationTrackerLoaded) {
          currentInterviewJobs = state.interviewJobs;
        }

        return RefreshIndicator(
          color: AppConstants.successColor,
          onRefresh: () async {
            context.read<JobsBloc>().add(const LoadApplicationTrackerEvent());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: _buildInterviewCards(context, currentInterviewJobs),
          ),
        );
      },
    );
  }

  /// Builds the hired tab content
  Widget _buildHiredTab(
    BuildContext context,
    List<Map<String, dynamic>> hiredJobs,
  ) {
    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        // Get latest data from state
        List<Map<String, dynamic>> currentHiredJobs = hiredJobs;
        if (state is ApplicationTrackerLoaded) {
          currentHiredJobs = state.hiredJobs;
        }

        return RefreshIndicator(
          color: AppConstants.successColor,
          onRefresh: () async {
            context.read<JobsBloc>().add(const LoadApplicationTrackerEvent());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: _buildHiredCards(context, currentHiredJobs),
          ),
        );
      },
    );
  }

  /// Builds the applied job cards
  Widget _buildAppliedCard(
    BuildContext context,
    List<Map<String, dynamic>> appliedJobs,
  ) {
    if (appliedJobs.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: EmptyStateWidget(
            icon: Icons.description_outlined,
            title: 'No Applied Jobs',
            subtitle:
                'You haven\'t applied to any jobs yet.\nBrowse jobs and apply to the ones you\'re interested in.',
            actionButton: ElevatedButton(
              onPressed: () {
                context.goNamed('home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
              ),
              child: const Text(
                'Browse Jobs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      );
    }

    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        // Get latest data from state
        List<Map<String, dynamic>> currentAppliedJobs = appliedJobs;
        if (state is ApplicationTrackerLoaded) {
          currentAppliedJobs = state.appliedJobs;
        }

        return ListView.builder(
          itemCount: currentAppliedJobs.length,
          itemBuilder: (context, index) {
            final job = currentAppliedJobs[index];
            final applicationId =
                job['application_id']?.toString() ??
                job['id']?.toString() ??
                '$index';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildAppliedJobCard(
                context: context,
                jobTitle: _capitalizeFirst(
                  job['title']?.toString() ?? 'Job Title',
                ),
                companyName: _getCompanyName(job, 'Company Name'),
                location: job['location']?.toString() ?? 'Location',
                experience: job['experience']?.toString() ?? 'Fresher',
                appliedDate: job['appliedDate']?.toString() ?? 'Applied Date',
                positions: job['positions']?.toString() ?? 'Positions',
                salary: job['salary']?.toString() ?? '',
                applicationId: applicationId,
                jobData: job,
                status: job['status']?.toString() ?? 'Applied',
              ),
            );
          },
        );
      },
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
    required String salary,
    required String applicationId,
    required Map<String, dynamic> jobData,
    required String status,
  }) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, title, company, and status badge
            _buildJobHeader(jobTitle, companyName, status, jobData),
            const SizedBox(height: AppConstants.smallPadding),
            // Job info (location and experience)
            _buildJobInfo(location, experience),
            const SizedBox(height: AppConstants.smallPadding),
            // Salary info
            if (salary.isNotEmpty) ...[
              _buildSalaryInfo(salary),
              const SizedBox(height: AppConstants.smallPadding),
            ],
            // Applied date and deadline
            _buildJobDateInfo(appliedDate, positions),
            const SizedBox(height: AppConstants.smallPadding),
            // View Application button
            _buildActionButton(context, applicationId, jobData),
          ],
        ),
      ),
    );
  }

  /// Returns icon based on job application status
  IconData _getStatusIcon(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower == 'hired' || statusLower == 'selected') {
      return Icons.celebration; // Celebration icon for hired
    } else if (statusLower == 'shortlisted') {
      return Icons.check_circle; // Check circle for shortlisted
    } else {
      return Icons.work; // Work/bag icon for applied
    }
  }

  /// Safely extracts company logo URL from job data
  String? _getCompanyLogo(Map<String, dynamic> jobData) {
    // First try company_logo (flat string)
    if (jobData['company_logo'] != null) {
      final logo = jobData['company_logo'];
      if (logo is String && logo.isNotEmpty) {
        return logo;
      }
    }
    
    // Then try company as map with company_logo
    final company = jobData['company'];
    if (company != null && company is Map) {
      final logo = company['company_logo'];
      if (logo != null && logo is String && logo.isNotEmpty) {
        return logo;
      }
    }
    
    return null;
  }

  /// Builds the header with icon, title, company, and status badge
  Widget _buildJobHeader(String jobTitle, String companyName, String status, Map<String, dynamic> jobData) {
    final statusLower = status.toLowerCase();
    final companyLogoUrl = _getCompanyLogo(jobData);
    
    return Row(
      children: [
        // Company logo or job icon - based on status
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: companyLogoUrl != null 
                ? Colors.transparent 
                : AppConstants.successColor,
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          child: companyLogoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppConstants.smallBorderRadius,
                  ),
                  child: Image.network(
                    companyLogoUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppConstants.successColor,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppConstants.successColor,
                        child: Icon(_getStatusIcon(status), color: Colors.white, size: 24),
                      );
                    },
                  ),
                )
              : Icon(_getStatusIcon(status), color: Colors.white, size: 24),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        // Job title and company
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jobTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                companyName,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Status badge (show for Applied, Shortlisted, and Hired)
        if (statusLower == 'applied' ||
            statusLower == 'shortlisted' ||
            statusLower == 'hired' ||
            statusLower == 'selected')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusLower == 'applied'
                  ? AppConstants
                        .primaryColor // Blue for applied
                  : statusLower == 'shortlisted'
                  ? AppConstants
                        .warningColor // Orange for shortlisted
                  : AppConstants.successColor, // Green for hired
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              statusLower == 'selected' ? 'Hired' : status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  /// Builds job info section (location and experience)
  Widget _buildJobInfo(String location, String experience) {
    return Row(
      children: [
        Flexible(
          child: Text(
            location,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Text(
          ' • ',
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
            height: 1.4,
          ),
        ),
        Flexible(
          child: Text(
            experience,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds salary information section
  Widget _buildSalaryInfo(String salary) {
    return Text(
      salary,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppConstants.successColor, // Green color matching button
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  /// Builds date info section (applied date and deadline)
  Widget _buildJobDateInfo(String appliedDate, String positions) {
    return Row(
      children: [
        // Applied date
        Text(
          'Applied: $appliedDate',
          style: const TextStyle(
            fontSize: 14,
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        // Deadline/Positions info
        if (positions.isNotEmpty && positions != 'Positions')
          Text(
            positions,
            style: const TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
            ),
          ),
      ],
    );
  }

  /// Builds the action button
  Widget _buildActionButton(
    BuildContext context,
    String applicationId,
    Map<String, dynamic> jobData,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (applicationId.isEmpty) {
            TopSnackBar.showError(
              context,
              message: 'Application ID not available.',
            );
            return;
          }

          final navigationData = Map<String, dynamic>.from(jobData);
          navigationData['_navigation_source'] = 'applied_jobs';

          context.pushNamed(
            'studentApplicationDetail',
            pathParameters: {'id': applicationId},
            extra: navigationData,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.successColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          'Application Details',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Builds the interview cards
  Widget _buildInterviewCards(
    BuildContext context,
    List<Map<String, dynamic>> interviewJobs,
  ) {
    if (interviewJobs.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: EmptyStateWidget(
            icon: Icons.star_outline,
            title: 'No Shortlisted Jobs',
            subtitle:
                'You haven\'t been shortlisted for any jobs yet.\nBrowse jobs and apply to the ones you\'re interested in.',
            actionButton: ElevatedButton(
              onPressed: () {
                context.goNamed('home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
              ),
              child: const Text(
                'Browse Jobs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      );
    }

    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        // Get latest data from state
        List<Map<String, dynamic>> currentInterviewJobs = interviewJobs;
        if (state is ApplicationTrackerLoaded) {
          currentInterviewJobs = state.interviewJobs;
        }

        return ListView.builder(
          itemCount: currentInterviewJobs.length,
          itemBuilder: (context, index) {
            final job = currentInterviewJobs[index];

            // Get backend data - prioritize interview data from API
            final mode = job['mode']?.toString() ?? '';
            final isOnline = mode.toLowerCase() == 'online';

            // For location: online uses platform_name, offline uses location
            String displayLocation = '';
            if (isOnline) {
              // Show platform name instead of link for online interviews
              displayLocation = job['platform_name']?.toString() ?? '';
            } else {
              displayLocation = job['location']?.toString() ?? '';
            }

            // Get interview date/time from backend (scheduled_at)
            String interviewDate = '';
            String interviewTime = '';
            final scheduledAt = job['scheduled_at']?.toString() ?? '';
            if (scheduledAt.isNotEmpty) {
              try {
                final dateTime = DateTime.parse(scheduledAt);
                final day = dateTime.day.toString().padLeft(2, '0');
                final month = _getMonthName(dateTime.month);
                final year = dateTime.year.toString();
                interviewDate = '$day $month $year';

                final hour = dateTime.hour;
                final minute = dateTime.minute.toString().padLeft(2, '0');
                final period = hour >= 12 ? 'PM' : 'AM';
                final displayHour = hour > 12
                    ? hour - 12
                    : (hour == 0 ? 12 : hour);
                interviewTime = '$displayHour:$minute $period';
              } catch (e) {
                // Fallback to formatted fields if parsing fails
                interviewDate =
                    job['interviewDate']?.toString() ??
                    job['appliedDate']?.toString() ??
                    '';
                interviewTime = job['interviewTime']?.toString() ?? '';
              }
            } else {
              // Fallback to formatted fields if scheduled_at not available
              interviewDate =
                  job['interviewDate']?.toString() ??
                  job['appliedDate']?.toString() ??
                  '';
              interviewTime = job['interviewTime']?.toString() ?? '';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ShortlistedJobCard(
                jobTitle: _capitalizeFirst(
                  job['title']?.toString() ?? 'Job Title',
                ),
                companyName: _getCompanyName(job, 'Company Name'),
                location: displayLocation,
                interviewDate: interviewDate,
                interviewTime: interviewTime,
                mode: mode,
                status: job['status']?.toString() ?? 'Shortlisted',
                salary: job['salary']?.toString() ?? '',
                appliedDate: job['appliedDate']?.toString() ?? '',
                appliedTime: job['appliedTime']?.toString() ?? '',
                jobData: job,
              ),
            );
          },
        );
      },
    );
  }

  /// Builds the hired job cards
  Widget _buildHiredCards(
    BuildContext context,
    List<Map<String, dynamic>> hiredJobs,
  ) {
    if (hiredJobs.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: EmptyStateWidget(
            icon: Icons.work_outlined,
            title: 'No Hired Jobs',
            subtitle:
                'You haven\'t been hired for any jobs yet.\nKeep applying and improving your profile!',
            actionButton: ElevatedButton(
              onPressed: () {
                context.goNamed('home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
              ),
              child: const Text(
                'Browse Jobs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      );
    }

    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        // Get latest data from state
        List<Map<String, dynamic>> currentHiredJobs = hiredJobs;
        if (state is ApplicationTrackerLoaded) {
          currentHiredJobs = state.hiredJobs;
        }

        return ListView.builder(
          itemCount: currentHiredJobs.length,
          itemBuilder: (context, index) {
            final job = currentHiredJobs[index];
            final applicationId =
                job['application_id']?.toString() ??
                job['id']?.toString() ??
                '$index';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildHiredJobCard(
                context: context,
                jobTitle: _capitalizeFirst(
                  job['title']?.toString() ?? 'Job Title',
                ),
                companyName: _getCompanyName(job, 'Company Name'),
                location: job['location']?.toString() ?? 'Location',
                experience: job['experience']?.toString() ?? 'Fresher',
                applicationDate:
                    job['appliedDate']?.toString() ?? 'Applied Date',
                shortlistedDate: job['shortlisted_date']?.toString(),
                hiredDate: job['hiredDate']?.toString() ?? 'Hired Date',
                salary: job['salary']?.toString() ?? '',
                applicationId: applicationId,
                jobData: job,
                status: job['status']?.toString() ?? 'Hired',
              ),
            );
          },
        );
      },
    );
  }

  /// Builds an individual hired job card
  Widget _buildHiredJobCard({
    required BuildContext context,
    required String jobTitle,
    required String companyName,
    required String location,
    required String experience,
    required String applicationDate,
    String? shortlistedDate,
    required String hiredDate,
    required String salary,
    required String applicationId,
    required Map<String, dynamic> jobData,
    required String status,
  }) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, title, company, and status badge
            Row(
              children: [
                // Company logo or job icon - based on status
                Builder(
                  builder: (context) {
                    final companyLogoUrl = _getCompanyLogo(jobData);
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: companyLogoUrl != null 
                            ? Colors.transparent 
                            : AppConstants.successColor,
                        borderRadius: BorderRadius.circular(
                          AppConstants.smallBorderRadius,
                        ),
                      ),
                      child: companyLogoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppConstants.smallBorderRadius,
                              ),
                              child: Image.network(
                                companyLogoUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: AppConstants.successColor,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppConstants.successColor,
                                    child: Icon(
                                      _getStatusIcon(status),
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Icon(
                              _getStatusIcon(status),
                              color: Colors.white,
                              size: 24,
                            ),
                    );
                  },
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                // Job title and company
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        companyName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status badge - "Hired"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.successColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Hired',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            // Job info (location and experience)
            _buildJobInfo(location, experience),
            const SizedBox(height: AppConstants.smallPadding),
            // Salary info
            if (salary.isNotEmpty) ...[
              _buildSalaryInfo(salary),
              const SizedBox(height: AppConstants.smallPadding),
            ],
            // Dates info
            _buildHiredDateInfo(applicationDate, shortlistedDate, hiredDate),
            const SizedBox(height: AppConstants.smallPadding),
            // View Details button
            _buildHiredActionButton(context, applicationId, jobData),
          ],
        ),
      ),
    );
  }

  /// Builds date info section for hired jobs
  Widget _buildHiredDateInfo(
    String applicationDate,
    String? shortlistedDate,
    String hiredDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Application date
        Text(
          'Applied: $applicationDate',
          style: const TextStyle(
            fontSize: 14,
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        // Shortlisted date (optional)
        if (shortlistedDate != null && shortlistedDate.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Shortlisted: $shortlistedDate',
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        // Hired date
        const SizedBox(height: 4),
        Text(
          'Hired: $hiredDate',
          style: const TextStyle(
            fontSize: 14,
            color: AppConstants.successColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Builds the action button for hired jobs
  Widget _buildHiredActionButton(
    BuildContext context,
    String applicationId,
    Map<String, dynamic> jobData,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (applicationId.isEmpty) {
            TopSnackBar.showError(
              context,
              message: 'Application ID not available.',
            );
            return;
          }

          final navigationData = Map<String, dynamic>.from(jobData);
          navigationData['_navigation_source'] = 'hired_jobs';

          // Navigate to hired job detail (can reuse student application detail or create new)
          context.pushNamed(
            'studentApplicationDetail',
            pathParameters: {'id': applicationId},
            extra: navigationData,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.successColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          'View Details',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Helper method to get month name
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
