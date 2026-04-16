import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.lastSeen,
    required this.isOnline,
  });

  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime? lastSeen;
  final bool isOnline;

  @override
  List<Object?> get props => [id, name, email, photoUrl, lastSeen, isOnline];
}