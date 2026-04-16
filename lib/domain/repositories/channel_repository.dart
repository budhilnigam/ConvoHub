import 'package:convo_hub/domain/entities/channel.dart';

abstract class ChannelRepository {
  Stream<List<Channel>> watchChannels(String workspaceId);
  Future<List<Channel>> fetchChannels(String workspaceId);
  Future<Channel> createChannel({
    required String workspaceId,
    required String name,
    required bool isPrivate,
  });
}