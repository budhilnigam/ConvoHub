part of 'workspace_bloc.dart';

sealed class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}

class WorkspaceSubscriptionRequested extends WorkspaceEvent {
  const WorkspaceSubscriptionRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class WorkspaceSelected extends WorkspaceEvent {
  const WorkspaceSelected(this.workspaceId);

  final String workspaceId;

  @override
  List<Object?> get props => [workspaceId];
}

class WorkspaceRefreshRequested extends WorkspaceEvent {
  const WorkspaceRefreshRequested(this.workspaces);

  final List<Workspace> workspaces;

  @override
  List<Object?> get props => [workspaces];
}

class WorkspaceCreateRequested extends WorkspaceEvent {
  const WorkspaceCreateRequested({required this.userId, required this.name});

  final String userId;
  final String name;

  @override
  List<Object?> get props => [userId, name];
}