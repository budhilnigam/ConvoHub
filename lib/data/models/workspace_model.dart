import 'package:convo_hub/domain/entities/workspace.dart';

class WorkspaceModel extends Workspace {
  const WorkspaceModel({required super.id, required super.name, required super.members});

  factory WorkspaceModel.fromMap(String id, Map<String, dynamic> map) {
    return WorkspaceModel(
      id: id,
      name: map['name'] as String? ?? 'Workspace',
      members: List<String>.from(map['members'] as List<dynamic>? ?? const <String>[]),
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'members': members};
}