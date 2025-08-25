import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_constants.dart';
import '../utils/navigation_service.dart';

class LoginOtpCodeScreen extends StatefulWidget {
  const LoginOtpCodeScreen({super.key});

  @override
  State<LoginOtpCodeScreen> createState() => _LoginOtpCodeScreenState();
}

class _LoginOtpCodeScreenState extends State<LoginOtpCodeScreen> {
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

  /// Whether the OTP is being verified
  bool _isVerifying = false;

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
                onPressed: () => NavigationService.goBack(),
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
                      style: TextStyle(fontSize: 14, color: Color(0xFF4F789B)),
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
        onPressed: _isVerifying ? null : _verifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5C9A24),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isVerifying
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
    setState(() {
      _isVerifying = true;
    });

    // Get the complete OTP
    final otp = _otpControllers.map((controller) => controller.text).join();

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isVerifying = false;
      });

      // For demo purposes, accept any 4-digit OTP
      if (otp.length == 4) {
        // Navigate to profile builder step 1 using smart navigation
        NavigationService.smartNavigate(
          routeName: RouteNames.profileBuilderStep1,
        );
      } else {
        // Show error message
        _showErrorSnackBar('Please enter a valid 4-digit OTP');
      }
    });
  }

  /// Resends OTP to the user
  void _resendOTP() {
    // TODO: Implement resend OTP functionality
    _showSuccessSnackBar('OTP resent successfully');
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
