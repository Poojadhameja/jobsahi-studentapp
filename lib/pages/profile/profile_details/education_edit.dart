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
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final _qualificationController = TextEditingController();
  final _instituteController = TextEditingController();
  final _courseController = TextEditingController();
  final _yearController = TextEditingController();
  final _percentageController = TextEditingController();

  // Dropdown options for ITI students
  final List<String> _qualificationOptions = [
    '10th Pass',
    '12th Pass',
    'ITI Certificate',
    'Diploma',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'Other'
  ];

  String _selectedQualification = 'ITI Certificate';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = UserData.currentUser;
    
    // Load qualification from user data or set default
    final userQualification = user['education_qualification'];
    if (userQualification != null && _qualificationOptions.contains(userQualification)) {
      _selectedQualification = userQualification;
    }
    
    _instituteController.text = user['education_institute'] ?? '';
    _courseController.text = user['education_course'] ?? '';
    _yearController.text = user['education_year'] ?? '';
    _percentageController.text = user['education_percentage'] ?? '';
  }

  @override
  void dispose() {
    _qualificationController.dispose();
    _instituteController.dispose();
    _courseController.dispose();
    _yearController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  void _saveEducation() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save to backend/database
      setState(() {
        // Update local user data
        UserData.currentUser['education_qualification'] = _selectedQualification;
        UserData.currentUser['education_institute'] = _instituteController.text;
        UserData.currentUser['education_course'] = _courseController.text;
        UserData.currentUser['education_year'] = _yearController.text;
        UserData.currentUser['education_percentage'] = _percentageController.text;
      });
      
      _showMessage('Education details updated successfully!');
      Future.delayed(const Duration(seconds: 1), () {
        NavigationService.goBack();
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
      ),
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
        actions: [
          TextButton(
            onPressed: _saveEducation,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highest Qualification
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
                
                // Institute Name
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
                
                // Course Name
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
                
                // Year of Completion
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
                
                // Percentage/CGPA
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
                
                // Helpful Information Section
                _buildHelpSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          style: TextStyle(
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
              color: AppConstants.borderColor,
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
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

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
          style: TextStyle(
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
              color: AppConstants.borderColor,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              underline: Container(),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: AppConstants.textPrimaryColor,
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

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppConstants.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                'Helpful Information',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            '• Enter your highest completed qualification\n'
            '• Use the full name of your institute\n'
            '• Include your specific course or specialization\n'
            '• Year should be when you completed the course\n'
            '• For percentage: enter 0-100, for CGPA: enter 0-10',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
