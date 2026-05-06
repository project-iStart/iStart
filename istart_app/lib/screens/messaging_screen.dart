// lib/screens/messaging_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/startup_idea.dart';
import '../providers/discussion_provider.dart';
import '../providers/auth_provider.dart';

class MessagingScreen extends StatefulWidget {
  final StartupIdea idea;

  const MessagingScreen({super.key, required this.idea});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final TextEditingController _attachCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscussionProvider>().fetchThreadsForIdea(widget.idea.id);
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _attachCtrl.dispose();
    super.dispose();
  }

  List<String> _extractParticipantIds() {
    final ids = <String>[];
    try {
      final founder = widget.idea.founder;
      if (founder['_id'] != null) {
        ids.add(founder['_id'].toString());
      }
      for (var tm in widget.idea.teamMembers) {
        if (tm is String) {
          ids.add(tm);
        } else if (tm is Map) {
          if (tm['_id'] != null) {
            ids.add(tm['_id'].toString());
          }
        }
      }
    } catch (_) {}
    return ids;
  }

  Future<void> _createCommonThread() async {
    final currentUser = context.read<AuthProvider>().user;
    final participantIds = _extractParticipantIds();
    if (currentUser != null && !participantIds.contains(currentUser.id)) {
      participantIds.add(currentUser.id);
    }

    final ok = await context.read<DiscussionProvider>().createThread(
      ideaId: widget.idea.id,
      title: 'Conversation',
      participants: participantIds,
    );
    if (ok) {
      await context.read<DiscussionProvider>().fetchThreadsForIdea(
        widget.idea.id,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thread created')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to create thread')));
    }
  }

  Future<void> _sendMessage() async {
    final provider = context.read<DiscussionProvider>();
    final thread = provider.selectedThread;
    if (thread == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select or create a thread first')),
      );
      return;
    }

    final content = _msgCtrl.text.trim();
    final attachUrl = _attachCtrl.text.trim();
    List<Map<String, dynamic>>? attachments;
    if (attachUrl.isNotEmpty) {
      attachments = [
        {'url': attachUrl, 'filename': attachUrl.split('/').last},
      ];
    }

    final success = await provider.postMessage(
      threadId: thread.id,
      content: content,
      attachments: attachments,
    );
    if (success) {
      _msgCtrl.clear();
      _attachCtrl.clear();
      await provider.fetchMessages(thread.id);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscussionProvider>();
    final threads = provider.threads;
    final selected = provider.selectedThread;
    final messages = provider.messages;

    return Scaffold(
      appBar: AppBar(title: Text('Messages — ${widget.idea.title}')),
      body: Column(
        children: [
          // Threads list
          Container(
            height: 90,
            padding: const EdgeInsets.all(8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: threads.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return ElevatedButton(
                    onPressed: _createCommonThread,
                    child: const Text('Create common thread'),
                  );
                }
                final t = threads[i - 1];
                final active = selected?.id == t.id;
                return GestureDetector(
                  onTap: () async {
                    await provider.selectThread(t);
                  },
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.blueAccent.withOpacity(0.15)
                          : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title.isNotEmpty ? t.title : 'Thread',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Participants: ${t.participants.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Messages
          Expanded(
            child: selected == null
                ? const Center(
                    child: Text('Select or create a thread to start messaging'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      return ListTile(
                        title: Text(m.senderName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (m.content.isNotEmpty) Text(m.content),
                            for (var a in m.attachments)
                              Text(
                                "Attachment: ${a['filename'] ?? a['url']}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            Text(
                              '${m.createdAt}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Compose
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _attachCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Attachment URL (optional)',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Write a message',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _sendMessage,
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
