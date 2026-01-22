/// Campus Drive Details Screen
/// Shows detailed information about a campus drive and companies (Mobile optimized)

library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/top_snackbar.dart';
import '../../../shared/widgets/common/empty_state_widget.dart';
import '../../../core/utils/application_utils.dart';
import '../bloc/campus_drive_bloc.dart';
import '../bloc/campus_drive_event.dart';
import '../bloc/campus_drive_state.dart';
import '../models/campus_drive.dart';

class CampusDriveDetailsScreen extends StatefulWidget {
  final String driveId;

  const CampusDriveDetailsScreen({super.key, required this.driveId});

  @override
  State<CampusDriveDetailsScreen> createState() =>
      _CampusDriveDetailsScreenState();
}

class _CampusDriveDetailsScreenState extends State<CampusDriveDetailsScreen> {
  // Store selected preferences: [company_id_1, company_id_2, ..., company_id_6]
  final List<int?> _selectedPreferences = List.filled(6, null);
  bool _isSubmitting = false;

  // Cache details to prevent white screen during state transitions
  CampusDriveDetails? _cachedDetails;

  // Search and Filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final driveId = int.tryParse(widget.driveId);
    if (driveId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<CampusDriveBloc>().add(LoadDriveDetailsEvent(driveId));
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Get the next available preference number
  int? _getNextPreferenceNumber() {
    for (int i = 0; i < 6; i++) {
      if (_selectedPreferences[i] == null) {
        return i + 1;
      }
    }
    return null;
  }

  // Get applied preference number from existing application
  int? _getAppliedPreference(int companyId, CampusApplication? application) {
    if (application == null) return null;
    for (final pref in application.preferences) {
      // Match using driveCompanyId which is cdc.id (the company card's ID)
      if (pref.driveCompanyId == companyId) {
        return pref.preferenceNumber;
      }
    }
    return null;
  }

  // Check if a company is already selected
  int? _getCompanyPreference(int companyId) {
    for (int i = 0; i < 6; i++) {
      if (_selectedPreferences[i] == companyId) {
        return i + 1;
      }
    }
    return null;
  }

  // Select a company for a preference
  void _selectCompany(int companyId, int? preferenceNumber) {
    setState(() {
      if (preferenceNumber != null) {
        for (int i = 0; i < 6; i++) {
          if (_selectedPreferences[i] == companyId) {
            _selectedPreferences[i] = null;
            break;
          }
        }
        _selectedPreferences[preferenceNumber - 1] = companyId;
      } else {
        for (int i = 0; i < 6; i++) {
          if (_selectedPreferences[i] == companyId) {
            _selectedPreferences[i] = null;
            break;
          }
        }
      }
    });
  }

  // Get button text for a company
  String _getButtonText(
    int companyId, {
    required bool hasApplied,
    required int alreadyAppliedCount,
    CampusApplication? application,
  }) {
    final appliedPref = _getAppliedPreference(companyId, application);
    
    // If already applied to this company from server
    if (appliedPref != null) {
      return 'Applied at ${_getOrdinal(appliedPref)} Preference';
    }

    // Check if selected in current session (not yet submitted)
    final existingPref = _getCompanyPreference(companyId);
    if (existingPref != null) {
      final totalPref = alreadyAppliedCount + existingPref;
      return 'Selected as ${_getOrdinal(totalPref)} Preference';
    }

    // Check if limit reached
    final currentSelectedCount = _selectedPreferences
        .where((p) => p != null)
        .length;
    final totalCount = alreadyAppliedCount + currentSelectedCount;
    
    if (totalCount >= 6) {
      return 'Application Limit Reached';
    }

    // Show next available preference number
    final nextPrefInBatch = _getNextPreferenceNumber();
    if (nextPrefInBatch != null) {
      final nextTotalPref = alreadyAppliedCount + nextPrefInBatch;
      return 'Add as ${_getOrdinal(nextTotalPref)} Preference';
    }

    return 'Add Preference';
  }

  // Helper method to convert number to ordinal (1st, 2nd, 3rd, etc.)
  String _getOrdinal(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  // Check if at least 1 and max 6 preferences are selected
  bool _isSelectionValid() {
    final selectedCount = _selectedPreferences
        .where((pref) => pref != null)
        .length;
    return selectedCount >= 1 && selectedCount <= 6;
  }

  // Submit application
  void _submitApplication(int driveId) {
    if (!_isSelectionValid()) {
      TopSnackBar.showError(
        context,
        message: 'Please select at least 1 company preference',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final preferences = _selectedPreferences
        .where((id) => id != null)
        .map((companyId) => {'company_id': companyId})
        .toList();

    context.read<CampusDriveBloc>().add(
      ApplyToDriveEvent(driveId: driveId, preferences: preferences),
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

  @override
  Widget build(BuildContext context) {
    final currentDriveId = int.tryParse(widget.driveId);
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Drive Details',
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
          if (state.status == CampusDriveStatus.failure &&
              state.errorMessage != null) {
            TopSnackBar.showError(context, message: state.errorMessage!);
            setState(() {
              _isSubmitting = false;
            });
          } else if (state.status == CampusDriveStatus.success &&
              _isSubmitting) {
            setState(() {
              _isSubmitting = false;
              // Clear selected preferences immediately to prevent double counting
              _selectedPreferences.fillRange(0, 6, null);
            });
            
            ApplicationUtils.showSuccessDialog(
              context,
              title: 'Successfully Applied!',
              message:
                  'Your application for this campus drive has been submitted successfully. Good luck!',
              onConfirm: () {
                final driveId = int.tryParse(widget.driveId);
                if (driveId != null) {
                  context.read<CampusDriveBloc>().add(
                    LoadDriveDetailsEvent(driveId),
                  );
                }
              },
            );
          }
        },
        builder: (context, state) {
          if (currentDriveId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Invalid campus drive link',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (state.isDetailsLoading && _cachedDetails == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.secondaryColor,
                ),
              ),
            );
          }

          if (state.status == CampusDriveStatus.failure &&
              _cachedDetails == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'An error occurred',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final driveId = int.tryParse(widget.driveId);
                      if (driveId != null) {
                        context.read<CampusDriveBloc>().add(
                          LoadDriveDetailsEvent(driveId),
                        );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final blocDetails = state.selectedDriveDetails;
          if (blocDetails != null && blocDetails.drive.id == currentDriveId) {
            _cachedDetails = blocDetails;
          }

          if (_cachedDetails != null) {
            final drive = _cachedDetails!.drive;
            final companies = _cachedDetails!.companies;
            final driveApplication = _cachedDetails!.application;
            final hasApplied =
                (driveApplication?.id ?? 0) > 0 || drive.hasApplied == true;

            final alreadyAppliedCount =
                driveApplication?.preferences.length ?? 0;

            final filteredCompanies = _getFilteredCompanies(companies);

            return Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppConstants.defaultPadding,
                  right: AppConstants.defaultPadding,
                  top: AppConstants.defaultPadding,
                  bottom: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drive Info Card
                    Container(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
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
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(
                                width: AppConstants.defaultPadding,
                              ),
                              Expanded(
                                child: Text(
                                  drive.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.textPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildInfoRowWithGreenIcon(
                            Icons.business,
                            'Organizer',
                            drive.organizer,
                          ),
                          const SizedBox(height: 12),

                          _buildInfoRowWithGreenIcon(
                            Icons.location_on,
                            'Venue',
                            '${drive.venue}, ${drive.city}',
                          ),
                          const SizedBox(height: 12),

                          _buildInfoRowWithGreenIcon(
                            Icons.calendar_today,
                            'Last Date',
                            '${_formatDate(drive.endDate)}',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Search Section
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search companies, roles, location...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppConstants.secondaryColor,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.smallBorderRadius,
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.smallBorderRadius,
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.smallBorderRadius,
                          ),
                          borderSide: const BorderSide(color: AppConstants.secondaryColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Participating Companies Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Companies (${filteredCompanies.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (filteredCompanies.isEmpty)
                      EmptyStateWidget(
                        icon: Icons.business_center,
                        title: _searchQuery.isEmpty
                            ? 'No Companies'
                            : 'No Results Found',
                        subtitle: _searchQuery.isEmpty
                            ? 'No companies have been added to this drive yet.'
                            : 'Try adjusting your search.',
                      )
                    else
                      ...filteredCompanies.map((company) {
                        final appliedPref = _getAppliedPreference(
                          company.id,
                          driveApplication,
                        );
                        final isAlreadyApplied = appliedPref != null;

                        return _CompanyCard(
                          company: company,
                          onSelect: (companyId) {
                            if (isAlreadyApplied) return;

                            final existingPref = _getCompanyPreference(
                              companyId,
                            );

                            if (existingPref != null) {
                              _selectCompany(companyId, null);
                            } else {
                              final currentSelectedCount = _selectedPreferences
                                  .where((p) => p != null)
                                  .length;
                              if (alreadyAppliedCount + currentSelectedCount >=
                                  6) {
                                return;
                              }

                              final nextPref = _getNextPreferenceNumber();
                              if (nextPref != null) {
                                _selectCompany(companyId, nextPref);
                              }
                            }
                          },
                          getButtonText: (id) => _getButtonText(
                            id,
                            hasApplied: hasApplied,
                            alreadyAppliedCount: alreadyAppliedCount,
                            application: driveApplication,
                          ),
                          isSelected: (id) {
                            final isApplied =
                                _getAppliedPreference(id, driveApplication) !=
                                null;
                            if (isApplied) return true;

                            return _getCompanyPreference(id) != null;
                          },
                          showSelection: drive.status == 'live',
                          isDisabled: (id) {
                            final isAppliedInServer =
                                _getAppliedPreference(id, driveApplication) !=
                                null;
                            if (isAppliedInServer) return true;

                            final currentLocalSelections = _selectedPreferences
                                .where((p) => p != null)
                                .length;
                            final totalCount =
                                alreadyAppliedCount + currentLocalSelections;

                            if (totalCount >= 6) {
                              final isInCurrentSelection =
                                  _getCompanyPreference(id) != null;
                              return !isInCurrentSelection;
                            }

                            return false;
                          },
                        );
                      }),
                  ],
                ),
              ),
              // Sticky Apply Button at bottom
              bottomNavigationBar: (drive.status == 'live')
                    ? Builder(
                      builder: (context) {
                        final selectedCount = _selectedPreferences
                            .where((p) => p != null)
                            .length;
                        
                        // Total count = already applied + newly selected
                        final totalCount = alreadyAppliedCount + selectedCount;

                        if (selectedCount > 0) {
                          return Container(
                            padding: const EdgeInsets.all(
                              AppConstants.defaultPadding,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: SafeArea(
                              child: ElevatedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () {
                                        final driveId = int.tryParse(
                                          widget.driveId,
                                        );
                                        if (driveId != null) {
                                          _submitApplication(driveId);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.successColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.borderRadius,
                                    ),
                                  ),
                                  elevation: 2,
                                  disabledBackgroundColor: Colors.grey,
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.send, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Apply Now ($totalCount/6)',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        }

                        if (hasApplied) {
                          if (alreadyAppliedCount >= 6) {
                            return Container(
                              padding: const EdgeInsets.all(
                                AppConstants.defaultPadding,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: SafeArea(
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    AppConstants.defaultPadding,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.borderRadius,
                                    ),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.info_outline,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'Application Limit Reached (6 Max)',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            context.pop(); // Go back to campus drive list
                                          },
                                          icon: const Icon(Icons.list_alt, size: 18),
                                          label: const Text(
                                            'View Applications',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                AppConstants.borderRadius,
                                              ),
                                            ),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        }

                        return Container(
                          padding: const EdgeInsets.all(
                            AppConstants.defaultPadding,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            child: ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadius,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Select Companies to Apply',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : null,
            );
          }

          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.secondaryColor,
              ),
            ),
          );
        },
      ),
    );
  }

  List<CampusDriveCompany> _getFilteredCompanies(
    List<CampusDriveCompany> companies,
  ) {
    List<CampusDriveCompany> filtered = companies.where((company) {
      final query = _searchQuery.trim().toLowerCase();

      if (query.isEmpty) return true;

      // Search in company name
      if (company.companyName.toLowerCase().contains(query)) {
        return true;
      }

      // Search in job roles
      if (company.jobRoles?.any(
            (role) => role.toLowerCase().contains(query),
          ) ??
          false) {
        return true;
      }

      // Search in company location
      if (company.companyLocation?.toLowerCase().contains(query) ?? false) {
        return true;
      }

      // Search in company description
      if (company.companyDescription?.toLowerCase().contains(query) ?? false) {
        return true;
      }

      // Search in criteria (Map values)
      if (company.criteria != null) {
        for (var entry in company.criteria!.entries) {
          final key = entry.key.toLowerCase();
          final value = entry.value.toString().toLowerCase();
          
          if (key.contains(query) || value.contains(query)) {
            return true;
          }
        }
      }

      // Search in description/min_cgpa field
      if (company.criteria?['min_cgpa']
              ?.toString()
              .toLowerCase()
              .contains(query) ??
          false) {
        return true;
      }

      // Search in stipend/CTC
      if (company.criteria?['ctc']
              ?.toString()
              .toLowerCase()
              .contains(query) ??
          false) {
        return true;
      }

      // Search in vacancies
      if (company.vacancies.toString().contains(query)) {
        return true;
      }

      return false;
    }).toList();

    return filtered;
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

/// Company Card Widget
class _CompanyCard extends StatelessWidget {
  final CampusDriveCompany company;
  final Function(int) onSelect;
  final String Function(int) getButtonText;
  final bool Function(int) isSelected;
  final bool showSelection;
  final bool Function(int)? isDisabled;

  const _CompanyCard({
    required this.company,
    required this.onSelect,
    required this.getButtonText,
    required this.isSelected,
    required this.showSelection,
    this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = isDisabled?.call(company.id) ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (company.logo != null && company.logo!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      company.logo!,
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
                          child: const Icon(Icons.business),
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
                    child: const Icon(Icons.business),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.companyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      if (company.companyLocation != null &&
                          company.companyLocation!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppConstants.textSecondaryColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  company.companyLocation!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppConstants.textSecondaryColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
            if (company.jobRoles != null && company.jobRoles!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: company.jobRoles!.map((role) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppConstants.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (company.criteria != null) ...[
              const SizedBox(height: 12),
              ...(() {
                final entries = company.criteria!.entries.toList();
                entries.sort((a, b) {
                  if (a.key.toLowerCase() == 'min_cgpa') return 1;
                  if (b.key.toLowerCase() == 'min_cgpa') return -1;
                  return a.key.compareTo(b.key);
                });

                return entries.map((entry) {
                  final key = entry.key;
                  final value = entry.value;

                  if (key.trim().isEmpty ||
                      key.startsWith('manual_') ||
                      key.startsWith('_') ||
                      key.toLowerCase() == 'year' ||
                      key.toLowerCase() == 'years' ||
                      key.toLowerCase() == 'branches') {
                    return const SizedBox.shrink();
                  }

                  String displayKey;
                  if (key.toLowerCase() == 'min_cgpa') {
                    displayKey = 'Description';
                  } else {
                    final words = key
                        .replaceAll('_', ' ')
                        .split(' ')
                        .map((w) => w.trim())
                        .where((w) => w.isNotEmpty)
                        .toList();

                    displayKey = words.isEmpty
                        ? key
                        : words
                              .map(
                                (w) => w.length == 1
                                    ? w.toUpperCase()
                                    : w[0].toUpperCase() + w.substring(1),
                              )
                              .join(' ');
                  }

                  String displayValue = '';
                  if (value is List) {
                    displayValue = value.join(', ');
                  } else if (value is Map) {
                    displayValue = value.toString();
                  } else {
                    displayValue = value.toString();
                  }

                  return _buildCriteriaRow(displayKey, displayValue);
                }).toList();
              })(),
            ],
            if (company.vacancies > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.work,
                      size: 14,
                      color: AppConstants.successColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${company.vacancies} Vacancies',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ],

            // Preference Selection Button
            if (showSelection) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: disabled ? null : () => onSelect(company.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected(company.id)
                        ? AppConstants.successColor
                        : AppConstants.successColor.withOpacity(0.1),
                    foregroundColor: isSelected(company.id)
                        ? Colors.white
                        : AppConstants.successColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallBorderRadius,
                      ),
                      side: BorderSide(
                        color: isSelected(company.id)
                            ? AppConstants.successColor
                            : AppConstants.successColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    elevation: isSelected(company.id) ? 2 : 0,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey.shade500,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected(company.id))
                        const Icon(Icons.check_circle, size: 18),
                      if (isSelected(company.id)) const SizedBox(width: 8),
                      Text(
                        getButtonText(company.id),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppConstants.secondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            softWrap: true,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
