import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../../../shared/widgets/common/top_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SetPasswordCodeScreen extends StatefulWidget {
  final String? purpose; // 'forgot_password' or 'phone_login'
  final String? email; // For forgot password
  final String? phoneNumber; // For phone login
  final int? userId; // User ID for verification

  const SetPasswordCodeScreen({
    super.key,
    this.purpose,
    this.email,
    this.phoneNumber,
    this.userId,
  });

  @override
  State<SetPasswordCodeScreen> createState() => _SetPasswordCodeScreenState();
}

class _SetPasswordCodeScreenState extends State<SetPasswordCodeScreen> {
  /// Controllers for code input fields (4 digits)
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

  /// Purpose for OTP verification
  late String _purpose;

  /// Email address where OTP was sent (for forgot password)
  String _email = '';

  /// Phone number where OTP was sent (for phone login)
  String _phoneNumber = '';

  /// Current OTP value
  String _currentOtp = '';

  /// User ID for verification
  int _userId = 0;

  @override
  void initState() {
    super.initState();

    // Initialize purpose - default to forgot_password if not provided
    _purpose = widget.purpose ?? 'forgot_password';

    // Initialize from widget parameters or GoRouter extra
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // First try widget parameters
      if (widget.email != null) {
        _email = widget.email!;
      }
      if (widget.phoneNumber != null) {
        _phoneNumber = widget.phoneNumber!;
      }
      if (widget.userId != null) {
        _userId = widget.userId!;
      }
      if (widget.purpose != null) {
        _purpose = widget.purpose!;
      }

      // Then try GoRouter extra parameter (for backward compatibility)
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic>) {
        if (extra['email'] != null && _email.isEmpty) {
          setState(() {
            _email = extra['email'] as String;
          });
        }
        if (extra['phoneNumber'] != null && _phoneNumber.isEmpty) {
          setState(() {
            _phoneNumber = extra['phoneNumber'] as String;
          });
        }
        if (extra['userId'] != null && _userId == 0) {
          setState(() {
            _userId = extra['userId'] as int;
          });
        }
        if (extra['purpose'] != null) {
          _purpose = extra['purpose'] as String;
        }
      }

      // If still no data, try to get from Bloc state (for phone login)
      if (_purpose == 'phone_login' && (_phoneNumber.isEmpty || _userId == 0)) {
        final currentState = context.read<AuthBloc>().state;
        if (currentState is OtpSentState) {
          setState(() {
            _phoneNumber = currentState.phoneNumber;
            _userId = currentState.userId ?? 0;
          });
        }
      }
    });

    // Set up focus listeners for each field
    for (int i = 0; i < 4; i++) {
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
          // Navigate immediately without any delay or snackbar
          context.push(
            AppRoutes.setNewPassword,
            extra: {'userId': state.userId},
          );
        } else if (state is OtpVerificationSuccess) {
          // Handle phone login success
          if (_purpose == 'phone_login') {
            setState(() {
              _isVerifying = false;
            });
            _showSuccessSnackBar('OTP verified successfully');
            context.go(AppRoutes.loginVerifiedPopup);
          }
        } else if (state is OtpSentState) {
          // Handle resend OTP success for phone login
          if (_purpose == 'phone_login') {
            setState(() {
              _phoneNumber = state.phoneNumber;
              _userId = state.userId ?? _userId;
              _isVerifying = false;
            });
            _showSuccessSnackBar('OTP sent successfully');
          }
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
                        Text(
                          _purpose == 'phone_login'
                              ? "हमने आपके मोबाइल पर 4 अंकों का OTP भेजा है"
                              : "हमने आपके ईमेल पर 4 अंकों का सत्यापन कोड भेजा है",
                          style: const TextStyle(
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
      ),
    );
  }

  /// Builds the code input section
  Widget _buildCodeInput() {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Email/Phone display
        Center(
          child: Text(
            _purpose == 'phone_login'
                ? (_phoneNumber.isNotEmpty && _phoneNumber.length == 10
                      ? '+91 ${_phoneNumber.substring(0, 5)} ${_phoneNumber.substring(5)}'
                      : _phoneNumber.isNotEmpty
                      ? '+91 $_phoneNumber'
                      : 'Loading...')
                : (_email.isNotEmpty ? _email : 'Loading...'),
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
            children: List.generate(4, (index) => _buildCodeField(index)),
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
      if (index < 3) {
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
    for (int i = 0; i < cleanValue.length && (startIndex + i) < 4; i++) {
      _codeControllers[startIndex + i].text = cleanValue[i];
    }

    // Move focus to the next empty field or the last field
    final nextEmptyIndex = _findNextEmptyField(startIndex);
    if (nextEmptyIndex < 4) {
      _codeFocusNodes[nextEmptyIndex].requestFocus();
    } else {
      // All fields are filled, focus on the last field
      _codeFocusNodes[3].requestFocus();
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
    for (int i = startIndex; i < 4; i++) {
      if (_codeControllers[i].text.isEmpty) {
        return i;
      }
    }
    return 4; // All fields are filled
  }

  /// Handles backspace key press
  void _handleBackspace() {
    // Find the currently focused field
    for (int i = 0; i < 4; i++) {
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
    if (value.isNotEmpty && index < 3) {
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
          disabledBackgroundColor: const Color(0xFF5C9A24),
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
    // Dismiss keyboard instantly
    FocusScope.of(context).unfocus();

    if (_currentOtp.length != 4) {
      _showErrorSnackBar('Please enter a valid 4-digit code');
      return;
    }

    // Validate that we have a valid userId
    if (_userId == 0) {
      _showErrorSnackBar('User ID not found. Please try again.');
      return;
    }

    // Dispatch OTP verification event to BLoC based on purpose
    if (_purpose == 'phone_login') {
      context.read<AuthBloc>().add(
        VerifyOtpEvent(
          otp: _currentOtp,
          phoneNumber: _phoneNumber,
          userId: _userId,
        ),
      );
    } else {
      context.read<AuthBloc>().add(
        VerifyForgotPasswordOtpEvent(
          userId: _userId,
          otp: _currentOtp,
          purpose: _purpose,
        ),
      );
    }
  }

  /// Resends the verification code
  void _resendCode() {
    if (_purpose == 'phone_login') {
      // Resend OTP for phone login
      if (_phoneNumber.isNotEmpty) {
        // Clear all input boxes before resending OTP
        _clearAllInputBoxes();

        // Dispatch resend OTP event to BLoC
        context.read<AuthBloc>().add(
          LoginWithOtpEvent(phoneNumber: _phoneNumber),
        );
      } else {
        // Try to get from state if not stored
        final currentState = context.read<AuthBloc>().state;
        if (currentState is OtpSentState) {
          _phoneNumber = currentState.phoneNumber;
          _userId = currentState.userId ?? _userId;
          _clearAllInputBoxes();
          context.read<AuthBloc>().add(
            LoginWithOtpEvent(phoneNumber: _phoneNumber),
          );
        } else {
          _showErrorSnackBar('Phone number not available for resending OTP');
        }
      }
    } else {
      // Resend OTP for forgot password
      if (_email.isNotEmpty) {
        // Clear all input boxes before resending OTP
        _clearAllInputBoxes();

        // Dispatch resend OTP event to BLoC
        context.read<AuthBloc>().add(
          ResendOtpEvent(email: _email, purpose: _purpose),
        );
      } else {
        _showErrorSnackBar('Email not available for resending OTP');
      }
    }
  }

  /// Clears all OTP input boxes
  void _clearAllInputBoxes() {
    for (int i = 0; i < 4; i++) {
      _codeControllers[i].clear();
    }
    _currentOtp = '';

    // Focus on the first input box after clearing
    _codeFocusNodes[0].requestFocus();
  }

  /// Shows error snackbar
  void _showErrorSnackBar(String message) {
    TopSnackBar.showError(context, message: message);
  }

  /// Shows success snackbar
  void _showSuccessSnackBar(String message) {
    TopSnackBar.showSuccess(context, message: message);
  }
}
