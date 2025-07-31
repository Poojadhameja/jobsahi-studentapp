import 'package:flutter/material.dart';

void main() {
  runApp(const JobApp());
}

class JobApp extends StatelessWidget {
  const JobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Sahi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

// Home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomePage(),
    CoursesPage(),
    ApplicationsPage(),
    MessagesPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF144B75),
        unselectedItemColor: Colors.lightBlue,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Applications'),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// Home Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget filterChip(String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF144B75),
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF144B75)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF144B75)),
          onPressed: () {},
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'नौकरी खोजें',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF144B75)),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none, color: Color(0xFF144B75)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Hi Name,',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF144B75),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('सेव की गई नौकरियाँ', style: TextStyle(color: Color(0xFF144B75))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('आवेदन की गई नौकरियाँ', style: TextStyle(color: Color(0xFF144B75))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/home.png'),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  filterChip("Filter"),
                  const SizedBox(width: 8),
                  filterChip("Sort"),
                  const SizedBox(width: 8),
                  filterChip("Job Title"),
                  const SizedBox(width: 8),
                  filterChip("Experience"),
                  const SizedBox(width: 8),
                  filterChip("Location"),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Recommended jobs (अनुशंसित नौकरियाँ)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 10),
            const JobList(),
          ],
        ),
      ),
    );
  }
}

// Job List & Cards
class JobList extends StatelessWidget {
  const JobList({super.key});

  final List<Map<String, dynamic>> jobs = const [
    {
      "title": "इलेक्ट्रिशियन अप्रेंटिस",
      "company": "VoltX Energy",
      "rating": 4.7,
      "tags": ["Full-Time", "Apprenticeship"],
      "salary": "₹1.2L – ₹1.8L P.A.",
      "location": "Nashik, India",
      "time": "3 दिन पहले",
      "logo": "assets/group.png",
    },

    // You can add more jobs here
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: jobs.map((job) => JobCard(job: job)).toList(),
    );
  }
}

class JobCard extends StatefulWidget {
  final Map<String, dynamic> job;
  const JobCard({super.key, required this.job});

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(job['logo'], width: 40, height: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(job['company'], style: const TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  Text(job['rating'].toString()),
                ],
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => isSaved = !isSaved),
                child: Column(
                  children: [
                    Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSaved ? 'Saved' : 'Save',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF144B75)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: job['tags'].map<Widget>((tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: JobTag(text: tag),
            )).toList(),
          ),
          const SizedBox(height: 10),
          Text(job['salary'], style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(job['location']),
              const Spacer(),
              Text(job['time'], style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class JobTag extends StatelessWidget {
  final String text;
  const JobTag({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.blue),
      ),
    );
  }
}

// Bottom Navigation Screens
class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Courses Page (Connect with Courses)', style: TextStyle(fontSize: 20))),
    );
  }
}

class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Applications Page (Jobs you applied)', style: TextStyle(fontSize: 20))),
    );
  }
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Messages Page (Inbox)', style: TextStyle(fontSize: 20))),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Profile Page (User Settings)', style: TextStyle(fontSize: 20))),
    );
  }
}
