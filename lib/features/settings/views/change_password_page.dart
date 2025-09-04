import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully'),
              backgroundColor: AppConstants.successColor,
            ),
          );
          context.pop();
        } else if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppConstants.errorColor,
            ),
          );
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),

            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, size: 48, color: AppConstants.primaryColor),
          const SizedBox(height: AppConstants.defaultPadding),

          Text(
            'Change Your Password',
            style: AppConstants.headingStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.smallPadding),

          Text(
            'Enter your current password and choose a new one',
            style: AppConstants.captionStyle.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
            color: Colors.black.withValues(alpha: 1.0),
            blurRadius: 10,
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
