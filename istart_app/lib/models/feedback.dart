// lib/models/feedback.dart

class Feedback {
  final String id;
  final String userId;
  final String ideaId;
  final String category;
  final String comment;
  final int rating;
  final DateTime createdAt;

  Feedback({
    required this.id,
    required this.userId,
    required this.ideaId,
    required this.category,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) => Feedback(
        id: json['_id'] ?? '',
        userId: json['user'] ?? '',
        ideaId: json['idea'] ?? '',
        category: json['category'] ?? '',
        comment: json['comment'] ?? '',
        rating: json['rating'] ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}