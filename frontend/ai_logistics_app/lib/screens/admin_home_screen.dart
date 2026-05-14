import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  Map<String, dynamic> _stats = {
    'total_deliveries': '0',
    'pending': '0',
    'in_progress': '0',
    'delivered': '0',
    'cancelled': '0',
    'available_drivers': '0',
    'total_customers': '0',
  };
  bool _loadingStats = true;

  List<Map<String, dynamic>> _deliveries = [];
  bool _loadingDeliveries = true;

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

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadDeliveries();
  }

  void _loadStats() async {
    final result = await ApiService.getAdminDashboard();
    if (result['success']) {
      setState(() {
        _stats = result['data']['stats'];
        _loadingStats = false;
      });
    } else {
      setState(() => _loadingStats = false);
    }
  }

  void _loadDeliveries() async {
    // We'll use a list of recent delivery IDs to fetch
    // For now fetch deliveries 1-10 and filter valid ones
    List<Map<String, dynamic>> loaded = [];
    for (int i = 1; i <= 15; i++) {
      final result = await ApiService.getDelivery(i);
      if (result['success'] && result['data'] != null) {
        loaded.add(result['data']);
      }
    }
    setState(() {
      _deliveries = loaded;
      _loadingDeliveries = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'In Transit';
      case 'pending':
        return 'Pending';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

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

          _loadingStats
              ? const Center(child: CircularProgressIndicator(color: Colors.orange))
              : GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                title: 'Total Customers',
                value: _stats['total_customers'].toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
              _StatCard(
                title: 'Available Drivers',
                value: _stats['available_drivers'].toString(),
                icon: Icons.drive_eta,
                color: Colors.green,
              ),
              _StatCard(
                title: 'Total Deliveries',
                value: _stats['total_deliveries'].toString(),
                icon: Icons.local_shipping,
                color: Colors.orange,
              ),
              _StatCard(
                title: 'Pending',
                value: _stats['pending'].toString(),
                icon: Icons.pending,
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Summary Row
          if (!_loadingStats) ...[
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'In Progress',
                    value: _stats['in_progress'].toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Delivered',
                    value: _stats['delivered'].toString(),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Cancelled',
                    value: _stats['cancelled'].toString(),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

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
            subtitle: 'A new customer joined the system',
            time: 'Recent',
          ),
          _ActivityItem(
            icon: Icons.local_shipping,
            color: Colors.orange,
            title: 'New delivery request',
            subtitle: 'Waiting for driver assignment',
            time: 'Recent',
          ),
          _ActivityItem(
            icon: Icons.check_circle,
            color: Colors.green,
            title: 'Delivery completed',
            subtitle: 'Package delivered successfully',
            time: 'Recent',
          ),
          _ActivityItem(
            icon: Icons.route,
            color: Colors.purple,
            title: 'Route optimized by AI',
            subtitle: 'Route updated for faster delivery',
            time: 'Recent',
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
                    backgroundColor:
                    user['role'] == 'driver' ? Colors.blue : Colors.orange,
                    child: Icon(
                      user['role'] == 'driver'
                          ? Icons.drive_eta
                          : Icons.person,
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
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
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
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
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
    if (_loadingDeliveries) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    if (_deliveries.isEmpty) {
      return const Center(child: Text('No deliveries found.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            final status = delivery['status'] ?? 'pending';
            final driverId = delivery['driver_id'];

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
                        '#DEL${delivery['id'].toString().padLeft(3, '0')}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(status),
                          style: TextStyle(
                            color: _statusColor(status),
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
                      const Icon(Icons.drive_eta, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        driverId != null
                            ? 'Driver ID: $driverId'
                            : 'Unassigned',
                        style: TextStyle(
                          color:
                          driverId != null ? Colors.grey : Colors.red,
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
                          delivery['pickup_location'] ?? '',
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
                          delivery['delivery_location'] ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  if (driverId == null && status == 'pending') ...[
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

  void _showAssignDriver(int deliveryId) {
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
                'Assign Driver to #DEL${deliveryId.toString().padLeft(3, '0')}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...drivers.map((driver) {
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    // For now using driver index as ID — will be replaced with real driver IDs
                    final result = await ApiService.assignDriver(deliveryId, 1);
                    if (result['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${driver['name']} assigned successfully!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadDeliveries(); // Refresh list
                      _loadStats(); // Refresh stats
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message'] ?? 'Failed to assign driver'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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

// Summary Card
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
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
              color: color.withValues(alpha: 0.1),
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