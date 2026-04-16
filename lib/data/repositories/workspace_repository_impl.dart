import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo_hub/core/services/firebase_bootstrap.dart';
import 'package:convo_hub/data/models/workspace_model.dart';
import 'package:convo_hub/data/repositories/local_seed_data.dart';
import 'package:convo_hub/domain/entities/workspace.dart';
import 'package:convo_hub/domain/repositories/workspace_repository.dart';
import 'package:uuid/uuid.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {
  WorkspaceRepositoryImpl({required this.bootstrapState});

  final FirebaseBootstrapState bootstrapState;
  final Uuid _uuid = const Uuid();

  @override
  Stream<List<Workspace>> watchWorkspaces(String userId) {
    if (!bootstrapState.enabled) {
      return Stream<List<Workspace>>.value(LocalSeedData.workspacesForUser(userId));
    }

    return FirebaseFirestore.instance
        .collection('workspaces')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => WorkspaceModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<List<Workspace>> fetchWorkspaces(String userId) async {
    if (!bootstrapState.enabled) {
      return LocalSeedData.workspacesForUser(userId);
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('workspaces')
        .where('members', arrayContains: userId)
        .get();
    return snapshot.docs.map((doc) => WorkspaceModel.fromMap(doc.id, doc.data())).toList();
  }

  @override
  Future<Workspace> createWorkspace({required String ownerId, required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Workspace name cannot be empty.');
    }

    if (!bootstrapState.enabled) {
      return LocalSeedData.addWorkspace(
        id: _uuid.v4(),
        ownerId: ownerId,
        name: trimmed,
      );
    }

    final payload = WorkspaceModel(id: '', name: trimmed, members: [ownerId]).toMap();
    final doc = await FirebaseFirestore.instance.collection('workspaces').add(payload);
    return WorkspaceModel(id: doc.id, name: trimmed, members: [ownerId]);
  }
}