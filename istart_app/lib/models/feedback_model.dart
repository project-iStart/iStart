class FeedbackModel {
  final String id;
  final String ideaId;
  final String userId;
  final String? userName;   // ← add
  final String category;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.ideaId,
    required this.userId,
    this.userName,           // ← add
    required this.category,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return FeedbackModel(
      id: json['_id'] ?? '',
      ideaId: json['startupIdea'] is Map
          ? json['startupIdea']['_id'] ?? ''
          : json['startupIdea'] ?? '',
      userId: user is Map ? user['_id'] ?? '' : user ?? '',
      userName: user is Map ? user['name'] : null,   // ← add
      category: json['category'] ?? '',
      rating: json['rating'] ?? 1,
      comment: json['comment'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

const List<String> kFeedbackCategories = [
  'Market Viability',
  'Team Strength',
  'Innovation',
  'Execution Plan',
  'Scalability',
];