import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Sarah Johnson',
      'email': 'sarah@email.com',
      'role': 'customer',
      'status': 'Active',
    },
    {
      'name': 'Ali Hassan',
      'email': 'ali@email.com',
      'role': 'driver',
      'status': 'Active',
    },
    {
      'name': 'Emma Davis',
      'email': 'emma@email.com',
      'role': 'customer',
      'status': 'Active',
    },
    {
      'name': 'Mike Smith',
      'email': 'mike@email.com',
      'role': 'driver',
      'status': 'Inactive',
    },
  ];

  final List<Map<String, dynamic>> _deliveries = [
    {
      'id': '#DEL001',
      'customer': 'Sarah Johnson',
      'driver': 'Ali Hassan',
      'status': 'In Transit',
      'statusColor': Colors.blue,
      'pickup': '123 Main St',
      'dropoff': '456 Oak Ave',
    },
    {
      'id': '#DEL002',
      'customer': 'Emma Davis',
      'driver': 'Unassigned',
      'status': 'Pending',
      'statusColor': Colors.orange,
      'pickup': '789 Pine Rd',
      'dropoff': '321 Elm St',
    },
    {
      'id': '#DEL003',
      'customer': 'John Lee',
      'driver': 'Mike Smith',
      'status': 'Delivered',
      'statusColor': Colors.green,
      'pickup': '555 Maple Dr',
      'dropoff': '888 Cedar Ln',
    },
    {
      'id': '#DEL004',
      'customer': 'Anna White',
      'driver': 'Unassigned',
      'status': 'Pending',
      'statusColor': Colors.orange,
      'pickup': '222 Oak St',
      'dropoff': '999 Pine Ave',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildDashboard()
          : _selectedIndex == 1
          ? _buildUsers()
          : _buildDeliveries(),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Deliveries',
          ),
        ],
      ),
    );
  }

  // Dashboard Tab
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Admin 👋',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'AI Logistics System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stats Grid
          const Text(
            'System Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                title: 'Total Users',
                value: '24',
                icon: Icons.people,
                color: Colors.blue,
              ),
              _StatCard(
                title: 'Active Drivers',
                value: '8',
                icon: Icons.drive_eta,
                color: Colors.green,
              ),
              _StatCard(
                title: 'Total Deliveries',
                value: '156',
                icon: Icons.local_shipping,
                color: Colors.orange,
              ),
              _StatCard(
                title: 'Pending',
                value: '12',
                icon: Icons.pending,
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _ActivityItem(
            icon: Icons.person_add,
            color: Colors.blue,
            title: 'New user registered',
            subtitle: 'Sarah Johnson joined as customer',
            time: '5 mins ago',
          ),
          _ActivityItem(
            icon: Icons.local_shipping,
            color: Colors.orange,
            title: 'New delivery request',
            subtitle: 'DEL004 - Waiting for driver assignment',
            time: '12 mins ago',
          ),
          _ActivityItem(
            icon: Icons.check_circle,
            color: Colors.green,
            title: 'Delivery completed',
            subtitle: 'DEL003 delivered successfully',
            time: '30 mins ago',
          ),
          _ActivityItem(
            icon: Icons.route,
            color: Colors.purple,
            title: 'Route optimized by AI',
            subtitle: 'DEL001 route updated for faster delivery',
            time: '45 mins ago',
          ),
        ],
      ),
    );
  }

  // Users Tab
  Widget _buildUsers() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          ..._users.map((user) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: user['role'] == 'driver'
                        ? Colors.blue
                        : Colors.orange,
                    child: Icon(
                      user['role'] == 'driver' ? Icons.drive_eta : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user['email'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: user['role'] == 'driver'
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                user['role'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: user['role'] == 'driver'
                                      ? Colors.blue
                                      : Colors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: user['status'] == 'Active'
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                user['status'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: user['status'] == 'Active'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Text('View Profile'),
                      ),
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: Text('Deactivate'),
                      ),
                    ],
                    onSelected: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$value - ${user['name']}')),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Deliveries Tab
  Widget _buildDeliveries() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search deliveries...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          ..._deliveries.map((delivery) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        delivery['id'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: delivery['statusColor'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          delivery['status'],
                          style: TextStyle(
                            color: delivery['statusColor'],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Customer: ${delivery['customer']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.drive_eta, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Driver: ${delivery['driver']}',
                        style: TextStyle(
                          color: delivery['driver'] == 'Unassigned'
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          delivery['pickup'],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          delivery['dropoff'],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  if (delivery['driver'] == 'Unassigned') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showAssignDriver(delivery['id']);
                        },
                        icon: const Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: const Text(
                          'Assign Driver',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAssignDriver(String deliveryId) {
    final drivers = _users.where((user) => user['role'] == 'driver').toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign Driver to $deliveryId',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...drivers.map((driver) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${driver['name']} assigned to $deliveryId',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.drive_eta,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              driver['status'],
                              style: TextStyle(
                                color: driver['status'] == 'Active'
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// Stat Card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

// Activity Item
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}
