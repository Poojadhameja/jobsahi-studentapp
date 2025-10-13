import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../bloc/messages_bloc.dart';
import '../bloc/messages_event.dart';
import '../bloc/messages_state.dart';

class ChatScreen extends StatelessWidget {
  final Map<String, dynamic> company;

  const ChatScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessagesBloc()
        ..add(LoadChatMessagesEvent(chatId: company['id']?.toString() ?? '')),
      child: _ChatScreenView(company: company),
    );
  }
}

class _ChatScreenView extends StatefulWidget {
  final Map<String, dynamic> company;

  const _ChatScreenView({required this.company});

  @override
  State<_ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<_ChatScreenView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesBloc, MessagesState>(
      builder: (context, state) {
        List<Map<String, dynamic>> chatMessages = [];
        if (state is ChatMessagesLoaded) {
          chatMessages = state.chatMessages;
        }

        return KeyboardDismissWrapper(
          child: Scaffold(
            backgroundColor: AppConstants.cardBackgroundColor,
            appBar: _buildAppBar(),
            body: Column(
              children: [
                // Chat messages area
                Expanded(child: _buildChatArea(chatMessages)),

                // Input area
                _buildInputArea(),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.cardBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppConstants.textPrimaryColor,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          // Company logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.company['logoColor'],
              borderRadius: BorderRadius.circular(
                AppConstants.smallBorderRadius,
              ),
            ),
            child: Icon(
              widget.company['logoIcon'],
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),

          // Company info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.company['companyName'],
                  style: const TextStyle(
                    color: AppConstants.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'is typing...',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Phone call button
        IconButton(
          icon: const Icon(Icons.call, color: AppConstants.textPrimaryColor),
          onPressed: () {
            // TODO: Implement phone call functionality
          },
        ),
        // Video call button
        IconButton(
          icon: const Icon(
            Icons.videocam,
            color: AppConstants.textPrimaryColor,
          ),
          onPressed: () {
            // TODO: Implement video call functionality
          },
        ),
      ],
    );
  }

  Widget _buildChatArea(List<Map<String, dynamic>> chatMessages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: chatMessages.length,
      itemBuilder: (context, index) {
        final message = chatMessages[index];

        if (message['type'] == 'date') {
          return _buildDateSeparator(message['text']);
        } else {
          return _buildMessageBubble(message, chatMessages);
        }
      },
    );
  }

  Widget _buildDateSeparator(String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppConstants.textSecondaryColor.withValues(alpha: 0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.smallPadding,
            ),
            child: Text(
              date,
              style: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppConstants.textSecondaryColor.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
    List<Map<String, dynamic>> chatMessages,
  ) {
    final isUser = message['isUser'];
    // final showAvatar = message['showAvatar'];

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isUser) const Spacer(),

          // if (!isUser && showAvatar) ...[
          //   Container(
          //     width: 32,
          //     height: 32,
          //     decoration: BoxDecoration(
          //       color: widget.company['logoColor'],
          //       borderRadius: BorderRadius.circular(16),
          //     ),
          //     child: Icon(
          //       widget.company['logoIcon'],
          //       color: Colors.white,
          //       size: 16,
          //     ),
          //   ),
          //   const SizedBox(width: AppConstants.smallPadding),
          // ] else if (!isUser && !showAvatar) ...[
          //   const SizedBox(width: 40),
          // ],

          // Message bubble
          GestureDetector(
            onLongPress: () =>
                _showDeleteDialog(context, chatMessages.indexOf(message)),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                minWidth: MediaQuery.of(context).size.width * 0.2,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.defaultPadding,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color.fromARGB(225, 91, 154, 36)
                    : const Color.fromARGB(23, 11, 83, 125),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Text(
                message['text'],
                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // if (isUser && showAvatar) ...[
          //   const SizedBox(width: AppConstants.smallPadding),
          //   Container(
          //     width: 32,
          //     height: 32,
          //     decoration: BoxDecoration(
          //       color: widget.company['logoColor'],
          //       borderRadius: BorderRadius.circular(16),
          //     ),
          //     child: Icon(
          //       widget.company['logoIcon'],
          //       color: Colors.white,
          //       size: 16,
          //     ),
          //   ),
          // ] else if (isUser && !showAvatar) ...[
          //   const SizedBox(width: 40),
          // ],
          if (!isUser) const Spacer(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        border: Border(
          top: BorderSide(color: AppConstants.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            icon: const Icon(
              Icons.attach_file,
              color: AppConstants.primaryColor,
              size: 22,
            ),
            onPressed: () {
              // TODO: Implement file attachment
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),

          // Emoji button
          IconButton(
            icon: const Icon(
              Icons.emoji_emotions_outlined,
              color: AppConstants.primaryColor,
              size: 22,
            ),
            onPressed: () {
              // TODO: Implement emoji picker
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),

          // Text input field
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.smallPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: AppConstants.borderColor.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: TextField(
                controller: _messageController,
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  hintText: 'Type something...',
                  hintStyle: TextStyle(color: AppConstants.textSecondaryColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: AppConstants.smallPadding,
                  ),
                ),
                maxLines: null,
                minLines: 1,
              ),
            ),
          ),

          // Send button
          IconButton(
            icon: const Icon(
              Icons.send,
              color: AppConstants.primaryColor,
              size: 22,
            ),
            onPressed: _sendMessage,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<MessagesBloc>().add(
        SendMessageEvent(
          recipientId: widget.company['id']?.toString() ?? '',
          message: _messageController.text.trim(),
        ),
      );

      _messageController.clear();

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showDeleteDialog(BuildContext context, int messageIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMessage(context, messageIndex);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(BuildContext context, int messageIndex) {
    context.read<MessagesBloc>().add(
      DeleteMessageEvent(messageId: messageIndex.toString()),
    );
  }
}
