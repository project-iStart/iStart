class NotificationModel {
  final String id;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedIdea;

  NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedIdea,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      relatedIdea: json['relatedIdea'],
    );
  }
}