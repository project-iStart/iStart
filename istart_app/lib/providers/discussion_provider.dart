import 'package:flutter/material.dart';
import '../models/discussion_thread.dart';
import '../models/message.dart';
import '../services/discussion_service.dart';

class DiscussionProvider extends ChangeNotifier {
  final DiscussionService _service = DiscussionService();

  List<DiscussionThread> _threads = [];
  DiscussionThread? _selectedThread;
  List<Message> _messages = [];
  bool _loading = false;
  String? _error;

  List<DiscussionThread> get threads => _threads;
  DiscussionThread? get selectedThread => _selectedThread;
  List<Message> get messages => _messages;
  bool get loading => _loading;
  String? get error => _error;

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  /// Create a new discussion thread
  Future<bool> createThread({
    required String ideaId,
    required String title,
    List<String>? participants,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final raw = await _service.createThread(
        ideaId: ideaId,
        title: title,
        participants: participants,
      );
      final newThread = DiscussionThread.fromJson(raw);
      _threads.add(newThread);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch threads for an idea
  Future<void> fetchThreadsForIdea(String ideaId) async {
    _setLoading(true);
    _error = null;
    try {
      final data = await _service.getThreadsForIdea(ideaId);
      _threads = (data)
          .map((e) => DiscussionThread.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Select a thread and fetch its messages
  Future<void> selectThread(DiscussionThread thread) async {
    _selectedThread = thread;
    await fetchMessages(thread.id);
  }

  /// Fetch messages for a thread
  Future<void> fetchMessages(String threadId) async {
    _setLoading(true);
    _error = null;
    try {
      final data = await _service.getMessages(threadId);
      _messages = (data)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
      // Sort by creation time (oldest first)
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Post a message to a thread
  Future<bool> postMessage({
    required String threadId,
    required String content,
    List<Map<String, dynamic>>? attachments,
  }) async {
    try {
      final data = await _service.postMessage(
        threadId: threadId,
        content: content,
        attachments: attachments,
      );
      final newMessage = Message.fromJson(data);
      _messages.add(newMessage);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
