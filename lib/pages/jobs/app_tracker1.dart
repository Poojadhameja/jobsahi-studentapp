import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import 'calendar_view.dart';

class AppTracker1Screen extends StatefulWidget {
  const AppTracker1Screen({super.key});

  @override
  State<AppTracker1Screen> createState() => _AppTracker1ScreenState();
}

class _AppTracker1ScreenState extends State<AppTracker1Screen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
      body: Column(
        children: [
            _buildTabBar(),
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

  /// Builds the applied job card
  Widget _buildAppliedCard() {
    return Column(
      children: [
        // Calendar View button at the top
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _openCalendarView,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF0B537D), // Light blue border
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Calendar View',
                    style: TextStyle(
                      color: Color(0xFF0B537D), // Dark blue text
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Job application card
        Container(
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
                    child: const Text(
                      'Full Stack Developer',
                      style: TextStyle(
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
              const Text(
                'Bharat Electrician Pvt. Ltd.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF0B537D),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Job details
              _buildJobDetail(Icons.location_on, 'Lunknow, Uttar Pradesh'),
              const SizedBox(height: 6),
              _buildJobDetail(Icons.work, '2 years'),
              const SizedBox(height: 12),

              // Application date
              const Text(
                'Applied on 10 july 2025',
                style: TextStyle(fontSize: 13, color: Color(0xFF0B537D)),
              ),
              const SizedBox(height: 6),

              // Number of positions
              const Text(
                '5 position',
                style: TextStyle(fontSize: 13, color: Color(0xFF0B537D)),
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

  /// Builds the interview cards
  Widget _buildInterviewCards() {
    return Column(
      children: [
        // Calendar View button at the top
        // Container(
        //   width: double.infinity,
        //   margin: const EdgeInsets.only(bottom: 16),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       GestureDetector(
        //         onTap: _openCalendarView,
        //         child: Container(
        //           padding: const EdgeInsets.symmetric(
        //             vertical: 8,
        //             horizontal: 14,
        //           ),
        //           decoration: BoxDecoration(
        //             color: Colors.white,
        //             borderRadius: BorderRadius.circular(16),
        //             border: Border.all(
        //               color: const Color(0xFF3B82F6), // Light blue border
        //               width: 1,
        //             ),
        //           ),
        //           child: const Text(
        //             'Calendar View',
        //             style: TextStyle(
        //               color: Color(0xFF0B537D),
        //               fontSize: 13,
        //               fontWeight: FontWeight.w500,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

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
