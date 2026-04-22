// lib/models/vote.dart

class Vote {
  final String id;
  final String userId;
  final String ideaId;
  final String type; // 'upvote' | 'downvote'

  Vote({
    required this.id,
    required this.userId,
    required this.ideaId,
    required this.type,
  });

  factory Vote.fromJson(Map<String, dynamic> json) => Vote(
        id: json['_id'] ?? '',
        userId: json['user'] ?? '',
        ideaId: json['idea'] ?? '',
        type: json['type'] ?? '',
      );
}