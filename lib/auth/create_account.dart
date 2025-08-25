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
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isTermsAccepted = false;

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),

              /// Back button
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppConstants.textPrimaryColor,
                ),
                onPressed: () => NavigationService.smartNavigate(
                  routeName: RouteNames.signin,
                ),
              ),
              const SizedBox(height: 4),

              /// Profile avatar & title
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFE0E7EF),
                      child: Icon(
                        Icons.person,
                        size: 45,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "वापसी का स्वागत है! कृपया अपनी जानकारी दर्ज करें",
                      style: TextStyle(fontSize: 14, color: Color(0xFF4F789B)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              /// Form fields
              Form(key: _formKey, child: _buildFormFields()),
              const SizedBox(height: 12),

              /// Submit button
              _buildSubmitButton(),
              const SizedBox(height: 12),

              /// Or divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFF58B248))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Or Sign up with",
                      style: const TextStyle(color: Color(0xFF58B248)),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFF58B248))),
                ],
              ),
              const SizedBox(height: 12),

              /// Social buttons
              _buildSocialLoginButtons(),
              const SizedBox(height: 16),

              /// Sign in link
              _buildSignInLink(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the form fields with modern styling
  Widget _buildFormFields() {
    return Column(
      children: [
        // Full Name
        _buildFormField(
          controller: _nameController,
          label: "Full Name*",
          hint: "नाम",
          prefixIcon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.nameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Email
        _buildFormField(
          controller: _emailController,
          label: "Email Address*",
          hint: "ईमेल पता",
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
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
        const SizedBox(height: 12),

        // Phone Number
        _buildFormField(
          controller: _phoneController,
          label: "Phone Number*",
          hint: "मोबाइल नंबर",
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
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
        const SizedBox(height: 12),

        // Password
        _buildFormField(
          controller: _passwordController,
          label: "Password*",
          hint: "पासवर्ड",
          prefixIcon: Icons.lock,
          isPassword: true,
          passwordVisible: _isPasswordVisible,
          onPasswordToggle: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
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
        const SizedBox(height: 12),

        // Confirm Password
        _buildFormField(
          controller: _confirmPasswordController,
          label: "Confirm Password*",
          hint: "पासवर्ड की पुष्टि करें",
          prefixIcon: Icons.lock,
          isPassword: true,
          passwordVisible: _isConfirmPasswordVisible,
          onPasswordToggle: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
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
        const SizedBox(height: 12),

        // Terms and Conditions Checkbox
        Row(
          children: [
            Checkbox(
              value: _isTermsAccepted,
              onChanged: (value) {
                setState(() {
                  _isTermsAccepted = value ?? false;
                });
              },
              activeColor: const Color(0xFF144B75),
            ),
            Expanded(
              child: const Text(
                'मैं नियम, प्राइवेसी और शुल्क से सहमत हूँ',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF144B75),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Helper method for form fields with modern styling
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool? passwordVisible,
    VoidCallback? onPasswordToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll('*', ''),
            style: const TextStyle(fontSize: 14, color: Color(0xFF144B75)),
            children: [
              if (label.contains('*'))
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? !(passwordVisible ?? false) : false,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  /// Builds the submit button with modern styling
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF144B75),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
                "Sign Up",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// Social Login Buttons with modern styling
  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        SignInButton(
          logoPath: AppConstants.googleLogoAsset,
          text: 'Sign up with Google',
          onPressed: () {
            debugPrint("Redirect to Google signup API");
          },
        ),
        const SizedBox(height: 12),
        SignInButton(
          logoPath: AppConstants.linkedinLogoAsset,
          text: 'Sign up with Linkedin',
          onPressed: () {
            debugPrint("Redirect to LinkedIn signup API");
          },
        ),
      ],
    );
  }

  /// Builds the sign in link with modern styling
  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
          onTap: () {
            NavigationService.smartNavigate(destination: const SigninScreen());
          },
          child: const Text(
            "Sign In",
            style: TextStyle(
              color: Color(0xFF58B248),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Submits the form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Check if terms are accepted
      if (!_isTermsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('कृपया नियम, प्राइवेसी और शुल्क से सहमत हों'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

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

/// Custom social login button
class SignInButton extends StatelessWidget {
  final String logoPath;
  final String text;
  final VoidCallback onPressed;

  const SignInButton({
    super.key,
    required this.logoPath,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset(
        logoPath,
        height: 24,
        width: 24,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      ),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Color(0xFFE0E7EF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}
