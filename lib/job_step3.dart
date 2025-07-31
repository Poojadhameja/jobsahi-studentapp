import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TradeSelectionScreen(),
  ));
}

class ConnectPage extends StatelessWidget {
  const ConnectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Connect Page')),
    );
  }
}

class TradeSelectionScreen extends StatefulWidget {
  const TradeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TradeSelectionScreen> createState() => _TradeSelectionScreenState();
}

class _TradeSelectionScreenState extends State<TradeSelectionScreen> {
  final List<String> trades = [
    'Computer Science',
    'COPA',
    'Disel Mechanic',
    'Mining',
    'Mechanical',
    'Fitter',
    'Electrical',
    'Electrician',
    'Civil',
    'On Demand',
  ];

  String? selectedTrade = 'Computer Science';

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
              Colors.white, // White bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Top Stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  StepCircle(number: 1, isFilled: true),
                  StepLine(isFilled: false),
                  StepCircle(number: 2, isFilled: true),
                  StepLine(isFilled: true),
                  StepCircle(number: 3, isFilled: true),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'What trade are you\nlooking to obtain?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF144B75),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'नीचे से सही विकल्प चुनें',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: trades.length,
                          itemBuilder: (context, index) {
                            String trade = trades[index];
                            bool isSelected = selectedTrade == trade;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTrade = trade;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFE8F0FE) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF1967D2) : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (_) {
                                        setState(() {
                                          selectedTrade = trade;
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4)),
                                      activeColor: const Color(0xFF1967D2),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        trade,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isSelected ? Colors.black : Colors.black87,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64A70B), // Green
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ConnectPage()),
                          );
                        },
                        child: const Text(
                          "Next",
                          style: TextStyle(fontSize: 18, color: Colors.white),
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

// Stepper Circle

class StepCircle extends StatelessWidget {
  final int number;
  final bool isFilled;

  const StepCircle({Key? key, required this.number, required this.isFilled})
      : super(key: key);

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

//Stepper Line

class StepLine extends StatelessWidget {
  final bool isFilled;

  const StepLine({Key? key, required this.isFilled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      color: isFilled ? Colors.white : Colors.grey.shade400,
    );
  }
}