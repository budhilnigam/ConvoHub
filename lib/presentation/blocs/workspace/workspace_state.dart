part of 'workspace_bloc.dart';

sealed class WorkspaceState extends Equatable {
  const WorkspaceState();

  @override
  List<Object?> get props => [];

  String? get selectedWorkspaceId => null;
}

class WorkspaceInitial extends WorkspaceState {
  const WorkspaceInitial();
}

class WorkspaceLoadInProgress extends WorkspaceState {
  const WorkspaceLoadInProgress();
}

class WorkspaceLoadSuccess extends WorkspaceState {
  const WorkspaceLoadSuccess({required this.workspaces, required this.selectedWorkspaceId});

  final List<Workspace> workspaces;
  @override
  final String? selectedWorkspaceId;

  WorkspaceLoadSuccess copyWith({List<Workspace>? workspaces, String? selectedWorkspaceId}) {
    return WorkspaceLoadSuccess(
      workspaces: workspaces ?? this.workspaces,
      selectedWorkspaceId: selectedWorkspaceId ?? this.selectedWorkspaceId,
    );
  }

  @override
  List<Object?> get props => [workspaces, selectedWorkspaceId];
}

class WorkspaceLoadFailure extends WorkspaceState {
  const WorkspaceLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}