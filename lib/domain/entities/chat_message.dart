import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.text,
    required this.type,
    required this.timestamp,
    required this.readBy,
    this.replyToMessageId,
  });

  final String id;
  final String channelId;
  final String senderId;
  final String text;
  final String type;
  final DateTime timestamp;
  final List<String> readBy;
  final String? replyToMessageId;

  @override
  List<Object?> get props => [id, channelId, senderId, text, type, timestamp, readBy, replyToMessageId];
}