import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/idea_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/idea_card.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch ideas if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<IdeaProvider>();
      if (provider.ideas.isEmpty) provider.fetchIdeas();
    });
  }

  Color _accentForRole(String role) {
    switch (role) {
      case 'collaborator': return const Color(0xFF10B981);
      case 'investor':     return const Color(0xFFF59E0B);
      default:             return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role ?? 'founder';
    final accent = _accentForRole(role);
    final provider = context.watch<IdeaProvider>();
    final saved = provider.bookmarkedIdeas;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    saved.isEmpty
                        ? 'No bookmarks yet'
                        : '${saved.length} idea${saved.length == 1 ? '' : 's'} saved',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Content
            Expanded(
              child: provider.loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: accent,
                        strokeWidth: 2,
                      ),
                    )
                  : saved.isEmpty
                      ? _EmptyState(accent: accent)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                          itemCount: saved.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => IdeaCard(
                            idea: saved[i],
                            accent: accent,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom bookmark outline icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.bookmark_outline_rounded,
                size: 32,
                color: accent.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nothing saved yet',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the bookmark on any idea\nto save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: Colors.white.withOpacity(0.35),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}