// lib/screens/feed/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/idea_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/idea_card.dart';
import '../post_idea/post_idea_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late TextEditingController _searchController;

  final List<String> _categories = [
    'Tech', 'Health', 'Finance', 'Education', 'Social', 'Other',
  ];

  final List<String> _stages = ['Idea', 'MVP', 'Growth', 'Scaling'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIdeas();
    });
  }

  Future<void> _loadIdeas() async {
    final auth = context.read<AuthProvider>();
    await auth.ready;
    if (!mounted) return;
    await context.read<IdeaProvider>().fetchIdeas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ideas = context.watch<IdeaProvider>().ideas;
    final loading = context.watch<IdeaProvider>().loading;
    final user = context.watch<AuthProvider>().user;
    final role = user?.role ?? 'founder';
    final accent = _accentForRole(role);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            _FeedHeader(accent: accent, role: role),
            _SearchBar(
              controller: _searchController,
              accent: accent,
              onChanged: (query) {
                context.read<IdeaProvider>().setSearchQuery(query);
              },
            ),
            _FilterBar(
              accent: accent,
              categories: _categories,
              stages: _stages,
            ),
            Expanded(
              child: loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: accent,
                        strokeWidth: 2,
                      ),
                    )
                  : ideas.isEmpty
                      ? _EmptyState(accent: accent)
                      : RefreshIndicator(
                          color: accent,
                          backgroundColor: const Color(0xFF161616),
                          onRefresh: _loadIdeas,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: ideas.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) => IdeaCard(
                              idea: ideas[i],
                              accent: accent,
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: role == 'founder'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PostIdeaScreen(),
                  ),
                );
              },
              backgroundColor: accent,
              elevation: 0,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
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

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.accent, required this.role});

  final Color accent;
  final String role;

  @override
  Widget build(BuildContext context) {
    final title = switch (role) {
      'investor' => 'Discover startup ideas',
      'collaborator' => 'Find teams to join',
      _ => 'Explore the feed',
    };

    final subtitle = switch (role) {
      'investor' => 'Track promising founders and funding-ready concepts.',
      'collaborator' => 'Browse ideas where your skills can make an impact.',
      _ => 'See what the community is building right now.',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              height: 1.5,
              color: Colors.white.withOpacity(0.62),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: accent.withOpacity(0.16),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.accent,
    required this.onChanged,
  });

  final TextEditingController controller;
  final Color accent;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'DM Sans',
        ),
        decoration: InputDecoration(
          hintText: 'Search ideas, categories, or keywords',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontFamily: 'DM Sans',
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.45),
          ),
          filled: true,
          fillColor: const Color(0xFF161616),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accent.withOpacity(0.7)),
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.accent,
    required this.categories,
    required this.stages,
  });

  final Color accent;
  final List<String> categories;
  final List<String> stages;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IdeaProvider>();

    return SizedBox(
      height: 108,
      child: Column(
        children: [
          _FilterRow(
            label: 'Category',
            accent: accent,
            selectedValue: provider.selectedCategory,
            options: categories,
            onSelected: (value) {
              provider.setSelectedCategory(
                provider.selectedCategory == value ? null : value,
              );
            },
          ),
          _FilterRow(
            label: 'Stage',
            accent: accent,
            selectedValue: provider.selectedStage,
            options: stages,
            onSelected: (value) {
              provider.setSelectedStage(
                provider.selectedStage == value ? null : value,
              );
            },
            trailing: TextButton(
              onPressed: () {
                provider.clearFilters();
              },
              child: Text(
                'Clear',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.accent,
    required this.selectedValue,
    required this.options,
    required this.onSelected,
    this.trailing,
  });

  final String label;
  final Color accent;
  final String? selectedValue;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.58),
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final option = options[index];
              final selected = selectedValue == option;
              return ChoiceChip(
                label: Text(
                  option,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : Colors.white.withOpacity(0.65),
                  ),
                ),
                selected: selected,
                onSelected: (_) => onSelected(option),
                selectedColor: accent.withOpacity(0.88),
                backgroundColor: const Color(0xFF161616),
                side: BorderSide(
                  color: selected
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.08),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                color: accent,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No ideas found',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search or clear your filters to explore more startup ideas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                height: 1.5,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
