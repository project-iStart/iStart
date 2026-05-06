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
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedStage => _selectedStage;

  List<StartupIdea> get _filteredIdeas {
    return _ideas.where((idea) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesSearch =
            idea.title.toLowerCase().contains(query) ||
            idea.description.toLowerCase().contains(query) ||
            (idea.category?.toLowerCase().contains(query) ?? false);
        if (!matchesSearch) return false;
      }

      if (_selectedCategory != null && idea.category != _selectedCategory) {
        return false;
      }

      if (_selectedStage != null && idea.stage != _selectedStage) {
        return false;
      }

      return true;
    }).toList();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedStage(String? stage) {
    _selectedStage = stage;
    notifyListeners();
  }

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

  StartupIdea _applyStoredFlags(
    StartupIdea idea, {
    required Set<String> bookmarkedIds,
    required Set<String> votedIds,
    required Set<String> followedIds,
  }) {
    return idea.copyWith(
      isBookmarked: idea.isBookmarked || bookmarkedIds.contains(idea.id),
      isVoted: idea.isVoted || votedIds.contains(idea.id),
      isFollowing: idea.isFollowing || followedIds.contains(idea.id),
    );
  }

  Future<void> fetchIdeas({
    String? category,
    String? stage,
    String? search,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final bookmarkedIds = await _getStoredBookmarkedIds();
      final votedIds = await _getStoredVotedIds();
      final followedIds = await _getStoredFollowedIds();
      final fetchedIdeas = await _service.fetchIdeas(
        category: category,
        stage: stage,
        search: search,
      );

      _ideas = fetchedIdeas
          .map(
            (idea) => _applyStoredFlags(
              idea,
              bookmarkedIds: bookmarkedIds,
              votedIds: votedIds,
              followedIds: followedIds,
            ),
          )
          .toList();
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
      final fetchedIdea = await _service.getIdeaById(id);
      final syncedIdea = _applyStoredFlags(
        fetchedIdea,
        bookmarkedIds: await _getStoredBookmarkedIds(),
        votedIds: await _getStoredVotedIds(),
        followedIds: await _getStoredFollowedIds(),
      );

      _selectedIdea = syncedIdea;

      final index = _ideas.indexWhere((idea) => idea.id == id);
      if (index != -1) {
        _ideas[index] = syncedIdea;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createIdea({
    required String title,
    required String description,
    String? problemStatement,
    String? category,
    String? stage,
  }) async {
    final idea = await _service.createIdea(
      title: title,
      description: description,
      problemStatement: problemStatement,
      category: category,
      stage: stage,
    );

    _ideas.insert(0, idea);
    notifyListeners();
  }

  Future<void> updateIdea({
    required String ideaId,
    required String title,
    required String description,
    String? problemStatement,
    String? category,
    String? stage,
  }) async {
    final updatedIdea = await _service.updateIdea(
      ideaId: ideaId,
      title: title,
      description: description,
      problemStatement: problemStatement,
      category: category,
      stage: stage,
    );

    final bookmarkedIds = await _getStoredBookmarkedIds();
    final votedIds = await _getStoredVotedIds();
    final followedIds = await _getStoredFollowedIds();
    final syncedIdea = _applyStoredFlags(
      updatedIdea,
      bookmarkedIds: bookmarkedIds,
      votedIds: votedIds,
      followedIds: followedIds,
    );

    final index = _ideas.indexWhere((idea) => idea.id == ideaId);
    if (index != -1) {
      _ideas[index] = syncedIdea;
    }
    if (_selectedIdea?.id == ideaId) {
      _selectedIdea = syncedIdea;
    }
    notifyListeners();
  }

  Future<bool> deleteIdea(String ideaId) async {
    try {
      await _service.deleteIdea(ideaId);
      _ideas.removeWhere((idea) => idea.id == ideaId);
      if (_selectedIdea?.id == ideaId) {
        _selectedIdea = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleBookmark(String ideaId) async {
    try {
      final result = await _service.toggleBookmark(ideaId);
      final isBookmarked = result['bookmarked'] == true;

      final storedIds = await _getStoredBookmarkedIds();
      if (isBookmarked) {
        storedIds.add(ideaId);
      } else {
        storedIds.remove(ideaId);
      }
      await _saveStoredBookmarkedIds(storedIds);

      final index = _ideas.indexWhere((idea) => idea.id == ideaId);
      if (index != -1) {
        _ideas[index] = _ideas[index].copyWith(isBookmarked: isBookmarked);
      }
      if (_selectedIdea?.id == ideaId) {
        _selectedIdea = _selectedIdea!.copyWith(isBookmarked: isBookmarked);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleVote(String ideaId, [String? currentUserId]) async {
    final index = _ideas.indexWhere((idea) => idea.id == ideaId);
    if (index != -1 && currentUserId != null) {
      final founderId = _ideas[index].founder['_id']?.toString();
      if (founderId == currentUserId) {
        return;
      }
    }

    try {
      final result = await _service.toggleVote(ideaId);
      final isVoted = result['isVoted'] == true;
      final voteCount = result['voteCount'] is int
          ? result['voteCount'] as int
          : int.tryParse('${result['voteCount']}') ?? 0;

      final storedIds = await _getStoredVotedIds();
      if (isVoted) {
        storedIds.add(ideaId);
      } else {
        storedIds.remove(ideaId);
      }
      await _saveStoredVotedIds(storedIds);

      if (index != -1) {
        _ideas[index] = _ideas[index].copyWith(
          isVoted: isVoted,
          voteCount: voteCount,
        );
      }
      if (_selectedIdea?.id == ideaId) {
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

  Future<void> toggleFollow(String ideaId) async {
    try {
      final storedIds = await _getStoredFollowedIds();
      final isFollowing = !storedIds.contains(ideaId);

      if (isFollowing) {
        storedIds.add(ideaId);
      } else {
        storedIds.remove(ideaId);
      }
      await _saveStoredFollowedIds(storedIds);

      final index = _ideas.indexWhere((idea) => idea.id == ideaId);
      if (index != -1) {
        _ideas[index] = _ideas[index].copyWith(isFollowing: isFollowing);
      }
      if (_selectedIdea?.id == ideaId) {
        _selectedIdea = _selectedIdea!.copyWith(isFollowing: isFollowing);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fundInterest(String ideaId) async {
    final index = _ideas.indexWhere((idea) => idea.id == ideaId);
    if (index == -1) return;

    final previousIdea = _ideas[index];
    _ideas[index] = previousIdea.copyWith(
      hasFundingInterest: true,
      fundingInterestCount: previousIdea.fundingInterestCount + 1,
    );
    if (_selectedIdea?.id == ideaId) {
      _selectedIdea = _selectedIdea!.copyWith(
        hasFundingInterest: true,
        fundingInterestCount: _selectedIdea!.fundingInterestCount + 1,
      );
    }
    notifyListeners();

    try {
      final result = await _service.fundInterest(ideaId);
      final fundingInterestCount = result['fundingInterestCount'] is int
          ? result['fundingInterestCount'] as int
          : int.tryParse('${result['fundingInterestCount']}') ??
              _ideas[index].fundingInterestCount;
      final hasFundingInterest = result['hasFundingInterest'] == true;

      _ideas[index] = _ideas[index].copyWith(
        hasFundingInterest: hasFundingInterest,
        fundingInterestCount: fundingInterestCount,
      );
      if (_selectedIdea?.id == ideaId) {
        _selectedIdea = _selectedIdea!.copyWith(
          hasFundingInterest: hasFundingInterest,
          fundingInterestCount: fundingInterestCount,
        );
      }
      notifyListeners();
    } catch (e) {
      _ideas[index] = previousIdea;
      if (_selectedIdea?.id == ideaId) {
        _selectedIdea = previousIdea;
      }
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
