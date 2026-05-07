import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/startup_idea.dart';
import '../../models/feedback_model.dart';
import '../../providers/idea_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../screens/feedback/feedback_sheet.dart';

class IdeaDetailScreen extends StatefulWidget {
  final String ideaId;
  const IdeaDetailScreen({super.key, required this.ideaId});

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

    // Try to find from existing list first
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
    final feedbacks = context.watch<FeedbackProvider>().feedbackFor(widget.ideaId);
    final userRole = context.watch<AuthProvider>().user?.role ?? '';
    final uid = context.watch<AuthProvider>().user?.id ?? '';
    final founderId = (idea.founder['_id'] ?? idea.founder['id'] ?? '') as String;
    final isOwn = uid == founderId;

    // Community score: avg of all ratings
    double avgRating = 0;
    if (feedbacks.isNotEmpty) {
      avgRating = feedbacks.map((f) => f.rating).reduce((a, b) => a + b) / feedbacks.length;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Idea Detail',
          style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Stage chips
                  Row(
                    children: [
                      if (idea.category != null) _Chip(idea.category!, color: const Color(0xFF6366F1)),
                      if (idea.stage != null) ...[
                        const SizedBox(width: 8),
                        _Chip(idea.stage!, color: Colors.white24, textColor: Colors.white54),
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

                  // Founder
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                        child: Text(
                          (idea.founder['name'] ?? '?')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6366F1), fontFamily: 'Sora'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        idea.founder['name'] ?? 'Unknown',
                        style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: Colors.white70),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Founder',
                            style: TextStyle(fontSize: 10, color: Color(0xFF6366F1), fontFamily: 'DM Sans')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _Section(
                    title: 'Description',
                    child: Text(
                      idea.description,
                      style: const TextStyle(
                          fontFamily: 'DM Sans', fontSize: 14, color: Colors.white70, height: 1.6),
                    ),
                  ),

                  // Problem Statement
                  if (idea.problemStatement != null && idea.problemStatement!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _Section(
                      title: 'Problem Statement',
                      child: Text(
                        idea.problemStatement!,
                        style: const TextStyle(
                            fontFamily: 'DM Sans', fontSize: 14, color: Colors.white70, height: 1.6),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Community Score
                  _Section(
                    title: 'Community Score',
                    child: Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                              i < avgRating.round()
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: const Color(0xFFF59E0B),
                              size: 22,
                            )),
                        const SizedBox(width: 10),
                        Text(
                          feedbacks.isEmpty
                              ? 'No ratings yet'
                              : '${avgRating.toStringAsFixed(1)} / 5  (${feedbacks.length} review${feedbacks.length == 1 ? '' : 's'})',
                          style: const TextStyle(
                              fontFamily: 'DM Sans', fontSize: 13, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Feedback List
                  _Section(
                    title: 'Feedback',
                    trailing: !isOwn
                        ? GestureDetector(
                            onTap: () => FeedbackSheet.show(context, widget.ideaId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('+ Give Feedback',
                                  style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 12,
                                      color: Color(0xFF6366F1),
                                      fontWeight: FontWeight.w600)),
                            ),
                          )
                        : null,
                    child: feedbacks.isEmpty
                        ? const Text('No feedback yet.',
                            style: TextStyle(fontFamily: 'DM Sans', color: Colors.white38, fontSize: 13))
                        : Column(
                            children: feedbacks
                                .map((f) => _FeedbackTile(feedback: f))
                                .toList(),
                          ),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  if (userRole == 'collaborator' && !isOwn)
                    _ActionButton(
                      label: 'Send Join Request',
                      icon: Icons.group_add_outlined,
                      color: const Color(0xFF10B981),
                      onTap: () {
                        // Join request — next feature
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Join Request coming soon')),
                        );
                      },
                    ),

                  if (userRole == 'investor' && !isOwn) ...[
                    _ActionButton(
                      label: 'Request Document',
                      icon: Icons.description_outlined,
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Doc Request coming soon')),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

// ─── Section wrapper ──────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _Section({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
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
  const _Chip(this.label, {required this.color, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor == Colors.white ? color : textColor)),
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
          // User + category + stars
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                child: Text(
                  (feedback.userName ?? '?')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feedback.userName ?? 'User',
                  style: const TextStyle(
                      fontFamily: 'DM Sans', fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              // Stars
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < feedback.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Category chip
          _Chip(feedback.category, color: const Color(0xFF6366F1)),
          // Comment
          if (feedback.comment != null && feedback.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              feedback.comment!,
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: Colors.white60, height: 1.5),
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
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18, color: color),
          label: Text(label, style: TextStyle(fontFamily: 'DM Sans', color: color, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: color.withOpacity(0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}