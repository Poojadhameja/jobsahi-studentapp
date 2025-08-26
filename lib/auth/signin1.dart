import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_constants.dart';
import '../utils/navigation_service.dart';

class Signin1Screen extends StatefulWidget {
  const Signin1Screen({super.key});

  @override
  State<Signin1Screen> createState() => _Signin1ScreenState();
}

class _Signin1ScreenState extends State<Signin1Screen> {
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppConstants.textPrimaryColor,
          ),
          onPressed: () => NavigationService.goBack(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            children: [
              // Header section with profile icon and title
              _buildHeaderSection(),
              const SizedBox(height: AppConstants.largePadding),

              // OTP instruction text
              _buildOTPInstruction(),
              const SizedBox(height: AppConstants.largePadding),

              // OTP input section
              _buildOTPInputSection(),
              const SizedBox(height: AppConstants.largePadding),

              // Resend OTP section
              _buildResendOTPSection(),
              const Spacer(),

              // Verify button
              _buildVerifyButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section with profile icon and title
  Widget _buildHeaderSection() {
    return Column(
      children: [
        // Profile icon
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
          'Enter Code',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  /// Builds the OTP instruction text
  Widget _buildOTPInstruction() {
    return Column(
      children: [
        const Text(
          'Enter the 4-digit code sent to your phone',
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '+91 98765 43210',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the OTP input section
  Widget _buildOTPInputSection() {
    return Column(
      children: [
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
      width: 50,
      height: 55,
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
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppConstants.textPrimaryColor,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppConstants.textPrimaryColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppConstants.textPrimaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        style: const TextStyle(
          fontSize: 24,
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
          "If you don't receive code! ",
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
          backgroundColor: AppConstants.secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
                "VERIFY & PROCEED",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
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
        // Navigate to location screen using smart navigation
        NavigationService.smartNavigate(routeName: RouteNames.location1);
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
