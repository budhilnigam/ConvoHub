import 'package:convo_hub/domain/entities/channel.dart';

class ChannelModel extends Channel {
  const ChannelModel({
    required super.id,
    required super.workspaceId,
    required super.name,
    required super.isPrivate,
  });

  factory ChannelModel.fromMap(String id, Map<String, dynamic> map) {
    return ChannelModel(
      id: id,
      workspaceId: map['workspaceId'] as String? ?? '',
      name: map['name'] as String? ?? 'general',
      isPrivate: map['isPrivate'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'workspaceId': workspaceId,
        'name': name,
        'isPrivate': isPrivate,
      };
}