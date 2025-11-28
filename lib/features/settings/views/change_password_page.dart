import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/common/top_snackbar.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SettingsBloc()..add(const LoadChangePasswordFormEvent()),
      child: const _ChangePasswordPageView(),
    );
  }
}

class _ChangePasswordPageView extends StatefulWidget {
  const _ChangePasswordPageView();

  @override
  State<_ChangePasswordPageView> createState() =>
      _ChangePasswordPageViewState();
}

class _ChangePasswordPageViewState extends State<_ChangePasswordPageView> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is PasswordChangedSuccess) {
          TopSnackBar.showSuccess(
            context,
            message: 'Password changed successfully',
          );
          context.pop();
        } else if (state is SettingsError) {
          TopSnackBar.showError(context, message: state.message);
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          bool isOldPasswordVisible = false;
          bool isNewPasswordVisible = false;
          bool isConfirmPasswordVisible = false;
          bool isLoading = false;

          if (state is ChangePasswordFormLoaded) {
            isOldPasswordVisible = state.isOldPasswordVisible;
            isNewPasswordVisible = state.isNewPasswordVisible;
            isConfirmPasswordVisible = state.isConfirmPasswordVisible;
          } else if (state is PasswordChanging) {
            isLoading = true;
          }

          return Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    _buildHeader(),
                    const SizedBox(height: AppConstants.largePadding),

                    // Password form
                    _buildPasswordForm(
                      context,
                      isOldPasswordVisible,
                      isNewPasswordVisible,
                      isConfirmPasswordVisible,
                    ),
                    const SizedBox(height: AppConstants.largePadding),

                    // Submit button
                    _buildSubmitButton(context, isLoading),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Password requirements
                    _buildPasswordRequirements(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Back + header block similar to Policy/Terms
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppConstants.textPrimaryColor,
                ),
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 4),
              // Centered icon and titles
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
                      'Change Password',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Keep your account secure with a strong password',
                      style: TextStyle(fontSize: 14, color: Color(0xFF4F789B)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm(
    BuildContext context,
    bool isOldPasswordVisible,
    bool isNewPasswordVisible,
    bool isConfirmPasswordVisible,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Details',
            style: AppConstants.subheadingStyle.copyWith(
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Old Password Field
          _buildPasswordField(
            controller: _oldPasswordController,
            label: 'Current Password / वर्तमान पासवर्ड',
            hint: 'Enter your current password',
            isVisible: isOldPasswordVisible,
            onVisibilityChanged: (value) {
              context.read<SettingsBloc>().add(
                UpdatePasswordVisibilityEvent(field: 'old', isVisible: value),
              );
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Current password is required';
              }
              return null;
            },
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // New Password Field
          _buildPasswordField(
            controller: _newPasswordController,
            label: 'New Password / नया पासवर्ड',
            hint: 'Enter your new password',
            isVisible: isNewPasswordVisible,
            onVisibilityChanged: (value) {
              context.read<SettingsBloc>().add(
                UpdatePasswordVisibilityEvent(field: 'new', isVisible: value),
              );
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'New password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Confirm Password Field
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirm Password / पासवर्ड की पुष्टि करें',
            hint: 'Confirm your new password',
            isVisible: isConfirmPasswordVisible,
            onVisibilityChanged: (value) {
              context.read<SettingsBloc>().add(
                UpdatePasswordVisibilityEvent(
                  field: 'confirm',
                  isVisible: value,
                ),
              );
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required Function(bool) onVisibilityChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppConstants.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),

        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppConstants.textSecondaryColor),
            filled: true,
            fillColor: AppConstants.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
              borderSide: BorderSide(color: AppConstants.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
              borderSide: BorderSide(color: AppConstants.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
              borderSide: BorderSide(
                color: AppConstants.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
              borderSide: BorderSide(color: AppConstants.errorColor),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: AppConstants.textSecondaryColor,
              ),
              onPressed: () => onVisibilityChanged(!isVisible),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.defaultPadding,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handlePasswordChange(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Change Password / पासवर्ड बदलें',
                style: AppConstants.buttonTextStyle.copyWith(fontSize: 16),
              ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppConstants.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements / पासवर्ड आवश्यकताएं',
            style: AppConstants.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),

          _buildRequirementItem('At least 6 characters long', true),
          _buildRequirementItem('Should not be same as current password', true),
          _buildRequirementItem(
            'Use a combination of letters and numbers',
            false,
          ),
          _buildRequirementItem('Avoid common passwords', false),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isRequired ? Icons.check_circle : Icons.info_outline,
            size: 16,
            color: isRequired
                ? AppConstants.successColor
                : AppConstants.textSecondaryColor,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Text(
              text,
              style: AppConstants.captionStyle.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePasswordChange(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<SettingsBloc>().add(
      ChangePasswordEvent(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );
  }
}
