import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ForgotPasswordScreen(),
  ));
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    /// Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFEAF1F8),
                          child: Icon(Icons.arrow_back, color: Color(0xFF144B75)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    /// Avatar icon
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFE0EAF2),
                      child: Icon(Icons.person, size: 40, color: Color(0xFF144B75)),
                    ),
                    const SizedBox(height: 20),

                    /// Title
                    const Text(
                      "Forgot Password",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF144B75),
                      ),
                    ),
                    const SizedBox(height: 8),

                    /// Hindi subtitle
                    const Text(
                      "अपना ईमेल डालें – हम आपको पासवर्ड रीसेट करने का लिंक भेजेंगे",
                      style: TextStyle(fontSize: 14, color: Color(0xFF144B75)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    /// Email label
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Email Address*",
                        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF144B75)),
                      ),
                    ),
                    const SizedBox(height: 6),

                    /// Email field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "ईमेल ऐड्रेस",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFE7EEF5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),

            /// SEND MAIL Button (Bottom)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mail sent successfully'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Color(0xFF144B75),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black45,
                    ),
                    child: const Text(
                      "SEND OTP",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
