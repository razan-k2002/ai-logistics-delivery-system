import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Driver Assigned!',
      'message': 'Ali Hassan has been assigned to your delivery #DEL001',
      'time': '5 mins ago',
      'icon': Icons.person,
      'color': Colors.blue,
      'isRead': false,
    },
    {
      'title': 'Package Picked Up',
      'message': 'Your package has been picked up and is on the way!',
      'time': '20 mins ago',
      'icon': Icons.inventory,
      'color': Colors.orange,
      'isRead': false,
    },
    {
      'title': 'Delivery In Transit',
      'message': 'Your delivery #DEL001 is now in transit. ETA: 25 mins',
      'time': '25 mins ago',
      'icon': Icons.local_shipping,
      'color': Colors.purple,
      'isRead': true,
    },
    {
      'title': 'Delivery Completed!',
      'message': 'Your delivery #DEL002 has been delivered successfully!',
      'time': '1 hour ago',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'isRead': true,
    },
    {
      'title': 'Route Optimized',
      'message': 'AI has optimized the route for faster delivery',
      'time': '2 hours ago',
      'icon': Icons.route,
      'color': Colors.teal,
      'isRead': true,
    },
    {
      'title': 'New Delivery Request',
      'message': 'You have a new delivery request #DEL003 assigned to you',
      'time': '3 hours ago',
      'icon': Icons.add_circle,
      'color': Colors.orange,
      'isRead': true,
    },
  ];

  void _markAllRead() {
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
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

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
      body: Column(
        children: [
          // Unread count banner
          if (unreadCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.orange.withOpacity(0.1),
              child: Text(
                'You have $unreadCount unread notifications',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Notifications List
          Expanded(
            child: _notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(color: Colors.grey),
                        ),
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
                                : Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: notification['isRead']
                                  ? Colors.transparent
                                  : Colors.orange.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: notification['color'].withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  notification['icon'],
                                  color: notification['color'],
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          notification['title'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: notification['isRead']
                                                ? Colors.black
                                                : Colors.orange,
                                          ),
                                        ),
                                        if (!notification['isRead'])
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
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
