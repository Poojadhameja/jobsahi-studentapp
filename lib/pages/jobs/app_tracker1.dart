import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/global/simple_app_bar.dart';
import 'calendar_view.dart';

class AppTracker1Screen extends StatefulWidget {
  const AppTracker1Screen({super.key});

  @override
  State<AppTracker1Screen> createState() => _AppTracker1ScreenState();
}

class _AppTracker1ScreenState extends State<AppTracker1Screen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['Applied', 'Interview Scheduled', 'Offers'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grey background
      appBar: const SimpleAppBar(
        title: 'Application Tracker / आवेदन ट्रैकर',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildContentBasedOnTab(),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the filter tabs
  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = index == _selectedTabIndex;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(
                                0xFF475569,
                              ) // Blue-grey color for selected tab
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(
                                  0xFF475569,
                                ) // Blue-grey color for selected tab
                              : const Color(
                                  0xFFE2E8F0,
                                ), // Light grey border for unselected tabs
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tab,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors
                                    .white // White text for selected tab
                              : const Color(
                                  0xFF64748B,
                                ), // Dark grey text for unselected tabs
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          // Bottom border line
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 1,
            color: const Color(0xFFE3F2FD), // Light blue horizontal line
          ),
        ],
      ),
    );
  }

  /// Builds content based on selected tab
  Widget _buildContentBasedOnTab() {
    switch (_selectedTabIndex) {
      case 0: // Applied
        return _buildAppliedCard();
      case 1: // Interview Scheduled
        return _buildInterviewCards();
      case 2: // Offers
        return _buildOffersCard();
      default:
        return _buildAppliedCard();
    }
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
                    vertical: 8,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF3B82F6), // Light blue border
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Calendar View',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A), // Dark blue text
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
                        color: Color(0xFF1E3A8A), // Dark blue color
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Applied',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
                  color: Color(0xFF64748B),
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
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 6),

              // Number of positions
              const Text(
                '5 position',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),

              // View Application button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _viewApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.successColor,
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
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  /// Builds the interview cards
  Widget _buildInterviewCards() {
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
                    vertical: 8,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF3B82F6), // Light blue border
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Calendar View',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

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
                              color: Color(0xFF1E3A8A), // Dark blue color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Company Name
                          const Text(
                            'Ashok Leyland',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF10B981), // Light green color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Location
                          const Text(
                            'Location Bhopal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B), // Dark grey color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Interview Date
                          const Text(
                            'Interview: 25 July 2025',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B), // Dark grey color
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
                        color: Color(0xFF1E3A8A), // Dark blue color
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
                              color: Color(0xFF1E3A8A), // Dark blue color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Company Name
                          const Text(
                            'Ashok Leyland',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF10B981), // Light green color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Job Type
                          const Text(
                            'Full Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B), // Dark grey color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Skills
                          const Text(
                            'Skills: Drilling, Measuring',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B), // Dark grey color
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
                            color: AppConstants.successColor,
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
                            color: Color(0xFF64748B), // Dark grey color
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
                              color: Color(0xFF1E3A8A), // Dark blue color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Company Name
                          const Text(
                            'Ashok Leyland',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF10B981), // Light green color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Job Type
                          const Text(
                            'Full Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B), // Dark grey color
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Skills
                          const Text(
                            'Skills: Drilling, Measuring',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B), // Dark grey color
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
                        color: const Color(0xFF1E3A8A), // Dark blue
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
