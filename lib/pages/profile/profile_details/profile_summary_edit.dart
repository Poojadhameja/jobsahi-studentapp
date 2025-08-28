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
                      const SizedBox(height: 8),
                      
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
                      const SizedBox(height: 12),
                      
                      // Tips section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppConstants.primaryColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppConstants.primaryColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.lightbulb_outline,
                                    color: AppConstants.primaryColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Writing Tips',
                                  style: TextStyle(
                                    color: AppConstants.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Keep it professional and concise\n'
                              '• Highlight your key skills and experience\n'
                              '• Mention your career objectives\n'
                              '• Use action words and be specific\n'
                              '• Proofread for grammar and spelling',
                              style: TextStyle(
                                color: AppConstants.textSecondaryColor,
                                fontSize: 13,
                                height: 1.3,
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
                  onPressed: _saveSummary,
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
}
