// lib/screens/team_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/startup_idea.dart';
import '../providers/discussion_provider.dart';
import '../providers/auth_provider.dart';
import 'discussion_thread_screen.dart';
import 'profile/public_profile_screen.dart';

class TeamDetailsScreen extends StatefulWidget {
  final StartupIdea idea;

  const TeamDetailsScreen({super.key, required this.idea});

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  late TextEditingController _threadTitleController;

  @override
  void initState() {
    super.initState();
    _threadTitleController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscussionProvider>().fetchThreadsForIdea(widget.idea.id);
    });
  }

  @override
  void dispose() {
    _threadTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final accent = _accentForRole(user?.role ?? 'founder');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
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
                          const Text(
                            'Team',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.idea.title,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.4),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                labelColor: accent,
                unselectedLabelColor: Colors.white.withOpacity(0.5),
                indicatorColor: accent,
                labelStyle: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Discussions'),
                  Tab(text: 'Team Members'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _DiscussionsTab(ideaId: widget.idea.id, accent: accent),
                    _TeamMembersTab(idea: widget.idea, accent: accent),
                  ],
                ),
              ),
            ],
          ),
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

// ─── Discussions Tab ──────────────────────────────────────────────────────────

class _DiscussionsTab extends StatefulWidget {
  const _DiscussionsTab({required this.ideaId, required this.accent});

  final String ideaId;
  final Color accent;

  @override
  State<_DiscussionsTab> createState() => _DiscussionsTabState();
}

class _DiscussionsTabState extends State<_DiscussionsTab> {
  late TextEditingController _threadTitleController;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _threadTitleController = TextEditingController();
  }

  @override
  void dispose() {
    _threadTitleController.dispose();
    super.dispose();
  }

  Future<void> _showCreateThreadDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        title: const Text(
          'New Discussion',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: _threadTitleController,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Discussion topic...',
            hintStyle: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: Colors.white.withOpacity(0.3),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: widget.accent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: _isCreating
                ? null
                : () async {
                    if (_threadTitleController.text.trim().isEmpty) return;
                    setState(() => _isCreating = true);
                    final success = await context
                        .read<DiscussionProvider>()
                        .createThread(
                          ideaId: widget.ideaId,
                          title: _threadTitleController.text.trim(),
                        );
                    if (!mounted) return;
                    setState(() => _isCreating = false);
                    _threadTitleController.clear();
                    if (mounted) Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Discussion created!'),
                          backgroundColor: widget.accent,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.accent,
              disabledBackgroundColor: widget.accent.withOpacity(0.5),
              elevation: 0,
            ),
            child: _isCreating
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8),
                      ),
                    ),
                  )
                : const Text(
                    'Create',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final threads = context.watch<DiscussionProvider>().threads;
    final loading = context.watch<DiscussionProvider>().loading;

    return loading
        ? Center(
            child: CircularProgressIndicator(
              color: widget.accent,
              strokeWidth: 2,
            ),
          )
        : threads.isEmpty
            ? _EmptyDiscussions(
                accent: widget.accent,
                onCreateTap: _showCreateThreadDialog,
              )
            : Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      color: widget.accent,
                      backgroundColor: const Color(0xFF161616),
                      onRefresh: () => context
                          .read<DiscussionProvider>()
                          .fetchThreadsForIdea(widget.ideaId),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: threads.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, i) => _ThreadCard(
                          thread: threads[i],
                          accent: widget.accent,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showCreateThreadDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.accent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'New Discussion',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
  }
}

// ─── Thread Card ──────────────────────────────────────────────────────────────

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread, required this.accent});

  final dynamic thread;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DiscussionThreadScreen(thread: thread),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded, color: accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.title,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Created ${_formatDate(thread.createdAt)}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.2),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.month}/${date.day}';
  }
}

// ─── Empty Discussions ────────────────────────────────────────────────────────

class _EmptyDiscussions extends StatelessWidget {
  const _EmptyDiscussions({required this.accent, required this.onCreateTap});

  final Color accent;
  final VoidCallback onCreateTap;

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
            'No discussions yet',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a discussion to collaborate',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onCreateTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Start Discussion',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Team Members Tab ─────────────────────────────────────────────────────────

class _TeamMembersTab extends StatelessWidget {
  const _TeamMembersTab({required this.idea, required this.accent});

  final StartupIdea idea;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final teamMembers = [idea.founder, ...idea.teamMembers];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: teamMembers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final member = teamMembers[i];
        final memberMap =
            member is Map ? member : {'name': member.toString()};
        final isFounder = i == 0;
        final memberId =
            (memberMap['_id'] ?? memberMap['id'] ?? '') as String;
        final memberName =
            (memberMap['name'] ?? 'Team Member') as String;

        return GestureDetector(
          onTap: memberId.isEmpty
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PublicProfileScreen(
                        userId: memberId,
                        userName: memberName,
                      ),
                    ),
                  );
                },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFounder
                    ? accent
                    : Colors.white.withOpacity(0.07),
                width: isFounder ? 1 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      memberName.isNotEmpty
                          ? memberName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              memberName,
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isFounder)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Founder',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (memberMap['role'] != null)
                        Text(
                          memberMap['role'] as String,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                ),
                if (memberId.isNotEmpty)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.2),
                    size: 14,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}