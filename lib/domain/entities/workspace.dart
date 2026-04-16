import 'package:equatable/equatable.dart';

class Workspace extends Equatable {
  const Workspace({required this.id, required this.name, required this.members});

  final String id;
  final String name;
  final List<String> members;

  @override
  List<Object?> get props => [id, name, members];
}