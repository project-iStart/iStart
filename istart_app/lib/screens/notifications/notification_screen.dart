import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/notification_model.dart';
import '../../services/notification_services.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _loading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token == null) {
      setState(() {
        _loading = false;
      });
      // Optionally, show a message or redirect to login
      return;
    }

    try {
      final raw = await _service.getNotifications(_token!);
      setState(() {
        _notifications = raw.map((e) => NotificationModel.fromJson(e)).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(NotificationModel n, int index) async {
    if (n.isRead || _token == null) return;
    await _service.markAsRead(n.id, _token!);
    setState(() {
      _notifications[index] = NotificationModel(
        id: n.id,
        message: n.message,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
        relatedIdea: n.relatedIdea,
      );
    });
  }

  Future<void> _markAllAsRead() async {
    if (_token == null) return;
    await _service.markAllAsRead(_token!);
    setState(() {
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id,
        message: n.message,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
        relatedIdea: n.relatedIdea,
      )).toList();
    });
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'vote': return Icons.thumb_up_alt_rounded;
      case 'feedback': return Icons.chat_bubble_rounded;
      case 'join_request': return Icons.group_add_rounded;
      case 'doc_request': return Icons.description_rounded;
      case 'fund_interest': return Icons.monetization_on_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'vote': return const Color(0xFF6366F1);       // Indigo
      case 'feedback': return const Color(0xFF10B981);   // Emerald
      case 'join_request': return const Color(0xFF6366F1);
      case 'doc_request': return const Color(0xFFF59E0B); // Amber
      case 'fund_interest': return const Color(0xFFF59E0B);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text(
          'Alerts',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : _notifications.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: const Color(0xFF6366F1),
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: Color(0xFF1C1C1C),
                      height: 1,
                    ),
                    itemBuilder: (context, i) {
                      final n = _notifications[i];
                      return _NotificationTile(
                        notification: n,
                        icon: _iconForType(n.type),
                        iconColor: _colorForType(n.type),
                        onTap: () => _markAsRead(n, i),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_rounded, size: 56, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'No alerts yet',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You\'ll be notified about votes,\nfeedback, and team activity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : const Color(0xFF6366F1).withOpacity(0.06),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            // Message + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: notification.isRead ? Colors.grey[400] : Colors.white,
                      fontWeight: notification.isRead
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(notification.createdAt),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Unread dot
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}