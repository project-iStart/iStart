// lib/models/discussion_thread.dart

class DiscussionThread {
  final String id;
  final String ideaId;
  final String title;
  final DateTime createdAt;

  DiscussionThread({
    required this.id,
    required this.ideaId,
    required this.title,
    required this.createdAt,
  });

  factory DiscussionThread.fromJson(Map<String, dynamic> json) =>
      DiscussionThread(
        id: json['_id'] ?? '',
        ideaId: json['idea'] ?? '',
        title: json['title'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}