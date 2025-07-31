import 'package:flutter/material.dart';

void main() {
  runApp(const JobSearchApp());
}

class JobSearchApp extends StatelessWidget {
  const JobSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search Job',
      debugShowCheckedModeBanner: false,
      home: const SearchJobScreen(),
    );
  }
}

class SearchJobScreen extends StatelessWidget {
  const SearchJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 

      //  Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, //
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Applications'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Back Button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Search Job',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Job title input
              TextField(
                decoration: InputDecoration(
                  hintText: 'नौकरी शीर्षक, कीवर्ड, या कंपनी', suffixStyle: TextStyle(color: Color(0xFF144B75)),
                  prefixIcon: const Icon(Icons.work_outline,  color: Color(0xFF144B75)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Location input
              TextField(
                decoration: InputDecoration(
                  hintText: 'नौकरी स्थान',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF144B75)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Search Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Search Jobs',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),

              // Most Search
              const Text(
                'Most Search',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    SearchChip(label: 'इलेक्ट्रिशियन अप्रेंटिस'),
                    SizedBox(width: 8),
                    SearchChip(label: 'फिटर टेक्नीशियन'),
                    SizedBox(width: 8),
                    SearchChip(label: 'ऑटोमोबाइल'),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Banner
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/home.png', // Replace with your asset path
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // Recommended Jobs Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Recommended jobs(अनुशंसित नौकरियाँ)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  Text('See All', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 10),

              // Job Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFB2DFDB),
                          child: Icon(Icons.bolt, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'इलेक्ट्रीशियन अप्रेंटिस',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'VoltX Energy   ⭐ 4.7 Review',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.bookmark_border, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text('save', style: TextStyle(color: Color(0xFF144B75))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        JobTypeChip(label: 'Full-Time'),
                        SizedBox(width: 10),
                        JobTypeChip(label: 'Apprenticeship'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('₹1.2L – ₹1.8L P.A.'),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text('Nashik, India', style: TextStyle(color: Colors.grey)),
                        Spacer(),
                        Text('3 दिन पहले', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable search chip
class SearchChip extends StatelessWidget {
  final String label;

  const SearchChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue),
      ),
      avatar: const Icon(Icons.search, size: 18),
      label: Text(label),
    );
  }
}

// Reusable job type chip
class JobTypeChip extends StatelessWidget {
  final String label;

  const JobTypeChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.grey.shade200,
      label: Text(label),
    );
  }
}
