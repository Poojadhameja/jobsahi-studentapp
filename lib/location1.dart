import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LocationScreen(),
  ));
}

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Location icon
              Icon(
                Icons.location_on,
                size: 100,
                color: Colors.green[700],
              ),

              const SizedBox(height: 30),

              // Title
              const Text(
                "What is your Location?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003366), // dark blue
                ),
              ),

              const SizedBox(height: 8),

              // Subtext in Hindi
              const Text(
                "अपने पास की नौकरियों को खोजने के लिए लोकेशन शुरू करें",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 40),

              // Allow location button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ConnectScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "Allow Location Access",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Enter location manually text
              TextButton(
                onPressed: () {
                  // You can route to a manual location input screen here
                },
                child: Text(
                  "Enter location Manually",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect"),
        backgroundColor: Colors.green[700],
      ),
      body: const Center(
        child: Text(
          "Welcome to the Connect Page!",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
