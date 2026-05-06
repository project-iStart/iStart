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
    'Tech',
    'Health',
    'Finance',
    'Education',
    'Social',
    'Other',
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
    final ideaProvider = context.watch<IdeaProvider>();
    final ideas = ideaProvider.ideas;
    final loading = ideaProvider.loading;

    final user = context.watch<AuthProvider>().user;
    final role = user?.role ?? 'founder';
    final accent = _accentForRole(role);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      resizeToAvoidBottomInset: true, // helps with keyboard overflow
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

            // THIS Expanded ensures no overflow happens
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
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) =>
                            IdeaCard(idea: ideas[i], accent: accent),
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
                  MaterialPageRoute(builder: (_) => const PostIdeaScreen()),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'iStart',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
                Text(
                  'Explore startup ideas',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role[0].toUpperCase() + role.substring(1),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          cursorColor: accent,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Search ideas, problems, categories...',
            hintStyle: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.35),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.35),
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();

                return IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                );
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
    final ideaProvider = context.watch<IdeaProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          _FilterRow(
            title: 'Category',
            accent: accent,
            options: categories,
            selectedValue: ideaProvider.selectedCategory,
            onSelected: context.read<IdeaProvider>().setSelectedCategory,
          ),
          const SizedBox(height: 8),
          _FilterRow(
            title: 'Stage',
            accent: accent,
            options: stages,
            selectedValue: ideaProvider.selectedStage,
            onSelected: context.read<IdeaProvider>().setSelectedStage,
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.title,
    required this.accent,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final String title;
  final Color accent;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _FilterPill(
              label: title,
              accent: accent,
              selected: selectedValue == null,
              onTap: () => onSelected(null),
            );
          }

          final option = options[index - 1];
          return _FilterPill(
            label: option,
            accent: accent,
            selected: selectedValue == option,
            onTap: () => onSelected(selectedValue == option ? null : option),
          );
        },
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.18)
              : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? accent : Colors.white.withValues(alpha: 0.52),
          ),
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
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 48,
            color: accent.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'No ideas yet',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to post a startup idea.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
