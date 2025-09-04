import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';

class SetPasswordCodeScreen extends StatefulWidget {
  const SetPasswordCodeScreen({super.key});

  @override
  State<SetPasswordCodeScreen> createState() => _SetPasswordCodeScreenState();
}

class _SetPasswordCodeScreenState extends State<SetPasswordCodeScreen> {
  /// Controllers for code input fields
  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  /// Focus nodes for code input fields
  final List<FocusNode> _codeFocusNodes = List.generate(
    4,
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
                      "हमने आपके ईमेल पर 4 अंकों का सत्यापन कोड भेजा है",
                      style: TextStyle(fontSize: 14, color: Color(0xFF4F789B)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Code input section
              _buildCodeInput(),
              const SizedBox(height: 24),

              // Verify button
              _buildVerifyButton(),
              const SizedBox(height: 24),

              // Resend code section
              _buildResendCodeSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the code input section
  Widget _buildCodeInput() {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Email display
        Center(
          child: Text(
            'rahul.kumar@email.com', // TODO: Replace with dynamic email
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 20),

        // Code input fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) => _buildCodeField(index)),
        ),
      ],
    );
  }

  /// Builds individual code input field
  Widget _buildCodeField(int index) {
    return SizedBox(
      width: 56,
      height: 60,
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

  /// Builds the resend code section
  Widget _buildResendCodeSection() {
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
          onTap: _resendCode,
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

  /// Verifies the entered code
  void _verifyCode() {
    final code = _codeControllers.map((controller) => controller.text).join();

    if (code.length != 4) {
      _showErrorSnackBar('Please enter a valid 4-digit code');
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

      // For demo purposes, accept any 4-digit code
      if (code.length == 4) {
        // Navigate to set new password screen
        if (mounted) {
          context.push(AppRoutes.setNewPassword);
        }
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
