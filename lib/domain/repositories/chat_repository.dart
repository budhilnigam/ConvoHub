import 'package:convo_hub/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> watchMessages({
    required String channelId,
    int limit,
    DateTime? before,
  });

  Future<void> sendMessage({
    required String channelId,
    required String senderId,
    required String text,
    String type,
    String? replyToMessageId,
  });

  Future<void> markRead({required String channelId, required String messageId, required String userId});
}