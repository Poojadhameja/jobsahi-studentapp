import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_constants.dart';
import '../utils/navigation_service.dart';
import 'signin1.dart';
import 'signin2.dart';
import 'create_account.dart';
import 'forgot_password.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  bool isOTPSelected = true;
  bool _isPasswordVisible = false;

  /// 👁 for password toggle

  // Add controllers for text fields
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
                onPressed: () {
                  NavigationService.goBack();
                },
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
                        Icons.person,
                        size: 45,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Sign In With",
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

              /// OTP / Mail toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildToggleButton("OTP", isOTPSelected, () {
                    setState(() => isOTPSelected = true);
                  }),
                  _buildToggleButton("MAIL", !isOTPSelected, () {
                    setState(() => isOTPSelected = false);
                  }),
                ],
              ),
              const SizedBox(height: 20),

              /// Hindi welcome text
              const Center(
                child: Text(
                  "स्वागत है! आपने लॉग इन नहीं किया कुछ समय से",
                  style: TextStyle(fontSize: 14, color: Color(0xFF4F789B)),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              /// Login input section
              isOTPSelected ? _buildOTPLogin() : _buildEmailLogin(),

              const SizedBox(height: 24),

              /// Or divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFF58B248))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Or Login with",
                      style: const TextStyle(
                        color: Color(0xFF58B248),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFF58B248))),
                ],
              ),
              const SizedBox(height: 20),

              /// Social login buttons
              _buildSocialLoginButtons(),

              const SizedBox(height: 24),

              /// Create account link
              _buildCreateAccountLink(),
            ],
          ),
        ),
      ),
    );
  }

  /// OTP / MAIL toggle button
  Widget _buildToggleButton(String text, bool active, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: active ? AppConstants.textPrimaryColor : Colors.white,
        borderRadius: text == "OTP"
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
    return Column(
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
        TextField(
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
        ),
        const SizedBox(height: 20),

        /// Send OTP
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('OTP sent successfully'),
                  duration: Duration(seconds: 2),
                  backgroundColor: AppConstants.textPrimaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              NavigationService.smartNavigate(
                destination: const Signin1Screen(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C9A24),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: const Text(
              "Send OTP",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// Email login form
  Widget _buildEmailLogin() {
    return Column(
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
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "ईमेल पता",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 20),

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
        TextField(
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Color(0xFF0B537D),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              NavigationService.smartNavigate(
                destination: const ForgotPasswordScreen(),
              );
            },
            child: const Text(
              "Forgot Password?",
              style: TextStyle(color: Color(0xFF144B75)),
            ),
          ),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Sign In Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              NavigationService.smartNavigate(
                destination: const Signin2Screen(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: const Text(
              AppConstants.loginText,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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
            debugPrint("Redirect to Google login API");
          },
        ),
        const SizedBox(height: 16),
        SignInButton(
          logoPath: AppConstants.linkedinLogoAsset,
          text: 'Sign in with Linkedin',
          onPressed: () {
            debugPrint("Redirect to LinkedIn login API");
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
        GestureDetector(
          onTap: () {
            NavigationService.smartNavigate(
              destination: const CreateAccountScreen(),
            );
          },
          child: const Text(
            "Create an account",
            style: TextStyle(
              color: Color(0xFF58B248),
              fontWeight: FontWeight.bold,
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
