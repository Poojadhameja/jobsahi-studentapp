import 'package:flutter/material.dart';
import '../../../../core/utils/app_constants.dart';

class ProfileSummaryEditScreen extends StatefulWidget {
  final String? initialSummary;

  const ProfileSummaryEditScreen({super.key, this.initialSummary});

  @override
  State<ProfileSummaryEditScreen> createState() =>
      _ProfileSummaryEditScreenState();
}

class _ProfileSummaryEditScreenState extends State<ProfileSummaryEditScreen> {
  final _summaryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _summaryController.text = widget.initialSummary ?? '';
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile Summary'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Write a brief summary about yourself',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _summaryController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText:
                      'Tell us about yourself, your skills, and what makes you unique...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a profile summary';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implement save functionality
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Summary'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
