import 'package:flutter/material.dart';
import '../../../utils/app_constants.dart';
import '../../../data/user_data.dart';
import '../../../utils/navigation_service.dart';

class EducationEditScreen extends StatefulWidget {
  const EducationEditScreen({super.key});

  @override
  State<EducationEditScreen> createState() => _EducationEditScreenState();
}

class _EducationEditScreenState extends State<EducationEditScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Text editing controllers for form input fields
  final _instituteController = TextEditingController();
  final _courseController = TextEditingController();
  final _yearController = TextEditingController();
  final _percentageController = TextEditingController();

  // Available qualification options for dropdown selection
  // Catering specifically to ITI students and their educational background
  final List<String> _qualificationOptions = [
    '10th Pass',
    '12th Pass',
    'ITI Certificate',
    'Diploma',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'Other'
  ];

  // Currently selected qualification (defaults to ITI Certificate)
  String _selectedQualification = 'ITI Certificate';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Loads existing user education data into the form fields
  /// If no data exists, sets default values
  void _loadUserData() {
    final user = UserData.currentUser;
    
    // Load qualification from user data or set default
    final userQualification = user['education_qualification'];
    if (userQualification != null && _qualificationOptions.contains(userQualification)) {
      _selectedQualification = userQualification;
    }
    
    // Populate form fields with existing user data or empty strings
    _instituteController.text = user['education_institute'] ?? '';
    _courseController.text = user['education_course'] ?? '';
    _yearController.text = user['education_year'] ?? '';
    _percentageController.text = user['education_percentage'] ?? '';
  }

  @override
  void dispose() {
    _instituteController.dispose();
    _courseController.dispose();
    _yearController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  /// Validates and saves the education form data
  /// Updates local user data and shows success message
  void _saveEducation() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save to backend/database
      setState(() {
        // Update local user data with form values
        UserData.currentUser['education_qualification'] = _selectedQualification;
        UserData.currentUser['education_institute'] = _instituteController.text;
        UserData.currentUser['education_course'] = _courseController.text;
        UserData.currentUser['education_year'] = _yearController.text;
        UserData.currentUser['education_percentage'] = _percentageController.text;
      });
      
      // Show success message and navigate back after delay
      _showMessage('Education details updated successfully!');
      Future.delayed(const Duration(seconds: 1), () {
        NavigationService.goBack();
      });
    }
  }

  /// Displays a floating snackbar message to the user
  /// Used for showing success, error, or informational messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows a custom alert dialog with education form help tips
  /// Displays helpful information in Hindi for better user understanding
  void _showHelpAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppConstants.successColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppConstants.successColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'सहायक जानकारी',
                style: TextStyle(
                  color: AppConstants.successColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'अपनी शिक्षा की जानकारी भरते समय इन बातों का ध्यान रखें:',
                style: TextStyle(
                  color: AppConstants.successColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '• अपनी सबसे बड़ी / आखिरी पढ़ाई लिखें\n'
                '• कॉलेज या स्कूल का पूरा नाम लिखें\n'
                '• कौन-सा कोर्स या स्पेशलाइजेशन किया है, यह बताएं\n'
                '• जिस साल पढ़ाई पूरी की, वह साल लिखें\n'
                '• अंक लिखते समय: प्रतिशत (0–100) या CGPA (0–10) सही-सही लिखें',
                style: TextStyle(
                  color: AppConstants.successColor,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'समझ गया!',
                style: TextStyle(
                  color: AppConstants.successColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.textPrimaryColor),
          onPressed: () => NavigationService.goBack(),
        ),
        title: const Text(
          'Edit Education',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== EDUCATION FORM FIELDS =====
                      
                      // 1. Highest Qualification Dropdown
                      // Allows users to select their highest educational qualification
                      _buildDropdownField(
                        label: 'Highest Qualification',
                        selectedValue: _selectedQualification,
                        items: _qualificationOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedQualification = value!;
                          });
                        },
                        icon: Icons.school_outlined,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      // 2. Institute/College Name
                      // Text field for entering the name of educational institution
                      _buildEditField(
                        controller: _instituteController,
                        label: 'Institute Name',
                        icon: Icons.business_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter institute name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      // 3. Course/Program Name
                      // Text field for entering the specific course or program studied
                      _buildEditField(
                        controller: _courseController,
                        label: 'Course Name',
                        icon: Icons.description_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter course name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      // 4. Year of Completion
                      // Number field for entering the year when education was completed
                      // Includes validation for reasonable year range (1950 to current year + 5)
                      _buildEditField(
                        controller: _yearController,
                        label: 'Year of Completion',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter year of completion';
                          }
                          int? year = int.tryParse(value);
                          if (year == null || year < 1950 || year > DateTime.now().year + 5) {
                            return 'Please enter a valid year';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      // 5. Percentage/CGPA
                      // Number field for entering academic performance
                      // Supports both percentage (0-100) and CGPA (0-10) formats
                      _buildEditField(
                        controller: _percentageController,
                        label: 'Percentage/CGPA',
                        icon: Icons.grade_outlined,
                        keyboardType: TextInputType.number,
                        customHintText: 'e.g., 85.5 (percentage) or 8.5 (CGPA)',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter percentage or CGPA';
                          }
                          double? number = double.tryParse(value);
                          if (number == null) {
                            return 'Please enter a valid number';
                          }
                          
                          // Check if it's percentage (0-100) or CGPA (0-10)
                          if (number < 0) {
                            return 'Value cannot be negative';
                          }
                          
                          if (number > 100) {
                            // Might be CGPA, check if it's reasonable (0-10)
                            if (number > 10) {
                              return 'Please enter a valid percentage (0-100) or CGPA (0-10)';
                            }
                          }
                          
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      // Help button - shows alert when tapped
                      Center(
                        child: TextButton.icon(
                          onPressed: _showHelpAlert,
                          icon: Icon(
                            Icons.info_outline,
                            color: AppConstants.primaryColor,
                            size: 20,
                          ),
                          label: Text(
                            'Show Help Information',
                            style: TextStyle(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Save Button
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppConstants.cardBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEducation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.defaultPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  child: Text(
                    AppConstants.saveChangesText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a reusable text input field with consistent styling
  /// 
  /// Parameters:
  /// - controller: TextEditingController for the field
  /// - label: Display label above the field
  /// - icon: Icon to show in the prefix position
  /// - validator: Function to validate input
  /// - keyboardType: Type of keyboard to show (optional)
  /// - customHintText: Custom hint text (optional)
  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    String? customHintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          decoration: BoxDecoration(
            color: AppConstants.backgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: AppConstants.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppConstants.primaryColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
              hintText: customHintText ?? 'Enter your $label',
              hintStyle: TextStyle(
                color: AppConstants.textSecondaryColor.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a reusable dropdown field with consistent styling
  /// 
  /// Parameters:
  /// - label: Display label above the dropdown
  /// - selectedValue: Currently selected value
  /// - items: List of available options
  /// - onChanged: Callback when selection changes
  /// - icon: Icon to show in the prefix position
  Widget _buildDropdownField({
    required String label,
    required String selectedValue,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: AppConstants.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              underline: Container(),
              dropdownColor: Colors.white,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }


}
