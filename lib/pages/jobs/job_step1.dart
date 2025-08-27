import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import 'job_step2.dart';

class JobStep1Screen extends StatefulWidget {
  /// Job data for the application
  final Map<String, dynamic> job;

  const JobStep1Screen({super.key, required this.job});

  @override
  State<JobStep1Screen> createState() => _JobStep1ScreenState();
}

class _JobStep1ScreenState extends State<JobStep1Screen> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Text editing controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();

  /// Whether the form is being submitted
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(
        title: 'Job Application / नौकरी आवेदन',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: _buildMainCard(),
        ),
      ),
    );
  }

  /// Loads user data into form fields
  void _loadUserData() {
    // TODO: Load from user data service
    _nameController.text = 'Rahul Kumar';
    _emailController.text = 'rahul.kumar@email.com';
    _phoneController.text = '+91 98765 43210';
    _experienceController.text = '2 years';
    _educationController.text = '12th Pass';
  }

  /// Builds the job overview section
  Widget _buildJobOverviewSection() {
    return Row(
      children: [
        // Left side - Job icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.work, color: AppConstants.primaryColor, size: 24),
        ),
        const SizedBox(width: AppConstants.defaultPadding),

        // Right side - Job details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.job['title'] ?? 'Job Title',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.job['company'] ?? 'Company Name',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.job['location'] ?? 'Location',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the progress section
  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Application Progress / आवेदन प्रगति',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Step 1 of 3',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  Text(
                    '33%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.33,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppConstants.successColor,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              const Text(
                'Basic Information / बुनियादी जानकारी',
                style: TextStyle(
                  fontSize: 12,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the form section
  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information / व्यक्तिगत जानकारी',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Full Name
        _buildFormField(
          controller: _nameController,
          label: 'Full Name* / पूरा नाम*',
          hint: 'नाम',
          prefixIcon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Name is required / नाम आवश्यक है';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Email
        _buildFormField(
          controller: _emailController,
          label: 'Email Address* / ईमेल पता*',
          hint: 'ईमेल पता',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required / ईमेल आवश्यक है';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email / कृपया एक वैध ईमेल दर्ज करें';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Phone Number
        _buildFormField(
          controller: _phoneController,
          label: 'Phone Number* / फोन नंबर*',
          hint: 'मोबाइल नंबर',
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required / फोन नंबर आवश्यक है';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number / कृपया एक वैध फोन नंबर दर्ज करें';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Experience
        _buildFormField(
          controller: _experienceController,
          label: 'Experience / अनुभव',
          hint: 'अनुभव',
          prefixIcon: Icons.work,
        ),
        const SizedBox(height: 20),

        // Education
        _buildFormField(
          controller: _educationController,
          label: 'Education / शिक्षा',
          hint: 'शिक्षा',
          prefixIcon: Icons.school,
        ),
      ],
    );
  }

  /// Helper method for form fields with modern styling (from create account page)
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll('*', ''),
            style: const TextStyle(fontSize: 13, color: Color(0xFF144B75)),
            children: [
              if (label.contains('*'))
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 15,
            ),
          ),
          validator: validator,
        ),
        const SizedBox(height: 7),
      ],
    );
  }

  /// Builds the next button
  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _goToNextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 2,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Next Step',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// Closes the keyboard
  void _closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// Goes to the next step
  void _goToNextStep() {
    // Close keyboard first
    _closeKeyboard(context);

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate processing
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isSubmitting = false;
        });

        // Navigate to next step
        NavigationService.smartNavigate(
          destination: JobStep2Screen(job: widget.job),
        );
      });
    }
  }

  /// Builds the main card containing all content
  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job overview section
            _buildJobOverviewSection(),

            // Divider
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: AppConstants.defaultPadding,
              ),
              height: 1,
              color: Colors.grey.shade200,
            ),

            // Progress section
            _buildProgressSection(),

            // Divider
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: AppConstants.defaultPadding,
              ),
              height: 1,
              color: Colors.grey.shade200,
            ),

            // Form section
            _buildFormSection(),

            const SizedBox(height: AppConstants.largePadding),

            // Next button
            _buildNextButton(),
          ],
        ),
      ),
    );
  }
}
