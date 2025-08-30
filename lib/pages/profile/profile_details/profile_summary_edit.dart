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

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppConstants.textSecondaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Edit Options',
              style: TextStyle(
                color: AppConstants.textPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.content_copy, color: AppConstants.primaryColor),
              title: Text(
                'Copy Summary',
                style: TextStyle(color: AppConstants.textPrimaryColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _copySummary();
              },
            ),
            ListTile(
              leading: Icon(Icons.refresh, color: AppConstants.primaryColor),
              title: Text(
                'Reset to Default',
                style: TextStyle(color: AppConstants.textPrimaryColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _resetToDefault();
              },
            ),
            ListTile(
              leading: Icon(Icons.clear, color: AppConstants.errorColor),
              title: Text(
                'Clear All',
                style: TextStyle(color: AppConstants.errorColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _clearSummary();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _copySummary() {
    // Copy summary to clipboard
    // You can implement clipboard functionality here
    _showMessage('Summary copied to clipboard!');
  }

  void _resetToDefault() {
    setState(() {
      _summaryController.text = "ITI Electrician fresher with practical knowledge of "
          "electrical wiring, installation, maintenance, and troubleshooting. "
          "Skilled in handling domestic and industrial circuits, motors, and control "
          "panels with focus on safety standards. Quick learner, hardworking, and eager "
          "to apply technical skills in a professional environment to contribute to "
          "organizational growth.";
    });
    _showMessage('Summary reset to default!');
  }

  void _clearSummary() {
    setState(() {
      _summaryController.text = '';
    });
    _showMessage('Summary cleared!');
  }

  void _showTipsAlert() {
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
                  Icons.lightbulb_outline,
                  color: AppConstants.successColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'प्रोफाइल सारांश सुझाव',
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
                'एक प्रभावी प्रोफाइल सारांश लिखने के लिए इन सुझावों का पालन करें:',
                style: TextStyle(
                  color: AppConstants.successColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '• इसे छोटा और साफ़ लिखें\n'
                '• अपने ज़रूरी कौशल और अनुभव बताएं\n'
                '• करियर में आगे क्या करना चाहते हैं, यह लिखें\n'
                '• काम करने वाले शब्दों का इस्तेमाल करें (जैसे: संभाला, बनाया, सीखा)\n'
                '• लिखाई और वर्तनी सही रखें',
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
          'Edit Profile Summary',
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppConstants.primaryColor),
            onPressed: () {
              // Enable editing mode or show edit options
              _showEditOptions();
            },
            tooltip: 'Edit',
          ),
        ],
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
                      
                      // Tips button - shows alert when tapped
                      Center(
                        child: TextButton.icon(
                          onPressed: _showTipsAlert,
                          icon: Icon(
                            Icons.lightbulb_outline,
                            color: AppConstants.primaryColor,
                            size: 20,
                          ),
                          label: Text(
                            'Show Writing Tips',
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
