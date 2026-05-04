import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/startup_idea.dart';
import '../providers/idea_provider.dart';
import '../providers/auth_provider.dart';
import 'rocket_icon.dart';

class IdeaCard extends StatelessWidget {
  const IdeaCard({
    super.key,
    required this.idea,
    required this.accent,
  });

  final StartupIdea idea;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    // Always read live idea from provider by ID
    final live = context.watch<IdeaProvider>().ideas.firstWhere(
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
          // context.go('/idea/${live.id}') ← wire when detail screen is ready
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row — category tag + bookmark
              Row(
                children: [
                  if (live.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        live.category!,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ),
                  const Spacer(),
                  _BookmarkButton(ideaId: live.id, accent: accent),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                live.title,
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
                live.description,
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

              // Bottom row — stage + funding badge + rocket vote
              Row(
                children: [
                  if (live.stage != null) ...[
                    Icon(Icons.circle,
                        size: 6, color: Colors.white.withOpacity(0.25)),
                    const SizedBox(width: 6),
                    Text(
                      live.stage!,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                  ],
                  if (live.fundingInterest) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Funding interest',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  _VoteButton(ideaId: live.id, accent: accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Rocket Vote Button ───────────────────────────────────────────────────────

class _VoteButton extends StatefulWidget {
  const _VoteButton({required this.ideaId, required this.accent});

  final String ideaId;
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
    _scale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
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
    context.read<IdeaProvider>().toggleVote(widget.ideaId, currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    // Read live state directly from provider
    final idea = context.watch<IdeaProvider>().ideas.firstWhere(
          (i) => i.id == widget.ideaId,
          orElse: () => throw StateError('Idea not found'),
        );

    return GestureDetector(
      onTap: _onTap,
      child: Row(
        children: [
          ScaleTransition(
            scale: _scale,
            child: RocketIcon(
              color: idea.isVoted
                  ? widget.accent
                  : Colors.white.withOpacity(0.35),
              size: 18,
              filled: idea.isVoted,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '${idea.voteCount}',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: idea.isVoted
                  ? widget.accent
                  : Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bookmark Button ──────────────────────────────────────────────────────────

class _BookmarkButton extends StatefulWidget {
  const _BookmarkButton({required this.ideaId, required this.accent});

  final String ideaId;
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
    _scale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
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
    context.read<IdeaProvider>().toggleBookmark(widget.ideaId);
  }

  @override
  Widget build(BuildContext context) {
    // Read live state directly from provider
    final idea = context.watch<IdeaProvider>().ideas.firstWhere(
          (i) => i.id == widget.ideaId,
          orElse: () => throw StateError('Idea not found'),
        );

    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: _BookmarkIcon(
          color: idea.isBookmarked
              ? widget.accent
              : Colors.white.withOpacity(0.35),
          filled: idea.isBookmarked,
          size: 20,
        ),
      ),
    );
  }
}

// ─── Custom Bookmark Icon ─────────────────────────────────────────────────────

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