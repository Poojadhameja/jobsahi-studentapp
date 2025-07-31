import 'package:flutter/material.dart';
import 'splash2.dart';


void main() {
  runApp(const Splash2());
}

class Splash2 extends StatelessWidget {
  const Splash2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: splash2(),
    );
  }
}

class splash2 extends StatelessWidget {
  const splash2({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/s1.png',
                    height: 280,
                  ),
                  Align(
                    alignment: const FractionalOffset(0.3, 0.85),
                    child: _buildTag("#Civil", Colors.purple),
                  ),
                  Align(
                    alignment: const FractionalOffset(0.8, 0.05),
                    child: _buildTag("#Disel Mechanic", Colors.blue),
                  ),
                  Align(
                    alignment: const FractionalOffset(0.05, 0.55),
                    child: _buildTag("#Mechanical", Colors.teal),
                  ),
                  Align(
                    alignment: const FractionalOffset(0.9, 0.7),
                    child: _buildTag("#Electrician", Colors.red),
                  ),
                  Align(
                    alignment: const FractionalOffset(0.2, 0.1),
                    child: _buildTag("#Fitter", Colors.deepOrange),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Text(
                    'Your Skills Deserve the Right Opportunity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C2A38),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'आपकी प्रतिभा और नौकरी के बीच की दूरी को\nकम करें',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildPagination(context), // fixed: pass context here
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: ElevatedButton(
                onPressed: () {
                  // Go to HomeScreen directly
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Let’s Get Started",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Skip to HomeScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              child: const Text(
                "SKIP →",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }


  static Widget _buildPagination(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            // Navigate to ConnectPage instead of splash2
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const splash2()),
            );
          },
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green,
            child: Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ),
      ],
    );
  }

}






// Dummy home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: const Center(
        child: Text(
          "Welcome to Home Screen!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}