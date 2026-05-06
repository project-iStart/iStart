import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/startup_idea.dart';
import '../providers/idea_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/idea_detail_screen.dart';
import '../screens/messaging_screen.dart';
import 'rocket_icon.dart';

class IdeaCard extends StatelessWidget {
  const IdeaCard({super.key, required this.idea, required this.accent});

  final StartupIdea idea;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final userRole = context.watch<AuthProvider>().user?.role ?? '';
    final current = context.watch<IdeaProvider>().ideas.firstWhere(
      (i) => i.id == idea.id,
      orElse: () => idea,
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to detail screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => IdeaDetailScreen(ideaId: idea.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row — category tag + bookmark
              Row(
                children: [
                  if (current.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        current.category!,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ),
                  const Spacer(),
                  _FollowButton(idea: current, accent: accent),
                  const SizedBox(width: 8),
                  _BookmarkButton(idea: current, accent: accent),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                current.title,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                current.description,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.5),
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Funding interest badge
              if (current.fundingInterestCount > 0 || current.fundingInterest)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFFF59E0B),
                          size: 13,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Funding interest received',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom row — stage + role-specific button + vote button
              Row(
                children: [
                  // Stage on left
                  if (idea.stage != null) ...[
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: Colors.white.withOpacity(0.25),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      current.stage!,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Role-specific buttons
                  if (userRole == 'investor') ...[
                    _FundButton(idea: current),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Funding',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ] else if (userRole == 'collaborator') ...[
                    _MessageButton(idea: current, accent: accent),
                  ],
                  const SizedBox(width: 12),
                  // Vote button on right
                  _VoteButton(idea: idea, accent: accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Fund Button ──────────────────────────────────────────────────────────────

class _FundButton extends StatelessWidget {
  const _FundButton({required this.idea});

  final StartupIdea idea;

  @override
  Widget build(BuildContext context) {
    final funded = idea.hasFundingInterest;

    return GestureDetector(
      onTap: funded
          ? null
          : () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Express Funding Interest',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  content: const Text(
                    'Your contact details will be shared with the Founder. The actual deal happens outside the platform.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;
              try {
                await context.read<IdeaProvider>().fundInterest(idea.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funding interest sent to the Founder!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: funded
              ? const Color(0xFFF59E0B).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: funded
                ? const Color(0xFFF59E0B)
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              funded ? Icons.bolt_rounded : Icons.bolt_outlined,
              color: funded
                  ? const Color(0xFFF59E0B)
                  : Colors.white.withOpacity(0.4),
              size: 15,
            ),
            const SizedBox(width: 4),
            Text(
              funded ? 'Interested' : 'Fund This',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: funded
                    ? const Color(0xFFF59E0B)
                    : Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Rocket Vote Button ───────────────────────────────────────────────────────

class _VoteButton extends StatefulWidget {
  const _VoteButton({required this.idea, required this.accent});

  final StartupIdea idea;
  final Color accent;

  @override
  State<_VoteButton> createState() => _VoteButtonState();
}

class _VoteButtonState extends State<_VoteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.35,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.user?.id ?? '';
    context.read<IdeaProvider>().toggleVote(widget.idea.id, currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Row(
        children: [
          ScaleTransition(
            scale: _scale,
            child: RocketIcon(
              color: widget.idea.isVoted
                  ? widget.accent
                  : Colors.white.withOpacity(0.35),
              size: 18,
              filled: widget.idea.isVoted,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '${widget.idea.voteCount}',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: widget.idea.isVoted
                  ? widget.accent
                  : Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message Button (for Collaborators) ────────────────────────────────────────

class _MessageButton extends StatelessWidget {
  const _MessageButton({required this.idea, required this.accent});

  final StartupIdea idea;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => MessagingScreen(idea: idea)),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mail_outline_rounded, color: accent, size: 15),
            const SizedBox(width: 4),
            Text(
              'Message',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: accent,
              ),
            ),
          ],
        ),
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
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
        child: _BookmarkIcon(
          color: widget.idea.isBookmarked
              ? widget.accent
              : Colors.white.withOpacity(0.35),
          filled: widget.idea.isBookmarked,
          size: 20,
        ),
      ),
    );
  }
}

class _BookmarkIcon extends StatelessWidget {
  const _BookmarkIcon({
    required this.color,
    required this.filled,
    this.size = 20,
  });

  final Color color;
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BookmarkPainter(color: color, filled: filled),
    );
  }
}

class _BookmarkPainter extends CustomPainter {
  _BookmarkPainter({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke;

    final path = Path()
      ..moveTo(w * 0.15, 0)
      ..lineTo(w * 0.85, 0)
      ..lineTo(w * 0.85, h * 0.92)
      ..lineTo(w * 0.5, h * 0.70)
      ..lineTo(w * 0.15, h * 0.92)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BookmarkPainter old) =>
      old.color != color || old.filled != filled;
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
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: widget.idea.isFollowing
                ? widget.accent.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.idea.isFollowing
                  ? widget.accent
                  : Colors.white.withOpacity(0.2),
            ),
          ),
          child: Icon(
            widget.idea.isFollowing
                ? Icons.notifications_rounded
                : Icons.notifications_none_rounded,
            color: widget.idea.isFollowing
                ? widget.accent
                : Colors.white.withOpacity(0.5),
            size: 18,
          ),
        ),
      ),
    );
  }
}
