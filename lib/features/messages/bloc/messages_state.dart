import 'package:equatable/equatable.dart';

/// Messages states
abstract class MessagesState extends Equatable {
  const MessagesState();
}

/// Initial messages state
class MessagesInitial extends MessagesState {
  const MessagesInitial();

  @override
  List<Object?> get props => [];
}

/// Messages loading state
class MessagesLoading extends MessagesState {
  const MessagesLoading();

  @override
  List<Object?> get props => [];
}

/// Messages loaded state
class MessagesLoaded extends MessagesState {
  final List<Map<String, dynamic>> messages;
  final List<Map<String, dynamic>> filteredMessages;
  final String searchQuery;
  final int unreadCount;

  const MessagesLoaded({
    required this.messages,
    required this.filteredMessages,
    this.searchQuery = '',
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [
    messages,
    filteredMessages,
    searchQuery,
    unreadCount,
  ];

  /// Copy with method for immutable state updates
  MessagesLoaded copyWith({
    List<Map<String, dynamic>>? messages,
    List<Map<String, dynamic>>? filteredMessages,
    String? searchQuery,
    int? unreadCount,
  }) {
    return MessagesLoaded(
      messages: messages ?? this.messages,
      filteredMessages: filteredMessages ?? this.filteredMessages,
      searchQuery: searchQuery ?? this.searchQuery,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Chat messages loaded state
class ChatMessagesLoaded extends MessagesState {
  final String chatId;
  final List<Map<String, dynamic>> chatMessages;
  final String recipientName;

  const ChatMessagesLoaded({
    required this.chatId,
    required this.chatMessages,
    required this.recipientName,
  });

  @override
  List<Object?> get props => [chatId, chatMessages, recipientName];
}

/// Messages error state
class MessagesError extends MessagesState {
  final String message;

  const MessagesError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Message sent success state
class MessageSentSuccessState extends MessagesState {
  final String messageId;

  const MessageSentSuccessState({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

/// Message marked as read state
class MessageMarkedAsReadState extends MessagesState {
  final String messageId;

  const MessageMarkedAsReadState({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

/// Message deleted state
class MessageDeletedState extends MessagesState {
  final String messageId;

  const MessageDeletedState({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}



