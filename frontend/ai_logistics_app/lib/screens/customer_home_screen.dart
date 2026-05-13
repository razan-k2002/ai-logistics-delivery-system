import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'AI Logistics Delivery',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
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
                    'Welcome back! 👋',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Where to deliver today?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.add_circle_outline,
                    label: 'New Delivery',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(context, '/create-delivery');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.track_changes,
                    label: 'Track Delivery',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, '/track-delivery');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Deliveries
            const Text(
              'Recent Deliveries',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _DeliveryCard(
              deliveryId: '#DEL001',
              status: 'In Transit',
              statusColor: Colors.blue,
              pickup: '123 Main St',
              dropoff: '456 Oak Ave',
              eta: '25 mins',
              onTap: () => Navigator.pushNamed(context, '/track-delivery'),
            ),
            const SizedBox(height: 12),
            _DeliveryCard(
              deliveryId: '#DEL002',
              status: 'Delivered',
              statusColor: Colors.green,
              pickup: '789 Pine Rd',
              dropoff: '321 Elm St',
              eta: 'Completed',
              onTap: () => Navigator.pushNamed(context, '/track-delivery'),
            ),
            const SizedBox(height: 12),
            _DeliveryCard(
              deliveryId: '#DEL003',
              status: 'Pending',
              statusColor: Colors.orange,
              pickup: '555 Maple Dr',
              dropoff: '888 Cedar Ln',
              eta: 'Waiting',
              onTap: () => Navigator.pushNamed(context, '/track-delivery'),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'My Deliveries',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Action Card Widget
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Delivery Card Widget
class _DeliveryCard extends StatelessWidget {
  final String deliveryId;
  final String status;
  final Color statusColor;
  final String pickup;
  final String dropoff;
  final String eta;
  final VoidCallback onTap;

  const _DeliveryCard({
    required this.deliveryId,
    required this.status,
    required this.statusColor,
    required this.pickup,
    required this.dropoff,
    required this.eta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  deliveryId,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 12),
                const SizedBox(width: 8),
                Text(pickup, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 12),
                const SizedBox(width: 8),
                Text(dropoff, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange, size: 14),
                const SizedBox(width: 4),
                Text(
                  'ETA: $eta',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
