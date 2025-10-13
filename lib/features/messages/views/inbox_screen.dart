import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/profile_navigation_app_bar.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../bloc/messages_bloc.dart';
import '../bloc/messages_event.dart';
import '../bloc/messages_state.dart';
import 'chat_screen.dart';

class InboxScreen extends StatelessWidget {
  /// Whether this screen is opened from profile navigation
  final bool isFromProfile;

  const InboxScreen({super.key, this.isFromProfile = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessagesBloc()..add(const LoadMessagesEvent()),
      child: _InboxScreenView(isFromProfile: isFromProfile),
    );
  }
}

class _InboxScreenView extends StatelessWidget {
  final bool isFromProfile;

  const _InboxScreenView({required this.isFromProfile});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesBloc, MessagesState>(
      builder: (context, state) {
        List<Map<String, dynamic>> messages = [];
        if (state is MessagesLoaded) {
          messages = state.messages;
        }

        return KeyboardDismissWrapper(
          child: Scaffold(
            backgroundColor: AppConstants.cardBackgroundColor,
            appBar: isFromProfile
                ? ProfileNavigationAppBar(title: 'Messages')
                : null,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppConstants.defaultPadding),
                    // Messages list
                    Expanded(
                      child: ListView.separated(
                        itemCount: messages.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Color(0xFFE0E0E0),
                        ),
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return _buildMessageItem(context, message);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
                color: AppConstants.primaryColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(
                  AppConstants.smallBorderRadius,
                ),
              ),
              child: const Icon(Icons.business, color: Colors.white, size: 24),
            ),

            const SizedBox(width: AppConstants.defaultPadding),

            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (message['sender'] ?? 'Message').toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (message['message'] ?? message['subject'] ?? '').toString(),
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
              (message['timestamp'] ?? '').toString().substring(0, 10),
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}
