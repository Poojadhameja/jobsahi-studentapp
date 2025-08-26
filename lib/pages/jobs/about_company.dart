/// About Company Screen

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import 'write_review.dart';

class AboutCompanyScreen extends StatefulWidget {
  final Map<String, dynamic> company;

  const AboutCompanyScreen({super.key, required this.company});

  @override
  State<AboutCompanyScreen> createState() => _AboutCompanyScreenState();
}

class _AboutCompanyScreenState extends State<AboutCompanyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: SimpleAppBar(
        title: widget.company['name'] ?? 'Company',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement visit website functionality
            },
            icon: const Icon(Icons.public),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Center(
              child: Text(
                'Visit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Company header section with teal background
          _buildCompanyHeader(),

          // Tab bar
          _buildTabBar(),

          // Tab content
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  /// Builds the company header section with teal background
  Widget _buildCompanyHeader() {
    return Container(
      width: double.infinity,
      color: const Color.fromARGB(255, 0, 40, 63), // Teal color
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Company logo
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.business,
              size: 40,
              color: Color.fromARGB(255, 0, 70, 88),
            ),
          ),
          const SizedBox(height: 12),

          // Company name
          Text(
            widget.company['name'] ?? 'Company Name',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),

          // Company tagline
          Text(
            widget.company['tagline'] ?? 'Company Tagline',
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the tab bar
  Widget _buildTabBar() {
    return Container(
      color: AppConstants.backgroundColor,
      child: TabBar(
        controller: _tabController,
        labelColor: AppConstants.textPrimaryColor,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        indicatorColor: AppConstants.primaryColor,
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Gallery'),
          Tab(text: 'Open Jobs'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  /// Builds the tab content
  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAboutTab(),
        _buildGalleryTab(),
        _buildOpenJobsTab(),
        _buildReviewsTab(),
      ],
    );
  }

  /// Builds the About tab
  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About Company section
          const Text(
            'About Company',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            widget.company['about'] ??
                'जब किसी कंपनी का विवरण लिखा जाता है, तब उसमें कंपनी का मिशन, विज़न, और संस्कृति की जानकारी दी जाती है। यह कंपनी के मूल्यों, इतिहास और भविष्य की योजनाओं को भी शामिल करता है।',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          const Divider(),
          const SizedBox(height: AppConstants.defaultPadding),

          // Company details
          _buildCompanyInfoRow(
            Icons.public,
            'Website',
            widget.company['website'] ?? 'www.google.com',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildCompanyInfoRow(
            Icons.location_on_outlined,
            'Headquarters',
            widget.company['headquarters'] ?? 'Noida, India',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildCompanyInfoRow(
            Icons.event_outlined,
            'Founded',
            widget.company['founded'] ?? '14 July 2005',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildCompanyInfoRow(
            Icons.group_outlined,
            'Size',
            widget.company['size']?.toString() ?? '2500',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildCompanyInfoRow(
            Icons.attach_money,
            'Revenue',
            widget.company['revenue'] ?? '10,000 Millions',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildCompanyInfoRow(
            Icons.business,
            'Industry',
            widget.company['industry'] ?? 'Technology',
          ),

          const SizedBox(height: AppConstants.defaultPadding),
          const Divider(),
          const SizedBox(height: AppConstants.defaultPadding),

          // // Company Specialties
          // const Text(
          //   'Company Specialties',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //     color: AppConstants.textPrimaryColor,
          //   ),
          // ),
          // const SizedBox(height: AppConstants.smallPadding),
          // _buildSpecialtiesList(),

          // const SizedBox(height: AppConstants.defaultPadding),
          // const Divider(),
          // const SizedBox(height: AppConstants.defaultPadding),

          // Certifications
          // const Text(
          //   'Certifications',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //     color: AppConstants.textPrimaryColor,
          //   ),
          // ),
          // const SizedBox(height: AppConstants.smallPadding),
          // _buildCertificationsList(),

          // const SizedBox(height: AppConstants.defaultPadding),
          // const Divider(),
          // const SizedBox(height: AppConstants.defaultPadding),

          // // Awards
          // const Text(
          //   'Awards & Recognition',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //     color: AppConstants.textPrimaryColor,
          //   ),
          // ),
          // const SizedBox(height: AppConstants.smallPadding),
          // _buildAwardsList(),

          // const SizedBox(height: AppConstants.defaultPadding),
          // const Divider(),
          // const SizedBox(height: AppConstants.defaultPadding),

          // Life of Company section
          const Text(
            'Life Of Company',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildCompanyLifeGrid(),
        ],
      ),
    );
  }

  /// Builds the Gallery tab
  Widget _buildGalleryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Company Gallery',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          const Text(
            'Take a look at our workplace, team events, and company culture',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Office and workplace images
          _buildGallerySection('Office & Workplace', [
            'assets/images/company/office1.jpg',
            'assets/images/company/office2.jpg',
            'assets/images/company/office3.jpg',
            'assets/images/company/office4.jpg',
            'assets/images/company/office5.jpg',
            'assets/images/company/office6.jpg',
          ]),

          const SizedBox(height: AppConstants.defaultPadding),

          // Team and events images
          _buildGallerySection('Team & Events', [
            'assets/images/company/team1.jpg',
            'assets/images/company/team2.jpg',
            'assets/images/company/event1.jpg',
            'assets/images/company/event2.jpg',
            'assets/images/company/event3.jpg',
            'assets/images/company/event4.jpg',
          ]),

          const SizedBox(height: AppConstants.defaultPadding),

          // Projects and achievements images
          _buildGallerySection('Projects & Achievements', [
            'assets/images/company/project1.jpg',
            'assets/images/company/project2.jpg',
            'assets/images/company/award1.jpg',
            'assets/images/company/award2.jpg',
            'assets/images/company/project3.jpg',
            'assets/images/company/project4.jpg',
          ]),
        ],
      ),
    );
  }

  /// Builds the Open Jobs tab
  Widget _buildOpenJobsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Open Positions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          const Text(
            'Join our team and be part of something amazing',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Open job listings
          _buildOpenJobCard(
            'Senior Software Engineer',
            'Full-time • Remote',
            '₹8L - ₹15L P.A.',
            '3-5 years experience in Flutter/Dart',
            Icons.code,
          ),

          const SizedBox(height: AppConstants.smallPadding),

          _buildOpenJobCard(
            'Product Manager',
            'Full-time • On-site',
            '₹12L - ₹20L P.A.',
            '5+ years experience in product management',
            Icons.manage_accounts,
          ),

          const SizedBox(height: AppConstants.smallPadding),

          _buildOpenJobCard(
            'UI/UX Designer',
            'Full-time • Hybrid',
            '₹6L - ₹12L P.A.',
            '2-4 years experience in design',
            Icons.design_services,
          ),

          const SizedBox(height: AppConstants.smallPadding),

          _buildOpenJobCard(
            'Data Analyst',
            'Full-time • On-site',
            '₹5L - ₹10L P.A.',
            '1-3 years experience in data analysis',
            Icons.analytics,
          ),

          const SizedBox(height: AppConstants.smallPadding),

          _buildOpenJobCard(
            'DevOps Engineer',
            'Full-time • Remote',
            '₹10L - ₹18L P.A.',
            '4-6 years experience in DevOps',
            Icons.cloud,
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to all open jobs
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.smallBorderRadius,
                  ),
                ),
              ),
              child: const Text(
                'View All Open Positions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Bottom margin for the button
          const SizedBox(height: AppConstants.defaultPadding * 3),
        ],
      ),
    );
  }

  /// Builds the Reviews tab
  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall rating summary
          _buildOverallRatingCard(),

          const SizedBox(height: AppConstants.defaultPadding),

          const Text(
            'Employee Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),

          // Individual reviews
          _buildReviewCard(
            'Sarah Johnson',
            'Senior Software Engineer',
            '5.0',
            '2 months ago',
            'Amazing company culture and work-life balance. The team is very supportive and the projects are challenging yet rewarding. Great opportunities for growth and learning.',
            Icons.verified,
          ),

          const SizedBox(height: AppConstants.smallPadding),

          _buildReviewCard(
            'Rajesh Kumar',
            'Product Manager',
            '4.8',
            '1 month ago',
            'Excellent work environment with supportive management. The company values innovation and provides great resources for professional development.',
            Icons.verified,
          ),

          const SizedBox(height: AppConstants.smallPadding),

          _buildReviewCard(
            'Emily Chen',
            'UI/UX Designer',
            '4.6',
            '3 weeks ago',
            'Great team collaboration and creative freedom. The company invests in employee development and provides good benefits.',
            Icons.verified,
          ),

          const SizedBox(height: AppConstants.smallPadding),

          _buildReviewCard(
            'Amit Patel',
            'Data Analyst',
            '4.4',
            '2 weeks ago',
            'Good learning opportunities and supportive colleagues. The work is interesting and there\'s room for growth.',
            Icons.verified,
          ),

          const SizedBox(height: AppConstants.smallPadding),

          _buildReviewCard(
            'Lisa Wang',
            'DevOps Engineer',
            '4.2',
            '1 week ago',
            'Challenging projects and good technical environment. The team is knowledgeable and collaborative.',
            Icons.verified,
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Write review button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to write review page
                try {
                  NavigationService.navigateTo(
                    WriteReviewScreen(
                      job: {
                        'title': 'Company Review',
                        'company': widget.company['name'],
                        'location': widget.company['headquarters'],
                      },
                    ),
                  );
                } catch (e) {
                  // Fallback navigation
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WriteReviewScreen(
                        job: {
                          'title': 'Company Review',
                          'company': widget.company['name'],
                          'location': widget.company['headquarters'],
                        },
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.secondaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.smallBorderRadius,
                  ),
                ),
              ),
              child: const Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Bottom margin for the button
          const SizedBox(height: AppConstants.defaultPadding * 3),
        ],
      ),
    );
  }

  /// Reusable row for a company info item
  Widget _buildCompanyInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppConstants.textSecondaryColor),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: AppConstants.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  /// Builds the company life grid
  Widget _buildCompanyLifeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 5, // 20+ items
      itemBuilder: (context, index) {
        if (index == 4) {
          // Last item showing "20+"
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                '5+',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ),
          );
        }

        // Regular grid items
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.image,
              color: AppConstants.textSecondaryColor,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  /// Builds a gallery section with images
  Widget _buildGallerySection(String title, List<String> imagePaths) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: imagePaths.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Stack(
                children: [
                  // Placeholder for image
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ),
                  // Image label overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        imagePaths[index]
                            .split('/')
                            .last
                            .replaceAll('.jpg', ''),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Builds an open job card
  Widget _buildOpenJobCard(
    String title,
    String type,
    String salary,
    String requirements,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 24),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  salary,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.successColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  requirements,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Navigate to job details
            },
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: AppConstants.textSecondaryColor,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the overall rating card
  Widget _buildOverallRatingCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '4.6',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '/5',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Based on 127 reviews',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < 4 ? Icons.star : Icons.star_half,
                      color: AppConstants.warningColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 0.6, '5 stars'),
                _buildRatingBar(4, 0.25, '4 stars'),
                _buildRatingBar(3, 0.1, '3 stars'),
                _buildRatingBar(2, 0.03, '2 stars'),
                _buildRatingBar(1, 0.02, '1 star'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a rating bar
  Widget _buildRatingBar(int stars, double percentage, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                color: AppConstants.warningColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 25,
            child: Text(
              '${(percentage * 100).round()}%',
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a review card
  Widget _buildReviewCard(
    String name,
    String role,
    String rating,
    String time,
    String review,
    IconData verifiedIcon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppConstants.primaryColor.withValues(
                  alpha: 0.1,
                ),
                radius: 20,
                child: Text(
                  name[0],
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          verifiedIcon,
                          color: AppConstants.successColor,
                          size: 16,
                        ),
                      ],
                    ),
                    Text(
                      role,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppConstants.warningColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            review,
            style: const TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
