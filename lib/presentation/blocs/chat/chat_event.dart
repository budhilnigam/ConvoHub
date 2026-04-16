part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatSubscriptionRequested extends ChatEvent {
  const ChatSubscriptionRequested({required this.channelId, this.limit = 20});

  final String channelId;
  final int limit;

  @override
  List<Object?> get props => [channelId, limit];
}

class ChatMessagesRefreshRequested extends ChatEvent {
  const ChatMessagesRefreshRequested(this.messages);

  final List<ChatMessage> messages;

  @override
  List<Object?> get props => [messages];
}

class ChatMessageSendRequested extends ChatEvent {
  const ChatMessageSendRequested({
    required this.senderId,
    required this.text,
    this.type = 'text',
    this.replyToMessageId,
  });

  final String senderId;
  final String text;
  final String type;
  final String? replyToMessageId;

  @override
  List<Object?> get props => [senderId, text, type, replyToMessageId];
}