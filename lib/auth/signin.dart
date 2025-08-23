import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_constants.dart';
import '../utils/navigation_service.dart';
import 'signin1.dart';
import 'signin2.dart';
import 'create_account.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  /// Tracks whether OTP or Email login is selected
  bool isOTPSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Back button
              _buildBackButton(),
              const SizedBox(height: 8),

              // Main content
              _buildMainContent(),
              const SizedBox(height: AppConstants.largePadding),

              // Login method selector
              _buildLoginMethodSelector(),
              const SizedBox(height: AppConstants.largePadding),

              // Login options
              _buildLoginOptions(),
              const SizedBox(height: AppConstants.largePadding),

              // Social login buttons
              _buildSocialLoginButtons(),
              const SizedBox(height: AppConstants.largePadding),

              // Create account link
              _buildCreateAccountLink(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the back button
  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppConstants.accentColor),
      onPressed: () {
        // Go back to previous screen
        NavigationService.goBack();
      },
    );
  }

  /// Builds the main content section
  Widget _buildMainContent() {
    return Center(
      child: Column(
        children: [
          // Profile avatar
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFE0E7EF),
            child: Icon(
              Icons.person,
              size: 45,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            "Sign In With",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the login method selector (OTP vs Email)
  Widget _buildLoginMethodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // OTP button
        Container(
          decoration: BoxDecoration(
            color: isOTPSelected
                ? AppConstants.textPrimaryColor
                : AppConstants.cardBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              bottomLeft: Radius.circular(6),
            ),
            border: Border.all(color: AppConstants.textPrimaryColor),
          ),
          child: TextButton(
            onPressed: () {
              setState(() {
                isOTPSelected = true;
              });
            },
            child: Text(
              "OTP",
              style: TextStyle(
                color: isOTPSelected
                    ? Colors.white
                    : AppConstants.textPrimaryColor,
              ),
            ),
          ),
        ),

        // Email button
        Container(
          decoration: BoxDecoration(
            color: !isOTPSelected
                ? AppConstants.textPrimaryColor
                : AppConstants.cardBackgroundColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
            border: Border.all(color: AppConstants.textPrimaryColor),
          ),
          child: TextButton(
            onPressed: () {
              setState(() {
                isOTPSelected = false;
              });
            },
            child: Text(
              "MAIL",
              style: TextStyle(
                color: !isOTPSelected
                    ? Colors.white
                    : AppConstants.textPrimaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the login options based on selected method
  Widget _buildLoginOptions() {
    if (isOTPSelected) {
      return _buildOTPLoginOption();
    } else {
      return _buildEmailLoginOption();
    }
  }

  /// Builds the OTP login option
  Widget _buildOTPLoginOption() {
    return Column(
      children: [
        // Phone number input
        TextField(
          decoration: InputDecoration(
            labelText: AppConstants.phoneLabel,
            hintText: 'Enter your phone number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Get OTP button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to OTP verification screen
              NavigationService.smartNavigate(
                destination: const Signin1Screen(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.textPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: const Text(
              'Get OTP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the email login option
  Widget _buildEmailLoginOption() {
    return Column(
      children: [
        // Email input
        TextField(
          decoration: InputDecoration(
            labelText: AppConstants.emailLabel,
            hintText: 'Enter your email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Password input
        TextField(
          decoration: InputDecoration(
            labelText: AppConstants.passwordLabel,
            hintText: 'Enter your password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: const Icon(Icons.visibility_off),
          ),
          obscureText: true,
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Forgot password link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: Navigate to forgot password screen
            },
            child: const Text(
              AppConstants.forgotPasswordText,
              style: TextStyle(color: AppConstants.accentColor),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Sign in button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to email verification screen
               NavigationService.smartNavigate(destination: const Signin2Screen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.textPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: const Text(
              AppConstants.loginText,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the social login buttons
  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        // Social login buttons
        Row(
          children: [
            // Google button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement Google sign in
                },
                icon: Image.asset(AppConstants.googleLogoAsset, height: 20),
                label: const Text('Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),

            // LinkedIn button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement LinkedIn sign in
                },
                icon: Image.asset(AppConstants.linkedinLogoAsset, height: 20),
                label: const Text('LinkedIn'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the create account link
  Widget _buildCreateAccountLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account? ",
            style: TextStyle(color: AppConstants.textSecondaryColor),
          ),
          TextButton(
            onPressed: () {
              // Navigate to create account screen
               NavigationService.smartNavigate(destination: const CreateAccountScreen());
            },
            child: const Text(
              AppConstants.signupText,
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
}
