import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OtpVerificationScreen(),
  ));
}

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
  List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _verifyOTP() {
    String enteredOTP = _otpControllers.map((e) => e.text).join();

    if (enteredOTP.length == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP Verified"),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF144B75),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SuccessScreen()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a 4-digit OTP"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildOTPBox(int index) {
    return SizedBox(
      width: 55,
      height: 60,
      child: TextField(
        controller: _otpControllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF144B75)),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: const Color(0xFFE7EEF5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                "Enter Code",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF144B75),
                ),
              ),
              const SizedBox(height: 8),

              /// Subtitle in Hindi
              const Text(
                "ओटीपी भेजा गया है: testing@gmail.com पर",
                style: TextStyle(color: Color(0xFF144B75)),
              ),
              const SizedBox(height: 30),

              /// OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _buildOTPBox(index)),
              ),
              const SizedBox(height: 30),

              /// Resend Button
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(""),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFF144B75),
                    ),
                  );
                },
                child: const Text(
                  "Resend",
                  style: TextStyle(color: Color(0xFF144B75)),
                ),
              ),

              const Spacer(),

              /// VERIFY & PROCEED button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "VERIFY & PROCEED",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF144B75),
        title: const Text("Welcome"),
      ),
      body: const Center(
        child: Text(
          "OTP Verified Successfully!",
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF144B75),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
