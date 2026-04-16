import 'package:convo_hub/domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.photoUrl,
    required super.lastSeen,
    required super.isOnline,
  });

  factory AppUserModel.fromMap(String id, Map<String, dynamic> map) {
    return AppUserModel(
      id: id,
      name: map['name'] as String? ?? 'Unknown User',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      lastSeen: (map['lastSeen'] as DateTime?) ?? (map['lastSeen'] as dynamic)?.toDate?.call(),
      isOnline: map['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'lastSeen': lastSeen,
      'isOnline': isOnline,
    };
  }
}