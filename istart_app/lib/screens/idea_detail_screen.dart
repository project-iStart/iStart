import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/startup_idea.dart';
import '../../models/feedback_model.dart';

import '../../providers/idea_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/discussion_provider.dart';
import '../../providers/doc_request_provider.dart';
import '../../providers/investment_request_provider.dart';
import '../../providers/join_request_provider.dart';

import '../../screens/feedback/feedback_sheet.dart';
import '../../screens/discussion_thread_screen.dart';
import '../../screens/send_doc_request_dialog.dart';
import '../../screens/send_funding_request_dialog.dart';
import '../../screens/join_request_screen.dart';
import '../../screens/join_request_management_screen.dart';
import '../../screens/profile/public_profile_screen.dart';

class IdeaDetailScreen extends StatefulWidget {
  final String ideaId;

  const IdeaDetailScreen({
    super.key,
    required this.ideaId,
  });

  @override
  State<IdeaDetailScreen> createState() => _IdeaDetailScreenState();
}

class _IdeaDetailScreenState extends State<IdeaDetailScreen> {
  bool _loading = true;
  StartupIdea? _idea;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ip = context.read<IdeaProvider>();
    final fp = context.read<FeedbackProvider>();

    try {
      _idea = ip.ideas.firstWhere((i) => i.id == widget.ideaId);
    } catch (_) {}

    await fp.loadFeedback(widget.ideaId);

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final idea = context.watch<IdeaProvider>().ideas.firstWhere(
          (i) => i.id == widget.ideaId,
          orElse: () => _idea!,
        );

    final feedbacks =
        context.watch<FeedbackProvider>().feedbackFor(widget.ideaId);

    final user = context.watch<AuthProvider>().user;
    final userRole = user?.role ?? '';
    final uid = user?.id ?? '';

    final founderId =
        (idea.founder['_id'] ?? idea.founder['id'] ?? '') as String;

    final isOwn = uid == founderId;

    final isTeamMember =
        isOwn || idea.teamMemberIds.contains(uid);

    double avgRating = 0;
    if (feedbacks.isNotEmpty) {
      avgRating = feedbacks
              .map((f) => f.rating)
              .reduce((a, b) => a + b) /
          feedbacks.length;
    }

    final accent = _accentForRole(userRole);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Idea Detail',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Bookmark
          _BookmarkButton(idea: idea, accent: accent),
          // Follow
          _FollowButton(idea: idea, accent: accent),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: accent,
                strokeWidth: 2,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Stage
                  Row(
                    children: [
                      if (idea.category != null)
                        _Chip(idea.category!, color: accent),
                      if (idea.stage != null) ...[
                        const SizedBox(width: 8),
                        _Chip(
                          idea.stage!,
                          color: Colors.white24,
                          textColor: Colors.white54,
                        ),
                      ],
                      if (idea.fundingInterest) ...[
                        const SizedBox(width: 8),
                        _Chip(
                          'Seeking Funding',
                          color: const Color(0xFFF59E0B),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Title
                  Text(
                    idea.title,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Founder row — tappable
                  GestureDetector(
                    onTap: founderId.isEmpty
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PublicProfileScreen(
                                  userId: founderId,
                                  userName:
                                      idea.founder['name'] ?? 'Founder',
                                ),
                              ),
                            ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: accent.withOpacity(0.2),
                          child: Text(
                            (idea.founder['name'] ?? '?')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: accent,
                              fontFamily: 'Sora',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          idea.founder['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Founder',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6366F1),
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ),
                        if (founderId.isNotEmpty) ...[
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Vote section
                  _VoteSection(idea: idea, accent: accent),

                  const SizedBox(height: 24),

                  // Description
                  _Section(
                    title: 'Description',
                    child: Text(
                      idea.description,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                    ),
                  ),

                  // Problem Statement
                  if (idea.problemStatement != null &&
                      idea.problemStatement!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _Section(
                      title: 'Problem Statement',
                      child: Text(
                        idea.problemStatement!,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],

                  // Team Members
                  if (idea.teamMembers.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _Section(
                      title: 'Team Members',
                      child: Column(
                        children: idea.teamMembers.map((member) {
                          final m = member is Map
                              ? member as Map<String, dynamic>
                              : <String, dynamic>{};
                          final mName =
                              (m['name'] ?? 'Team Member') as String;
                          final mId =
                              (m['_id'] ?? m['id'] ?? '') as String;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: mId.isEmpty
                                  ? null
                                  : () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => PublicProfileScreen(
                                            userId: mId,
                                            userName: mName,
                                          ),
                                        ),
                                      ),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF161616),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.07),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          const Color(0xFF10B981)
                                              .withOpacity(0.15),
                                      child: Text(
                                        mName[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF10B981),
                                          fontFamily: 'Sora',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        mName,
                                        style: const TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (mId.isNotEmpty)
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 12,
                                        color:
                                            Colors.white.withOpacity(0.2),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  // Pitch Deck
                  if (idea.pitchDeckUrl != null) ...[
                    const SizedBox(height: 24),
                    _Section(
                      title: 'Pitch Deck',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161616),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.07),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf_outlined,
                                color: accent, size: 24),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'View Pitch Deck',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white.withOpacity(0.3),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Community Score
                  _Section(
                    title: 'Community Score',
                    child: Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < avgRating.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          feedbacks.isEmpty
                              ? 'No ratings yet'
                              : '${avgRating.toStringAsFixed(1)} / 5  (${feedbacks.length} review${feedbacks.length == 1 ? '' : 's'})',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Feedback
                  _Section(
                    title: 'Feedback',
                    trailing: !isOwn
                        ? GestureDetector(
                            onTap: () =>
                                FeedbackSheet.show(context, widget.ideaId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '+ Give Feedback',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 12,
                                  color: accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : null,
                    child: feedbacks.isEmpty
                        ? const Text(
                            'No feedback yet.',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          )
                        : Column(
                            children: feedbacks
                                .map((f) => _FeedbackTile(feedback: f))
                                .toList(),
                          ),
                  ),

                  const SizedBox(height: 32),

                  // ── Action Buttons ──────────────────────────────────────

                  // Team Discussion — Founder + approved Collaborators only
                  if (user != null && isTeamMember) ...[
                    _TeamDiscussionButton(idea: idea, accent: accent),
                    const SizedBox(height: 12),
                  ],

                  // Manage Join Requests — Founder only
                  if (isOwn) ...[
                    _ActionButton(
                      label: 'Manage Join Requests',
                      icon: Icons.people_outline_rounded,
                      color: accent,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              JoinRequestManagementScreen(idea: idea),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Send Join Request — Collaborators on ideas they don't own
                  if (userRole == 'collaborator' && !isOwn)
                    _ActionButton(
                      label: 'Send Join Request',
                      icon: Icons.group_add_outlined,
                      color: const Color(0xFF10B981),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => JoinRequestScreen(idea: idea),
                        ),
                      ),
                    ),

                  // Investor actions
                  if (userRole == 'investor' && !isOwn) ...[
                    _ActionButton(
                      label: 'Request Document',
                      icon: Icons.description_outlined,
                      color: const Color(0xFFF59E0B),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => SendDocRequestDialog(
                          ideaId: idea.id,
                          ideaTitle: idea.title,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      label: 'Express Funding Interest',
                      icon: Icons.attach_money_rounded,
                      color: const Color(0xFFF59E0B),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => SendFundingRequestDialog(
                          ideaId: idea.id,
                          ideaTitle: idea.title,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
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

// ─── Vote Section ─────────────────────────────────────────────────────────────

class _VoteSection extends StatefulWidget {
  const _VoteSection({required this.idea, required this.accent});

  final StartupIdea idea;
  final Color accent;

  @override
  State<_VoteSection> createState() => _VoteSectionState();
}

class _VoteSectionState extends State<_VoteSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 160));
    _scale = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    if (!mounted) return;
    context.read<IdeaProvider>().toggleVote(widget.idea.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Support this idea',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.idea.voteCount} upvotes',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _onTap,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.idea.isVoted
                      ? widget.accent
                      : widget.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.idea.isVoted
                          ? Icons.rocket_rounded
                          : Icons.rocket_launch_outlined,
                      color: widget.idea.isVoted
                          ? Colors.white
                          : widget.accent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.idea.isVoted ? 'Voted' : 'Vote',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.idea.isVoted
                            ? Colors.white
                            : widget.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bookmark Button ──────────────────────────────────────────────────────────

class _BookmarkButton extends StatefulWidget {
  const _BookmarkButton({required this.idea, required this.accent});

  final StartupIdea idea;
  final Color accent;

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 160));
    _scale = Tween<double>(begin: 1.0, end: 1.3)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    if (!mounted) return;
    context.read<IdeaProvider>().toggleBookmark(widget.idea.id);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: IconButton(
        onPressed: _onTap,
        icon: Icon(
          widget.idea.isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_outline_rounded,
          color: widget.idea.isBookmarked
              ? widget.accent
              : Colors.white.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ─── Follow Button ────────────────────────────────────────────────────────────

class _FollowButton extends StatefulWidget {
  const _FollowButton({required this.idea, required this.accent});

  final StartupIdea idea;
  final Color accent;

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 160));
    _scale = Tween<double>(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    if (!mounted) return;
    context.read<IdeaProvider>().toggleFollow(widget.idea.id);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: IconButton(
        onPressed: _onTap,
        icon: Icon(
          widget.idea.isFollowing
              ? Icons.notifications_rounded
              : Icons.notifications_none_rounded,
          color: widget.idea.isFollowing
              ? widget.accent
              : Colors.white.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ─── Section ──────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _Section({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// ─── Chip ─────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Chip(
    this.label, {
    required this.color,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor == Colors.white ? color : textColor,
        ),
      ),
    );
  }
}

// ─── Feedback Tile ────────────────────────────────────────────────────────────

class _FeedbackTile extends StatelessWidget {
  final FeedbackModel feedback;

  const _FeedbackTile({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                child: Text(
                  (feedback.userName ?? '?')[0].toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF6366F1)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feedback.userName ?? 'User',
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < feedback.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Chip(feedback.category, color: const Color(0xFF6366F1)),
          if (feedback.comment != null && feedback.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              feedback.comment!,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: Colors.white60,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: color.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ─── Team Discussion Button ───────────────────────────────────────────────────

class _TeamDiscussionButton extends StatefulWidget {
  const _TeamDiscussionButton({required this.idea, required this.accent});

  final StartupIdea idea;
  final Color accent;

  @override
  State<_TeamDiscussionButton> createState() => _TeamDiscussionButtonState();
}

class _TeamDiscussionButtonState extends State<_TeamDiscussionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 160));
    _scale = Tween<double>(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    if (!mounted) return;

    setState(() => _loading = true);

    final thread = await context.read<DiscussionProvider>().getOrCreateThread(
          ideaId: widget.idea.id,
          title: widget.idea.title,
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (thread != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DiscussionThreadScreen(thread: thread),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open discussion'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ActionButton(
      label: _loading ? 'Opening Discussion...' : 'Team Discussion',
      icon: Icons.forum_outlined,
      color: widget.accent,
      onTap: _loading ? () {} : _onTap,
    );
  }
}