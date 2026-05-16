import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isAvailable = true;
  List<dynamic> _deliveries = [];
  bool _isLoading = true;
  String _driverEmail = '';
  String _driverName = '';

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  void _loadDeliveries() async {
    final userId = await StorageService.getUserId();
    final email = await StorageService.getEmail();
    final name = await StorageService.getName();

    setState(() {
      _driverEmail = email ?? 'driver@example.com';
      _driverName = name ?? 'Driver';
    });

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Get real driver ID from user ID
    final driverResult = await ApiService.getDriverByUserId(userId);


    if (!driverResult['success']) {
      setState(() => _isLoading = false);
      return;
    }

    final driverId = driverResult['data']['driver']['id'];
    final result = await ApiService.getDriverDeliveries(driverId);
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _deliveries = result['data'] is List ? result['data'] : [];
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'delivered':
        return 'Delivered';
      case 'pending':
        return 'Pending';
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
          'Driver Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadDeliveries();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await StorageService.clearLoginData();
              ApiService.token = null;
              if (!mounted) return;
              navigator.pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Availability Banner
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
                            value ? 'You are now Online!' : 'You are now Offline!',
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

            const SizedBox(height: 24),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _StatsCard(
                    label: 'Total',
                    value: _deliveries.length.toString(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatsCard(
                    label: 'In Progress',
                    value: _deliveries
                        .where((d) => d['status'] == 'in_progress')
                        .length
                        .toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatsCard(
                    label: 'Delivered',
                    value: _deliveries
                        .where((d) => d['status'] == 'delivered')
                        .length
                        .toString(),
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Assigned Deliveries',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
                : _deliveries.isEmpty
                ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.inbox, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No deliveries assigned yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : Column(
              children: _deliveries.map((delivery) {
                final status = delivery['status'] ?? 'pending';
                return GestureDetector(
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      '/delivery-details',
                      arguments: delivery,
                    );
                    // Refresh deliveries when coming back
                    setState(() => _isLoading = true);
                    _loadDeliveries();
                  },
                  child: Container(
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
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '#DEL${delivery['id'].toString().padLeft(3, '0')}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status)
                                    .withValues(alpha: 0.1),
                                borderRadius:
                                BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getStatusLabel(status),
                                style: TextStyle(
                                  color: _getStatusColor(status),
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
                            const Icon(Icons.circle,
                                color: Colors.green, size: 12),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                delivery['pickup_location'] ?? '',
                                style: const TextStyle(
                                    color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.red, size: 12),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                delivery['delivery_location'] ?? '',
                                style: const TextStyle(
                                    color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        if (delivery['estimated_time'] != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.timer,
                                  color: Colors.orange, size: 12),
                              const SizedBox(width: 8),
                              Text(
                                'ETA: ${delivery['estimated_time']} mins',
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            _showHistory();
          } else if (index == 2) {
            _showProfile();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _showHistory() {
    final delivered =
    _deliveries.where((d) => d['status'] == 'delivered').toList();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              delivered.isEmpty
                  ? const Center(child: Text('No completed deliveries yet'))
                  : Column(
                children: delivered.map((delivery) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#DEL${delivery['id'].toString().padLeft(3, '0')}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Delivered ✅',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.orange,
                child: Icon(Icons.drive_eta, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                _driverName,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _driverEmail,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isAvailable
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isAvailable ? 'Active Driver' : 'Offline',
                  style: TextStyle(
                      color: _isAvailable ? Colors.green : Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ProfileStat(
                      label: 'Total',
                      value: _deliveries.length.toString()),
                  _ProfileStat(
                      label: 'Delivered',
                      value: _deliveries
                          .where((d) => d['status'] == 'delivered')
                          .length
                          .toString()),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await StorageService.clearLoginData();
                    ApiService.token = null;
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Logout',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatsCard(
      {required this.label, required this.value, required this.color});

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
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}