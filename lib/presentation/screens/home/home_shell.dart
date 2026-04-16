import 'package:convo_hub/core/constants/app_colors.dart';
import 'package:convo_hub/core/utils/responsive.dart';
import 'package:convo_hub/domain/entities/app_user.dart';
import 'package:convo_hub/domain/entities/channel.dart';
import 'package:convo_hub/domain/entities/chat_message.dart';
import 'package:convo_hub/domain/entities/workspace.dart';
import 'package:convo_hub/presentation/blocs/auth/auth_bloc.dart';
import 'package:convo_hub/presentation/blocs/channel/channel_bloc.dart';
import 'package:convo_hub/presentation/blocs/chat/chat_bloc.dart';
import 'package:convo_hub/presentation/blocs/presence/presence_bloc.dart';
import 'package:convo_hub/presentation/blocs/workspace/workspace_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.user});

  final AppUser user;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  String? _selectedWorkspaceId;
  String? _selectedChannelId;
  int _selectedTabIndex = 2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = Responsive.screenType(context);
        final isMobile = screenType == ScreenType.mobile;
        final isRailLayout = screenType == ScreenType.tablet;
        final isWideLayout = constraints.maxWidth >= 1200;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Convo Hub'),
            actions: [
              IconButton(
                onPressed: _createWorkspace,
                icon: const Icon(Icons.add_business_rounded),
                tooltip: 'Create workspace',
              ),
              IconButton(
                onPressed: _createDirectChat,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                tooltip: 'Start direct chat',
              ),
              BlocBuilder<PresenceBloc, PresenceState>(
                builder: (context, state) {
                  final onlineCount = state is PresenceLoadSuccess ? state.onlineCount : 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text('$onlineCount online'),
                      avatar: const Icon(Icons.circle, size: 12, color: AppColors.success),
                    ),
                  );
                },
              ),
              if (!isMobile)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(child: Text(widget.user.name)),
                ),
              IconButton(
                onPressed: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Sign out',
              ),
            ],
          ),
          bottomNavigationBar: isMobile
              ? NavigationBar(
                  selectedIndex: _selectedTabIndex,
                  onDestinationSelected: (index) => setState(() => _selectedTabIndex = index),
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.workspaces_rounded), label: 'Workspaces'),
                    NavigationDestination(icon: Icon(Icons.tag_rounded), label: 'Channels'),
                    NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Chat'),
                  ],
                )
              : null,
          body: SafeArea(
            top: false,
            child: MultiBlocListener(
              listeners: [
                BlocListener<WorkspaceBloc, WorkspaceState>(
                  listener: (context, state) {
                    if (state is WorkspaceLoadSuccess && state.workspaces.isNotEmpty) {
                      final selectedWorkspaceId = _selectedWorkspaceId ?? state.selectedWorkspaceId ?? state.workspaces.first.id;
                      if (_selectedWorkspaceId != selectedWorkspaceId) {
                        setState(() {
                          _selectedWorkspaceId = selectedWorkspaceId;
                          _selectedChannelId = null;
                        });
                        context.read<ChannelBloc>().add(ChannelSubscriptionRequested(selectedWorkspaceId));
                        context.read<PresenceBloc>().add(PresenceSubscriptionRequested(selectedWorkspaceId));
                      }
                    }
                  },
                ),
                BlocListener<ChannelBloc, ChannelState>(
                  listener: (context, state) {
                    if (state is ChannelLoadSuccess && state.channels.isNotEmpty) {
                      final selectedChannelId = _selectedChannelId ?? state.selectedChannelId ?? state.channels.first.id;
                      if (_selectedChannelId != selectedChannelId) {
                        setState(() => _selectedChannelId = selectedChannelId);
                        context.read<ChatBloc>().add(ChatSubscriptionRequested(channelId: selectedChannelId));
                      }
                    }
                  },
                ),
              ],
              child: isWideLayout
                  ? _WideHomeView(
                      selectedWorkspaceId: _selectedWorkspaceId,
                      selectedChannelId: _selectedChannelId,
                      onWorkspaceSelected: (workspaceId) {
                        setState(() {
                          _selectedWorkspaceId = workspaceId;
                          _selectedChannelId = null;
                          _selectedTabIndex = 1;
                        });
                        context.read<WorkspaceBloc>().add(WorkspaceSelected(workspaceId));
                        context.read<ChannelBloc>().add(ChannelSubscriptionRequested(workspaceId));
                        context.read<PresenceBloc>().add(PresenceSubscriptionRequested(workspaceId));
                      },
                      onChannelSelected: (channelId) {
                        setState(() {
                          _selectedChannelId = channelId;
                          _selectedTabIndex = 2;
                        });
                        context.read<ChannelBloc>().add(ChannelSelected(channelId));
                        context.read<ChatBloc>().add(ChatSubscriptionRequested(channelId: channelId));
                      },
                      onCreateWorkspace: _createWorkspace,
                      onCreateChannel: _createChannel,
                      onSendMessage: _sendMessage,
                    )
                  : isRailLayout
                      ? Row(
                          children: [
                            NavigationRail(
                              selectedIndex: _selectedTabIndex,
                              extended: constraints.maxWidth >= 1000,
                              labelType: constraints.maxWidth >= 1000 ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                              onDestinationSelected: (index) => setState(() => _selectedTabIndex = index),
                              destinations: const [
                                NavigationRailDestination(
                                  icon: Icon(Icons.workspaces_rounded),
                                  label: Text('Workspaces'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.tag_rounded),
                                  label: Text('Channels'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.chat_bubble_outline_rounded),
                                  label: Text('Chat'),
                                ),
                              ],
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(
                              child: _CompactHomeView(
                                selectedTab: _selectedTabIndex,
                                selectedWorkspaceId: _selectedWorkspaceId,
                                selectedChannelId: _selectedChannelId,
                                onWorkspaceSelected: (workspaceId) {
                                  setState(() {
                                    _selectedWorkspaceId = workspaceId;
                                    _selectedChannelId = null;
                                    _selectedTabIndex = 1;
                                  });
                                  context.read<WorkspaceBloc>().add(WorkspaceSelected(workspaceId));
                                  context.read<ChannelBloc>().add(ChannelSubscriptionRequested(workspaceId));
                                  context.read<PresenceBloc>().add(PresenceSubscriptionRequested(workspaceId));
                                },
                                onChannelSelected: (channelId) {
                                  setState(() {
                                    _selectedChannelId = channelId;
                                    _selectedTabIndex = 2;
                                  });
                                  context.read<ChannelBloc>().add(ChannelSelected(channelId));
                                  context.read<ChatBloc>().add(ChatSubscriptionRequested(channelId: channelId));
                                },
                                onCreateWorkspace: _createWorkspace,
                                onCreateChannel: _createChannel,
                                onSendMessage: _sendMessage,
                              ),
                            ),
                          ],
                        )
                      : _CompactHomeView(
                          selectedTab: _selectedTabIndex,
                          selectedWorkspaceId: _selectedWorkspaceId,
                          selectedChannelId: _selectedChannelId,
                          onWorkspaceSelected: (workspaceId) {
                            setState(() {
                              _selectedWorkspaceId = workspaceId;
                              _selectedChannelId = null;
                              _selectedTabIndex = 1;
                            });
                            context.read<WorkspaceBloc>().add(WorkspaceSelected(workspaceId));
                            context.read<ChannelBloc>().add(ChannelSubscriptionRequested(workspaceId));
                            context.read<PresenceBloc>().add(PresenceSubscriptionRequested(workspaceId));
                          },
                          onChannelSelected: (channelId) {
                            setState(() {
                              _selectedChannelId = channelId;
                              _selectedTabIndex = 2;
                            });
                            context.read<ChannelBloc>().add(ChannelSelected(channelId));
                            context.read<ChatBloc>().add(ChatSubscriptionRequested(channelId: channelId));
                          },
                          onCreateWorkspace: _createWorkspace,
                          onCreateChannel: _createChannel,
                          onSendMessage: _sendMessage,
                        ),
            ),
          ),
        );
      },
    );
  }

  void _sendMessage(String text) {
    final channelId = _selectedChannelId;
    if (channelId == null || text.trim().isEmpty) {
      return;
    }

    context.read<ChatBloc>().add(ChatMessageSendRequested(senderId: widget.user.id, text: text.trim()));
  }

  Future<void> _createWorkspace() async {
    final workspaceName = await _showNameDialog(
      title: 'Create workspace',
      label: 'Workspace name',
      hint: 'e.g. Engineering',
    );
    if (!mounted || workspaceName == null) {
      return;
    }

    context.read<WorkspaceBloc>().add(
      WorkspaceCreateRequested(userId: widget.user.id, name: workspaceName),
    );
  }

  Future<void> _createChannel() async {
    final workspaceId = _selectedWorkspaceId;
    if (workspaceId == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create or select a workspace first.')),
      );
      return;
    }

    final channelInfo = await _showChannelDialog();
    if (!mounted || channelInfo == null) {
      return;
    }

    context.read<ChannelBloc>().add(
      ChannelCreateRequested(
        workspaceId: workspaceId,
        name: channelInfo.name,
        isPrivate: channelInfo.isPrivate,
      ),
    );
  }

  Future<void> _createDirectChat() async {
    final workspaceId = _selectedWorkspaceId;
    if (workspaceId == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create or select a workspace first.')),
      );
      return;
    }

    final personName = await _showNameDialog(
      title: 'Start direct chat',
      label: 'Person name',
      hint: 'e.g. Jamie',
    );
    if (!mounted || personName == null) {
      return;
    }

    context.read<ChannelBloc>().add(
      ChannelCreateRequested(
        workspaceId: workspaceId,
        name: 'dm-${personName.toLowerCase().replaceAll(' ', '-')}',
        isPrivate: true,
      ),
    );
  }

  Future<String?> _showNameDialog({
    required String title,
    required String label,
    required String hint,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: label, hintText: hint),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  return;
                }
                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  Future<_ChannelCreatePayload?> _showChannelDialog() async {
    final controller = TextEditingController();
    var isPrivate = false;

    final result = await showDialog<_ChannelCreatePayload>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create channel'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Channel name', hintText: 'e.g. general'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: isPrivate,
                    onChanged: (value) => setDialogState(() => isPrivate = value),
                    title: const Text('Private channel'),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.isEmpty) {
                      return;
                    }
                    Navigator.of(dialogContext).pop(_ChannelCreatePayload(name: value, isPrivate: isPrivate));
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }
}

class _CompactHomeView extends StatelessWidget {
  const _CompactHomeView({
    required this.selectedTab,
    required this.selectedWorkspaceId,
    required this.selectedChannelId,
    required this.onWorkspaceSelected,
    required this.onChannelSelected,
    required this.onCreateWorkspace,
    required this.onCreateChannel,
    required this.onSendMessage,
  });

  final int selectedTab;
  final String? selectedWorkspaceId;
  final String? selectedChannelId;
  final ValueChanged<String> onWorkspaceSelected;
  final ValueChanged<String> onChannelSelected;
  final VoidCallback onCreateWorkspace;
  final VoidCallback onCreateChannel;
  final ValueChanged<String> onSendMessage;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: selectedTab,
      children: [
        _WorkspacePane(
          selectedWorkspaceId: selectedWorkspaceId,
          onWorkspaceSelected: onWorkspaceSelected,
          onCreateWorkspace: onCreateWorkspace,
        ),
        _ChannelPane(
          selectedWorkspaceId: selectedWorkspaceId,
          selectedChannelId: selectedChannelId,
          onChannelSelected: onChannelSelected,
          onCreateChannel: onCreateChannel,
        ),
        _ChatPane(selectedChannelId: selectedChannelId, onSendMessage: onSendMessage),
      ],
    );
  }
}

class _WorkspacePane extends StatelessWidget {
  const _WorkspacePane({
    required this.selectedWorkspaceId,
    required this.onWorkspaceSelected,
    required this.onCreateWorkspace,
  });

  final String? selectedWorkspaceId;
  final ValueChanged<String> onWorkspaceSelected;
  final VoidCallback onCreateWorkspace;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceBloc, WorkspaceState>(
      builder: (context, state) {
        final workspaces = state is WorkspaceLoadSuccess ? state.workspaces : const <Workspace>[];

        return _PaneCard(
          title: 'Workspaces',
          subtitle: '${workspaces.length} active spaces',
          actionIcon: Icons.add_business_rounded,
          actionTooltip: 'Create workspace',
          onAction: onCreateWorkspace,
          child: workspaces.isEmpty
              ? const _EmptyPanel(icon: Icons.workspaces_rounded, title: 'No workspaces', subtitle: 'Create or join a workspace to begin.')
              : ListView.builder(
                  itemCount: workspaces.length,
                  itemBuilder: (context, index) {
                    final workspace = workspaces[index];
                    final selected = workspace.id == selectedWorkspaceId;
                    return _SelectableTile(
                      selected: selected,
                      title: workspace.name,
                      subtitle: '${workspace.members.length} members',
                      icon: Icons.apartment_rounded,
                      onTap: () => onWorkspaceSelected(workspace.id),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _ChannelPane extends StatelessWidget {
  const _ChannelPane({
    required this.selectedWorkspaceId,
    required this.selectedChannelId,
    required this.onChannelSelected,
    required this.onCreateChannel,
  });

  final String? selectedWorkspaceId;
  final String? selectedChannelId;
  final ValueChanged<String> onChannelSelected;
  final VoidCallback onCreateChannel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelBloc, ChannelState>(
      builder: (context, state) {
        final channels = state is ChannelLoadSuccess ? state.channels : const <Channel>[];

        return _PaneCard(
          title: 'Channels',
          subtitle: selectedWorkspaceId == null ? 'Select a workspace' : '${channels.length} channels',
          actionIcon: Icons.add_rounded,
          actionTooltip: 'Create channel',
          onAction: selectedWorkspaceId == null ? null : onCreateChannel,
          child: channels.isEmpty
              ? const _EmptyPanel(icon: Icons.tag_rounded, title: 'No channels', subtitle: 'Channels for the selected workspace appear here.')
              : ListView.builder(
                  itemCount: channels.length,
                  itemBuilder: (context, index) {
                    final channel = channels[index];
                    final selected = channel.id == selectedChannelId;
                    return _SelectableTile(
                      selected: selected,
                      title: '# ${channel.name}',
                      subtitle: channel.isPrivate ? 'Private channel' : 'Public channel',
                      icon: Icons.tag_rounded,
                      onTap: () => onChannelSelected(channel.id),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _ChatPane extends StatelessWidget {
  const _ChatPane({required this.selectedChannelId, required this.onSendMessage});

  final String? selectedChannelId;
  final ValueChanged<String> onSendMessage;

  @override
  Widget build(BuildContext context) {
    if (selectedChannelId == null) {
      return const _EmptyPanel(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Select a channel',
        subtitle: 'Choose a channel to read and send messages.',
      );
    }

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final messages = state is ChatLoadSuccess ? state.messages : const <ChatMessage>[];

        return Column(
          children: [
            _ChatHeader(channelId: selectedChannelId!),
            const Divider(height: 1),
            Expanded(
              child: messages.isEmpty
                  ? const _EmptyPanel(icon: Icons.forum_rounded, title: 'No messages yet', subtitle: 'Start the conversation with your team.')
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _MessageBubble(message: message, isMe: message.senderId == 'local-user-1');
                      },
                    ),
            ),
            _MessageComposer(onSend: onSendMessage),
          ],
        );
      },
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.channelId});

  final String channelId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.tag_rounded, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('# $channelId', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                Text('Messages update in real time through Firestore streams.', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.more_horiz_rounded),
        ],
      ),
    );
  }
}

class _PaneCard extends StatelessWidget {
  const _PaneCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.actionIcon,
    this.actionTooltip,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final IconData? actionIcon;
  final String? actionTooltip;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (actionIcon != null)
                  IconButton(
                    onPressed: onAction,
                    icon: Icon(actionIcon),
                    tooltip: actionTooltip,
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({required this.selected, required this.title, required this.subtitle, required this.icon, required this.onTap});

  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      leading: CircleAvatar(
        backgroundColor: selected ? AppColors.accent : AppColors.surfaceAlt,
        child: Icon(icon, color: selected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = isMe ? AppColors.accent : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = isMe ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 6),
            bottomRight: Radius.circular(isMe ? 6 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor, height: 1.4)),
            const SizedBox(height: 8),
            Text(DateFormat.Hm().format(message.timestamp), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor.withValues(alpha: 0.75))),
          ],
        ),
      ),
    );
  }
}

class _MessageComposer extends StatefulWidget {
  const _MessageComposer({required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline_rounded)),
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write a message...',
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: _submit,
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    widget.onSend(text);
    _controller.clear();
  }
}

class _WideHomeView extends StatelessWidget {
  const _WideHomeView({
    required this.selectedWorkspaceId,
    required this.selectedChannelId,
    required this.onWorkspaceSelected,
    required this.onChannelSelected,
    required this.onCreateWorkspace,
    required this.onCreateChannel,
    required this.onSendMessage,
  });

  final String? selectedWorkspaceId;
  final String? selectedChannelId;
  final ValueChanged<String> onWorkspaceSelected;
  final ValueChanged<String> onChannelSelected;
  final VoidCallback onCreateWorkspace;
  final VoidCallback onCreateChannel;
  final ValueChanged<String> onSendMessage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final workspaceWidth = math.max(280.0, math.min(340.0, constraints.maxWidth * 0.22));
        final channelWidth = math.max(300.0, math.min(380.0, constraints.maxWidth * 0.26));

        return Row(
          children: [
            SizedBox(
              width: workspaceWidth,
              child: _WorkspacePane(
                selectedWorkspaceId: selectedWorkspaceId,
                onWorkspaceSelected: onWorkspaceSelected,
                onCreateWorkspace: onCreateWorkspace,
              ),
            ),
            SizedBox(
              width: channelWidth,
              child: _ChannelPane(
                selectedWorkspaceId: selectedWorkspaceId,
                selectedChannelId: selectedChannelId,
                onChannelSelected: onChannelSelected,
                onCreateChannel: onCreateChannel,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _ChatPane(
                selectedChannelId: selectedChannelId,
                onSendMessage: onSendMessage,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChannelCreatePayload {
  const _ChannelCreatePayload({required this.name, required this.isPrivate});

  final String name;
  final bool isPrivate;
}