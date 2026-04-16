import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo_hub/core/services/firebase_bootstrap.dart';
import 'package:convo_hub/data/models/chat_message_model.dart';
import 'package:convo_hub/data/repositories/local_seed_data.dart';
import 'package:convo_hub/domain/entities/chat_message.dart';
import 'package:convo_hub/domain/repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required this.bootstrapState});

  final FirebaseBootstrapState bootstrapState;
  final Uuid _uuid = const Uuid();
  final Map<String, StreamController<List<ChatMessage>>> _controllers = {};

  @override
  Stream<List<ChatMessage>> watchMessages({required String channelId, int limit = 20, DateTime? before}) {
    if (!bootstrapState.enabled) {
      final messages = LocalSeedData.messages(channelId);
      return Stream<List<ChatMessage>>.value(messages);
    }

    final query = FirebaseFirestore.instance
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => ChatMessageModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<void> sendMessage({
    required String channelId,
    required String senderId,
    required String text,
    String type = 'text',
    String? replyToMessageId,
  }) async {
    if (!bootstrapState.enabled) {
      final controller = _controllers.putIfAbsent(channelId, () => StreamController<List<ChatMessage>>.broadcast());
      final currentMessages = List<ChatMessage>.from(LocalSeedData.messages(channelId));
      currentMessages.insert(
        0,
        ChatMessageModel(
          id: _uuid.v4(),
          channelId: channelId,
          senderId: senderId,
          text: text,
          type: type,
          timestamp: DateTime.now(),
          readBy: [senderId],
          replyToMessageId: replyToMessageId,
        ),
      );
      controller.add(currentMessages);
      return;
    }

    await FirebaseFirestore.instance
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .add(
          ChatMessageModel(
            id: _uuid.v4(),
            channelId: channelId,
            senderId: senderId,
            text: text,
            type: type,
            timestamp: DateTime.now(),
            readBy: [senderId],
            replyToMessageId: replyToMessageId,
          ).toMap(),
        );
  }

  @override
  Future<void> markRead({required String channelId, required String messageId, required String userId}) async {
    if (!bootstrapState.enabled) {
      return;
    }

    final ref = FirebaseFirestore.instance.collection('channels').doc(channelId).collection('messages').doc(messageId);
    await ref.set(
      {
        'readBy': FieldValue.arrayUnion([userId]),
      },
      SetOptions(merge: true),
    );
  }
}