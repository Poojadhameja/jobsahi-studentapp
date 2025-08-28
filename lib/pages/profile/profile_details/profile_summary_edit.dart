import 'package:flutter/material.dart';
import '../../../utils/app_constants.dart';
import '../../../data/user_data.dart';
import '../../../utils/navigation_service.dart';

class ProfileSummaryEditScreen extends StatefulWidget {
  const ProfileSummaryEditScreen({super.key});

  @override
  State<ProfileSummaryEditScreen> createState() => _ProfileSummaryEditScreenState();
}

class _ProfileSummaryEditScreenState extends State<ProfileSummaryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  int _characterCount = 0;
  static const int _maxCharacters = 500;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _summaryController.addListener(_updateCharacterCount);
  }

  void _loadUserData() {
    final user = UserData.currentUser;
    _summaryController.text = user['summary'] ?? 
        "ITI Electrician fresher with practical knowledge of "
        "electrical wiring, installation, maintenance, and troubleshooting. "
        "Skilled in handling domestic and industrial circuits, motors, and control "
        "panels with focus on safety standards. Quick learner, hardworking, and eager "
        "to apply technical skills in a professional environment to contribute to "
        "organizational growth.";
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _summaryController.text.length;
    });
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  void _saveSummary() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save to backend/database
      setState(() {
        // Update local user data
        UserData.currentUser['summary'] = _summaryController.text;
      });
      
      _showMessage('Profile summary updated successfully!');
      Future.delayed(const Duration(seconds: 1), () {
        NavigationService.goBack();
      });
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
          'Edit Profile Summary',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveSummary,
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
                // Character count and limit info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Summary',
                      style: TextStyle(
                        color: AppConstants.textPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_characterCount/$_maxCharacters',
                      style: TextStyle(
                        color: _characterCount > _maxCharacters 
                            ? AppConstants.errorColor 
                            : AppConstants.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.smallPadding),
                
                // Summary text field
                Container(
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: AppConstants.borderColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextFormField(
                    controller: _summaryController,
                    maxLines: 8,
                    maxLength: _maxCharacters,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your profile summary';
                      }
                      if (value.length < 50) {
                        return 'Profile summary should be at least 50 characters';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(AppConstants.defaultPadding),
                      hintText: 'Write a compelling summary of your professional background, skills, and career objectives...',
                      counterText: '', // Hide default counter
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Tips section
                Container(
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
                            Icons.lightbulb_outline,
                            color: AppConstants.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: AppConstants.smallPadding),
                          Text(
                            'Writing Tips',
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
                        '• Keep it professional and concise\n'
                        '• Highlight your key skills and experience\n'
                        '• Mention your career goals\n'
                        '• Use action words and be specific\n'
                        '• Proofread for grammar and spelling',
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
