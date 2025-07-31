import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: JobDetailsScreen(),
  ));
}

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Color(0xFF144B75)),
        title: const Text('Job Details', style: TextStyle(color: Color(0xFF144B75))),
        backgroundColor: const Color(0xFFF5F9FC),
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.bookmark_border, color: Color(0xFF144B75)),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF58B248),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {},
          child: const Text(
            "Apply This Job",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: const Color(0xFFF5F9FC),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFD7EDFF),
                    radius: 26,
                    child: Icon(Icons.contact_mail_rounded, color: Colors.blue, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'इलेक्ट्रिशियन अप्रेंटिस',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF144B75)),
                      ),
                      SizedBox(height: 4),
                      Text('Bakeron', style: TextStyle(fontSize: 14, color: Colors.green)),
                    ],
                  )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  // Full-Time
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        "Full-Time",
                        style: TextStyle(color: Colors.blue), // better contrast
                      ),
                    ),
                  ),

                  // On-Site
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12, // still allowed outside const
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        "On-Site",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),

                  // Apprenticeship
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        "Apprenticeship",
                        style: TextStyle(color: Colors.blue), // improved visibility
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Text("₹1.2L – ₹1.8L P.A.", style: TextStyle(fontSize: 14, color: Color(0xFF144B75))),
                  Spacer(),
                  Text("5 days ago", style: TextStyle(color: Color(0xFF144B75))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Color(0xFF144B75),
              labelStyle: TextStyle(fontSize: 16),
              unselectedLabelStyle: TextStyle(fontSize: 14),
              tabs: [
                Tab(text: "About"),
                Tab(text: "Company"),
                Tab(text: "Review"),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  AboutTab(),
                  CompanyTab(),
                  ReviewTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("About the role", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF144B75))),
          SizedBox(height: 8),
          Text(
            'An Electrician Apprentice assists in installing, maintaining, and repairing electrical systems...',
            style: TextStyle(color: Color(0xFF144B75)),
          ),
          SizedBox(height: 12),
          Text(
            '➡️ इलेक्ट्रिशियन अप्रेंटिस रहने पर आप बिजली संबंधित सिस्टम को इंस्टॉल, मेंटेन और रिपेयर करने में सहायता करोगे — जैसे कि रेसिडेंशियल, कमर्शियल या इंडस्ट्रियल सेटिंग में।',
            style: TextStyle(height: 1.4, color: Color(0xFF144B75)),
          ),
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 8),
          Text("मुख्य ज़िम्मेदारियाँ (Key Responsibilities)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF144B75))),
          SizedBox(height: 12),
          BulletPoint(text: 'नई बिल्डिंग या मरम्मत के लिए वायरिंग इंस्टॉल करना'),
          BulletPoint(text: 'इलेक्ट्रिकल फ़ॉल्ट्स को ठीक करने और टेस्ट करने में सीनियर की मदद करना'),
          BulletPoint(text: 'इलेक्ट्रिकल पैनल, स्विच, सॉकेट, लाइटिंग सिस्टम आदि की देखभाल करना'),
          BulletPoint(text: 'वायरिंग प्लान, ब्लूप्रिंट और तकनीकी ड्रॉइंग पढ़ना सीखना'),
          BulletPoint(text: 'सेफ्टी प्रोटोकॉल और ऑपरेशन प्रोसेस को फॉलो करना'),
          BulletPoint(text: 'मल्टीमीटर, वायर स्ट्रिपर, पाइप बेंडर जैसे टूल्स को चलाना'),
        ],
      ),
    );
  }
}

class CompanyTab extends StatelessWidget {
  const CompanyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("About Company", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF144B75))),
          const SizedBox(height: 6),
          const Text(
            "जब किसी कंपनी का विवरण लिखा जाता है, तब उसमें कंपनी का मिशन, इतिहास, और संस्कृति की जानकारी दी जाती है…",
            style: TextStyle(color: Color(0xFF144B75)),
          ),
          const SizedBox(height: 16),
          infoRow(Icons.language, "Website", "www.google.com"),
          const SizedBox(height: 12),
          infoRow(Icons.location_on, "Headquarters", "Noida, India"),
          const SizedBox(height: 12),
          infoRow(Icons.calendar_today, "Founded", "14 July 2005"),
          const SizedBox(height: 12),
          infoRow(Icons.group, "Size", "2500"),
          const SizedBox(height: 12),
          infoRow(Icons.currency_rupee_outlined, "Revenue", "10,000 Millions"),
        ],
      ),
    );
  }
}

class ReviewTab extends StatelessWidget {
  const ReviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Column(
                  children: const [
                    Text("4.5", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF144B75))),
                    Text("/5"),
                    Text("2.7k Review", style: TextStyle(color: Color(0xFF144B75))),
                  ],
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Column(
                    children: [
                      ratingBar("5 Star", 0.9),
                      ratingBar("4 Star", 0.7),
                      ratingBar("3 Star", 0.5),
                      ratingBar("2 Star", 0.2),
                      ratingBar("1 Star", 0.1),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Text("Review", style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text("Add Review", style: TextStyle(color: Color(0xFF144B75))),
                SizedBox(width: 10),
                Text("Recent", style: TextStyle(color: Colors.black54)),
                Icon(Icons.arrow_drop_down, color: Colors.black54),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: const [
                ReviewCard(
                  name: "Kim Shine",
                  rating: 5.0,
                  time: "2 hr ago",
                  comment: "एक सहयोगी और सकारात्मक कार्य वातावरण मिलता है...",
                ),
                ReviewCard(
                  name: "Avery Thompson",
                  rating: 3.0,
                  time: "3 days ago",
                  comment: "फ्रेंडली वर्क एनवायरमेंट, लेकिन फिजिकली थकाने वाला हो सकता है।",
                ),
                ReviewCard(
                  name: "Jordan Mitchell",
                  rating: 4.0,
                  time: "2 months ago",
                  comment: "",
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

Widget ratingBar(String label, double value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        SizedBox(width: 50, child: Text(label)),
        const SizedBox(width: 6),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade300,
            color: const Color(0xFFFFC107),
            minHeight: 8,
          ),
        ),
      ],
    ),
  );
}

class ReviewCard extends StatelessWidget {
  final String name;
  final double rating;
  final String time;
  final String comment;

  const ReviewCard({
    super.key,
    required this.name,
    required this.rating,
    required this.time,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
                const SizedBox(width: 10),
                Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
                Row(
                  children: [
                    Text(rating.toString(), style: const TextStyle(color: Colors.black54)),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(time, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ],
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(comment, style: const TextStyle(color: Colors.black87)),
            ],
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  final Color color;

  const BulletPoint({
    super.key,
    required this.text,
    this.color = const Color(0xFF144B75),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontSize: 18, color: color)),
          Expanded(
            child: Text(text, style: TextStyle(height: 1.4, color: color)),
          ),
        ],
      ),
    );
  }
}

Widget infoRow(IconData icon, String title, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: Color(0xFF144B75)),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF144B75))),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Color(0xFF144B75))),
          ],
        ),
      ),
    ],
  );
}
