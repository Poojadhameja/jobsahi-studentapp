import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: const _CreateAccountScreenView(),
    );
  }
}

class _CreateAccountScreenView extends StatefulWidget {
  const _CreateAccountScreenView();

  @override
  State<_CreateAccountScreenView> createState() =>
      _CreateAccountScreenViewState();
}

class _CreateAccountScreenViewState extends State<_CreateAccountScreenView> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Text editing controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle specific error states with snackbars
        if (state is EmailAlreadyExistsError) {
          _showErrorSnackBar(
            context,
            'Email already exists. Please use a different email or try signing in.',
          );
          // Clear email field
          _emailController.clear();
        } else if (state is PhoneAlreadyExistsError) {
          _showErrorSnackBar(
            context,
            'Phone number already exists. Please use a different phone number or try signing in.',
          );
          // Clear phone field
          _phoneController.clear();
        } else if (state is AuthError) {
          _showErrorSnackBar(context, state.message);
        } else if (state is AccountCreationSuccess) {
          _showSuccessSnackBar(
            context,
            'Account created successfully! Welcome to Job Sahi! 🎉',
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              context.go(AppRoutes.loginOtpEmail);
            }
          });
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          bool isPasswordVisible = false;
          bool isConfirmPasswordVisible = false;
          bool isTermsAccepted = false;
          bool isSubmitting = false;

          if (state is CreateAccountFormState) {
            isPasswordVisible = state.isPasswordVisible;
            isConfirmPasswordVisible = state.isConfirmPasswordVisible;
            isTermsAccepted = state.isTermsAccepted;
            isSubmitting = state.isSubmitting;
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // Scrollable content
                  Expanded(
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
                            onPressed: () => context.pop(),
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF4F789B),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          /// Form fields
                          Form(
                            key: _formKey,
                            child: _buildFormFields(
                              context,
                              isPasswordVisible,
                              isConfirmPasswordVisible,
                              isTermsAccepted,
                            ),
                          ),
                          const SizedBox(height: 24),

                          /// Or divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: Color(0xFF58B248)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  "Or Sign up with",
                                  style: const TextStyle(
                                    color: Color(0xFF58B248),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: Color(0xFF58B248)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          /// Social buttons
                          _buildSocialLoginButtons(),
                          const SizedBox(height: 24),

                          /// Sign in link
                          _buildSignInLink(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // Fixed bottom button
                  Container(
                    padding: const EdgeInsets.all(AppConstants.largePadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: _buildSubmitButton(context, isSubmitting),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the form fields with modern styling
  Widget _buildFormFields(
    BuildContext context,
    bool isPasswordVisible,
    bool isConfirmPasswordVisible,
    bool isTermsAccepted,
  ) {
    return Column(
      children: [
        // Full Name
        _buildFormField(
          controller: _nameController,
          label: "Full Name*",
          hint: "पूरा नाम ",
          prefixIcon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.nameRequired;
            }
            if (value.trim().length < 6) {
              return 'Name must be at least 6 letters long';
            }
            // Check if name contains at least 2 words (first name and surname)
            final nameParts = value.trim().split(RegExp(r'\s+'));
            if (nameParts.length < 2) {
              return 'Please enter your full name with surname';
            }
            // Check if all parts have at least 2 characters
            for (String part in nameParts) {
              if (part.length < 2) {
                return 'Each name part must be at least 2 letters';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

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
        const SizedBox(height: 20),

        // Phone Number
        _buildFormField(
          controller: _phoneController,
          label: "Phone Number*",
          hint: "मोबाइल नंबर",
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.phoneRequired;
            }
            if (value.length != 10) {
              return 'Phone number must be exactly 10 digits';
            }
            if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
              return 'Phone number must contain only numbers';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Password
        _buildFormField(
          controller: _passwordController,
          label: "Password*",
          hint: "पासवर्ड",
          prefixIcon: Icons.lock,
          isPassword: true,
          passwordVisible: isPasswordVisible,
          onPasswordToggle: () {
            context.read<AuthBloc>().add(
              TogglePasswordVisibilityEvent(
                isPassword: true,
                isVisible: !isPasswordVisible,
              ),
            );
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
        const SizedBox(height: 20),

        // Confirm Password
        _buildFormField(
          controller: _confirmPasswordController,
          label: "Confirm Password*",
          hint: "पासवर्ड की पुष्टि करें",
          prefixIcon: Icons.lock,
          isPassword: true,
          passwordVisible: isConfirmPasswordVisible,
          onPasswordToggle: () {
            context.read<AuthBloc>().add(
              TogglePasswordVisibilityEvent(
                isPassword: false,
                isVisible: !isConfirmPasswordVisible,
              ),
            );
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
        const SizedBox(height: 20),

        // Terms and Conditions Checkbox
        Row(
          children: [
            Checkbox(
              value: isTermsAccepted,
              onChanged: (value) {
                context.read<AuthBloc>().add(
                  ToggleTermsAcceptanceEvent(isAccepted: value ?? false),
                );
              },
              activeColor: const Color(0xFF144B75),
            ),
            GestureDetector(
              onTap: () {
                context.read<AuthBloc>().add(
                  ToggleTermsAcceptanceEvent(isAccepted: !isTermsAccepted),
                );
              },
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
    List<TextInputFormatter>? inputFormatters,
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
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? !(passwordVisible ?? false) : false,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      passwordVisible ?? false
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: onPasswordToggle,
                  )
                : null,
          ),
          validator: validator,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Builds the submit button with modern styling
  Widget _buildSubmitButton(BuildContext context, bool isSubmitting) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : () => _submitForm(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5C9A24),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
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
        const SizedBox(height: 16),
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
            context.push(AppRoutes.loginOtpEmail);
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
  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Get current state to check terms acceptance
      final currentState = context.read<AuthBloc>().state;
      bool isTermsAccepted = false;

      if (currentState is CreateAccountFormState) {
        isTermsAccepted = currentState.isTermsAccepted;
      }

      // Check if terms are accepted
      if (!isTermsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('कृपया नियम, प्राइवेसी और शुल्क से सहमत हों'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Set submitting state
      context.read<AuthBloc>().add(
        const SetFormSubmittingEvent(isSubmitting: true),
      );

      // Create account using existing CreateAccountEvent
      context.read<AuthBloc>().add(
        CreateAccountEvent(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  /// Shows success snackbar
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }

  /// Shows error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
