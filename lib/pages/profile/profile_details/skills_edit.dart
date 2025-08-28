import 'package:flutter/material.dart';
import '../../../utils/app_constants.dart';
import '../../../data/user_data.dart';
import '../../../utils/navigation_service.dart';

class SkillsEditScreen extends StatefulWidget {
  const SkillsEditScreen({super.key});

  @override
  State<SkillsEditScreen> createState() => _SkillsEditScreenState();
}

class _SkillsEditScreenState extends State<SkillsEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _skillController = TextEditingController();
  final List<String> _userSkills = [];
  
  // ITI Trade Skills for different trades
  final List<String> _electricalSkills = [
    'Electrical Wiring', 'Circuit Testing', 'Motor Installation', 'Transformer Maintenance',
    'PLC Programming', 'Industrial Automation', 'HVAC Systems', 'Solar Panel Installation',
    'Electrical Troubleshooting', 'Safety Procedures', 'Electrical Drawing Reading'
  ];
  
  final List<String> _mechanicalSkills = [
    'Welding', 'Fabrication', 'CNC Operation', 'Lathe Machine', 'Drilling Machine',
    'Grinding Machine', 'Milling Machine', 'Quality Control', 'Precision Measurement',
    'Machine Maintenance', 'Tool Making', 'Assembly Work'
  ];
  
  final List<String> _itSkills = [
    'Computer Hardware', 'Software Installation', 'Network Basics', 'Troubleshooting',
    'Basic Programming', 'Database Management', 'Web Development', 'Graphic Design',
    'Office Applications', 'System Administration'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserSkills();
  }

  void _loadUserSkills() {
    final user = UserData.currentUser;
    try {
      final skillsData = user['skills'];
      if (skillsData is List) {
        _userSkills.addAll(skillsData.whereType<String>());
      }
    } catch (e) {
      // Handle errors safely
    }
    
    // Add default skills if none found (ITI relevant)
    if (_userSkills.isEmpty) {
      _userSkills.addAll(['Electrical Wiring', 'Safety Procedures', 'Basic Hand Tools', 'Quality Awareness', 'Teamwork']);
    }
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    if (_skillController.text.isNotEmpty) {
      setState(() {
        _userSkills.add(_skillController.text.trim());
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _userSkills.remove(skill);
    });
  }

  void _addPredefinedSkill(String skill) {
    if (!_userSkills.contains(skill)) {
      setState(() {
        _userSkills.add(skill);
      });
    }
  }

  void _saveSkills() {
    if (_userSkills.isNotEmpty) {
      // TODO: Save to backend/database
      setState(() {
        // Update local user data
        UserData.currentUser['skills'] = _userSkills;
      });
      
      _showMessage('Skills updated successfully!');
      Future.delayed(const Duration(seconds: 1), () {
        NavigationService.goBack();
      });
    } else {
      _showMessage('Please add at least one skill');
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
          'Edit Skills',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveSkills,
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
                // Add Custom Skill
                _buildAddSkillSection(),
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Current Skills
                _buildCurrentSkillsSection(),
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Predefined Skills
                _buildPredefinedSkillsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          Text(
            'Add Custom Skill',
            style: TextStyle(
              color: AppConstants.textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Row(
            children: [
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
              ElevatedButton(
                onPressed: _addSkill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: AppConstants.backgroundColor,
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Skills (${_userSkills.length})',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        if (_userSkills.isEmpty)
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
                'No skills added yet. Add some skills to get started!',
                style: TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: _userSkills.map((skill) => _buildSkillChip(skill, true)).toList(),
          ),
      ],
    );
  }

  Widget _buildPredefinedSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ITI Trade Skills',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Electrical Trade Skills
        _buildSkillCategory('Electrical Trade Skills', _electricalSkills),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Mechanical Trade Skills
        _buildSkillCategory('Mechanical Trade Skills', _mechanicalSkills),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // IT Trade Skills
        _buildSkillCategory('IT Trade Skills', _itSkills),
      ],
    );
  }

  Widget _buildSkillCategory(String title, List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Wrap(
          spacing: AppConstants.smallPadding,
          runSpacing: AppConstants.smallPadding,
          children: skills.map((skill) => _buildSkillChip(skill, false)).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String skill, bool isRemovable) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 6,
      ),
      decoration: BoxDecoration(
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
          Text(
            skill,
            style: TextStyle(
              color: isRemovable ? AppConstants.backgroundColor : AppConstants.textPrimaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isRemovable) ...[
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
}
