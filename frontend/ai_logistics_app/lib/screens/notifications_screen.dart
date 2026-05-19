import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() async {
    final result = await ApiService.getNotifications();
    if (!result['success']) {
      setState(() => _isLoading = false);
      return;
    }

    final data = result['data']['notifications'] as List;
    setState(() {
      _notifications = data.map((n) => {
        'id': n['id'],
        'title': n['title'] ?? 'Notification',
        'message': n['message'] ?? '',
        'time': n['created_at'].toString().substring(0, 10),
        'icon': _getIcon(n['title'] ?? ''),
        'color': _getColor(n['title'] ?? ''),
        'isRead': n['is_read'] ?? false,
      }).toList();
      _isLoading = false;
    });
  }

  IconData _getIcon(String title) {
    if (title.contains('Driver')) return Icons.person;
    if (title.contains('Completed')) return Icons.check_circle;
    if (title.contains('Cancelled')) return Icons.cancel;
    if (title.contains('Transit')) return Icons.local_shipping;
    return Icons.notifications;
  }

  Color _getColor(String title) {
    if (title.contains('Driver')) return Colors.blue;
    if (title.contains('Completed')) return Colors.green;
    if (title.contains('Cancelled')) return Colors.red;
    if (title.contains('Transit')) return Colors.purple;
    return Colors.orange;
  }

  void _markAllRead() async {
    await ApiService.markAllNotificationsRead();
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        _notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Colors.orange))
          : Column(
        children: [
          if (unreadCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              color: Colors.orange.withValues(alpha: 0.1),
              child: Text(
                'You have $unreadCount unread notifications',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: _notifications.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off,
                      size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications yet',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      notification['isRead'] = true;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: notification['isRead']
                          ? Colors.white
                          : Colors.orange
                          .withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: notification['isRead']
                            ? Colors.transparent
                            : Colors.orange
                            .withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.grey.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: notification['color']
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            notification['icon'],
                            color: notification['color'],
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: notification['isRead']
                                            ? Colors.black
                                            : Colors.orange,
                                      ),
                                    ),
                                  ),
                                  if (!notification['isRead'])
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration:
                                      const BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification['message'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notification['time'],
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}