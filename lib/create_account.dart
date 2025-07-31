import 'package:flutter/material.dart';
import 'signin1.dart'; // make sure this file exists

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SignUpScreen(),
  ));
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool agreeToTerms = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 5),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFE0EAF2),
                child: Icon(Icons.person, size: 40, color: Color(0xFF144B75)),
              ),
              const SizedBox(height: 6),
              const Text(
                "Create your account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF144B75)),
              ),
              const SizedBox(height: 8),
              const Text(
                "वापसी का स्वागत है! कृपया अपनी जानकारी दर्ज करें",
                style: TextStyle(color: Color(0xFF144B75)),
              ),
              const SizedBox(height: 15),

              // Name
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Name*", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF144B75))),
              ),
              const SizedBox(height: 3),
              TextField(
                decoration: InputDecoration(
                  hintText: "नाम",
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

              // Email
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Email Address*", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF144B75))),
              ),
              const SizedBox(height: 3),
              TextField(
                decoration: InputDecoration(
                  hintText: "ईमेल ऐड्रेस",
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

              // Password
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Password*", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF144B75))),
              ),
              const SizedBox(height: 3),
              TextField(
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
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 3),

              // Checkbox
              Row(
                children: [
                  Checkbox(
                    value: agreeToTerms,
                    onChanged: (value) {
                      setState(() => agreeToTerms = value ?? false);
                    },
                    activeColor: const Color(0xFF144B75),
                  ),
                  const Expanded(
                    child: Text(
                      "मैं नियम, प्राइवेसी और शुल्क से सहमत हूँ",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Add sign-up logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("SIGN UP", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),

              // Divider
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.green)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("Or Continue With", style: TextStyle(color: Colors.green)),
                  ),
                  Expanded(child: Divider(color: Colors.green)),
                ],
              ),
              const SizedBox(height: 10),

              // Google
              SignInButton(
                logoPath: 'assets/google.png',
                text: 'Sign in with google',
                onPressed: () {
                  // Add your Google sign-in logic
                },
              ),
              const SizedBox(height: 5),

              // LinkedIn
              SignInButton(
                logoPath: 'assets/linkedin.png',
                text: 'Sign in with LinkedIn',
                onPressed: () {
                  // Add your LinkedIn sign-in logic
                },
              ),
              const SizedBox(height: 10),

              // Already a member
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already a member?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(color: Colors.green),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(logoPath, height: 24),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Color(0xFF144B75))),
          ],
        ),
      ),
    );
  }
}
