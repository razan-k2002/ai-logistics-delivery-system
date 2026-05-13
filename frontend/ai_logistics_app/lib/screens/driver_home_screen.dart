import 'package:flutter/material.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isAvailable = true;

  final List<Map<String, dynamic>> _assignedDeliveries = [
    {
      'id': '#DEL001',
      'customer': 'Sarah Johnson',
      'pickup': '123 Main St',
      'dropoff': '456 Oak Ave',
      'status': 'Pending',
      'statusColor': Colors.orange,
      'distance': '3.2 km',
      'eta': '15 mins',
    },
    {
      'id': '#DEL002',
      'customer': 'Mike Smith',
      'pickup': '789 Pine Rd',
      'dropoff': '321 Elm St',
      'status': 'In Transit',
      'statusColor': Colors.blue,
      'distance': '5.8 km',
      'eta': '25 mins',
    },
    {
      'id': '#DEL003',
      'customer': 'Emma Davis',
      'pickup': '555 Maple Dr',
      'dropoff': '888 Cedar Ln',
      'status': 'Assigned',
      'statusColor': Colors.purple,
      'distance': '2.1 km',
      'eta': '10 mins',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Driver Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Availability Toggle Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isAvailable ? Colors.orange : Colors.grey[400],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Availability Status',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        _isAvailable ? 'You are Online' : 'You are Offline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isAvailable,
                    onChanged: (value) {
                      setState(() => _isAvailable = value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'You are now Online!'
                                : 'You are now Offline!',
                          ),
                          backgroundColor: value ? Colors.green : Colors.grey,
                        ),
                      );
                    },
                    activeThumbColor: Colors.white,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Today\'s\nDeliveries',
                    value: '5',
                    icon: Icons.local_shipping,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Completed\nToday',
                    value: '3',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Rating',
                    value: '4.8',
                    icon: Icons.star,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Assigned Deliveries
            const Text(
              'Assigned Deliveries',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ..._assignedDeliveries.map((delivery) {
              return _DeliveryCard(
                delivery: delivery,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/delivery-details',
                  arguments: delivery,
                ),
              );
            }),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Stat Card Widget
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Delivery Card Widget
class _DeliveryCard extends StatelessWidget {
  final Map<String, dynamic> delivery;
  final VoidCallback onTap;

  const _DeliveryCard({required this.delivery, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                const Icon(Icons.person, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  delivery['customer'],
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 12),
                const SizedBox(width: 8),
                Expanded(child: Text(delivery['pickup'])),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 12),
                const SizedBox(width: 8),
                Expanded(child: Text(delivery['dropoff'])),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.route, color: Colors.orange, size: 14),
                const SizedBox(width: 4),
                Text(
                  delivery['distance'],
                  style: const TextStyle(color: Colors.orange),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, color: Colors.orange, size: 14),
                const SizedBox(width: 4),
                Text(
                  delivery['eta'],
                  style: const TextStyle(color: Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
