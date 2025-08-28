import 'package:flutter/material.dart';
import '../../../utils/app_constants.dart';
import '../../../data/user_data.dart';
import '../../../utils/navigation_service.dart';

class ExperienceEditScreen extends StatefulWidget {
  const ExperienceEditScreen({super.key});

  @override
  State<ExperienceEditScreen> createState() => _ExperienceEditScreenState();
}

class _ExperienceEditScreenState extends State<ExperienceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _experiences = [];
  
  // Controllers for form fields
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isCurrentlyWorking = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = UserData.currentUser;
    try {
      final experiencesData = user['experiences'];
      if (experiencesData is List) {
        _experiences.addAll(experiencesData.whereType<Map<String, dynamic>>());
      }
    } catch (e) {
      // Handle errors safely
    }
    
    // Add default experiences if none found
    if (_experiences.isEmpty) {
      _experiences.addAll([
        {
          'company': 'E-commerce Websites',
          'position': 'example.com',
          'startDate': 'July 2016',
          'endDate': 'July 2019',
          'description': 'Developed and maintained e-commerce websites',
          'isCurrentlyWorking': false,
        },
        {
          'company': 'Custom Web Applications',
          'position': 'example.com',
          'startDate': 'April 2019',
          'endDate': 'Oct 2021',
          'description': 'Built custom web applications for clients',
          'isCurrentlyWorking': false,
        },
      ]);
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addExperience() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _experiences.add({
          'company': _companyController.text,
          'position': _positionController.text,
          'startDate': _startDateController.text,
          'endDate': _isCurrentlyWorking ? 'Present' : _endDateController.text,
          'description': _descriptionController.text,
          'isCurrentlyWorking': _isCurrentlyWorking,
        });
      });
      
      // Clear form
      _companyController.clear();
      _positionController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _descriptionController.clear();
      _isCurrentlyWorking = false;
      
      _showMessage('Experience added successfully!');
    }
  }

  void _removeExperience(int index) {
    setState(() {
      _experiences.removeAt(index);
    });
    _showMessage('Experience removed successfully!');
  }

  void _saveExperiences() {
    if (_experiences.isNotEmpty) {
      // TODO: Save to backend/database
      setState(() {
        // Update local user data
        UserData.currentUser['experiences'] = _experiences;
      });
      
      _showMessage('Experiences updated successfully!');
      Future.delayed(const Duration(seconds: 1), () {
        NavigationService.goBack();
      });
    } else {
      _showMessage('Please add at least one experience');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.primaryColor,
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
          'Edit Experience',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveExperiences,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Experience Form
              _buildAddExperienceForm(),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Current Experiences
              _buildCurrentExperiencesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddExperienceForm() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppConstants.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Experience',
              style: TextStyle(
                color: AppConstants.textPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Company Name
            _buildEditField(
              controller: _companyController,
              label: 'Company Name',
              icon: Icons.business_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter company name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.smallPadding),
            
            // Position
            _buildEditField(
              controller: _positionController,
              label: 'Position/Title',
              icon: Icons.work_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter position/title';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.smallPadding),
            
            // Date Range
            Row(
              children: [
                Expanded(
                  child: _buildEditField(
                    controller: _startDateController,
                    label: 'Start Date',
                    icon: Icons.calendar_today_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter start date';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: _buildEditField(
                    controller: _endDateController,
                    label: 'End Date',
                    icon: Icons.calendar_today_outlined,
                    validator: (value) {
                      if (!_isCurrentlyWorking && (value == null || value.isEmpty)) {
                        return 'Please enter end date';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            
            // Currently Working Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isCurrentlyWorking,
                  onChanged: (value) {
                    setState(() {
                      _isCurrentlyWorking = value ?? false;
                    });
                  },
                  activeColor: AppConstants.primaryColor,
                ),
                Text(
                  'I currently work here',
                  style: TextStyle(
                    color: AppConstants.textPrimaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            
            // Description
            _buildEditField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description_outlined,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter job description';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addExperience,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.accentColor,
                  foregroundColor: AppConstants.backgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
                ),
                child: const Text('Add Experience'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentExperiencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Experiences (${_experiences.length})',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        if (_experiences.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.cardBackgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: AppConstants.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(
                'No experiences added yet. Add some work experience to get started!',
                style: TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ..._experiences.asMap().entries.map((entry) {
            final index = entry.key;
            final experience = entry.value;
            return _buildExperienceCard(experience, index);
          }),
      ],
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> experience, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppConstants.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience['company'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      experience['position'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeExperience(index),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppConstants.errorColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            '${experience['startDate'] ?? ''} - ${experience['endDate'] ?? ''}',
            style: TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          if (experience['description'] != null && experience['description'].isNotEmpty) ...[
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              experience['description'],
              style: const TextStyle(
                fontSize: 14,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppConstants.primaryColor, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.smallPadding,
              vertical: AppConstants.smallPadding,
            ),
          ),
        ),
      ],
    );
  }
}


