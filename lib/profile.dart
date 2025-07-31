import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CompleteProfileScreen(),
  ));
}

/// Dummy next page
class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Next Page"),
        backgroundColor: const Color(0xFF144B75),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "You have successfully moved to the next screen!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

/// Edit Avatar Page
class EditAvatarScreen extends StatelessWidget {
  const EditAvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Avatar"),
        backgroundColor: const Color(0xFF144B75),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Edit Avatar Page",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

/// Profile Avatar + Edit Widget
class ProfileAvatarEdit extends StatelessWidget {
  final VoidCallback onEdit;

  const ProfileAvatarEdit({super.key, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE0ECF6),
          ),
          child: const Icon(
            Icons.person,
            size: 60,
            color: Color(0xFF144B75),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 16, color: Colors.white),
          label: const Text(
            "Edit",
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3D7CA4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

/// Main Screen
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String selectedGender = 'Male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFF0F5FA),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF144B75)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Complete Your Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF144B75),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "आपकी जानकारी सिर्फ आपके लिए सुरक्षित है    कोई और इसे नहीं\nदेख सकता",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF144B75)),
              ),
              const SizedBox(height: 25),

              /// Avatar with Edit
              ProfileAvatarEdit(
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditAvatarScreen()),
                  );
                },
              ),
              const SizedBox(height: 15),

              /// Name
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: const TextSpan(
                    text: 'Name',
                    style: TextStyle(color: Color(0xFF144B75), fontSize: 14),
                    children: [
                      TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "नाम",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// Phone
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: const TextSpan(
                    text: 'Phone Number',
                    style: TextStyle(color: Color(0xFF144B75), fontSize: 14),
                    children: [
                      TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: "मोबाइल नंबर",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFE7EDF4),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '+91',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 20),

              /// Gender
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: const TextSpan(
                    text: 'Gender',
                    style: TextStyle(color: Color(0xFF144B75), fontSize: 14),
                    children: [
                      TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  genderOption("Male"),
                  const SizedBox(width: 16),
                  genderOption("Female"),
                  const SizedBox(width: 16),
                  genderOption("Other"),
                ],
              ),
              const SizedBox(height: 60),

              /// Next Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NextPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BAF46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gender Widget
  Widget genderOption(String gender) {
    return Row(
      children: [
        Radio<String>(
          value: gender,
          groupValue: selectedGender,
          activeColor: const Color(0xFF144B75),
          onChanged: (val) {
            setState(() {
              selectedGender = val!;
            });
          },
        ),
        Text(gender),
      ],
    );
  }
}
