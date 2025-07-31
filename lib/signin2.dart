import 'package:flutter/material.dart';
import 'package:my_new_project/signin.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isOTPSelected = false;
  bool _obscurePassword = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.arrow_back, size: 28),
                ),
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFE0E7EF),
                  child: Icon(Icons.person, size: 40, color: Color(0xFF144B75)),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Sign In With",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,  color: Color(0xFF144B75),),

                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isOTPSelected ? const Color(0xFF144B75) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                        ),
                        border: Border.all(color: const Color(0xFF144B75)),
                      ),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            isOTPSelected = false;
                          });
                        },
                        child: Text(
                          "OTP",
                          style: TextStyle(
                            color: isOTPSelected ? Colors.white : const Color(0xFF144B75),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: !isOTPSelected ? const Color(0xFF144B75) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                        border: Border.all(color: const Color(0xFF144B75)),
                      ),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            isOTPSelected = true;
                          });
                        },
                        child: Text(
                          "MAIL",
                          style: TextStyle(
                            color: !isOTPSelected ? Colors.white : const Color(0xFF144B75),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "स्वागत है! आपने लॉग इन नहीं किया कुछ समय से",
                  style: TextStyle(fontSize: 14, color: Color(0xFF144B75)),
                ),
                const SizedBox(height: 16),

                /// Email field
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email Address*",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF144B75)),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  decoration: InputDecoration(
                    hintText: "ईमेल पता",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

          const SizedBox(height: 10),

          /// Password field with Show/Hide toggle
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Password*",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF144B75),
              ),
            ),
          ),
          const SizedBox(height: 10),
          StatefulBuilder(
            builder: (BuildContext context, StateSetter localSetState) {
              return TextField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "पासवर्ड",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF0B537D),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                      localSetState(() {}); // Ensures StatefulBuilder updates too
                    },
                  ),
                ),
              );
            },
          ),

                const SizedBox(height: 8),

                /// Forgot Password with tap popup
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('A reset password link has been sent to your email.'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Color(0xFF144B75), // Custom background color
                        ),
                      );
                    },
                    child: const Text(
                      "Forgot Password",
                      style: TextStyle(color: Color(0xFF144B75)),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Sign In logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "SIGN IN",
                      style: TextStyle(
                        color: Colors.white, // White text color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),


                const SizedBox(height: 15),

                /// Divider with "Or Continue With"
                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.green)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Or Continue With"),
                    ),
                    Expanded(child: Divider(color: Colors.green)),
                  ],
                ),

                const SizedBox(height: 10),
                SignInButton(
                  logoPath: 'assets/google.png',
                  text: 'Sign in with google',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );// Google sign-in logic
                  },
                ),
                const SizedBox(height: 10),
                SignInButton(
                  logoPath: 'assets/linkedin.png',
                  text: 'Sign in with Linkedin',
                  onPressed: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    ); // LinkedIn sign-in logic
                  },
                ),

                const SizedBox(height: 10),

                /// Create Account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Not a member?"),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to Create Account
                      },
                      child: const Text(
                        "Create an account",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Toggle Button Widget
class ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLeft;

  const ToggleButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF144B75) : Colors.white,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(6) : Radius.zero,
            right: !isLeft ? const Radius.circular(6) : Radius.zero,
          ),
          border: Border.all(color: const Color(0xFF144B75)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF144B75),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Social Sign-in Button Widget
class SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final Color borderColor;

  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton.icon(
        onPressed: () {
          // TODO: Add respective login logic
        },
        icon: Icon(icon, color: textColor),
        label: Text(label, style: TextStyle(color: textColor)),
      ),
    );
  }
}
