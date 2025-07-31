import 'package:flutter/material.dart';
import 'splash1.dart'; // Import your next screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Job Sahi',
      debugShowCheckedModeBanner: false,
      home: Splash1(), // Start with Splash1
    );
  }
}

class Splash1 extends StatefulWidget {
  const Splash1({Key? key}) : super(key: key);

  @override
  State<Splash1> createState() => _Splash1State();
}

class _Splash1State extends State<Splash1> {
  @override
  void initState() {
    super.initState();

    // Navigate to Splash2 after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Splash1()), // Go to Splash2 instead
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/job_sahi_logo.png', // Ensure this path is correct in pubspec.yaml
              height: 120,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.green),
          ],
        ),
      ),
    );
  }
}
