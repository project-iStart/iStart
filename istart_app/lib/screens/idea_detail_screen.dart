// lib/screens/idea_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/startup_idea.dart';
import '../providers/idea_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/rocket_icon.dart';
import 'send_doc_request_dialog.dart';
import 'send_short_message_dialog.dart';
import 'profile/public_profile_screen.dart';

class IdeaDetailScreen extends StatefulWidget {
  final String ideaId;

  const IdeaDetailScreen({super.key, required this.ideaId});

  @override
  State<IdeaDetailScreen> createState() => _IdeaDetailScreenState();
}

class _IdeaDetailScreenState extends State<IdeaDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IdeaProvider>().fetchIdeaById(widget.ideaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final idea = context.watch<IdeaProvider>().selectedIdea;
    final loading = context.watch<IdeaProvider>().loading;
    final user = context.watch<AuthProvider>().user;
    final role = user?.role ?? 'founder';
    final accent = _accentForRole(role);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: loading
            ? Center(
                child:
                    CircularProgressIndicator(color: accent, strokeWidth: 2))
            : idea == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 48, color: accent.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        const Text(
                          'Idea not found',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor: const Color(0xFF0D0D0D),
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        leading: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Align(
                            alignment: Alignment.center,
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
                        ),
                        actions: [
                          if (role == 'investor')
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _DocumentRequestButton(
                                  idea: idea, accent: accent),
                            ),
                          if (role == 'collaborator')
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _MessageButtonDetail(
                                  idea: idea, accent: accent),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FollowButton(idea: idea, accent: accent),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child:
                                _BookmarkButton(idea: idea, accent: accent),
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (idea.category != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    idea.category!,
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: accent,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                idea.title,
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  if (idea.stage != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF161616),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        idea.stage!,
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 12,
                                          color:
                                              Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  if (idea.fundingInterest)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B)
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Seeking Funding',
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFF59E0B),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _VoteSection(idea: idea, accent: accent),
                              const SizedBox(height: 24),
                              _SectionTitle(
                                  title: 'Description', accent: accent),
                              const SizedBox(height: 12),
                              Text(
                                idea.description,
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (idea.problemStatement != null) ...[
                                _SectionTitle(
                                    title: 'Problem Statement',
                                    accent: accent),
                                const SizedBox(height: 12),
                                Text(
                                  idea.problemStatement!,
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                              _SectionTitle(
                                  title: 'Founder', accent: accent),
                              const SizedBox(height: 12),
                              _FounderCard(
                                  founder: idea.founder, accent: accent),
                              const SizedBox(height: 24),
                              if (idea.teamMembers.isNotEmpty) ...[
                                _SectionTitle(
                                    title: 'Team Members', accent: accent),
                                const SizedBox(height: 12),
                                ...idea.teamMembers.map((member) {
                                  final memberMap = member is Map
                                      ? member as Map<String, dynamic>
                                      : {'name': member.toString()}
                                            as Map<String, dynamic>;
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: _TeamMemberCard(
                                      member: memberMap,
                                      accent: accent,
                                    ),
                                  );
                                }),
                                const SizedBox(height: 24),
                              ],
                              if (idea.pitchDeckUrl != null) ...[
                                _SectionTitle(
                                    title: 'Pitch Deck', accent: accent),
                                const SizedBox(height: 12),
                                Container(
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
                                      Icon(
                                          Icons.picture_as_pdf_outlined,
                                          color: accent,
                                          size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'View Pitch Deck',
                                              style: TextStyle(
                                                fontFamily: 'DM Sans',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'PDF Document',
                                              style: TextStyle(
                                                fontFamily: 'DM Sans',
                                                fontSize: 12,
                                                color: Colors.white
                                                    .withOpacity(0.4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color:
                                            Colors.white.withOpacity(0.3),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                              _SectionTitle(
                                  title: 'Community Score', accent: accent),
                              const SizedBox(height: 12),
                              _CommunityScoreBar(
                                  score: idea.communityScore, accent: accent),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.idea.isVoted
                      ? widget.accent
                      : widget.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RocketIcon(
                      color: widget.idea.isVoted
                          ? Colors.white
                          : widget.accent,
                      size: 18,
                      filled: widget.idea.isVoted,
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

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.accent});

  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Sora',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}

// ─── Founder Card ─────────────────────────────────────────────────────────────

class _FounderCard extends StatelessWidget {
  const _FounderCard({required this.founder, required this.accent});

  final Map<String, dynamic> founder;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final name = (founder['name'] ?? 'Unknown') as String;
    final email = founder['email'] as String?;
    final role = founder['role'] as String?;
    final founderId =
        (founder['_id'] ?? founder['id'] ?? '') as String;

    return GestureDetector(
      onTap: founderId.isEmpty
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PublicProfileScreen(
                    userId: founderId,
                    userName: name,
                  ),
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.white.withOpacity(0.07), width: 0.5),
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
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
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
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (role != null)
                    Text(
                      role,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  if (email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (founderId.isNotEmpty)
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.2), size: 14),
          ],
        ),
      ),
    );
  }
}

// ─── Team Member Card ─────────────────────────────────────────────────────────

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({required this.member, required this.accent});

  final Map<String, dynamic> member;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final name = (member['name'] ?? 'Team Member') as String;
    final role = member['role'] as String?;
    final expertise = member['expertise'] as String?;
    final memberId = (member['_id'] ?? member['id'] ?? '') as String;

    return GestureDetector(
      onTap: memberId.isEmpty
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PublicProfileScreen(
                    userId: memberId,
                    userName: name,
                  ),
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Colors.white.withOpacity(0.07), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
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
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (role != null || expertise != null)
                    Text(
                      [
                        if (role != null) role,
                        if (expertise != null) expertise,
                      ].where((e) => e.isNotEmpty).join(' • '),
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                ],
              ),
            ),
            if (memberId.isNotEmpty)
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.2), size: 14),
          ],
        ),
      ),
    );
  }
}

// ─── Community Score Bar ──────────────────────────────────────────────────────

class _CommunityScoreBar extends StatelessWidget {
  const _CommunityScoreBar({required this.score, required this.accent});

  final int score;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    const maxScore = 100;
    final percentage = (score / maxScore).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Score',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            Text(
              '$score / $maxScore',
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
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
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              widget.idea.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: widget.idea.isBookmarked
                  ? widget.accent
                  : Colors.white.withOpacity(0.4),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Document Request Button ──────────────────────────────────────────────────

class _DocumentRequestButton extends StatefulWidget {
  const _DocumentRequestButton({required this.idea, required this.accent});

  final StartupIdea idea;
  final Color accent;

  @override
  State<_DocumentRequestButton> createState() =>
      _DocumentRequestButtonState();
}

class _DocumentRequestButtonState extends State<_DocumentRequestButton>
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
    showDialog(
      context: context,
      builder: (context) => SendDocRequestDialog(
        ideaId: widget.idea.id,
        ideaTitle: widget.idea.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(Icons.file_copy_outlined,
                color: Colors.white.withOpacity(0.6), size: 20),
          ),
        ),
      ),
    );
  }
}

// ─── Message Button Detail ────────────────────────────────────────────────────

class _MessageButtonDetail extends StatefulWidget {
  const _MessageButtonDetail({required this.idea, required this.accent});

  final StartupIdea idea;
  final Color accent;

  @override
  State<_MessageButtonDetail> createState() => _MessageButtonDetailState();
}

class _MessageButtonDetailState extends State<_MessageButtonDetail>
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
    showDialog(
      context: context,
      builder: (context) => SendShortMessageDialog(
        ideaId: widget.idea.id,
        ideaTitle: widget.idea.title,
        founderName: widget.idea.founder['name'] ?? 'Founder',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(Icons.message_outlined,
                color: Colors.white.withOpacity(0.6), size: 20),
          ),
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
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              widget.idea.isFollowing
                  ? Icons.notifications_rounded
                  : Icons.notifications_none_rounded,
              color: widget.idea.isFollowing
                  ? widget.accent
                  : Colors.white.withOpacity(0.4),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}