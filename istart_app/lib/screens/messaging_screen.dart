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
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<DiscussionProvider>();
      await provider.fetchThreadsForIdea(widget.idea.id);
      // Auto-select first thread if exists
      if (provider.threads.isNotEmpty && provider.selectedThread == null) {
        await provider.selectThread(provider.threads.first);
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<String> _extractParticipantIds() {
    final ids = <String>[];
    final founder = widget.idea.founder;
    if (founder['_id'] != null) ids.add(founder['_id'].toString());
    for (var tm in widget.idea.teamMembers) {
      if (tm is String) ids.add(tm);
      else if (tm is Map && tm['_id'] != null) ids.add(tm['_id'].toString());
    }
    return ids;
  }

  Future<void> _createThread() async {
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

    if (!mounted) return;
    if (ok) {
      await context.read<DiscussionProvider>().fetchThreadsForIdea(widget.idea.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thread created'), backgroundColor: Color(0xFF10B981)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create thread'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _msgCtrl.text.trim();
    if (content.isEmpty) return;

    final provider = context.read<DiscussionProvider>();
    final thread = provider.selectedThread;

    if (thread == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a thread first')),
      );
      return;
    }

    final success = await provider.postMessage(threadId: thread.id, content: content);
    if (success) {
      _msgCtrl.clear();
      await provider.fetchMessages(thread.id);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscussionProvider>();
    final threads = provider.threads;
    final selected = provider.selectedThread;
    final messages = provider.messages;
    final currentUserId = context.read<AuthProvider>().user?.id ?? '';

    final role = context.read<AuthProvider>().user?.role ?? 'founder';
    final accent = role == 'collaborator'
        ? const Color(0xFF10B981)
        : role == 'investor'
            ? const Color(0xFFF59E0B)
            : const Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Discussion',
                style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600)),
            Text(widget.idea.title,
                style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: Colors.white.withOpacity(0.45)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
      body: Column(
        children: [
          // Thread selector
          if (threads.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: threads.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final t = threads[i];
                  final active = selected?.id == t.id;
                  return GestureDetector(
                    onTap: () async {
                      await provider.selectThread(t);
                      _scrollToBottom();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? accent.withOpacity(0.15) : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? accent.withOpacity(0.6) : Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Text(
                        t.title.isNotEmpty ? t.title : 'Thread',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          color: active ? accent : Colors.white54,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Messages area
          Expanded(
            child: selected == null
                ? _EmptyThreadState(onCreateThread: _createThread, accent: accent)
                : messages.isEmpty
                    ? Center(
                        child: Text('No messages yet. Say hello!',
                            style: TextStyle(
                                fontFamily: 'DM Sans',
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 14)),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final m = messages[i];
                          final isMe = m.senderId == currentUserId;
                          return _MessageBubble(
                            message: m,
                            isMe: isMe,
                            accent: accent,
                          );
                        },
                      ),
          ),

          // Create thread button (when no threads exist)
          if (threads.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _createThread,
                  icon: Icon(Icons.add_rounded, color: accent, size: 18),
                  label: Text('Start a conversation',
                      style: TextStyle(fontFamily: 'DM Sans', color: accent, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: accent.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),

          // Compose bar
          if (selected != null)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: Colors.white),
                        cursorColor: accent,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Write a message...',
                          hintStyle: TextStyle(fontFamily: 'DM Sans', color: Colors.white.withOpacity(0.3), fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Empty Thread State ───────────────────────────────────────────────────────

class _EmptyThreadState extends StatelessWidget {
  final VoidCallback onCreateThread;
  final Color accent;
  const _EmptyThreadState({required this.onCreateThread, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: accent.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No conversation yet',
              style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Start a thread to discuss this idea.',
              style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: Colors.white.withOpacity(0.4))),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onCreateThread,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: accent.withOpacity(0.4)),
              ),
              child: Text('Start conversation',
                  style: TextStyle(fontFamily: 'DM Sans', color: accent, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final bool isMe;
  final Color accent;
  const _MessageBubble({required this.message, required this.isMe, required this.accent});

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: accent.withOpacity(0.2),
              child: Text(
                (message.senderName ?? '?')[0].toUpperCase(),
                style: TextStyle(fontSize: 11, color: accent, fontFamily: 'Sora'),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      message.senderName ?? 'User',
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.45),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? accent : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.content ?? '',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: isMe ? Colors.white : Colors.white.withOpacity(0.85),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                      fontFamily: 'DM Sans', fontSize: 10, color: Colors.white.withOpacity(0.3)),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}