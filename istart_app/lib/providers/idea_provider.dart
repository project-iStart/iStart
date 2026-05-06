// lib/providers/idea_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/startup_idea.dart';
import '../services/idea_service.dart';

class IdeaProvider extends ChangeNotifier {
  static const String _bookmarkedIdeaIdsKey = 'bookmarked_idea_ids';
  static const String _votedIdeaIdsKey = 'voted_idea_ids';
  static const String _followedIdeaIdsKey = 'followed_idea_ids';
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
  List<StartupIdea> get followedIdeas =>
      _ideas.where((idea) => idea.isFollowing).toList();
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

  Future<Set<String>> _getStoredBookmarkedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookmarkedIdeaIdsKey)?.toSet() ?? <String>{};
  }

  Future<void> _saveStoredBookmarkedIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bookmarkedIdeaIdsKey, ids.toList());
  }

  Future<Set<String>> _getStoredVotedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_votedIdeaIdsKey)?.toSet() ?? <String>{};
  }

  Future<void> _saveStoredVotedIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_votedIdeaIdsKey, ids.toList());
  }

  Future<Set<String>> _getStoredFollowedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_followedIdeaIdsKey)?.toSet() ?? <String>{};
  }

  Future<void> _saveStoredFollowedIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_followedIdeaIdsKey, ids.toList());
  }

  Future<void> fetchIdeas({
    String? category,
    String? stage,
    String? search,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final storedBookmarkedIds = await _getStoredBookmarkedIds();
      final storedVotedIds = await _getStoredVotedIds();
      final storedFollowedIds = await _getStoredFollowedIds();
      final fetchedIdeas = await _service.getIdeas(
        category: category,
        stage: stage,
        search: search,
      );
      _ideas = fetchedIdeas.map((idea) {
        var updatedIdea = idea;
        // Restore bookmarked status from local storage
        if (storedBookmarkedIds.contains(idea.id) && !idea.isBookmarked) {
          updatedIdea = updatedIdea.copyWith(isBookmarked: true);
        }
        // Restore voted status from local storage
        if (storedVotedIds.contains(idea.id) && !idea.isVoted) {
          updatedIdea = updatedIdea.copyWith(isVoted: true);
        }
        // Restore following status from local storage
        if (storedFollowedIds.contains(idea.id) && !idea.isFollowing) {
          updatedIdea = updatedIdea.copyWith(isFollowing: true);
        }
        return updatedIdea;
      }).toList();
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
      final fetched = await _service.getIdeaById(id);
      final storedBookmarkedIds = await _getStoredBookmarkedIds();
      final storedVotedIds = await _getStoredVotedIds();
      final storedFollowedIds = await _getStoredFollowedIds();
      var syncedIdea = fetched;

      // Restore bookmarked status from local storage
      if (storedBookmarkedIds.contains(fetched.id) && !fetched.isBookmarked) {
        syncedIdea = syncedIdea.copyWith(isBookmarked: true);
      }
      // Restore voted status from local storage
      if (storedVotedIds.contains(fetched.id) && !fetched.isVoted) {
        syncedIdea = syncedIdea.copyWith(isVoted: true);
      }
      // Restore following status from local storage
      if (storedFollowedIds.contains(fetched.id) && !fetched.isFollowing) {
        syncedIdea = syncedIdea.copyWith(isFollowing: true);
      }

      _selectedIdea = syncedIdea;

      final idx = _ideas.indexWhere((idea) => idea.id == id);
      if (idx != -1) {
        _ideas[idx] = syncedIdea;
      }
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
      final result = await _service.toggleBookmark(id);
      final isBookmarked = result['bookmarked'] == true;
      final storedBookmarkedIds = await _getStoredBookmarkedIds();
      if (isBookmarked) {
        storedBookmarkedIds.add(id);
      } else {
        storedBookmarkedIds.remove(id);
      }
      await _saveStoredBookmarkedIds(storedBookmarkedIds);

      final idx = _ideas.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final current = _ideas[idx];
        _ideas[idx] = current.copyWith(isBookmarked: isBookmarked);
      }

      if (_selectedIdea?.id == id) {
        _selectedIdea = _selectedIdea!.copyWith(isBookmarked: isBookmarked);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleVote(String id, [String? currentUserId]) async {
    try {
      final result = await _service.toggleVote(id);
      final isVoted = result['isVoted'] == true;
      final voteCount = result['voteCount'] is int
          ? result['voteCount'] as int
          : int.tryParse('${result['voteCount']}') ?? 0;

      // Update local storage for voted ideas
      final storedVotedIds = await _getStoredVotedIds();
      if (isVoted) {
        storedVotedIds.add(id);
      } else {
        storedVotedIds.remove(id);
      }
      await _saveStoredVotedIds(storedVotedIds);

      final idx = _ideas.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final current = _ideas[idx];
        _ideas[idx] = current.copyWith(isVoted: isVoted, voteCount: voteCount);
      }

      if (_selectedIdea?.id == id) {
        _selectedIdea = _selectedIdea!.copyWith(
          isVoted: isVoted,
          voteCount: voteCount,
        );
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Toggle follow status for an idea (investors tracking ideas)
  Future<void> toggleFollow(String id) async {
    try {
      final result = await _service.toggleFollow(id);
      final isFollowing = result['isFollowing'] == true;

      // Update local storage for followed ideas
      final storedFollowedIds = await _getStoredFollowedIds();
      if (isFollowing) {
        storedFollowedIds.add(id);
      } else {
        storedFollowedIds.remove(id);
      }
      await _saveStoredFollowedIds(storedFollowedIds);

      final idx = _ideas.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final current = _ideas[idx];
        _ideas[idx] = current.copyWith(isFollowing: isFollowing);
      }

      if (_selectedIdea?.id == id) {
        _selectedIdea = _selectedIdea!.copyWith(isFollowing: isFollowing);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
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
