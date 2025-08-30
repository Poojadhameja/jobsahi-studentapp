import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

/// PersonalizeJobfeedScreen - A screen for users to customize their job preferences
/// This screen allows users to set their trade, location, job sectors, job types,
/// availability, skills, and expected salary range for personalized job recommendations.
class PersonalizeJobfeedScreen extends StatefulWidget {
  const PersonalizeJobfeedScreen({super.key});

  @override
  State<PersonalizeJobfeedScreen> createState() =>
      _PersonalizeJobfeedScreenState();
}

class _PersonalizeJobfeedScreenState extends State<PersonalizeJobfeedScreen> {
  // ===== FORM STATE VARIABLES =====
  
  /// Selected trade/craft (e.g., Electrician, Fitter, Welder)
  String? selectedTrade = "इलेक्ट्रीशियन";
  
  /// Selected state for job location preference
  String? selectedState = "Madhya Pradesh";
  
  /// Selected city/district for job location preference
  String? selectedCity = "Balaghat";
  
  /// Selected salary range preference
  String? selectedSalaryRange;

  /// User's availability status (immediately available or within 1 month)
  String availability = AppConstants.immediatelyAvailable;
  
  /// Controller for adding new skills
  final TextEditingController skillsController = TextEditingController();
  
  // ===== JOB PREFERENCES LISTS =====
  
  /// Available job sectors for selection
  /// These are the different industry sectors where jobs are available
  List<String> jobSectors = [ "Power Plant"];
  
  /// Currently selected job sectors by the user
  /// Initially set to match the UI shown in the design image
  List<String> selectedSectors = [ "Power Plant"];

  /// Available job types (Full Time, Part Time, Internship)
  List<String> jobTypes = ["Full Time", "Internship"];
  
  /// Currently selected job types by the user
  List<String> selectedJobTypes = ["Full Time", "Internship"];

  /// User's skills list - starts with "Wiring" as shown in the design
  List<String> skills = ["Wiring"];
  
  /// Available salary ranges from app constants
  List<String> salaryRanges = AppConstants.salaryRanges;

  @override
  void initState() {
    super.initState();
    // Load any existing user preferences when screen initializes
    _loadExistingPreferences();
  }

  @override
  Widget build(BuildContext context) {
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
            _buildSectionTitle(AppConstants.selectTradeTitle, isGreen: true),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedTrade,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ),
                items: ["इलेक्ट्रीशियन", "फिटर", "वेल्डर"]
                    .map((trade) =>
                        DropdownMenuItem(value: trade, child: Text(trade)))
                    .toList(),
                onChanged: (val) => setState(() => selectedTrade = val),
              ),
            ),
            const SizedBox(height: 24),

            // ===== LOCATION PREFERENCE SECTION =====
            _buildSectionTitle(AppConstants.preferredLocationTitle, isGreen: true),
            Row(
              children: [
                // State Selection
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "State",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedState,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          items: ["Madhya Pradesh", "Maharashtra", "UP"]
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) => setState(() => selectedState = val),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // District/City Selection
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "District/City",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedCity,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                          ),
                          items: ["Balaghat", "Bhopal", "Indore"]
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) => setState(() => selectedCity = val),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ===== JOB SECTOR SELECTION SECTION =====
            _buildSectionTitle(AppConstants.jobSectorTitle, isGreen: true),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: jobSectors
                  .map((sector) => ChoiceChip(
                        label: Text(
                          sector,
                          style: TextStyle(
                            color: selectedSectors.contains(sector) 
                                ? Colors.black87 
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: selectedSectors.contains(sector),
                        selectedColor: Colors.blue.shade100,
                        backgroundColor: Colors.grey.shade100,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedSectors.add(sector);
                            } else {
                              selectedSectors.remove(sector);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // ===== JOB TYPE SELECTION SECTION =====
            _buildSectionTitle(AppConstants.jobTypeTitle, isGreen: false),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: jobTypes
                  .map((type) => ChoiceChip(
                        label: Text(
                          type,
                          style: TextStyle(
                            color: selectedJobTypes.contains(type) 
                                ? Colors.black87 
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: selectedJobTypes.contains(type),
                        selectedColor: Colors.blue.shade100,
                        backgroundColor: Colors.grey.shade100,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedJobTypes.add(type);
                            } else {
                              selectedJobTypes.remove(type);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 15),

            // ===== AVAILABILITY SELECTION SECTION =====
            _buildSectionTitle(AppConstants.availabilityTitle, isGreen: false),
            Row(
              children: [
                // Immediately Available Option
                Radio(
                  value: AppConstants.immediatelyAvailable,
                  groupValue: availability,
                  activeColor: AppConstants.secondaryColor,
                  onChanged: (val) => setState(() => availability = val!),
                ),
                Text(
                  AppConstants.immediatelyAvailable,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(width: 15),
                // Within 1 Month Option
                Radio(
                  value: AppConstants.withinOneMonth,
                  groupValue: availability,
                  activeColor: AppConstants.secondaryColor,
                  onChanged: (val) => setState(() => availability = val!),
                ),
                Text(
                  AppConstants.withinOneMonth,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ===== SKILLS MANAGEMENT SECTION =====
            _buildSectionTitle(AppConstants.skillsTitle, isGreen: true),
            // Display existing skills as removable chips
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: skills
                  .map((skill) => Chip(
                        label: Text(
                          skill,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: Colors.blue.shade100,
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            skills.remove(skill);
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Input field to add new skills
            TextFormField(
              controller: skillsController,
              decoration: InputDecoration(
                hintText: AppConstants.addSkillsHint,
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppConstants.secondaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: AppConstants.secondaryColor),
                  onPressed: () {
                    // Add new skill when add button is pressed
                    if (skillsController.text.trim().isNotEmpty) {
                      setState(() {
                        skills.add(skillsController.text.trim());
                        skillsController.clear();
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ===== SALARY RANGE SELECTION SECTION =====
            _buildSectionTitle(AppConstants.salaryRangeTitle, isGreen: true),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedSalaryRange,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  hintText: "Select range",
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ),
                items: salaryRanges
                    .map((range) =>
                        DropdownMenuItem(value: range, child: Text(range)))
                    .toList(),
                onChanged: (val) => setState(() => selectedSalaryRange = val),
              ),
            ),
            const SizedBox(height: 32),

            // ===== SAVE BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  // Validate form before saving
                  if (_validateForm()) {
                    _savePreferences(context);
                  }
                },
                child: Text(
                  AppConstants.saveChangesText,
                  style: AppConstants.buttonTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ===== HELPER METHODS =====

  /// Builds section titles with conditional green or dark grey color
  /// Green titles are used for primary preference sections
  /// Dark grey titles are used for secondary preference sections
  Widget _buildSectionTitle(String title, {required bool isGreen}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isGreen ? AppConstants.secondaryColor : AppConstants.textPrimaryColor,
        ),
      ),
    );
  }

  /// Saves user preferences and shows success message
  /// Displays a snackbar with success message and navigates back after delay
  void _savePreferences(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppConstants.preferencesSavedHindi),
        backgroundColor: AppConstants.successColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
    // Navigate back after showing success message
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  /// Validates all form fields before allowing save
  /// Returns true if all required fields are filled, false otherwise
  /// Shows error messages for missing fields
  bool _validateForm() {
    // Check if trade is selected
    if (selectedTrade == null) {
      _showErrorSnackBar('Please select a trade');
      return false;
    }
    // Check if location is selected
    if (selectedState == null || selectedCity == null) {
      _showErrorSnackBar('Please select location');
      return false;
    }
    // Check if at least one job sector is selected
    if (selectedSectors.isEmpty) {
      _showErrorSnackBar('Please select at least one job sector');
      return false;
    }
    // Check if at least one job type is selected
    if (selectedJobTypes.isEmpty) {
      _showErrorSnackBar('Please select at least one job type');
      return false;
    }
    // Check if at least one skill is added
    if (skills.isEmpty) {
      _showErrorSnackBar('Please add at least one skill');
      return false;
    }
    // Check if salary range is selected
    if (selectedSalaryRange == null) {
      _showErrorSnackBar('Please select salary range');
      return false;
    }
    return true;
  }

  /// Shows error message in a snackbar
  /// Used to display validation errors to the user
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Loads existing user preferences from storage
  /// Currently a placeholder for future backend/SharedPreferences integration
  void _loadExistingPreferences() {
    // TODO: Implement loading from backend API or SharedPreferences
    // For now, the initial state is set in the variable declarations above
    // This method will be used to restore user's previous preferences
  }
}
