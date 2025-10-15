import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginOtpCodeScreen extends StatefulWidget {
  const LoginOtpCodeScreen({super.key});

  @override
  State<LoginOtpCodeScreen> createState() => _LoginOtpCodeScreenState();
}

class _LoginOtpCodeScreenState extends State<LoginOtpCodeScreen> {
  bool _isSubmitting = false; // Track submission state locally

  /// Controllers for OTP input fields
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  /// Focus nodes for OTP input fields
  final List<FocusNode> _otpFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpVerificationLoading) {
          // Set submitting state when loading starts
          setState(() {
            _isSubmitting = true;
          });
        } else if (state is AuthError) {
          // Reset submitting state on error
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is OtpVerificationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP verified successfully'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Use go instead of push to replace the route and prevent back navigation
          context.go(AppRoutes.loginVerifiedPopup);
        }
      },
      child: KeyboardDismissWrapper(
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
                            Icons.verified_user,
                            size: 45,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Enter Verification Code",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "हमने आपके मोबाइल पर 4 अंकों का OTP भेजा है",
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

                  // OTP input section
                  _buildOTPInputSection(),
                  const SizedBox(height: 24),

                  // Verify button
                  _buildVerifyButton(),
                  const SizedBox(height: 24),

                  // Resend OTP section
                  _buildResendOTPSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the OTP input section
  Widget _buildOTPInputSection() {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Phone number display
        Center(
          child: Text(
            '+91 98765 43210', // TODO: Replace with dynamic phone number
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 20),

        // OTP input fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) => _buildOTPField(index)),
        ),
      ],
    );
  }

  /// Builds individual OTP input field
  Widget _buildOTPField(int index) {
    return SizedBox(
      width: 56,
      height: 60,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppConstants.textPrimaryColor,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppConstants.textPrimaryColor,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppConstants.textPrimaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimaryColor,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            // Move to next field
            _otpFocusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            // Move to previous field
            _otpFocusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  /// Builds the resend OTP section
  Widget _buildResendOTPSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Didn’t get the verification code? ",
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: _resendOTP,
          child: const Text(
            "Resend",
            style: TextStyle(
              color: Color(0xFF58B248),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the verify button
  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _verifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5C9A24),
          disabledBackgroundColor: const Color(0xFF5C9A24),
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
                "Verify Code",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  /// Verifies the entered OTP
  void _verifyOTP() {
    // Get the complete OTP
    final otp = _otpControllers.map((controller) => controller.text).join();

    // Dispatch OTP verification event to BLoC
    context.read<AuthBloc>().add(VerifyOtpEvent(otp: otp));
  }

  /// Resends OTP to the user
  void _resendOTP() {
    // Dispatch resend OTP event to BLoC
    context.read<AuthBloc>().add(
      const LoginWithOtpEvent(
        phoneNumber: '9876543210',
      ), // TODO: Get from previous screen
    );
  }
}
