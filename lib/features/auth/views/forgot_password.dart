import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: const _ForgotPasswordScreenView(),
    );
  }
}

class _ForgotPasswordScreenView extends StatefulWidget {
  const _ForgotPasswordScreenView();

  @override
  State<_ForgotPasswordScreenView> createState() =>
      _ForgotPasswordScreenViewState();
}

class _ForgotPasswordScreenViewState extends State<_ForgotPasswordScreenView> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Local state for submission tracking
  bool _isSubmitting = false;

  /// Email controller
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset submitting state when screen initializes
    _isSubmitting = false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          // Set submitting state
          setState(() {
            _isSubmitting = true;
          });
        } else if (state is PasswordResetCodeSentState) {
          // Navigate immediately without any delay or snackbar
          context.push(
            AppRoutes.setPasswordCode,
            extra: {'email': state.email, 'userId': state.userId},
          );
        } else if (state is AuthError) {
          // Reset submitting state and show error
          setState(() {
            _isSubmitting = false;
          });
          _showErrorSnackBar(context, state.message);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Reset submitting state if not in loading and submitting is true
          // This handles the case when user comes back from OTP screen
          if (_isSubmitting && state is! AuthLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isSubmitting = false;
                });
              }
            });
          }

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              // Always go to login when back is pressed
              context.go(AppRoutes.loginOtpEmail);
            },
            child: Scaffold(
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
                        onPressed: () {
                          // Check if can pop, otherwise go to login
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.loginOtpEmail);
                          }
                        },
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
                                Icons.lock_reset,
                                size: 45,
                                color: AppConstants.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Forgot Password",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "आपका पासवर्ड रीसेट करने के लिए अपना ईमेल दर्ज करें",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4F789B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Form fields
                      Form(key: _formKey, child: _buildFormFields()),
                      const SizedBox(height: 20),

                      /// Submit button
                      _buildSubmitButton(context, _isSubmitting),
                      const SizedBox(height: 20),

                      /// Help text
                      _buildHelpText(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the form fields with modern styling
  Widget _buildFormFields() {
    return Column(
      children: [
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
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Builds the submit button with modern styling
  Widget _buildSubmitButton(BuildContext context, bool isSending) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSending ? null : () => _sendResetLink(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5C9A24),
          disabledBackgroundColor: const Color(0xFF5C9A24),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSending
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "Send Reset Code",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// Builds the help text with modern styling
  Widget _buildHelpText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Remember your password? "),
        InkWell(
          onTap: () {
            context.go(AppRoutes.loginOtpEmail);
          },
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: const Text(
              "Sign In",
              style: TextStyle(
                color: Color(0xFF58B248),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Sends the reset link
  void _sendResetLink(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Send forgot password request using existing ForgotPasswordEvent
      context.read<AuthBloc>().add(
        ForgotPasswordEvent(email: _emailController.text),
      );
    }
  }

  /// Shows error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }
}
