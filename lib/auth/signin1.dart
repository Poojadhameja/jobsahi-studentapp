/// Sign In Screen 1 - OTP Verification

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_constants.dart';
import '../utils/navigation_service.dart';
import '../pages/home/home.dart';

class Signin1Screen extends StatefulWidget {
  const Signin1Screen({super.key});

  @override
  State<Signin1Screen> createState() => _Signin1ScreenState();
}

class _Signin1ScreenState extends State<Signin1Screen> {
  /// Controllers for OTP input fields
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  /// Focus nodes for OTP input fields
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
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
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.textPrimaryColor),
          onPressed: () => NavigationService.goBack(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeaderSection(),
              const SizedBox(height: AppConstants.largePadding),
              
              // OTP input section
              _buildOTPInputSection(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Verify button
              _buildVerifyButton(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Resend OTP section
              _buildResendOTPSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Verify OTP',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        
        // Description
        const Text(
          'We have sent a verification code to your phone number',
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        
        // Phone number display
        Text(
          '+91 98765 43210', // TODO: Get from previous screen
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  /// Builds the OTP input section
  Widget _buildOTPInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter OTP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        
        // OTP input fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildOTPField(index)),
        ),
      ],
    );
  }

  /// Builds individual OTP input field
  Widget _buildOTPField(int index) {
    return SizedBox(
      width: 45,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            borderSide: const BorderSide(color: AppConstants.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            borderSide: const BorderSide(color: AppConstants.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
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

  /// Builds the verify button
  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isVerifying ? null : _verifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
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
                AppConstants.verifyText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Builds the resend OTP section
  Widget _buildResendOTPSection() {
    return Center(
      child: Column(
        children: [
          const Text(
            "Didn't receive the code?",
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: _resendOTP,
            child: const Text(
              AppConstants.resendOtpText,
              style: TextStyle(
                color: AppConstants.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

      // For demo purposes, accept any 6-digit OTP
      if (otp.length == 6) {
        // Navigate to home screen
         NavigationService.smartNavigate(destination: const HomeScreen());
      } else {
        // Show error message
        _showErrorSnackBar('Please enter a valid 6-digit OTP');
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
