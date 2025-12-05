import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/widgets/common/top_snackbar.dart';
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
  String? _storedPhoneNumber; // Store phone number from state
  int? _storedUserId; // Store user ID from state

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
    // Store phone number and userId from current state when screen loads
    final currentState = context.read<AuthBloc>().state;
    if (currentState is OtpSentState && _storedPhoneNumber == null) {
      _storedPhoneNumber = currentState.phoneNumber;
      _storedUserId = currentState.userId;
      debugPrint(
        '🔵 Stored phone number: $_storedPhoneNumber, userId: $_storedUserId',
      );
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Update stored values if OtpSentState is received
        if (state is OtpSentState) {
          _storedPhoneNumber = state.phoneNumber;
          _storedUserId = state.userId;
          debugPrint(
            '🔵 Updated stored phone number: $_storedPhoneNumber, userId: $_storedUserId',
          );
        }

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
          TopSnackBar.showError(
            context,
            message: state.message,
            duration: const Duration(seconds: 3),
          );
        } else if (state is OtpVerificationSuccess) {
          TopSnackBar.showSuccess(
            context,
            message: 'OTP verified successfully',
            duration: const Duration(seconds: 2),
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Use stored phone number or get from current state
        String phoneNumber = _storedPhoneNumber ?? '';

        if (phoneNumber.isEmpty && state is OtpSentState) {
          phoneNumber = state.phoneNumber;
          _storedPhoneNumber = phoneNumber;
        }

        // Format phone number for display (add +91 and spacing)
        String formattedPhone = '+91 XXXXX XXXXX';
        if (phoneNumber.isNotEmpty && phoneNumber.length == 10) {
          // Format as +91 XXXXX XXXXX (first 5 digits, then last 5 digits)
          formattedPhone =
              '+91 ${phoneNumber.substring(0, 5)} ${phoneNumber.substring(5)}';
        } else if (phoneNumber.isNotEmpty) {
          // If not exactly 10 digits, just show with +91 prefix
          formattedPhone = '+91 $phoneNumber';
        }

        return Column(
          children: [
            const SizedBox(height: 20),

            // Phone number display
            Center(
              child: Text(
                formattedPhone,
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
      },
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
    // Dismiss keyboard instantly
    FocusScope.of(context).unfocus();

    // Get the complete OTP
    final otp = _otpControllers.map((controller) => controller.text).join();

    // Ensure we have phone number and userId stored before verification
    final currentState = context.read<AuthBloc>().state;
    if (currentState is OtpSentState) {
      _storedPhoneNumber = currentState.phoneNumber;
      _storedUserId = currentState.userId;
    }

    // If still no phone number, try to get from current state one more time
    if (_storedPhoneNumber == null || _storedPhoneNumber!.isEmpty) {
      final state = context.read<AuthBloc>().state;
      if (state is OtpSentState) {
        _storedPhoneNumber = state.phoneNumber;
        _storedUserId = state.userId;
      }
    }

    // If still no phone number, show error
    if (_storedPhoneNumber == null || _storedPhoneNumber!.isEmpty) {
      TopSnackBar.showError(
        context,
        message:
            'Phone number not found. Please go back and request a new OTP.',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Dispatch OTP verification event to BLoC with phone number and userId
    // This ensures verification works even if state changes
    context.read<AuthBloc>().add(
      VerifyOtpEvent(
        otp: otp,
        phoneNumber: _storedPhoneNumber,
        userId: _storedUserId,
      ),
    );
  }

  /// Resends OTP to the user
  void _resendOTP() {
    // Use stored phone number or get from current state
    String phoneNumber = _storedPhoneNumber ?? '';

    if (phoneNumber.isEmpty) {
      final currentState = context.read<AuthBloc>().state;
      if (currentState is OtpSentState) {
        phoneNumber = currentState.phoneNumber;
        _storedPhoneNumber = phoneNumber;
      }
    }

    if (phoneNumber.isEmpty) {
      TopSnackBar.showError(
        context,
        message: 'Phone number not found. Please go back and try again.',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Dispatch resend OTP event to BLoC
    context.read<AuthBloc>().add(LoginWithOtpEvent(phoneNumber: phoneNumber));
  }
}
