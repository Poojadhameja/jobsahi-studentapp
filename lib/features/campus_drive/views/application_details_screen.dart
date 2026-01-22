import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../bloc/campus_drive_bloc.dart';
import '../bloc/campus_drive_event.dart';
import '../bloc/campus_drive_state.dart';
import '../models/campus_application.dart';

class ApplicationDetailsScreen extends StatefulWidget {
  final String applicationId;

  const ApplicationDetailsScreen({super.key, required this.applicationId});

  @override
  State<ApplicationDetailsScreen> createState() =>
      _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final id = int.tryParse(widget.applicationId);
        if (id != null) {
          context.read<CampusDriveBloc>().add(LoadApplicationDetailsEvent(id));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Application Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<CampusDriveBloc, CampusDriveState>(
        listener: (context, state) {
          // Handle errors if needed
        },
        builder: (context, state) {
          if (state.isDetailsLoading &&
              state.selectedApplicationDetails == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.secondaryColor,
                ),
              ),
            );
          }

          if (state.status == CampusDriveStatus.failure &&
              state.selectedApplicationDetails == null) {
            return NoInternetWidget(onRefresh: _loadDetails);
          }

          if (state.selectedApplicationDetails != null) {
            return _buildContent(state.selectedApplicationDetails!);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(CampusApplication application) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      child: const Icon(
                        Icons.assignment_turned_in,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Application #${application.id}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Applied on ${application.appliedAt}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(application.status),
                  ],
                ),
                const SizedBox(height: 24),

                if (application.driveTitle != null) ...[
                  _buildInfoRowWithGreenIcon(
                    Icons.event,
                    'Drive',
                    application.driveTitle!,
                  ),
                  const SizedBox(height: 16),
                ],

                if (application.venue != null) ...[
                  _buildInfoRowWithGreenIcon(
                    Icons.location_on,
                    'Venue',
                    '${application.venue}, ${application.city}',
                  ),
                  const SizedBox(height: 16),
                ],

                if (application.assignedDay != null) ...[
                  _buildInfoRowWithGreenIcon(
                    Icons.calendar_today,
                    'Assigned Day',
                    '${application.assignedDay} (${application.assignedDate})',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Preferences Section
          const Text(
            'Your Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),

          if (application.preferences.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No preferences selected'),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: application.preferences.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pref = application.preferences[index];
                return _PreferenceCard(preference: pref);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'accepted':
      case 'selected':
      case 'pending':
        color = AppConstants.successColor;
        bgColor = AppConstants.successColor.withOpacity(0.1);
        status = "Registered";
        break;

      case 'rejected':
        color = AppConstants.errorColor;
        bgColor = AppConstants.errorColor.withOpacity(0.1);
        break;

      default:
        color = Colors.orange;
        bgColor = Colors.orange.withOpacity(0.1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRowWithGreenIcon(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 18, color: AppConstants.successColor),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  final CampusPreference preference;

  const _PreferenceCard({required this.preference});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preference Number Badge
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppConstants.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${preference.preferenceNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Company Logo
              if (preference.logo != null && preference.logo!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    preference.logo!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.business, color: Colors.grey),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.business, color: Colors.grey),
                ),

              const SizedBox(width: 16),

              // Company Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preference.companyName ?? 'Unknown Company',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    if (preference.jobRoles.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: preference.jobRoles.map((role) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              role,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.successColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (preference.criteria.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            ...preference.criteria.entries.map((entry) {
              final key = entry.key;
              final value = entry.value;

              if (key.startsWith('manual_') ||
                  key.startsWith('_') ||
                  key.toLowerCase() == 'year' ||
                  key.toLowerCase() == 'years' ||
                  key.toLowerCase() == 'branches') {
                return const SizedBox.shrink();
              }

              String displayKey = key.toLowerCase() == 'min_cgpa'
                  ? 'Description'
                  : key
                      .replaceAll('_', ' ')
                      .split(' ')
                      .map((word) => word.isNotEmpty
                          ? word[0].toUpperCase() + word.substring(1)
                          : '')
                      .join(' ');

              String displayValue = value is List
                  ? (value).join(', ')
                  : value.toString();

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        displayKey,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        displayValue,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.textPrimaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
