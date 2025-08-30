import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../widgets/global/profile_navigation_app_bar.dart';
import 'chat_screen.dart';

class InboxScreen extends StatefulWidget {
  /// Whether this screen is opened from profile navigation
  final bool isFromProfile;

  const InboxScreen({super.key, this.isFromProfile = false});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: widget.isFromProfile
          ? ProfileNavigationAppBar(title: 'Messages')
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              // const Text(
              //   'Your Messages',
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //     color: AppConstants.textPrimaryColor,
              //   ),
              // ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Messages list
              Expanded(
                child: ListView.separated(
                  itemCount: _messages.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Color(0xFFE0E0E0),
                  ),
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageItem(context, message);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, Map<String, dynamic> message) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(company: message)),
        );
      },
      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.smallPadding,
        ),
        child: Row(
          children: [
            // Company logo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: message['logoColor'],
                borderRadius: BorderRadius.circular(
                  AppConstants.smallBorderRadius,
                ),
              ),
              child: Icon(message['logoIcon'], color: Colors.white, size: 24),
            ),

            const SizedBox(width: AppConstants.defaultPadding),

            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['companyName'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Timestamp
            Text(
              message['timestamp'],
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  // Sample message data based on the screenshot
  final List<Map<String, dynamic>> _messages = [
    {
      'companyName': 'PowerZone Pvt. Ltd',
      'description': 'Hello',
      'timestamp': 'Fri',
      'logoColor': const Color(0xFF10B981), // Green
      'logoIcon': Icons.diamond,
    },
    {
      'companyName': 'Bakeron Pvt. Ltd.',
      'description': 'Web Designer',
      'timestamp': '2 Hours',
      'logoColor': const Color(0xFFF59E0B), // Orange
      'logoIcon': Icons.grid_view,
    },
    {
      'companyName': 'JobZilla Info Solution',
      'description': 'React Developer',
      'timestamp': '2 Min',
      'logoColor': const Color(0xFF3B82F6), // Blue
      'logoIcon': Icons.bar_chart,
    },
    {
      'companyName': 'JobBoard Network',
      'description': 'User Experience Design Lead',
      'timestamp': 'Mon',
      'logoColor': const Color(0xFF14B8A6), // Teal
      'logoIcon': Icons.hexagon,
    },
    {
      'companyName': 'PowerZone Pvt. Ltd',
      'description': 'Hello',
      'timestamp': 'Fri',
      'logoColor': const Color(0xFF10B981), // Green
      'logoIcon': Icons.diamond,
    },
    {
      'companyName': 'Bakeron Pvt. Ltd.',
      'description': 'Web Designer',
      'timestamp': '2 Hours',
      'logoColor': const Color(0xFFF59E0B), // Orange
      'logoIcon': Icons.grid_view,
    },
  ];
}
