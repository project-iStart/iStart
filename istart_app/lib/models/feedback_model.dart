class FeedbackModel {
  final String id;
  final String ideaId;
  final String userId;
  final String category;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.ideaId,
    required this.userId,
    required this.category,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['_id'] ?? '',
      ideaId: json['startupIdea'] is Map
          ? json['startupIdea']['_id'] ?? ''
          : json['startupIdea'] ?? '',
      userId:
          json['user'] is Map ? json['user']['_id'] ?? '' : json['user'] ?? '',
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
