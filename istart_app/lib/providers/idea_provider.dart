// lib/providers/idea_provider.dart

import 'package:flutter/material.dart';
import '../models/startup_idea.dart';
import '../services/idea_service.dart';

class IdeaProvider extends ChangeNotifier {
  final IdeaService _service = IdeaService();

  List<StartupIdea> _ideas = [];
  StartupIdea? _selectedIdea;
  bool _loading = false;
  String? _error;

  // Filter state
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedStage;

  List<StartupIdea> get ideas => _filteredIdeas;
  List<StartupIdea> get allIdeas => _ideas;
  List<StartupIdea> get bookmarkedIdeas =>
      _ideas.where((idea) => idea.isBookmarked).toList();
  StartupIdea? get selectedIdea => _selectedIdea;
  bool get loading => _loading;
  String? get error => _error;

  // Filter getters
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedStage => _selectedStage;

  /// Returns filtered list based on current search and filter state
  List<StartupIdea> get _filteredIdeas {
    return _ideas.where((idea) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!idea.title.toLowerCase().contains(query) &&
            !idea.description.toLowerCase().contains(query) &&
            !(idea.category?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && idea.category != _selectedCategory) {
        return false;
      }

      // Stage filter
      if (_selectedStage != null && idea.stage != _selectedStage) {
        return false;
      }

      return true;
    }).toList();
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  /// Update search query and refresh filtered results
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Update selected category filter
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Update selected stage filter
  void setSelectedStage(String? stage) {
    _selectedStage = stage;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedStage = null;
    notifyListeners();
  }

  Future<void> fetchIdeas({
    String? category,
    String? stage,
    String? search,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      _ideas = await _service.getIdeas(
        category: category,
        stage: stage,
        search: search,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchIdeaById(String id) async {
    _setLoading(true);
    _error = null;
    try {
      _selectedIdea = await _service.getIdeaById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createIdea(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _service.createIdea(
        title: data['title'],
        description: data['description'],
      );
      await fetchIdeas();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteIdea(String id) async {
    try {
      await _service.deleteIdea(id);
      _ideas.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleBookmark(String id) async {
    try {
      await _service.toggleBookmark(id);
      final idx = _ideas.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final current = _ideas[idx];
        _ideas[idx] = current.copyWith(isBookmarked: !current.isBookmarked);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleVote(String id, [String? currentUserId]) async {
    try {
      await _service.toggleVote(id);
      final idx = _ideas.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final current = _ideas[idx];
        final isVoted = !current.isVoted;
        _ideas[idx] = current.copyWith(
          isVoted: isVoted,
          voteCount: isVoted ? current.voteCount + 1 : current.voteCount - 1,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fundInterest(String ideaId) async {
    // optimistic update
    final idx = _ideas.indexWhere((i) => i.id == ideaId);
    if (idx == -1) return;

    final old = _ideas[idx];
    _ideas[idx] = old.copyWith(
      hasFundingInterest: true,
      fundingInterestCount: old.fundingInterestCount + 1,
    );
    notifyListeners();

    try {
      await _service.fundInterest(ideaId);
    } catch (e) {
      // rollback
      _ideas[idx] = old;
      notifyListeners();
      rethrow;
    }
  }
}
