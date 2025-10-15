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

class LoginOtpEmailScreen extends StatefulWidget {
  final bool showBackButton;

  const LoginOtpEmailScreen({
    super.key,
    this.showBackButton = false, // Default false since login is auth root
  });

  @override
  State<LoginOtpEmailScreen> createState() => _LoginOtpEmailScreenState();
}

class _LoginOtpEmailScreenState extends State<LoginOtpEmailScreen> {
  bool isOTPSelected = false; // false = Email selected, true = Phone selected
  bool _isPasswordVisible = false;
  bool _isSubmitting = false; // Track submission state locally

  /// 👁 for password toggle

  /// Double back press handling
  DateTime? _lastBackPressed;

  // Add controllers for text fields
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form keys for validation
  final _otpFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        debugPrint("🔵 LoginScreen received state: ${state.runtimeType}");

        if (state is AuthLoading) {
          // Set submitting state when loading starts
          setState(() {
            _isSubmitting = true;
          });
        } else if (state is AuthError) {
          debugPrint("🔵 LoginScreen showing error: ${state.message}");
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
        } else if (state is OtpSentState) {
          debugPrint("🔵 LoginScreen navigating to OTP code screen");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully'),
              duration: Duration(seconds: 2),
              backgroundColor: AppConstants.textPrimaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Keep submitting state true until navigation completes
          context.push(AppRoutes.loginOtpCode);
        } else if (state is AuthSuccess) {
          debugPrint("🔵 LoginScreen showing success and navigating to popup");
          debugPrint("🔵 AuthSuccess message: ${state.message}");
          debugPrint("🔵 AuthSuccess user: ${state.user}");
          // Use go instead of push to replace the route and prevent back navigation
          context.go(AppRoutes.loginVerifiedPopup);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _handleBackPress();
        },
        child: KeyboardDismissWrapper(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // Sticky header section
                  Builder(
                    builder: (context) {
                      // Check if back button should be shown
                      final shouldShowBackButton =
                          widget.showBackButton && context.canPop();

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.largePadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Back button (conditionally shown)
                            if (shouldShowBackButton) ...[
                              const SizedBox(height: 2),
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: AppConstants.textPrimaryColor,
                                ),
                                onPressed: () {
                                  context.pop();
                                },
                              ),
                              const SizedBox(height: 4),
                            ] else
                              const SizedBox(height: 50),

                            /// Profile avatar & title
                            Center(
                              child: Column(
                                children: [
                                  const CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Color(0xFFE0E7EF),
                                    child: Icon(
                                      Icons.person,
                                      size: 45,
                                      color: AppConstants.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "Sign in with",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.textPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            /// Email / Phone toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildToggleButton("Email", !isOTPSelected, () {
                                  setState(() => isOTPSelected = false);
                                }),
                                _buildToggleButton("Phone", isOTPSelected, () {
                                  setState(() => isOTPSelected = true);
                                }),
                              ],
                            ),
                            const SizedBox(height: 20),

                            /// Hindi welcome text
                            const Center(
                              child: Text(
                                "अपने सपनों की नौकरी तक पहुंचने के लिए लॉग इन करें",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4F789B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                  ),

                  // Scrollable content section
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.largePadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          /// Login input section
                          isOTPSelected ? _buildOTPLogin() : _buildEmailLogin(),

                          const SizedBox(height: 24),

                          /// Or divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: Color(0xFF58B248)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: const Text(
                                  "Or Login with",
                                  style: TextStyle(
                                    color: Color(0xFF58B248),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: Color(0xFF58B248)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          /// Social login buttons
                          _buildSocialLoginButtons(),

                          const SizedBox(height: 24),

                          /// Create account link
                          _buildCreateAccountLink(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handle back press with double tap to exit
  void _handleBackPress() {
    final now = DateTime.now();

    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      // First back press - show exit message
      _lastBackPressed = now;
      _showExitMessage();
    } else {
      // Second back press within 2 seconds - exit app
      _exitApp();
    }
  }

  /// Show exit confirmation message
  void _showExitMessage() {
    // Create custom overlay with fade animations
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CustomExitSnackbar(
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// Exit the app
  void _exitApp() {
    SystemNavigator.pop();
  }

  /// Email / Phone toggle button
  Widget _buildToggleButton(String text, bool active, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: active ? AppConstants.textPrimaryColor : Colors.white,
        borderRadius: text == "Email"
            ? const BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              )
            : const BorderRadius.only(
                topRight: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
        border: Border.all(color: AppConstants.textPrimaryColor),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : AppConstants.textPrimaryColor,
          ),
        ),
      ),
    );
  }

  /// OTP login form
  Widget _buildOTPLogin() {
    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              text: 'Phone Number',
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textPrimaryColor,
              ),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _mobileController,
            decoration: InputDecoration(
              hintText: "मोबाइल नंबर",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFE7EDF4),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '+91',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter mobile number';
              }
              if (value.length != 10) {
                return 'Mobile number must be 10 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          /// Send OTP
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (_otpFormKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                          LoginWithOtpEvent(
                            phoneNumber: _mobileController.text,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C9A24),
                disabledBackgroundColor: const Color(0xFF5C9A24),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
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
                      "Send OTP",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Email login form
  Widget _buildEmailLogin() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: const TextSpan(
                text: 'Email Address',
                style: TextStyle(fontSize: 14, color: Color(0xFF144B75)),
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: "ईमेल पता",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email address';
              }
              // Email validation regex
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),

          const SizedBox(height: 8),

          // Password field
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: const TextSpan(
                text: 'Password',
                style: TextStyle(fontSize: 14, color: Color(0xFF144B75)),
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: "पासवर्ड",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF0B537D),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 4),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                context.go(AppRoutes.forgotPassword);
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: Color(0xFF144B75)),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (_emailFormKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                          LoginWithEmailEvent(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.secondaryColor,
                disabledBackgroundColor: AppConstants.secondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
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
                      AppConstants.loginText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Google & LinkedIn login
  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        SignInButton(
          logoPath: AppConstants.googleLogoAsset,
          text: 'Sign in with Google',
          onPressed: () {
            // Social login integration pending
            debugPrint("Google login - Integration pending");
          },
        ),
        const SizedBox(height: 16),
        SignInButton(
          logoPath: AppConstants.linkedinLogoAsset,
          text: 'Sign in with Linkedin',
          onPressed: () {
            // Social login integration pending
            debugPrint("LinkedIn login - Integration pending");
          },
        ),
      ],
    );
  }

  /// Create account link
  Widget _buildCreateAccountLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Not a member? "),
        InkWell(
          onTap: () {
            context.go(AppRoutes.createAccount);
          },
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: const Text(
              "Create an account",
              style: TextStyle(
                color: Color(0xFF58B248),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom social login button
class SignInButton extends StatelessWidget {
  final String logoPath;
  final String text;
  final VoidCallback onPressed;

  const SignInButton({
    super.key,
    required this.logoPath,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset(
        logoPath,
        height: 24,
        width: 24,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      ),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Color(0xFFE0E7EF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}

/// Custom exit snackbar with fade animations
class _CustomExitSnackbar extends StatefulWidget {
  final VoidCallback onDismiss;

  const _CustomExitSnackbar({required this.onDismiss});

  @override
  State<_CustomExitSnackbar> createState() => _CustomExitSnackbarState();
}

class _CustomExitSnackbarState extends State<_CustomExitSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start animation
    _animationController.forward();

    // Start fade out after 1.2 seconds
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _animationController.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 167,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    'Press back again to exit the app',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
