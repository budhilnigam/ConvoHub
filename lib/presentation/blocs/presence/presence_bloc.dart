import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:convo_hub/domain/repositories/presence_repository.dart';
import 'package:equatable/equatable.dart';

part 'presence_event.dart';
part 'presence_state.dart';

class PresenceBloc extends Bloc<PresenceEvent, PresenceState> {
  PresenceBloc(this._repository) : super(const PresenceInitial()) {
    on<PresenceSubscriptionRequested>(_onSubscriptionRequested);
    on<PresenceRefreshRequested>(_onRefreshRequested);
  }

  final PresenceRepository _repository;
  StreamSubscription<Map<String, bool>>? _subscription;

  Future<void> _onSubscriptionRequested(
    PresenceSubscriptionRequested event,
    Emitter<PresenceState> emit,
  ) async {
    emit(const PresenceLoadInProgress());
    await _subscription?.cancel();
    _subscription = _repository.watchPresence(event.workspaceId).listen(
      (presence) => add(PresenceRefreshRequested(presence)),
      onError: (error) => add(const PresenceRefreshRequested(<String, bool>{})),
    );
    final initialPresence = await _repository.watchPresence(event.workspaceId).first;
    emit(PresenceLoadSuccess(presence: initialPresence));
  }

  void _onRefreshRequested(PresenceRefreshRequested event, Emitter<PresenceState> emit) {
    emit(PresenceLoadSuccess(presence: event.presence));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}