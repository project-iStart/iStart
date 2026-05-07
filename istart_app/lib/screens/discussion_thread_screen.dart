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
  final FocusNode _focusNode = FocusNode();

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
    _focusNode.dispose();
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final currentUserId = user?.id ?? '';
    final accent = _accentForRole(user?.role ?? 'founder');
    final messages = context.watch<DiscussionProvider>().messages;
    final loading = context.watch<DiscussionProvider>().loading;

    // Scroll to bottom when messages load
    if (messages.isNotEmpty) _scrollToBottom();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            _DiscussionHeader(thread: widget.thread, accent: accent),
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
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: messages.length,
                          itemBuilder: (context, i) {
                            final message = messages[i];
                            final isOwn = message.senderId == currentUserId;

                            // Show date separator if different day from previous
                            final showDate = i == 0 ||
                                !_isSameDay(
                                  messages[i - 1].createdAt,
                                  message.createdAt,
                                );

                            // Show avatar/name if different sender from previous
                            final showSender = i == 0 ||
                                messages[i - 1].senderId != message.senderId;

                            return Column(
                              children: [
                                if (showDate)
                                  _DateDivider(date: message.createdAt),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: showSender ? 12 : 3,
                                  ),
                                  child: _MessageBubble(
                                    message: message,
                                    isOwn: isOwn,
                                    accent: accent,
                                    showSender: showSender && !isOwn,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
            ),
            _MessageInput(
              messageController: _messageController,
              focusNode: _focusNode,
              threadId: widget.thread.id,
              accent: accent,
              onMessageSent: _scrollToBottom,
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _DiscussionHeader extends StatelessWidget {
  const _DiscussionHeader({required this.thread, required this.accent});

  final DiscussionThread thread;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.07),
            width: 0.5,
          ),
        ),
      ),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.forum_rounded, color: accent, size: 20),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Team Discussion',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: accent.withOpacity(0.8),
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

// ─── Date Divider ─────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label =
          '${_monthName(date.month)} ${date.day}, ${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.white.withOpacity(0.08),
              thickness: 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                color: Colors.white.withOpacity(0.35),
                letterSpacing: 0.3,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.white.withOpacity(0.08),
              thickness: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isOwn,
    required this.accent,
    required this.showSender,
  });

  final Message message;
  final bool isOwn;
  final Color accent;
  final bool showSender;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for others
          if (!isOwn) ...[
            if (showSender)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    message.senderName.isNotEmpty
                        ? message.senderName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isOwn
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (showSender && !isOwn)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isOwn
                        ? accent
                        : const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isOwn ? 16 : 4),
                      bottomRight: Radius.circular(isOwn ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isOwn
                            ? accent.withOpacity(0.2)
                            : Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: isOwn
                          ? Colors.white
                          : Colors.white.withOpacity(0.85),
                      height: 1.45,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Spacer for own messages
          if (isOwn) const SizedBox(width: 4),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}

// ─── Message Input ────────────────────────────────────────────────────────────

class _MessageInput extends StatefulWidget {
  const _MessageInput({
    required this.messageController,
    required this.focusNode,
    required this.threadId,
    required this.accent,
    required this.onMessageSent,
  });

  final TextEditingController messageController;
  final FocusNode focusNode;
  final String threadId;
  final Color accent;
  final VoidCallback onMessageSent;

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  bool _isSending = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(() {
      final has = widget.messageController.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  Future<void> _sendMessage() async {
    if (widget.messageController.text.trim().isEmpty) return;

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
      widget.focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.06),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _hasText
                      ? widget.accent.withOpacity(0.3)
                      : Colors.white.withOpacity(0.07),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: widget.messageController,
                focusNode: widget.focusNode,
                maxLines: null,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'Message your team...',
                  hintStyle: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.25),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _hasText && !_isSending
                  ? widget.accent
                  : widget.accent.withOpacity(0.3),
              borderRadius: BorderRadius.circular(13),
            ),
            child: GestureDetector(
              onTap: (_isSending || !_hasText) ? null : _sendMessage,
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
                    : Icon(
                        Icons.send_rounded,
                        color: _hasText
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        size: 19,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 36,
              color: accent.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation with your team',
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