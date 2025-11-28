import 'package:bloc/bloc.dart';
import 'messages_event.dart';
import 'messages_state.dart';
import '../../../shared/data/user_data.dart';

/// Messages BLoC
/// Handles all message-related business logic
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc() : super(const MessagesInitial()) {
    // Register event handlers
    on<LoadMessagesEvent>(_onLoadMessages);
    on<MarkMessageAsReadEvent>(_onMarkMessageAsRead);
    on<MarkAllMessagesAsReadEvent>(_onMarkAllMessagesAsRead);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<SendMessageEvent>(_onSendMessage);
    on<LoadChatMessagesEvent>(_onLoadChatMessages);
    on<RefreshMessagesEvent>(_onRefreshMessages);
    on<SearchMessagesEvent>(_onSearchMessages);
    on<ClearSearchEvent>(_onClearSearch);
  }

  /// Handle load messages
  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      emit(const MessagesLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Load messages from mock data
      final messages = UserData.messages;
      final unreadCount = messages
          .where((msg) => msg['isRead'] == false)
          .length;

      emit(
        MessagesLoaded(
          messages: messages,
          filteredMessages: messages,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(MessagesError(message: 'Failed to load messages: ${e.toString()}'));
    }
  }

  /// Handle mark message as read
  Future<void> _onMarkMessageAsRead(
    MarkMessageAsReadEvent event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      if (state is MessagesLoaded) {
        final currentState = state as MessagesLoaded;

        // Find and update the message
        final updatedMessages = currentState.messages.map((message) {
          if (message['id'] == event.messageId) {
            return {...message, 'isRead': true};
          }
          return message;
        }).toList();

        final updatedFilteredMessages = currentState.filteredMessages.map((
          message,
        ) {
          if (message['id'] == event.messageId) {
            return {...message, 'isRead': true};
          }
          return message;
        }).toList();

        final unreadCount = updatedMessages
            .where((msg) => msg['isRead'] == false)
            .length;

        emit(
          currentState.copyWith(
            messages: updatedMessages,
            filteredMessages: updatedFilteredMessages,
            unreadCount: unreadCount,
          ),
        );

        // Emit success state
        emit(MessageMarkedAsReadState(messageId: event.messageId));
      }
    } catch (e) {
      emit(
        MessagesError(
          message: 'Failed to mark message as read: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle mark all messages as read
  Future<void> _onMarkAllMessagesAsRead(
    MarkAllMessagesAsReadEvent event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      if (state is MessagesLoaded) {
        final currentState = state as MessagesLoaded;

        // Mark all messages as read
        final updatedMessages = currentState.messages.map((message) {
          return {...message, 'isRead': true};
        }).toList();

        final updatedFilteredMessages = currentState.filteredMessages.map((
          message,
        ) {
          return {...message, 'isRead': true};
        }).toList();

        emit(
          currentState.copyWith(
            messages: updatedMessages,
            filteredMessages: updatedFilteredMessages,
            unreadCount: 0,
          ),
        );
      }
    } catch (e) {
      emit(
        MessagesError(
          message: 'Failed to mark all messages as read: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle delete message
  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      if (state is MessagesLoaded) {
        final currentState = state as MessagesLoaded;

        // Remove the message
        final updatedMessages = currentState.messages
            .where((message) => message['id'] != event.messageId)
            .toList();

        final updatedFilteredMessages = currentState.filteredMessages
            .where((message) => message['id'] != event.messageId)
            .toList();

        final unreadCount = updatedMessages
            .where((msg) => msg['isRead'] == false)
            .length;

        emit(
          currentState.copyWith(
            messages: updatedMessages,
            filteredMessages: updatedFilteredMessages,
            unreadCount: unreadCount,
          ),
        );

        // Emit success state
        emit(MessageDeletedState(messageId: event.messageId));
      }
    } catch (e) {
      emit(MessagesError(message: 'Failed to delete message: ${e.toString()}'));
    }
  }

  /// Handle send message
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      emit(const MessagesLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Create new message
      final newMessage = {
        'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
        'sender': 'You',
        'recipient': event.recipientId,
        'subject': event.subject ?? 'New Message',
        'message': event.message,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': true,
        'isSent': true,
      };

      // In a real app, this would be sent to the server
      // For now, we'll just emit success

      // Emit success state
      emit(MessageSentSuccessState(messageId: newMessage['id'] as String));
    } catch (e) {
      emit(MessagesError(message: 'Failed to send message: ${e.toString()}'));
    }
  }

  /// Handle load chat messages
  Future<void> _onLoadChatMessages(
    LoadChatMessagesEvent event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      emit(const MessagesLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Load chat messages from API
      // TODO: Replace with actual API call
      final chatMessages = <Map<String, dynamic>>[];

      emit(
        ChatMessagesLoaded(
          chatId: event.chatId,
          chatMessages: chatMessages,
          recipientName: '',
        ),
      );
    } catch (e) {
      emit(
        MessagesError(message: 'Failed to load chat messages: ${e.toString()}'),
      );
    }
  }

  /// Handle refresh messages
  Future<void> _onRefreshMessages(
    RefreshMessagesEvent event,
    Emitter<MessagesState> emit,
  ) async {
    // Reload messages
    add(const LoadMessagesEvent());
  }

  /// Handle search messages
  void _onSearchMessages(
    SearchMessagesEvent event,
    Emitter<MessagesState> emit,
  ) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      final filteredMessages = _filterMessages(
        currentState.messages,
        event.query,
      );

      emit(
        currentState.copyWith(
          searchQuery: event.query,
          filteredMessages: filteredMessages,
        ),
      );
    }
  }

  /// Handle clear search
  void _onClearSearch(ClearSearchEvent event, Emitter<MessagesState> emit) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      final filteredMessages = _filterMessages(currentState.messages, '');

      emit(
        currentState.copyWith(
          searchQuery: '',
          filteredMessages: filteredMessages,
        ),
      );
    }
  }

  /// Filter messages based on search query
  List<Map<String, dynamic>> _filterMessages(
    List<Map<String, dynamic>> messages,
    String query,
  ) {
    if (query.isEmpty) {
      return messages;
    }

    final lowercaseQuery = query.toLowerCase();
    return messages.where((message) {
      final sender = message['sender']?.toString().toLowerCase() ?? '';
      final subject = message['subject']?.toString().toLowerCase() ?? '';
      final messageText = message['message']?.toString().toLowerCase() ?? '';

      return sender.contains(lowercaseQuery) ||
          subject.contains(lowercaseQuery) ||
          messageText.contains(lowercaseQuery);
    }).toList();
  }
}
