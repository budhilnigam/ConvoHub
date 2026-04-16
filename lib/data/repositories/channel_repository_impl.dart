import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo_hub/core/services/firebase_bootstrap.dart';
import 'package:convo_hub/data/models/channel_model.dart';
import 'package:convo_hub/data/repositories/local_seed_data.dart';
import 'package:convo_hub/domain/entities/channel.dart';
import 'package:convo_hub/domain/repositories/channel_repository.dart';
import 'package:uuid/uuid.dart';

class ChannelRepositoryImpl implements ChannelRepository {
  ChannelRepositoryImpl({required this.bootstrapState});

  final FirebaseBootstrapState bootstrapState;
  final Uuid _uuid = const Uuid();

  @override
  Stream<List<Channel>> watchChannels(String workspaceId) {
    if (!bootstrapState.enabled) {
      return Stream<List<Channel>>.value(LocalSeedData.channelsForWorkspace(workspaceId));
    }

    return FirebaseFirestore.instance
        .collection('channels')
        .where('workspaceId', isEqualTo: workspaceId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChannelModel.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Future<List<Channel>> fetchChannels(String workspaceId) async {
    if (!bootstrapState.enabled) {
      return LocalSeedData.channelsForWorkspace(workspaceId);
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('channels')
        .where('workspaceId', isEqualTo: workspaceId)
        .get();
    return snapshot.docs.map((doc) => ChannelModel.fromMap(doc.id, doc.data())).toList();
  }

  @override
  Future<Channel> createChannel({
    required String workspaceId,
    required String name,
    required bool isPrivate,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Channel name cannot be empty.');
    }

    if (!bootstrapState.enabled) {
      return LocalSeedData.addChannel(
        id: _uuid.v4(),
        workspaceId: workspaceId,
        name: trimmed,
        isPrivate: isPrivate,
      );
    }

    final payload = ChannelModel(
      id: '',
      workspaceId: workspaceId,
      name: trimmed,
      isPrivate: isPrivate,
    ).toMap();
    final doc = await FirebaseFirestore.instance.collection('channels').add(payload);
    return ChannelModel(id: doc.id, workspaceId: workspaceId, name: trimmed, isPrivate: isPrivate);
  }
}