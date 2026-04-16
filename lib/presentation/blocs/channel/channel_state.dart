part of 'channel_bloc.dart';

sealed class ChannelState extends Equatable {
  const ChannelState();

  @override
  List<Object?> get props => [];

  String? get selectedChannelId => null;
}

class ChannelInitial extends ChannelState {
  const ChannelInitial();
}

class ChannelLoadInProgress extends ChannelState {
  const ChannelLoadInProgress();
}

class ChannelLoadSuccess extends ChannelState {
  const ChannelLoadSuccess({required this.channels, required this.selectedChannelId});

  final List<Channel> channels;
  @override
  final String? selectedChannelId;

  ChannelLoadSuccess copyWith({List<Channel>? channels, String? selectedChannelId}) {
    return ChannelLoadSuccess(
      channels: channels ?? this.channels,
      selectedChannelId: selectedChannelId ?? this.selectedChannelId,
    );
  }

  @override
  List<Object?> get props => [channels, selectedChannelId];
}

class ChannelLoadFailure extends ChannelState {
  const ChannelLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}