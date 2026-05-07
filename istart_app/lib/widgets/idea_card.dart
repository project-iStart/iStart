import 'package:flutter/material.dart';
import '../models/startup_idea.dart';

class IdeaCard extends StatelessWidget {
  final StartupIdea idea;
  final Color accent;

  const IdeaCard({
    super.key,
    required this.idea,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───────────────── TITLE + CATEGORY ─────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  idea.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Sora',
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (idea.category != null)
                Flexible(
                  child: _Chip(
                    idea.category!,
                    color: accent,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // ───────────────── FOUNDER ROW ─────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: accent.withOpacity(0.15),
                child: Text(
                  (idea.founder['name'] ?? '?')[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: accent,
                    fontFamily: 'Sora',
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  idea.founder['name'] ?? 'Unknown',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),

              if (idea.stage != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: _Chip(
                    idea.stage!,
                    color: Colors.white24,
                    textColor: Colors.white70,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // ───────────────── DESCRIPTION ─────────────────
          Text(
            idea.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white60,
              fontFamily: 'DM Sans',
              height: 1.5,
            ),
          ),

          const SizedBox(height: 14),

          // ───────────────── VOTE ROW ─────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  '${idea.voteCount} votes',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              GestureDetector(
                onTap: () {
                  // TODO: vote logic
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.rocket_launch_outlined,
                        size: 16,
                        color: accent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Vote',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── CHIP (SAFE VERSION) ─────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.w600,
          color: textColor == Colors.white ? color : textColor,
        ),
      ),
    );
  }
}