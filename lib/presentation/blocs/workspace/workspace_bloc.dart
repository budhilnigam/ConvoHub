import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:convo_hub/domain/entities/workspace.dart';
import 'package:convo_hub/domain/repositories/workspace_repository.dart';
import 'package:equatable/equatable.dart';

part 'workspace_event.dart';
part 'workspace_state.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  WorkspaceBloc(this._repository) : super(const WorkspaceInitial()) {
    on<WorkspaceSubscriptionRequested>(_onSubscriptionRequested);
    on<WorkspaceSelected>(_onSelected);
    on<WorkspaceRefreshRequested>(_onRefreshRequested);
    on<WorkspaceCreateRequested>(_onCreateRequested);
  }

  final WorkspaceRepository _repository;
  StreamSubscription<List<Workspace>>? _subscription;

  Future<void> _onSubscriptionRequested(
    WorkspaceSubscriptionRequested event,
    Emitter<WorkspaceState> emit,
  ) async {
    emit(const WorkspaceLoadInProgress());
    await _subscription?.cancel();
    _subscription = _repository.watchWorkspaces(event.userId).listen(
      (workspaces) {
        add(WorkspaceRefreshRequested(workspaces));
      },
      onError: (error) => add(WorkspaceRefreshRequested(const <Workspace>[])),
    );

    final workspaces = await _repository.fetchWorkspaces(event.userId);
    emit(WorkspaceLoadSuccess(workspaces: workspaces, selectedWorkspaceId: workspaces.isNotEmpty ? workspaces.first.id : null));
  }

  void _onSelected(WorkspaceSelected event, Emitter<WorkspaceState> emit) {
    final state = this.state;
    if (state is WorkspaceLoadSuccess) {
      emit(state.copyWith(selectedWorkspaceId: event.workspaceId));
    }
  }

  void _onRefreshRequested(WorkspaceRefreshRequested event, Emitter<WorkspaceState> emit) {
    emit(WorkspaceLoadSuccess(workspaces: event.workspaces, selectedWorkspaceId: state.selectedWorkspaceId));
  }

  Future<void> _onCreateRequested(WorkspaceCreateRequested event, Emitter<WorkspaceState> emit) async {
    final currentState = state;
    if (currentState is! WorkspaceLoadSuccess) {
      return;
    }

    try {
      final workspace = await _repository.createWorkspace(ownerId: event.userId, name: event.name);
      emit(
        currentState.copyWith(
          workspaces: [workspace, ...currentState.workspaces],
          selectedWorkspaceId: workspace.id,
        ),
      );
    } catch (error) {
      emit(WorkspaceLoadFailure(error.toString()));
      emit(currentState);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}