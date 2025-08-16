/// Enter Code Screen

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_constants.dart';
import '../utils/navigation_service.dart';
import '../widgets/global/simple_app_bar.dart';
import 'enter_new_password.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  /// Controllers for code input fields
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  /// Focus nodes for code input fields
  final List<FocusNode> _codeFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  /// Whether the code is being verified
  bool _isVerifying = false;

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _codeFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: const SimpleAppBar(
        title: 'Enter Code',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeader(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Code input section
              _buildCodeInput(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Verify button
              _buildVerifyButton(),
              const SizedBox(height: AppConstants.largePadding),
              
              // Resend code section
              _buildResendCodeSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Verification Code',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        const Text(
          'We have sent a verification code to your email address. Please enter the code below.',
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondaryColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Builds the code input section
  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Code',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        
        // Code input fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildCodeField(index)),
        ),
      ],
    );
  }

  /// Builds individual code input field
  Widget _buildCodeField(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: _codeControllers[index],
        focusNode: _codeFocusNodes[index],
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
            _codeFocusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            // Move to previous field
            _codeFocusNodes[index - 1].requestFocus();
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
        onPressed: _isVerifying ? null : _verifyCode,
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

  /// Builds the resend code section
  Widget _buildResendCodeSection() {
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
            onPressed: _resendCode,
            child: const Text(
              'Resend Code',
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

  /// Verifies the entered code
  void _verifyCode() {
    final code = _codeControllers.map((controller) => controller.text).join();
    
    if (code.length != 6) {
      _showErrorSnackBar('Please enter a valid 6-digit code');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isVerifying = false;
      });

      // For demo purposes, accept any 6-digit code
      if (code.length == 6) {
        // Navigate to enter new password screen
        NavigationService.smartNavigate(destination: const EnterNewPasswordScreen());
      } else {
        _showErrorSnackBar('Invalid verification code');
      }
    });
  }

  /// Resends the verification code
  void _resendCode() {
    // TODO: Implement resend code functionality
    _showSuccessSnackBar('Verification code resent successfully');
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
