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
  bool _showFilters = false;

  final List<String> _categories = ['Tech', 'Health', 'Finance', 'Education', 'Social', 'Other'];
  final List<String> _stages = ['Idea', 'MVP', 'Growth', 'Scaling'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIdeas());
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

  Color _accentForRole(String role) {
    switch (role) {
      case 'collaborator': return const Color(0xFF10B981);
      case 'investor': return const Color(0xFFF59E0B);
      default: return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ideaProvider = context.watch<IdeaProvider>();
    final ideas = ideaProvider.ideas;
    final loading = ideaProvider.loading;
    final role = context.watch<AuthProvider>().user?.role ?? 'founder';
    final accent = _accentForRole(role);

    final hasActiveFilters = ideaProvider.selectedCategory != null ||
        ideaProvider.selectedStage != null ||
        ideaProvider.searchQuery.isNotEmpty;

    final activeFilterCount = [
      ideaProvider.selectedCategory,
      ideaProvider.selectedStage,
    ].where((f) => f != null).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _FeedHeader(accent: accent, role: role),

            // Search + Filter toggle row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  // Search bar
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (q) => context.read<IdeaProvider>().setSearchQuery(q),
                        cursorColor: accent,
                        style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search ideas...',
                          hintStyle: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: Colors.white.withOpacity(0.35)),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.35)),
                          suffixIcon: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _searchController,
                            builder: (_, value, __) => value.text.isEmpty
                                ? const SizedBox.shrink()
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<IdeaProvider>().setSearchQuery('');
                                    },
                                    icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.45)),
                                  ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Filter toggle button
                  GestureDetector(
                    onTap: () => setState(() => _showFilters = !_showFilters),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: _showFilters || activeFilterCount > 0
                            ? accent.withOpacity(0.15)
                            : const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _showFilters || activeFilterCount > 0
                              ? accent.withOpacity(0.6)
                              : Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: _showFilters || activeFilterCount > 0
                                ? accent
                                : Colors.white.withOpacity(0.45),
                            size: 20,
                          ),
                          if (activeFilterCount > 0)
                            Positioned(
                              top: -6,
                              right: -6,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$activeFilterCount',
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Collapsible filter panel
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: _showFilters
                  ? _FilterPanel(
                      accent: accent,
                      categories: _categories,
                      stages: _stages,
                    )
                  : const SizedBox.shrink(),
            ),

            // Result count + clear filters row
            if (hasActiveFilters)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: Row(
                  children: [
                    Text(
                      '${ideas.length} result${ideas.length == 1 ? '' : 's'} found',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.45),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        context.read<IdeaProvider>().clearFilters();
                        setState(() => _showFilters = false);
                      },
                      child: Text(
                        'Clear all',
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
              ),

            // Feed list
            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator(color: accent, strokeWidth: 2))
                  : ideas.isEmpty
                      ? _EmptyState(accent: accent, isFiltered: hasActiveFilters)
                      : RefreshIndicator(
                          color: accent,
                          backgroundColor: const Color(0xFF161616),
                          onRefresh: _loadIdeas,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: ideas.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) => IdeaCard(idea: ideas[i], accent: accent),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: role == 'founder'
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostIdeaScreen()),
              ),
              backgroundColor: accent,
              elevation: 0,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

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
                const Text('iStart',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.6)),
                Text('Explore startup ideas',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.4))),
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
              style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w600, color: accent),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Panel ─────────────────────────────────────────────────────────────

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.accent, required this.categories, required this.stages});
  final Color accent;
  final List<String> categories;
  final List<String> stages;

  @override
  Widget build(BuildContext context) {
    final ip = context.watch<IdeaProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Text('Category',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.4))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final selected = ip.selectedCategory == cat;
                return _FilterChip(
                  label: cat,
                  accent: accent,
                  selected: selected,
                  onTap: () => context.read<IdeaProvider>().setSelectedCategory(selected ? null : cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Stage
            Text('Stage',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.4))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stages.map((stage) {
                final selected = ip.selectedStage == stage;
                return _FilterChip(
                  label: stage,
                  accent: accent,
                  selected: selected,
                  onTap: () => context.read<IdeaProvider>().setSelectedStage(selected ? null : stage),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.accent, required this.selected, required this.onTap});
  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.18) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accent.withOpacity(0.7) : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? accent : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.accent, required this.isFiltered});
  final Color accent;
  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFiltered ? Icons.search_off_rounded : Icons.lightbulb_outline_rounded,
            size: 48,
            color: accent.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No results found' : 'No ideas yet',
            style: const TextStyle(
                fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered ? 'Try adjusting your search or filters.' : 'Be the first to post a startup idea.',
            style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: Colors.white.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }
}