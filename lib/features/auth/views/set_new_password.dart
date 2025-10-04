import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Text editing controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// Whether passwords are visible
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  /// Whether the password is being reset
  bool _isResetting = false;

  /// User ID for password reset
  int _userId = 51; // Default value, should be passed from previous screen

  @override
  void initState() {
    super.initState();
    // Get userId from GoRouter extra parameter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic> && extra['userId'] != null) {
        setState(() {
          _userId = extra['userId'] as int;
        });
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isResetting = true;
          });
        } else if (state is PasswordResetSuccess) {
          setState(() {
            _isResetting = false;
          });
          _showSuccessSnackBar('Password reset successfully');
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              // Navigate back to login screen
              context.go(AppRoutes.loginOtpEmail);
            }
          });
        } else if (state is AuthError) {
          setState(() {
            _isResetting = false;
          });
          _showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.largePadding,
            ),
            child: Form(
              key: _formKey,
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
                            Icons.lock_outline,
                            size: 45,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Enter New Password",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "आपका नया पासवर्ड पहले वाले से अलग होना चाहिए",
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

                  // Password input
                  _buildPasswordInput(),
                  const SizedBox(height: 20),

                  // Confirm password input
                  _buildConfirmPasswordInput(),
                  const SizedBox(height: 24),

                  // Submit button
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the password input field
  Widget _buildPasswordInput() {
    return _buildFormField(
      controller: _passwordController,
      label: "New Password*",
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
    );
  }

  /// Builds the confirm password input field
  Widget _buildConfirmPasswordInput() {
    return _buildFormField(
      controller: _confirmPasswordController,
      label: "Confirm New Password*",
      hint: "पासवर्ड दोबारा दर्ज करें",
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
    );
  }

  /// Helper method for form fields with modern styling
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required String? Function(String?) validator,
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
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? !(passwordVisible ?? false) : false,
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
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF0B537D),
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

  /// Builds the submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isResetting ? null : _resetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5C9A24),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isResetting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// Resets the password
  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      // Dispatch reset password event to BLoC
      context.read<AuthBloc>().add(
        ResetPasswordEvent(
          userId: _userId,
          newPassword: _passwordController.text,
        ),
      );
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

  /// Shows error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }
}
