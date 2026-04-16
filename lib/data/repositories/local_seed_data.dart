import 'package:convo_hub/data/models/chat_message_model.dart';
import 'package:convo_hub/data/models/channel_model.dart';
import 'package:convo_hub/data/models/workspace_model.dart';

class LocalSeedData {
  static const userId = 'local-user-1';

  static final List<WorkspaceModel> _workspaces = <WorkspaceModel>[
    WorkspaceModel(id: 'workspace-1', name: 'Product Team', members: [userId, 'local-user-2']),
    WorkspaceModel(id: 'workspace-2', name: 'Launch Squad', members: [userId]),
  ];

  static final List<ChannelModel> _channels = <ChannelModel>[
    ChannelModel(id: 'channel-1', workspaceId: 'workspace-1', name: 'general', isPrivate: false),
    ChannelModel(id: 'channel-2', workspaceId: 'workspace-1', name: 'design', isPrivate: false),
    ChannelModel(id: 'channel-3', workspaceId: 'workspace-2', name: 'announcements', isPrivate: false),
  ];

  static List<WorkspaceModel> workspacesForUser(String userId) {
    return _workspaces.where((workspace) => workspace.members.contains(userId)).toList();
  }

  static List<ChannelModel> channelsForWorkspace(String workspaceId) {
    return _channels.where((channel) => channel.workspaceId == workspaceId).toList();
  }

  static WorkspaceModel addWorkspace({required String id, required String ownerId, required String name}) {
    final workspace = WorkspaceModel(id: id, name: name, members: [ownerId]);
    _workspaces.insert(0, workspace);
    return workspace;
  }

  static ChannelModel addChannel({
    required String id,
    required String workspaceId,
    required String name,
    required bool isPrivate,
  }) {
    final channel = ChannelModel(id: id, workspaceId: workspaceId, name: name, isPrivate: isPrivate);
    _channels.insert(0, channel);
    return channel;
  }

  static List<ChatMessageModel> messages(String channelId) {
    final now = DateTime.now();
    return <ChatMessageModel>[
      ChatMessageModel(
        id: 'm1',
        channelId: channelId,
        senderId: 'local-user-2',
        text: 'The responsive shell is ready for review.',
        type: 'text',
        timestamp: now.subtract(const Duration(minutes: 18)),
        readBy: const ['local-user-2'],
      ),
      ChatMessageModel(
        id: 'm2',
        channelId: channelId,
        senderId: userId,
        text: 'Next step is connecting Google OAuth and Firestore.',
        type: 'text',
        timestamp: now.subtract(const Duration(minutes: 8)),
        readBy: const [userId],
      ),
      ChatMessageModel(
        id: 'm3',
        channelId: channelId,
        senderId: 'local-user-2',
        text: 'Good. Keep the mobile layout compact and the desktop layout multi-pane.',
        type: 'text',
        timestamp: now.subtract(const Duration(minutes: 2)),
        readBy: const ['local-user-2', userId],
      ),
    ];
  }
}