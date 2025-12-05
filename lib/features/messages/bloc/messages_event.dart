import 'package:equatable/equatable.dart';

/// Messages events
abstract class MessagesEvent extends Equatable {
  const MessagesEvent();
}

/// Load messages event
class LoadMessagesEvent extends MessagesEvent {
  const LoadMessagesEvent();

  @override
  List<Object?> get props => [];
}

/// Mark message as read event
class MarkMessageAsReadEvent extends MessagesEvent {
  final String messageId;

  const MarkMessageAsReadEvent({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

/// Mark all messages as read event
class MarkAllMessagesAsReadEvent extends MessagesEvent {
  const MarkAllMessagesAsReadEvent();

  @override
  List<Object?> get props => [];
}

/// Delete message event
class DeleteMessageEvent extends MessagesEvent {
  final String messageId;

  const DeleteMessageEvent({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

/// Send message event
class SendMessageEvent extends MessagesEvent {
  final String recipientId;
  final String message;
  final String? subject;

  const SendMessageEvent({
    required this.recipientId,
    required this.message,
    this.subject,
  });

  @override
  List<Object?> get props => [recipientId, message, subject];
}

/// Load chat messages event
class LoadChatMessagesEvent extends MessagesEvent {
  final String chatId;

  const LoadChatMessagesEvent({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}

/// Refresh messages event
class RefreshMessagesEvent extends MessagesEvent {
  const RefreshMessagesEvent();

  @override
  List<Object?> get props => [];
}

/// Search messages event
class SearchMessagesEvent extends MessagesEvent {
  final String query;

  const SearchMessagesEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Clear search event
class ClearSearchEvent extends MessagesEvent {
  const ClearSearchEvent();

  @override
  List<Object?> get props => [];
}



