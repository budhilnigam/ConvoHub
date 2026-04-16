import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:convo_hub/domain/entities/channel.dart';
import 'package:convo_hub/domain/repositories/channel_repository.dart';
import 'package:equatable/equatable.dart';

part 'channel_event.dart';
part 'channel_state.dart';

class ChannelBloc extends Bloc<ChannelEvent, ChannelState> {
  ChannelBloc(this._repository) : super(const ChannelInitial()) {
    on<ChannelSubscriptionRequested>(_onSubscriptionRequested);
    on<ChannelSelected>(_onSelected);
    on<ChannelRefreshRequested>(_onRefreshRequested);
    on<ChannelCreateRequested>(_onCreateRequested);
  }

  final ChannelRepository _repository;
  StreamSubscription<List<Channel>>? _subscription;

  Future<void> _onSubscriptionRequested(
    ChannelSubscriptionRequested event,
    Emitter<ChannelState> emit,
  ) async {
    emit(const ChannelLoadInProgress());
    await _subscription?.cancel();
    _subscription = _repository.watchChannels(event.workspaceId).listen(
      (channels) {
        add(ChannelRefreshRequested(channels));
      },
      onError: (error) => add(ChannelRefreshRequested(const <Channel>[])),
    );

    final channels = await _repository.fetchChannels(event.workspaceId);
    emit(ChannelLoadSuccess(channels: channels, selectedChannelId: channels.isNotEmpty ? channels.first.id : null));
  }

  void _onSelected(ChannelSelected event, Emitter<ChannelState> emit) {
    final state = this.state;
    if (state is ChannelLoadSuccess) {
      emit(state.copyWith(selectedChannelId: event.channelId));
    }
  }

  void _onRefreshRequested(ChannelRefreshRequested event, Emitter<ChannelState> emit) {
    emit(ChannelLoadSuccess(channels: event.channels, selectedChannelId: state.selectedChannelId));
  }

  Future<void> _onCreateRequested(ChannelCreateRequested event, Emitter<ChannelState> emit) async {
    final currentState = state;
    if (currentState is! ChannelLoadSuccess) {
      return;
    }

    try {
      final channel = await _repository.createChannel(
        workspaceId: event.workspaceId,
        name: event.name,
        isPrivate: event.isPrivate,
      );
      emit(
        currentState.copyWith(
          channels: [channel, ...currentState.channels],
          selectedChannelId: channel.id,
        ),
      );
    } catch (error) {
      emit(ChannelLoadFailure(error.toString()));
      emit(currentState);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}