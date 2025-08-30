import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/profile_navigation_app_bar.dart';
import 'calendar_view.dart';

class ApplicationTrackerScreen extends StatefulWidget {
  /// Whether this screen is opened from profile navigation
  final bool isFromProfile;

  const ApplicationTrackerScreen({super.key, this.isFromProfile = false});

  @override
  State<ApplicationTrackerScreen> createState() =>
      _ApplicationTrackerScreenState();
}

class _ApplicationTrackerScreenState extends State<ApplicationTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: widget.isFromProfile
            ? ProfileNavigationAppBar(title: 'Application Tracker')
            : null,
        body: Column(
          children: [
            if (!widget.isFromProfile) _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAppliedTab(),
                  _buildInterviewTab(),
                  _buildOffersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the tab bar similar to learning center
  Widget _buildTabBar() {
    return Container(
      color: AppConstants.cardBackgroundColor,
      child: TabBar(
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        indicatorColor: AppConstants.primaryColor,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Applied'),
          Tab(text: 'Interview Scheduled'),
          Tab(text: 'Offers'),
        ],
      ),
    );
  }

  /// Builds the applied tab content
  Widget _buildAppliedTab() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: _buildAppliedCard(),
    );
  }

  /// Builds the interview tab content
  Widget _buildInterviewTab() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: _buildInterviewCards(),
    );
  }

  /// Builds the offers tab content
  Widget _buildOffersTab() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: _buildOffersCard(),
    );
  }

  /// Builds the applied job cards
  Widget _buildAppliedCard() {
    return ListView(
      children: [
        // ITI Electrician Apprentice - Card 1
        _buildAppliedJobCard(
          jobTitle: 'इलेक्ट्रीशियन अप्रेंटिस',
          companyName: 'Bharat Heavy Electricals Ltd.',
          location: 'Bhopal, Madhya Pradesh',
          experience: 'Fresher',
          appliedDate: '15 July 2025',
          positions: '8 positions',
        ),
        const SizedBox(height: 16),

        // ITI Fitter - Card 2
        _buildAppliedJobCard(
          jobTitle: 'ITI Fitter',
          companyName: 'Maruti Suzuki India Ltd.',
          location: 'Gurgaon, Haryana',
          experience: '1-2 years',
          appliedDate: '12 July 2025',
          positions: '12 positions',
        ),
        const SizedBox(height: 16),

        // ITI Welder - Card 3
        _buildAppliedJobCard(
          jobTitle: 'ITI Welder',
          companyName: 'Tata Motors Ltd.',
          location: 'Pune, Maharashtra',
          experience: 'Fresher',
          appliedDate: '10 July 2025',
          positions: '6 positions',
        ),
        const SizedBox(height: 16),

        // ITI Machinist - Card 4
        _buildAppliedJobCard(
          jobTitle: 'ITI Machinist',
          companyName: 'Mahindra & Mahindra Ltd.',
          location: 'Mumbai, Maharashtra',
          experience: '1-3 years',
          appliedDate: '8 July 2025',
          positions: '10 positions',
        ),
        const SizedBox(height: 16),

        // ITI Turner - Card 5
        _buildAppliedJobCard(
          jobTitle: 'ITI Turner',
          companyName: 'Hero MotoCorp Ltd.',
          location: 'Gurgaon, Haryana',
          experience: 'Fresher',
          appliedDate: '5 July 2025',
          positions: '15 positions',
        ),
      ],
    );
  }

  /// Builds a job detail row with icon and text
  Widget _buildJobDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0B537D)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0B537D)),
        ),
      ],
    );
  }

  /// Builds an individual applied job card
  Widget _buildAppliedJobCard({
    required String jobTitle,
    required String companyName,
    required String location,
    required String experience,
    required String appliedDate,
    required String positions,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job title and status
          Row(
            children: [
              Expanded(
                child: Text(
                  jobTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B537D), // Dark blue color
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B537D),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'Applied',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Company name
          Text(
            companyName,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF0B537D),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Job details
          _buildJobDetail(Icons.location_on, location),
          const SizedBox(height: 6),
          _buildJobDetail(Icons.work, experience),
          const SizedBox(height: 12),

          // Application date
          Text(
            'Applied on $appliedDate',
            style: const TextStyle(fontSize: 13, color: Color(0xFF0B537D)),
          ),
          const SizedBox(height: 6),

          // Number of positions
          Text(
            positions,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0B537D)),
          ),
          const SizedBox(height: 16),

          // View Application button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _viewApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C9A24),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'View Application',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the interview cards
  Widget _buildInterviewCards() {
    return Column(
      children: [
        // Interview cards list
        Expanded(
          child: ListView.builder(
            itemCount: 3, // Show 3 identical cards as in the image
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Company Logo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Job Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job Title
                          const Text(
                            'इलेक्ट्रीशियन अप्रेंटिस',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B537D), // Dark blue color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Company Name
                          const Text(
                            'Ashok Leyland',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF5C9A24), // Light green color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Location
                          const Text(
                            'Location Bhopal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0B537D), // Dark grey color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Interview Date
                          const Text(
                            'Interview: 25 July 2025',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0B537D), // Dark grey color
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Interview Type
                    const Text(
                      'Interview:\nWalk-In',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF0B537D), // Dark blue color
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the offers card
  Widget _buildOffersCard() {
    return Column(
      children: [
        // Job offer cards
        Expanded(
          child: ListView(
            children: [
              // First job offer card
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Company Logo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 59, 153),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'W',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Job Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job Title
                          const Text(
                            'इलेक्ट्रीशियन अप्रेंटिस',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B537D), // Dark blue color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Company Name
                          const Text(
                            'Ashok Leyland',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF5C9A24), // Light green color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Job Type
                          const Text(
                            'Full Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0B537D), // Dark grey color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Skills
                          const Text(
                            'Skills: Drilling, Measuring',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0B537D), // Dark grey color
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right side content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Offer Accepted badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C9A24),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Offer Accepted',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Salary
                        const Text(
                          '₹18,000',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0B537D), // Dark grey color
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Second job offer card
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Company Logo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'W',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Job Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job Title
                          const Text(
                            'इलेक्ट्रीशियन अप्रेंटिस',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B537D), // Dark blue color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Company Name
                          const Text(
                            'Ashok Leyland',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF5C9A24), // Light green color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Job Type
                          const Text(
                            'Full Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0B537D), // Dark grey color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Skills
                          const Text(
                            'Skills: Drilling, Measuring',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0B537D), // Dark grey color
                            ),
                          ),
                        ],
                      ),
                    ),

                    // View Offer button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B537D), // Dark blue
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'View Offer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom Apply For More Job button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16),
          child: ElevatedButton(
            onPressed: _applyForMoreJobs,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Apply For More Job',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// Handles view application button press
  void _viewApplication() {
    // TODO: Implement view application functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'View application functionality will be implemented here',
        ),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }

  /// Handles apply for more jobs button press
  void _applyForMoreJobs() {
    // TODO: Implement apply for more jobs functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Apply for more jobs functionality will be implemented here',
        ),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }

  /// Opens the calendar view
  void _openCalendarView() {
    NavigationService.smartNavigate(destination: const CalendarViewScreen());
  }
}
