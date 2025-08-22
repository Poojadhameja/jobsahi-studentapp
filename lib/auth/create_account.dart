import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/navigation_service.dart';
import 'signin.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Text editing controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// Whether the form is being submitted
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppConstants.textPrimaryColor,
          ),
          onPressed: () =>
              NavigationService.smartNavigate(routeName: RouteNames.signin),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(color: AppConstants.textPrimaryColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: AppConstants.largePadding),

                // Form fields
                _buildFormFields(),
                const SizedBox(height: AppConstants.largePadding),

                // Submit button
                _buildSubmitButton(),
                const SizedBox(height: AppConstants.largePadding),

                // Sign in link
                _buildSignInLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header section
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create Your Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        const Text(
          'Fill in your details to create your account',
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  /// Builds the form fields
  Widget _buildFormFields() {
    return Column(
      children: [
        // Full Name
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: AppConstants.nameLabel,
            hintText: 'Enter your full name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.nameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Email
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: AppConstants.emailLabel,
            hintText: 'Enter your email address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.email),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.emailRequired;
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return AppConstants.invalidEmail;
            }
            return null;
          },
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Phone Number
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: AppConstants.phoneLabel,
            hintText: 'Enter your phone number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.phone),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.phoneRequired;
            }
            if (value.length < 10) {
              return AppConstants.invalidPhone;
            }
            return null;
          },
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Password
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppConstants.passwordLabel,
            hintText: 'Enter your password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: const Icon(Icons.visibility_off),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.passwordRequired;
            }
            if (value.length < 6) {
              return AppConstants.passwordTooShort;
            }
            return null;
          },
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Confirm Password
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: AppConstants.confirmPasswordLabel,
            hintText: 'Confirm your password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: const Icon(Icons.visibility_off),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.passwordRequired;
            }
            if (value != _passwordController.text) {
              return AppConstants.passwordsDoNotMatch;
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Builds the submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
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
                AppConstants.signupText,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// Builds the sign in link
  Widget _buildSignInLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Already have an account? ',
            style: TextStyle(color: AppConstants.textSecondaryColor),
          ),
          TextButton(
            onPressed: () {
              NavigationService.smartNavigate(
                destination: const SigninScreen(),
              );
            },
            child: const Text(
              AppConstants.loginText,
              style: TextStyle(
                color: AppConstants.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Submits the form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isSubmitting = false;
        });

        // Show success message and navigate to signin
        _showSuccessSnackBar(AppConstants.signupSuccess);
        Future.delayed(const Duration(seconds: 1), () {
          NavigationService.smartNavigate(destination: const SigninScreen());
        });
      });
    }
  }

  /// Shows success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }
}
