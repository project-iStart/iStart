// lib/screens/discussion_thread_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/discussion_thread.dart';
import '../models/message.dart';
import '../providers/discussion_provider.dart';
import '../providers/auth_provider.dart';

class DiscussionThreadScreen extends StatefulWidget {
  final DiscussionThread thread;

  const DiscussionThreadScreen({super.key, required this.thread});

  @override
  State<DiscussionThreadScreen> createState() => _DiscussionThreadScreenState();
}

class _DiscussionThreadScreenState extends State<DiscussionThreadScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscussionProvider>().selectThread(widget.thread);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final currentUserId = user?.id ?? '';
    final accent = _accentForRole(user?.role ?? 'founder');
    final messages = context.watch<DiscussionProvider>().messages;
    final loading = context.watch<DiscussionProvider>().loading;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _DiscussionHeader(thread: widget.thread, accent: accent),

            // Messages
            Expanded(
              child: loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: accent,
                        strokeWidth: 2,
                      ),
                    )
                  : messages.isEmpty
                  ? _EmptyMessages(accent: accent)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        final message = messages[i];
                        final isOwn = message.senderId == currentUserId;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: _MessageBubble(
                            message: message,
                            isOwn: isOwn,
                            accent: accent,
                          ),
                        );
                      },
                    ),
            ),

            // Message input
            _MessageInput(
              messageController: _messageController,
              threadId: widget.thread.id,
              accent: accent,
              onMessageSent: _scrollToBottom,
            ),
          ],
        ),
      ),
    );
  }

  Color _accentForRole(String role) {
    switch (role) {
      case 'collaborator':
        return const Color(0xFF10B981);
      case 'investor':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }
}

// ─── Discussion Header ─────────────────────────────────────────────────────────

class _DiscussionHeader extends StatelessWidget {
  const _DiscussionHeader({required this.thread, required this.accent});

  final DiscussionThread thread;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.title,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Discussion',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
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

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isOwn,
    required this.accent,
  });

  final Message message;
  final bool isOwn;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isOwn
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isOwn)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                message.senderName,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isOwn ? accent : const Color(0xFF161616),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: isOwn ? Colors.white : Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10,
                color: Colors.white.withOpacity(0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}

// ─── Message Input ────────────────────────────────────────────────────────────

class _MessageInput extends StatefulWidget {
  const _MessageInput({
    required this.messageController,
    required this.threadId,
    required this.accent,
    required this.onMessageSent,
  });

  final TextEditingController messageController;
  final String threadId;
  final Color accent;
  final VoidCallback onMessageSent;

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  bool _isSending = false;

  Future<void> _sendMessage() async {
    if (widget.messageController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isSending = true);
    final content = widget.messageController.text.trim();
    widget.messageController.clear();

    if (!mounted) return;
    final success = await context.read<DiscussionProvider>().postMessage(
      threadId: widget.threadId,
      content: content,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (success) {
      widget.onMessageSent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.07), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.messageController,
              maxLines: null,
              minLines: 1,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.3),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isSending
                    ? widget.accent.withOpacity(0.5)
                    : widget.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: _isSending
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                        ),
                      )
                    : Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty Messages ───────────────────────────────────────────────────────────

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: accent.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
