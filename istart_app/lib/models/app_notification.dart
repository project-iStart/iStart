class AppNotification {
  final String id;
  final String message;
  final String type;
  final bool read;

  AppNotification({
    required this.id,
    required this.message,
    required this.type,
    required this.read,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['_id'],
    message: json['message'],
    type: json['type'],
    read: json['read'] ?? false,
  );
}