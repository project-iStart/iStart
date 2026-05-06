// lib/models/discussion_thread.dart

class DiscussionThread {
  final String id;
  final String ideaId;
  final String title;
  final DateTime createdAt;
  final List<String> participants;

  DiscussionThread({
    required this.id,
    required this.ideaId,
    required this.title,
    required this.createdAt,
    this.participants = const [],
  });

  factory DiscussionThread.fromJson(Map<String, dynamic> json) =>
      DiscussionThread(
        id: json['_id'] ?? '',
        ideaId:
            json['startupIdea'] ?? json['idea'] ?? json['startupIdeaId'] ?? '',
        title: json['title'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        participants:
            (json['participants'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}
