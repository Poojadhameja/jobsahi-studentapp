import 'package:flutter/material.dart';
import '../../../utils/app_constants.dart';
import '../../../data/user_data.dart';
import '../../../utils/navigation_service.dart';

/// SkillsEditScreen - A screen for editing and managing user skills
class SkillsEditScreen extends StatefulWidget {
  const SkillsEditScreen({super.key});

  @override
  State<SkillsEditScreen> createState() => _SkillsEditScreenState();
}

class _SkillsEditScreenState extends State<SkillsEditScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controller for the custom skill input field
  final _skillController = TextEditingController();
  
  // List to store all skills selected/added by the user
  final List<String> _userSkills = [];
  
  // List to store filtered skill suggestions based on user input
  List<String> _filteredSuggestions = [];
  
  // Boolean to control visibility of suggestions box
  bool _showSuggestions = false;
  
  // Predefined ITI Trade Skills - users can select from these
  final List<String> _skills = [
    'Electrical', 'Wiring', 'Circuit Testing', 'Welding', 'Tool Making'
  ];
  
  @override
  void initState() {
    super.initState();
    // Load existing user skills when screen initializes
    _loadUserSkills();
    // Add listener to input field for real-time suggestions
    _skillController.addListener(_onSkillTextChanged);
  }

  /// Loads existing skills from user data or sets default skills
  void _loadUserSkills() {
    final user = UserData.currentUser;
    try {
      // Try to get skills from user data
      final skillsData = user['skills'];
      if (skillsData is List) {
        // Add all valid string skills to user skills list
        _userSkills.addAll(skillsData.whereType<String>());
      }
    } catch (e) {
      // Handle errors safely - continue with default skills
    }
    
    // If no skills found, add default ITI-relevant skills
    if (_userSkills.isEmpty) {
      _userSkills.addAll(['Electrical Wiring', 'Safety Procedures', 'Basic Hand Tools', 'Quality Awareness', 'Teamwork']);
    }
  }

  /// Handles real-time text changes in the skill input field
  /// Provides auto-suggestions based on user input
  void _onSkillTextChanged() {
    final query = _skillController.text.toLowerCase().trim();
    
    // If input is empty, hide suggestions
    if (query.isEmpty) {
      setState(() {
        _filteredSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Filter predefined skills that match the query and aren't already added
    final suggestions = _skills.where((skill) {
      final skillLower = skill.toLowerCase();
      return skillLower.contains(query) && !_userSkills.contains(skill);
    }).toList();

    // Additional common ITI-related skills for better suggestions
    final commonSkills = [
      'Basic Hand Tools', 'Quality Control', 'Safety Training', 'Technical Drawing',
      'Measurement Tools', 'Precision Work', 'Machine Operation', 'Quality Assurance',
      'Workplace Safety', 'Technical Skills', 'Practical Training', 'Industry Standards'
    ];

    // Filter common skills that match the query
    final commonSuggestions = commonSkills.where((skill) {
      final skillLower = skill.toLowerCase();
      return skillLower.contains(query) && !_userSkills.contains(skill);
    }).toList();

    // Combine all suggestions and remove duplicates
    final allSuggestions = [...suggestions, ...commonSuggestions];
    final uniqueSuggestions = allSuggestions.toSet().toList();
    
    setState(() {
      // Limit suggestions to 8 items for better UI performance
      _filteredSuggestions = uniqueSuggestions.take(8).toList();
      _showSuggestions = uniqueSuggestions.isNotEmpty;
    });
  }

  @override
  void dispose() {
    // Clean up resources when widget is disposed
    _skillController.removeListener(_onSkillTextChanged);
    _skillController.dispose();
    super.dispose();
  }

  /// Adds a custom skill entered by the user
  void _addSkill() {
    if (_skillController.text.isNotEmpty) {
      setState(() {
        // Add the skill to user's skill list
        _userSkills.add(_skillController.text.trim());
        // Clear input field
        _skillController.clear();
        // Hide suggestions after adding
        _filteredSuggestions = [];
        _showSuggestions = false;
      });
    }
  }

  /// Removes a skill from the user's skill list
  void _removeSkill(String skill) {
    setState(() {
      _userSkills.remove(skill);
    });
  }

  /// Adds a predefined skill when user clicks on it
  void _addPredefinedSkill(String skill) {
    if (!_userSkills.contains(skill)) {
      setState(() {
        _userSkills.add(skill);
      });
    }
  }

  /// Adds a skill from the suggestions list
  void _addSkillFromSuggestion(String skill) {
    setState(() {
      // Add the suggested skill
      _userSkills.add(skill);
      // Clear input field
      _skillController.clear();
      // Hide suggestions after adding
      _filteredSuggestions = [];
      _showSuggestions = false;
    });
  }

  /// Saves the user's skills to local storage and navigates back
  void _saveSkills() {
    if (_userSkills.isNotEmpty) {
      // TODO: Save to backend/database in future implementation
      setState(() {
        // Update local user data with new skills
        UserData.currentUser['skills'] = _userSkills;
      });
      
      // Show success message
      _showMessage('Skills updated successfully!');
      // Navigate back after 1 second delay
      Future.delayed(const Duration(seconds: 1), () {
        NavigationService.goBack();
      });
    } else {
      // Show error if no skills are added
      _showMessage('Please add at least one skill');
    }
  }

  /// Displays a snackbar message to the user
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
      // App Bar with back button and title
      appBar: AppBar(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.textPrimaryColor),
          onPressed: () => NavigationService.goBack(),
        ),
        title: const Text(
          'Edit Skills',
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
            // Main content area with scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Add Custom Skill with input field
                      _buildAddSkillSection(),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      // Section 2: Selected Skills (only shown when skills exist)
                      if (_userSkills.isNotEmpty) ...[
                        _buildSelectedSkillsSection(),
                        const SizedBox(height: AppConstants.defaultPadding),
                      ],
                      
                      // Section 3: Predefined Skills to choose from
                      _buildPredefinedSkillsSection(),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed bottom save button with shadow
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
                  onPressed: _saveSkills,
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

  /// Builds the custom skill input section with auto-suggestions
  Widget _buildAddSkillSection() {
    return Container(
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
          // Section header
          Text(
            'Add Skill',
            style: TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          
          // Input field and Add button row
          Row(
            children: [
              // Text input field for custom skills
              Expanded(
                child: TextFormField(
                  controller: _skillController,
                  decoration: InputDecoration(
                    hintText: 'Enter a new skill',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.smallPadding,
                      vertical: AppConstants.smallPadding,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              
              // Add button to submit custom skill
              ElevatedButton(
                onPressed: _addSkill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.secondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
          
          // Auto-suggestions box (only shown when suggestions exist)
          if (_showSuggestions) ...[
            const SizedBox(height: AppConstants.smallPadding),
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppConstants.cardBackgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                border: Border.all(
                  color: AppConstants.borderColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Suggestions header
                  Text(
                    'Suggestions:',
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  // Suggestions chips in a wrap layout
                  Wrap(
                    spacing: AppConstants.smallPadding,
                    runSpacing: 4,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: _filteredSuggestions.map((suggestion) => 
                      _buildSuggestionChip(suggestion)
                    ).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the selected skills display section with clear all functionality
  Widget _buildSelectedSkillsSection() {
    return Container(
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
          // Header row with skill count and clear all button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Skills count display
              Text(
                'Selected Skills (${_userSkills.length})',
                style: TextStyle(
                  color: AppConstants.textPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Clear all button (only shown when skills exist)
              if (_userSkills.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _userSkills.clear();
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          
          // Selected skills chips in a wrap layout
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: _userSkills.map((skill) => _buildSkillChip(skill, true)).toList(),
          ),
        ],
      ),
    );
  }



  /// Builds the predefined skills section for user selection
  Widget _buildPredefinedSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Display predefined skills in categories
        _buildSkillCategory('Skills', _skills),
        const SizedBox(height: AppConstants.defaultPadding),
      ],
    );
  }

  /// Builds a category of skills with title and skill chips
  Widget _buildSkillCategory(String title, List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category title
        Text(
          title,
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        
        // Skills chips in a wrap layout
        Wrap(
          spacing: AppConstants.smallPadding,
          runSpacing: AppConstants.smallPadding,
          children: skills.map((skill) => _buildSkillChip(skill, false)).toList(),
        ),
      ],
    );
  }

    /// Builds individual skill chips with different behaviors based on type
  /// isRemovable: true = selected skill (can be removed), false = predefined skill (can be added)
  Widget _buildSkillChip(String skill, bool isRemovable) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        // Different colors for selected vs predefined skills
        color: isRemovable ? AppConstants.primaryColor : AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(
          color: isRemovable 
              ? AppConstants.primaryColor 
              : AppConstants.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Skill name text
          Text(
            skill,
            style: TextStyle(
              color: isRemovable ? AppConstants.backgroundColor : AppConstants.textPrimaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // Action icon based on skill type
          if (isRemovable) ...[
            // Close icon for removing selected skills
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _removeSkill(skill),
              child: Icon(
                Icons.close,
                size: 16,
                color: AppConstants.backgroundColor,
              ),
            ),
          ] else ...[
            // Add icon for predefined skills
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _addPredefinedSkill(skill),
              child: Icon(
                Icons.add,
                size: 16,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds suggestion chips for auto-suggestions
  /// Users can tap these to quickly add suggested skills
  Widget _buildSuggestionChip(String suggestion) {
    return GestureDetector(
      onTap: () => _addSkillFromSuggestion(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          // Light primary color background with primary color border
          color: AppConstants.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          border: Border.all(
            color: AppConstants.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          suggestion,
          style: TextStyle(
            color: AppConstants.primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
