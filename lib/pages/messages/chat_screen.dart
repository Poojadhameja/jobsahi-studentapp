import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> company;

  const ChatScreen({super.key, required this.company});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
    return Scaffold(
      backgroundColor: AppConstants.cardBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Chat messages area
          Expanded(child: _buildChatArea()),

          // Input area
          _buildInputArea(),
        ],
      ),
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

  Widget _buildChatArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _chatMessages.length,
      itemBuilder: (context, index) {
        final message = _chatMessages[index];

        if (message['type'] == 'date') {
          return _buildDateSeparator(message['text']);
        } else {
          return _buildMessageBubble(message);
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

  Widget _buildMessageBubble(Map<String, dynamic> message) {
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
                _showDeleteDialog(_chatMessages.indexOf(message)),
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
      setState(() {
        _chatMessages.add({
          'text': _messageController.text.trim(),
          'isUser': true,
          'showAvatar': true,
          'timestamp': DateTime.now(),
        });
      });

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

  void _showDeleteDialog(int messageIndex) {
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
                _deleteMessage(messageIndex);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(int messageIndex) {
    if (messageIndex >= 0 && messageIndex < _chatMessages.length) {
      setState(() {
        _chatMessages.removeAt(messageIndex);
      });
    }
  }

  // Sample chat data based on the screenshot
  static final List<Map<String, dynamic>> _chatMessages = [
    {'type': 'date', 'text': '27 Feb 2024'},
    {
      'text': 'Good Morning!',
      'isUser': true,
      'showAvatar': true,
      'timestamp': DateTime.now(),
    },
    {
      'text': 'Good Morning!',
      'isUser': false,
      'showAvatar': true,
      'timestamp': DateTime.now(),
    },
    {
      'text': 'Of course, we have a great selection of laptops.',
      'isUser': false,
      'showAvatar': false,
      'timestamp': DateTime.now(),
    },
    {
      'text': 'I\'m looking for a new laptop',
      'isUser': true,
      'showAvatar': false,
      'timestamp': DateTime.now(),
    },
    {
      'text': 'Got It!',
      'isUser': false,
      'showAvatar': false,
      'timestamp': DateTime.now(),
    },
    {
      'text':
          'I\'ll mainly use it for work, so something with good processing power and a comfortable keyboard is essential.',
      'isUser': true,
      'showAvatar': false,
      'timestamp': DateTime.now(),
    },
    {
      'text':
          'we have several options that would suit your needs. let me show you a few models that match your criteria.',
      'isUser': false,
      'showAvatar': false,
      'timestamp': DateTime.now(),
    },
    {
      'text': 'I\'m looking to spend around \$800 to \$1,000.',
      'isUser': true,
      'showAvatar': false,
      'timestamp': DateTime.now(),
    },
    {'type': 'date', 'text': 'Today'},
  ];
}
