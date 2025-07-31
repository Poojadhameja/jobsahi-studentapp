import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ExperienceLevelScreen(),
  ));
}

class ExperienceLevelScreen extends StatefulWidget {
  const ExperienceLevelScreen({super.key});

  @override
  State<ExperienceLevelScreen> createState() => _ExperienceLevelScreenState();
}

class _ExperienceLevelScreenState extends State<ExperienceLevelScreen> {
  String? selectedOption;

  void onOptionSelected(String value) {
    setState(() {
      selectedOption = value;
    });
  }

  Widget customOption(String value) {
    final isSelected = selectedOption == value;
    return GestureDetector(
      onTap: () => onOptionSelected(value),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onOptionSelected(value),
              activeColor: Colors.blue,
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1), // Deep blue
              Color(0xFF042A5F5), // Mid white
              Colors.white, // white bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 4),
              // Top stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  StepCircle(number: 1, isFilled: true),
                  StepLine(isFilled: false),
                  StepCircle(number: 2, isFilled: true),
                  StepLine(isFilled: true),
                  StepCircle(number: 3, isFilled: false),
                ],
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "What is your current\nexperience level?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF144B75),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "नीचे से सही विकल्प चुनें",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Color(0xFF144B75)),
                      ),
                      const SizedBox(height: 5),
                      customOption("Fresher"),
                      customOption("Poly"),
                      customOption("Other"),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: selectedOption != null
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NextScreen()),
                          );
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Next",
                          style: TextStyle(fontSize: 16,  color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StepCircle extends StatelessWidget {
  final int number;
  final bool isFilled;

  // Stepper Circle

  const StepCircle({super.key, required this.number, required this.isFilled});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: isFilled ? Colors.white : Colors.white,
      child: CircleAvatar(
        radius: 15,
        backgroundColor: isFilled ? Colors.white : Colors.white,
        child: Text(
          "$number",
          style: const TextStyle(fontSize: 16, color: Colors.blue),
        ),
      ),
    );
  }
}

  // Stepper Circle
class StepLine extends StatelessWidget {
  final bool isFilled;

  const StepLine({super.key, required this.isFilled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      color: isFilled ? Colors.white : Colors.grey.shade400,
    );
  }
}

// Dummy next screen for navigation
class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Next Screen")),
      body: const Center(child: Text("You navigated to the next screen.")),
    );
  }
}
