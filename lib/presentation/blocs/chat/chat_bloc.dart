import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:convo_hub/domain/entities/chat_message.dart';
import 'package:convo_hub/domain/repositories/chat_repository.dart';
import 'package:equatable/equatable.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this._repository) : super(const ChatInitial()) {
    on<ChatSubscriptionRequested>(_onSubscriptionRequested);
    on<ChatMessageSendRequested>(_onMessageSendRequested);
    on<ChatMessagesRefreshRequested>(_onMessagesRefreshRequested);
  }

  final ChatRepository _repository;
  StreamSubscription<List<ChatMessage>>? _subscription;

  Future<void> _onSubscriptionRequested(
    ChatSubscriptionRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoadInProgress());
    await _subscription?.cancel();
    _subscription = _repository.watchMessages(channelId: event.channelId, limit: event.limit).listen(
      (messages) {
        add(ChatMessagesRefreshRequested(messages));
      },
      onError: (error) => add(const ChatMessagesRefreshRequested(<ChatMessage>[])),
    );

    final initialMessages = await _repository
        .watchMessages(channelId: event.channelId, limit: event.limit)
        .first;
    emit(ChatLoadSuccess(channelId: event.channelId, messages: initialMessages, isSending: false));
  }

  Future<void> _onMessageSendRequested(
    ChatMessageSendRequested event,
    Emitter<ChatState> emit,
  ) async {
    final state = this.state;
    if (state is! ChatLoadSuccess) {
      return;
    }

    final optimisticMessage = ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      channelId: state.channelId,
      senderId: event.senderId,
      text: event.text,
      type: event.type,
      timestamp: DateTime.now(),
      readBy: [event.senderId],
      replyToMessageId: event.replyToMessageId,
    );

    emit(state.copyWith(messages: [optimisticMessage, ...state.messages], isSending: true));
    try {
      await _repository.sendMessage(
        channelId: state.channelId,
        senderId: event.senderId,
        text: event.text,
        type: event.type,
        replyToMessageId: event.replyToMessageId,
      );
      emit(state.copyWith(messages: [optimisticMessage, ...state.messages], isSending: false));
    } catch (error) {
      emit(ChatLoadFailure(error.toString()));
    }
  }

  void _onMessagesRefreshRequested(
    ChatMessagesRefreshRequested event,
    Emitter<ChatState> emit,
  ) {
    final state = this.state;
    if (state is ChatLoadSuccess) {
      emit(state.copyWith(messages: event.messages, isSending: false));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}