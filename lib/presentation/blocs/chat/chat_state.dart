part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoadInProgress extends ChatState {
  const ChatLoadInProgress();
}

class ChatLoadSuccess extends ChatState {
  const ChatLoadSuccess({required this.channelId, required this.messages, required this.isSending});

  final String channelId;
  final List<ChatMessage> messages;
  final bool isSending;

  ChatLoadSuccess copyWith({List<ChatMessage>? messages, bool? isSending}) {
    return ChatLoadSuccess(
      channelId: channelId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [channelId, messages, isSending];
}

class ChatLoadFailure extends ChatState {
  const ChatLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}