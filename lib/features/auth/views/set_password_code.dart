import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SetPasswordCodeScreen extends StatefulWidget {
  const SetPasswordCodeScreen({super.key});

  @override
  State<SetPasswordCodeScreen> createState() => _SetPasswordCodeScreenState();
}

class _SetPasswordCodeScreenState extends State<SetPasswordCodeScreen> {
  /// Controllers for code input fields (6 digits)
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

  /// Purpose for OTP verification
  final String _purpose = 'forgot_password';

  /// Email address where OTP was sent
  String _email = '';

  /// Current OTP value
  String _currentOtp = '';

  @override
  void initState() {
    super.initState();
    // Get email from GoRouter extra parameter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic> && extra['email'] != null) {
        setState(() {
          _email = extra['email'] as String;
        });
      }
    });

    // Set up focus listeners for each field
    for (int i = 0; i < 6; i++) {
      _codeFocusNodes[i].addListener(() => _onFocusChanged(i));
    }

    // Auto-focus the first box when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeFocusNodes[0].requestFocus();
    });
  }

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isVerifying = true;
          });
        } else if (state is ForgotPasswordOtpVerificationSuccess) {
          setState(() {
            _isVerifying = false;
          });
          _showSuccessSnackBar(state.message);
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              context.push(
                AppRoutes.setNewPassword,
                extra: {'userId': state.userId},
              );
            }
          });
        } else if (state is ResendOtpSuccess) {
          setState(() {
            _isVerifying = false;
          });
          _showSuccessSnackBar(state.message);
        } else if (state is AuthError) {
          setState(() {
            _isVerifying = false;
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
                        "हमने आपके ईमेल पर 6 अंकों का सत्यापन कोड भेजा है",
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
            _email.isNotEmpty ? _email : 'Loading...',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 20),

        // OTP input fields with keyboard listener
        KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.backspace) {
                _handleBackspace();
              }
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) => _buildCodeField(index)),
          ),
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
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              color: Color(0xFF58B248), // Library green color
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
          _handleCodeInput(value, index);
        },
        onSubmitted: (value) {
          _handleCodeSubmit(value, index);
        },
      ),
    );
  }

  /// Handles focus changes for individual fields
  void _onFocusChanged(int index) {
    setState(() {
      // Trigger UI update when focus changes
    });
  }

  /// Handles code input for individual fields
  void _handleCodeInput(String value, int index) {
    if (value.length > 1) {
      // Handle paste operation - distribute across fields
      _handlePaste(value, index);
    } else if (value.isNotEmpty) {
      // Single character input - ensure only first character is kept
      if (value.length > 1) {
        _codeControllers[index].text = value[0];
        _codeControllers[index].selection = TextSelection.fromPosition(
          TextPosition(offset: 1),
        );
      }

      // Move to next field
      if (index < 5) {
        _codeFocusNodes[index + 1].requestFocus();
      }

      // Update current OTP
      _updateCurrentOtp();

      // Check if all fields are filled
      if (_isAllFieldsFilled()) {
        _verifyCode();
      }
    } else {
      // Field is empty (backspace was pressed)
      // Don't move focus automatically - let user control it
      _updateCurrentOtp();
    }
  }

  /// Handles paste operation by distributing characters across fields
  void _handlePaste(String pastedValue, int startIndex) {
    // Clean the pasted value (only digits)
    final cleanValue = pastedValue.replaceAll(RegExp(r'[^0-9]'), '');

    // Distribute characters starting from the current field
    for (int i = 0; i < cleanValue.length && (startIndex + i) < 6; i++) {
      _codeControllers[startIndex + i].text = cleanValue[i];
    }

    // Move focus to the next empty field or the last field
    final nextEmptyIndex = _findNextEmptyField(startIndex);
    if (nextEmptyIndex < 6) {
      _codeFocusNodes[nextEmptyIndex].requestFocus();
    } else {
      // All fields are filled, focus on the last field
      _codeFocusNodes[5].requestFocus();
    }

    // Update current OTP
    _updateCurrentOtp();

    // Check for auto-verification after paste
    if (_isAllFieldsFilled()) {
      _verifyCode();
    }
  }

  /// Finds the next empty field starting from the given index
  int _findNextEmptyField(int startIndex) {
    for (int i = startIndex; i < 6; i++) {
      if (_codeControllers[i].text.isEmpty) {
        return i;
      }
    }
    return 6; // All fields are filled
  }

  /// Handles backspace key press
  void _handleBackspace() {
    // Find the currently focused field
    for (int i = 0; i < 6; i++) {
      if (_codeFocusNodes[i].hasFocus) {
        if (_codeControllers[i].text.isNotEmpty) {
          // Clear current field
          _codeControllers[i].clear();
        } else if (i > 0) {
          // Move to previous field and clear it
          _codeFocusNodes[i - 1].requestFocus();
          _codeControllers[i - 1].clear();
        }
        _updateCurrentOtp();
        break;
      }
    }
  }

  /// Handles code submit (Enter key)
  void _handleCodeSubmit(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _codeFocusNodes[index + 1].requestFocus();
    } else if (_isAllFieldsFilled()) {
      _verifyCode();
    }
  }

  /// Updates the current OTP string from all fields
  void _updateCurrentOtp() {
    _currentOtp = _codeControllers.map((controller) => controller.text).join();
  }

  /// Checks if all fields are filled
  bool _isAllFieldsFilled() {
    return _codeControllers.every((controller) => controller.text.isNotEmpty);
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
    if (_currentOtp.length != 6) {
      _showErrorSnackBar('Please enter a valid 6-digit code');
      return;
    }

    // For now, we'll use a default user ID. In a real app, this would come from the previous screen
    // or from the forgot password response
    const userId = 51; // This should be passed from the forgot password screen

    // Dispatch OTP verification event to BLoC
    context.read<AuthBloc>().add(
      VerifyForgotPasswordOtpEvent(
        userId: userId,
        otp: _currentOtp,
        purpose: _purpose,
      ),
    );
  }

  /// Resends the verification code
  void _resendCode() {
    print('🔵 _resendCode: Email: $_email, Purpose: $_purpose');

    if (_email.isNotEmpty) {
      // Clear all input boxes before resending OTP
      _clearAllInputBoxes();

      // Dispatch resend OTP event to BLoC
      context.read<AuthBloc>().add(
        ResendOtpEvent(email: _email, purpose: _purpose),
      );
    } else {
      print('🔴 _resendCode: Email is empty');
      _showErrorSnackBar('Email not available for resending OTP');
    }
  }

  /// Clears all OTP input boxes
  void _clearAllInputBoxes() {
    for (int i = 0; i < 6; i++) {
      _codeControllers[i].clear();
    }
    _currentOtp = '';

    // Focus on the first input box after clearing
    _codeFocusNodes[0].requestFocus();
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
