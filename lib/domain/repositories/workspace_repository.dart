import 'package:convo_hub/domain/entities/workspace.dart';

abstract class WorkspaceRepository {
  Stream<List<Workspace>> watchWorkspaces(String userId);
  Future<List<Workspace>> fetchWorkspaces(String userId);
  Future<Workspace> createWorkspace({required String ownerId, required String name});
}