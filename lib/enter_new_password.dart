import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: NewPasswordScreen(),
  ));
}

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Navigate to Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  InputDecoration _inputDecoration(String hintText, bool obscureText, VoidCallback toggle) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFE7EEF5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
        ),
        onPressed: toggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 16),

                    /// Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFEAF1F8),
                          child: Icon(Icons.arrow_back, color: Color(0xFF144B75)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    /// Avatar Icon
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFE0EAF2),
                      child: Icon(Icons.person, size: 40, color: Color(0xFF144B75)),
                    ),
                    const SizedBox(height: 20),

                    /// Title
                    const Text(
                      "Enter New Password",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF144B75),
                      ),
                    ),
                    const SizedBox(height: 8),

                    /// Subtitle in Hindi
                    const Text(
                      "आपका नया पासवर्ड पहले वाले से अलग होना चाहिए",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF144B75)),
                    ),
                    const SizedBox(height: 30),

                    /// Password Field
                    const Text("Password*", style: TextStyle(color: Color(0xFF144B75))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration("पासवर्ड", _obscurePassword, () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      }),
                      style: const TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    /// Confirm Password Field
                    const Text("Confirm Password*", style: TextStyle(color: Color(0xFF144B75))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: _inputDecoration("पासवर्ड दोबारा दर्ज करें", _obscureConfirmPassword, () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      }),
                      style: const TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            /// Login Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dummy Login Screen
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF144B75),
        title: const Text("Login"),
      ),
      body: const Center(
        child: Text(
          "This is the Login Screen",
          style: TextStyle(fontSize: 22, color: Color(0xFF144B75)),
        ),
      ),
    );
  }
}
