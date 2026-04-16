import 'package:equatable/equatable.dart';

class Channel extends Equatable {
  const Channel({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.isPrivate,
  });

  final String id;
  final String workspaceId;
  final String name;
  final bool isPrivate;

  @override
  List<Object?> get props => [id, workspaceId, name, isPrivate];
}