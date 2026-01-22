import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/empty_state_widget.dart';
import '../../../shared/widgets/common/no_internet_widget.dart';
import '../bloc/campus_drive_bloc.dart';
import '../bloc/campus_drive_event.dart';
import '../bloc/campus_drive_state.dart';
import '../models/campus_application.dart';

class MyApplicationsList extends StatefulWidget {
  const MyApplicationsList({super.key});

  @override
  State<MyApplicationsList> createState() => _MyApplicationsListState();
}

class _MyApplicationsListState extends State<MyApplicationsList> {
  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  void _loadApplications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CampusDriveBloc>().add(const LoadMyApplicationsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CampusDriveBloc, CampusDriveState>(
      listener: (context, state) {
        // Error handling
      },
      builder: (context, state) {
        if (state.isMyApplicationsLoading && state.myApplications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.secondaryColor,
              ),
            ),
          );
        }

        if (state.status == CampusDriveStatus.failure &&
            state.myApplications.isEmpty) {
          return NoInternetWidget(
            onRefresh: () {
              context.read<CampusDriveBloc>().add(
                const LoadMyApplicationsEvent(),
              );
            },
          );
        }

        if (state.myApplications.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.assignment_outlined,
            title: 'No Applications Yet',
            subtitle: 'You haven\'t applied to any campus drives yet.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<CampusDriveBloc>().add(
              const LoadMyApplicationsEvent(),
            );
          },
          color: AppConstants.secondaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: state.myApplications.length,
            itemBuilder: (context, index) {
              final application = state.myApplications[index];
              return _ApplicationCard(
                application: application,
                onTap: () {
                  context.push(
                    AppRoutes.campusApplicationDetailsWithId(
                      application.id.toString(),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final CampusApplication application;
  final VoidCallback onTap;

  const _ApplicationCard({required this.application, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
                          application.driveTitle ??
                              'Application #${application.id}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(application.status),
                ],
              ),
              if (application.preferences.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.business,
                      size: 16,
                      color: AppConstants.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Preferences: ${application.preferences.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: application.preferences.map((pref) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        pref.companyName ?? 'Company ${pref.companyId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Applied on date
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppConstants.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Applied on: ${_formatDate(application.appliedAt)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // View Application Details Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.smallBorderRadius,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'View Application Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
