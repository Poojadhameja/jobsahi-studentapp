import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// PersonalizeJobfeedScreen - A screen for users to customize their job preferences
/// This screen allows users to set their trade, location, job sectors, job types,
/// availability, skills, and expected salary range for personalized job recommendations.
class PersonalizeJobfeedScreen extends StatelessWidget {
  const PersonalizeJobfeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(const LoadProfileDataEvent()),
      child: const _PersonalizeJobfeedView(),
    );
  }
}

class _PersonalizeJobfeedView extends StatefulWidget {
  const _PersonalizeJobfeedView();

  @override
  State<_PersonalizeJobfeedView> createState() =>
      _PersonalizeJobfeedViewState();
}

class _PersonalizeJobfeedViewState extends State<_PersonalizeJobfeedView> {
  /// Controller for adding new skills
  final TextEditingController skillsController = TextEditingController();

  // ===== JOB PREFERENCES LISTS =====

  /// Available job sectors for selection
  /// These are the different industry sectors where jobs are available
  List<String> jobSectors = [
    "Power Plant",
    "Manufacturing",
    "Construction",
    "Oil & Gas",
    "Mining",
    "Automotive",
    "Aerospace",
    "Telecommunications",
    "Healthcare",
    "Education",
  ];

  /// Available job types (Full Time, Part Time, Internship)
  List<String> jobTypes = [
    "Full Time",
    "Part Time",
    "Internship",
    "Contract",
    "Freelance",
    "Temporary",
  ];

  /// Available salary ranges from app constants
  List<String> salaryRanges = AppConstants.salaryRanges;

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    context.read<ProfileBloc>().add(
      const UpdateSelectedTradeEvent(trade: "इलेक्ट्रीशियन"),
    );
    context.read<ProfileBloc>().add(
      const UpdateSelectedStateEvent(state: "Madhya Pradesh"),
    );
    context.read<ProfileBloc>().add(
      const UpdateSelectedCityEvent(city: "Balaghat"),
    );
    context.read<ProfileBloc>().add(
      const UpdateAvailabilityEvent(availability: "Immediately Available"),
    );

    // Initialize with default selected sectors and job types
    context.read<ProfileBloc>().add(
      const ToggleJobSectorEvent(sector: "Power Plant", isSelected: true),
    );
    context.read<ProfileBloc>().add(
      const ToggleJobTypeEvent(jobType: "Full Time", isSelected: true),
    );
    context.read<ProfileBloc>().add(
      const ToggleJobTypeEvent(jobType: "Internship", isSelected: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String? selectedTrade;
        String? selectedState;
        String? selectedCity;
        String? selectedSalaryRange;
        String availability = "Immediately Available";
        List<String> selectedSectors = ["Power Plant"];
        List<String> selectedJobTypes = ["Full Time", "Internship"];
        List<String> skills = ["Wiring"];

        if (state is PersonalizeJobfeedState) {
          selectedTrade = state.selectedTrade;
          selectedState = state.selectedState;
          selectedCity = state.selectedCity;
          selectedSalaryRange = state.selectedSalaryRange;
          availability = state.availability;
          selectedSectors = state.selectedSectors;
          selectedJobTypes = state.selectedJobTypes;
          skills = state.skills;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          // ===== APP BAR =====
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Personalize Jobfeed",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          // ===== MAIN BODY CONTENT =====
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== TRADE SELECTION SECTION =====
                _buildSectionTitle(
                  AppConstants.selectTradeTitle,
                  isGreen: true,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedTrade,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items:
                        [
                              "इलेक्ट्रीशियन",
                              "फिटर",
                              "वेल्डर",
                              "मैकेनिक",
                              "प्लंबर",
                              "कारपेंटर",
                            ]
                            .map(
                              (trade) => DropdownMenuItem(
                                value: trade,
                                child: Text(trade),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => context.read<ProfileBloc>().add(
                      UpdateSelectedTradeEvent(trade: val!),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ===== LOCATION SELECTION SECTION =====
                _buildSectionTitle(
                  AppConstants.preferredLocationTitle,
                  isGreen: true,
                ),
                Row(
                  children: [
                    // State Dropdown
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedState,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            hintText: "Select State",
                          ),
                          items:
                              [
                                    "Madhya Pradesh",
                                    "Maharashtra",
                                    "Gujarat",
                                    "Rajasthan",
                                    "Uttar Pradesh",
                                  ]
                                  .map(
                                    (state) => DropdownMenuItem(
                                      value: state,
                                      child: Text(state),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) => context.read<ProfileBloc>().add(
                            UpdateSelectedStateEvent(state: val!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // City Dropdown
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedCity,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            hintText: "Select City",
                          ),
                          items:
                              [
                                    "Balaghat",
                                    "Bhopal",
                                    "Indore",
                                    "Jabalpur",
                                    "Gwalior",
                                  ]
                                  .map(
                                    (city) => DropdownMenuItem(
                                      value: city,
                                      child: Text(city),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) => context.read<ProfileBloc>().add(
                            UpdateSelectedCityEvent(city: val!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ===== JOB SECTORS SECTION =====
                _buildSectionTitle(AppConstants.jobSectorTitle, isGreen: true),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: jobSectors.map((sector) {
                    final isSelected = selectedSectors.contains(sector);
                    return FilterChip(
                      label: Text(sector),
                      selected: isSelected,
                      onSelected: (selected) {
                        context.read<ProfileBloc>().add(
                          ToggleJobSectorEvent(
                            sector: sector,
                            isSelected: selected,
                          ),
                        );
                      },
                      selectedColor: AppConstants.primaryColor.withValues(
                        alpha: 0.2,
                      ),
                      checkmarkColor: AppConstants.primaryColor,
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ===== JOB TYPES SECTION =====
                _buildSectionTitle(AppConstants.jobTypeTitle, isGreen: true),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: jobTypes.map((type) {
                    final isSelected = selectedJobTypes.contains(type);
                    return FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        context.read<ProfileBloc>().add(
                          ToggleJobTypeEvent(
                            jobType: type,
                            isSelected: selected,
                          ),
                        );
                      },
                      selectedColor: AppConstants.primaryColor.withValues(
                        alpha: 0.2,
                      ),
                      checkmarkColor: AppConstants.primaryColor,
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ===== AVAILABILITY SECTION =====
                _buildSectionTitle(
                  AppConstants.availabilityTitle,
                  isGreen: true,
                ),
                _buildCustomRadioOption(
                  AppConstants.immediatelyAvailable,
                  availability == AppConstants.immediatelyAvailable,
                  () => context.read<ProfileBloc>().add(
                    UpdateAvailabilityEvent(
                      availability: AppConstants.immediatelyAvailable,
                    ),
                  ),
                ),
                _buildCustomRadioOption(
                  AppConstants.withinOneMonth,
                  availability == AppConstants.withinOneMonth,
                  () => context.read<ProfileBloc>().add(
                    UpdateAvailabilityEvent(
                      availability: AppConstants.withinOneMonth,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ===== SKILLS SECTION =====
                _buildSectionTitle(AppConstants.skillsTitle, isGreen: true),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((skill) {
                    return Chip(
                      label: Text(skill),
                      backgroundColor: Colors.blue.shade100,
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        context.read<ProfileBloc>().add(
                          RemoveSkillEvent(skill: skill),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: skillsController,
                        decoration: const InputDecoration(
                          hintText: "Add a skill",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Add new skill when add button is pressed
                        if (skillsController.text.trim().isNotEmpty) {
                          context.read<ProfileBloc>().add(
                            AddSkillEvent(skill: skillsController.text.trim()),
                          );
                          skillsController.clear();
                        }
                      },
                      child: const Text("Add"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ===== SALARY RANGE SECTION =====
                _buildSectionTitle(
                  AppConstants.salaryRangeTitle,
                  isGreen: true,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedSalaryRange,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintText: "Select Salary Range",
                    ),
                    items: salaryRanges
                        .map(
                          (range) => DropdownMenuItem(
                            value: range,
                            child: Text(range),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => context.read<ProfileBloc>().add(
                      UpdateSelectedSalaryRangeEvent(salaryRange: val!),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ===== SAVE BUTTON =====
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Save preferences and navigate back
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Save Preferences",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds section title with optional green styling
  Widget _buildSectionTitle(String title, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isGreen
              ? AppConstants.primaryColor
              : AppConstants.textPrimaryColor,
        ),
      ),
    );
  }

  /// Builds custom radio option for availability selection
  Widget _buildCustomRadioOption(
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppConstants.primaryColor
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppConstants.primaryColor.withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppConstants.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppConstants.primaryColor
                    : AppConstants.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
