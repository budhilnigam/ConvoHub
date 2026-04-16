part of 'presence_bloc.dart';

sealed class PresenceEvent extends Equatable {
  const PresenceEvent();

  @override
  List<Object?> get props => [];
}

class PresenceSubscriptionRequested extends PresenceEvent {
  const PresenceSubscriptionRequested(this.workspaceId);

  final String workspaceId;

  @override
  List<Object?> get props => [workspaceId];
}

class PresenceRefreshRequested extends PresenceEvent {
  const PresenceRefreshRequested(this.presence);

  final Map<String, bool> presence;

  @override
  List<Object?> get props => [presence];
}