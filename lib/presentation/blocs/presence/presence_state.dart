part of 'presence_bloc.dart';

sealed class PresenceState extends Equatable {
  const PresenceState();

  @override
  List<Object?> get props => [];
}

class PresenceInitial extends PresenceState {
  const PresenceInitial();
}

class PresenceLoadInProgress extends PresenceState {
  const PresenceLoadInProgress();
}

class PresenceLoadSuccess extends PresenceState {
  const PresenceLoadSuccess({required this.presence});

  final Map<String, bool> presence;

  int get onlineCount => presence.values.where((value) => value).length;

  @override
  List<Object?> get props => [presence];
}

class PresenceLoadFailure extends PresenceState {
  const PresenceLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}