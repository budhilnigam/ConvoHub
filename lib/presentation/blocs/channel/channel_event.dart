part of 'channel_bloc.dart';

sealed class ChannelEvent extends Equatable {
  const ChannelEvent();

  @override
  List<Object?> get props => [];
}

class ChannelSubscriptionRequested extends ChannelEvent {
  const ChannelSubscriptionRequested(this.workspaceId);

  final String workspaceId;

  @override
  List<Object?> get props => [workspaceId];
}

class ChannelSelected extends ChannelEvent {
  const ChannelSelected(this.channelId);

  final String channelId;

  @override
  List<Object?> get props => [channelId];
}

class ChannelRefreshRequested extends ChannelEvent {
  const ChannelRefreshRequested(this.channels);

  final List<Channel> channels;

  @override
  List<Object?> get props => [channels];
}

class ChannelCreateRequested extends ChannelEvent {
  const ChannelCreateRequested({
    required this.workspaceId,
    required this.name,
    required this.isPrivate,
  });

  final String workspaceId;
  final String name;
  final bool isPrivate;

  @override
  List<Object?> get props => [workspaceId, name, isPrivate];
}