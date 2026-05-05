// lib/screens/feed/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/idea_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/idea_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late TextEditingController _searchController;

  final List<String> _categories = [
    'Technology',
    'Healthcare',
    'Finance',
    'Education',
    'E-commerce',
    'Sustainability',
  ];

  final List<String> _stages = [
    'Idea',
    'MVP',
    'Launched',
    'Growth',
    'Series A',
  ];

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
      // Only founders see the FAB to post an idea
      floatingActionButton: role == 'founder'
          ? FloatingActionButton(
              onPressed: () {
                // context.go('/post-idea') ← wire when screen is ready
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
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
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
            color: accent.withOpacity(0.4),
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
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatefulWidget {
  const _SearchBar({
    required this.controller,
    required this.accent,
    required this.onChanged,
  });

  final TextEditingController controller;
  final Color accent;
  final Function(String) onChanged;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateUI);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: 'Search ideas...',
          hintStyle: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Colors.white.withOpacity(0.3),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.3),
            size: 20,
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withOpacity(0.3),
                    size: 18,
                  ),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF161616),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.07),
              width: 0.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.07),
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.accent, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

// ─── Filter Bar ────────────────────────────────────────────────────────────────

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
    final selectedCategory = context.watch<IdeaProvider>().selectedCategory;
    final selectedStage = context.watch<IdeaProvider>().selectedStage;

    return Column(
      children: [
        // Category filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.read<IdeaProvider>().setSelectedCategory(null);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selectedCategory == null
                        ? accent
                        : const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.07),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'All Categories',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selectedCategory == null
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ...categories.map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      context.read<IdeaProvider>().setSelectedCategory(
                        isSelected ? null : category,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accent.withOpacity(0.2)
                            : const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? accent
                              : Colors.white.withOpacity(0.07),
                          width: isSelected ? 1 : 0.5,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? accent
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        // Stage filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.read<IdeaProvider>().setSelectedStage(null);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selectedStage == null
                        ? accent
                        : const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.07),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'All Stages',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selectedStage == null
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ...stages.map((stage) {
                final isSelected = selectedStage == stage;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      context.read<IdeaProvider>().setSelectedStage(
                        isSelected ? null : stage,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accent.withOpacity(0.2)
                            : const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? accent
                              : Colors.white.withOpacity(0.07),
                          width: isSelected ? 1 : 0.5,
                        ),
                      ),
                      child: Text(
                        stage,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? accent
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
