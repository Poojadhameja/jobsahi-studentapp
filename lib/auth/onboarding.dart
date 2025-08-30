import 'package:flutter/material.dart';
import '../utils/navigation_service.dart';
import 'login_otp_email.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding data
  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      image: 'assets/images/onboarding/onboarding_img1.png',
      title: 'Your Skills Deserve the Right Opportunity',
      subtitle: 'आपकी प्रतिभा और नौकरी के बीच की दूरी को\nकम करें',
      tags: [
        OnboardingTag('#Civil', Colors.purple, 0.02, 0.55),
        OnboardingTag('#Diesel Mechanic', Colors.blue, 0.8, 0.05),
        OnboardingTag('#Mechanical', Colors.teal, 0.05, 0.85),
        OnboardingTag('#Electrician', Colors.red, 0.9, 0.8),
        OnboardingTag('#Fitter', Colors.deepOrange, 0.2, 0.1),
      ],
    ),
    OnboardingData(
      image: 'assets/images/onboarding/onboarding_img2.png',
      title: 'Built for Graduates, Backed by Industry',
      subtitle: 'जब आसानियाँ के साथ करियर की शुरुआत\nकरें',
      tags: [
        OnboardingTag('#Civil', Colors.purple, 0.9, 0.85),
        OnboardingTag('#Diesel Mechanic', Colors.blue, 0.1, 0.15),
        OnboardingTag('#Electrician', Colors.red, 0.05, 0.85),
        OnboardingTag('#Mining', Colors.orange, 0.9, 0.30),
        OnboardingTag('#Mechanical', Colors.teal, 0.8, 0.05),
      ],
    ),
    OnboardingData(
      image: 'assets/images/onboarding/onboarding_img3.png',
      title: 'Smarter Job Matching. Better Results.',
      subtitle: 'जब बार-बार खोजने की जरूरत नहीं, नौकरियाँ खुद\nआपको खोजेंगी',
      tags: [
        OnboardingTag('#Civil', Colors.purple, 0.2, 0.1),
        OnboardingTag('#Electrical', Colors.blue, 0.9, 0.90),
        OnboardingTag('#Electrician', Colors.red, 0.9, 0.15),
        OnboardingTag('#COPA', Colors.orange, 0.9, 0.6),
        OnboardingTag('#Mechanical', Colors.teal, 0.05, 0.90),
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Navigate to the next page or complete onboarding
  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  /// Navigate to the previous page
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Complete onboarding and navigate to login
  void _completeOnboarding() {
    NavigationService.smartNavigate(destination: const LoginOtpEmailScreen());
  }

  /// Skip onboarding and go directly to login
  void _skipOnboarding() {
    NavigationService.smartNavigate(destination: const LoginOtpEmailScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at the top
            _buildSkipButton(),

            // PageView with onboarding content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingPages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingPages[index]);
                },
              ),
            ),

            // Bottom section with navigation
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  /// Builds the skip button at the top
  Widget _buildSkipButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: _skipOnboarding,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "SKIP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a single onboarding page
  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          // Main illustration with tags
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main image
                Image.asset(data.image, height: 200, fit: BoxFit.contain),
                // Floating tags
                ...data.tags.map(
                  (tag) => Align(
                    alignment: FractionalOffset(tag.x, tag.y),
                    child: _buildTag(tag.text, tag.color),
                  ),
                ),
              ],
            ),
          ),

          // Content section
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C2A38),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  data.subtitle,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a skill tag
  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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

  /// Builds the bottom section with navigation
  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          // Page indicators
          _buildPageIndicators(),
          const SizedBox(height: 30),

          // Navigation buttons
          Row(
            children: [
              // Previous button (only show if not on first page)
              if (_currentPage > 0)
                GestureDetector(
                  onTap: _previousPage,
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),

              const Spacer(),

              // Next/Get Started button
              GestureDetector(
                onTap: _nextPage,
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Always reserve space for the button to prevent layout shift
          SizedBox(
            width: double.infinity,
            height: 50,
            child: _currentPage == _onboardingPages.length - 1
                ? ElevatedButton(
                    onPressed: _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Let's Get Started",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink(), // Invisible placeholder when not on last page
          ),
        ],
      ),
    );
  }

  /// Builds page indicators
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingPages.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.green : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// Data class for onboarding page content
class OnboardingData {
  final String image;
  final String title;
  final String subtitle;
  final List<OnboardingTag> tags;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.tags,
  });
}

/// Data class for floating skill tags
class OnboardingTag {
  final String text;
  final Color color;
  final double x;
  final double y;

  OnboardingTag(this.text, this.color, this.x, this.y);
}
