import 'package:convo_hub/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.channelId,
    required super.senderId,
    required super.text,
    required super.type,
    required super.timestamp,
    required super.readBy,
    super.replyToMessageId,
  });

  factory ChatMessageModel.fromMap(String id, Map<String, dynamic> map) {
    final timestampValue = map['timestamp'];
    final DateTime timestamp = timestampValue is DateTime
        ? timestampValue
        : timestampValue?.toDate?.call() ?? DateTime.now();

    return ChatMessageModel(
      id: id,
      channelId: map['channelId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      type: map['type'] as String? ?? 'text',
      timestamp: timestamp,
      readBy: List<String>.from(map['readBy'] as List<dynamic>? ?? const <String>[]),
      replyToMessageId: map['replyToMessageId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'channelId': channelId,
      'senderId': senderId,
      'text': text,
      'type': type,
      'timestamp': timestamp,
      'readBy': readBy,
      'replyToMessageId': replyToMessageId,
    };
  }
}