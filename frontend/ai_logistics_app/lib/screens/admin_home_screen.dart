import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  // Stats
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

  // Users
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _loadingUsers = true;
  final _userSearchController = TextEditingController();

  // Drivers
  List<Map<String, dynamic>> _drivers = [];

  // Deliveries
  List<Map<String, dynamic>> _deliveries = [];
  List<Map<String, dynamic>> _filteredDeliveries = [];
  bool _loadingDeliveries = true;
  final _deliverySearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _userSearchController.dispose();
    _deliverySearchController.dispose();
    super.dispose();
  }

  void _loadAll() {
    _loadStats();
    _loadUsers();
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

  void _loadUsers() async {
    final usersResult = await ApiService.getAllUsers();
    final driversResult = await ApiService.getAllDrivers();

    if (usersResult['success']) {
      final allUsers = List<Map<String, dynamic>>.from(usersResult['data']['users']);
      setState(() {
        _users = allUsers;
        _filteredUsers = allUsers;
        _loadingUsers = false;
      });
    } else {
      setState(() => _loadingUsers = false);
    }

    if (driversResult['success']) {
      setState(() {
        _drivers = List<Map<String, dynamic>>.from(driversResult['data']['drivers'])
            .where((d) => d['availability_status'] == true)
            .toList();
      });
    }
  }

  void _loadDeliveries() async {
    final result = await ApiService.getAllDeliveries();
    if (result['success']) {
      final deliveries = List<Map<String, dynamic>>.from(result['data']['deliveries']);
      setState(() {
        _deliveries = deliveries;
        _filteredDeliveries = deliveries;
        _loadingDeliveries = false;
      });
    } else {
      setState(() => _loadingDeliveries = false);
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users.where((u) =>
      u['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
          u['email'].toString().toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  void _filterDeliveries(String query) {
    setState(() {
      _filteredDeliveries = _deliveries.where((d) =>
      (d['pickup_location'] ?? '').toString().toLowerCase().contains(query.toLowerCase()) ||
          (d['delivery_location'] ?? '').toString().toLowerCase().contains(query.toLowerCase()) ||
          (d['customer_name'] ?? '').toString().toLowerCase().contains(query.toLowerCase()) ||
          '#DEL${d['id'].toString().padLeft(3, '0')}'.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'in_progress': return Colors.blue;
      case 'pending': return Colors.orange;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress': return 'In Transit';
      case 'pending': return 'Pending';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Admin Dashboard',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAll,
          ),
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Deliveries'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(16)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, Admin!', style: TextStyle(color: Colors.white, fontSize: 16)),
                SizedBox(height: 4),
                Text('AI Logistics System',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('System Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _loadingStats
              ? const Center(child: CircularProgressIndicator(color: Colors.orange))
              : Column(
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(title: 'Total Customers', value: _stats['total_customers'].toString(), icon: Icons.people, color: Colors.blue),
                  _StatCard(title: 'Available Drivers', value: _stats['available_drivers'].toString(), icon: Icons.drive_eta, color: Colors.green),
                  _StatCard(title: 'Total Deliveries', value: _stats['total_deliveries'].toString(), icon: Icons.local_shipping, color: Colors.orange),
                  _StatCard(title: 'Pending', value: _stats['pending'].toString(), icon: Icons.pending, color: Colors.red),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _SummaryCard(label: 'In Progress', value: _stats['in_progress'].toString(), color: Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _SummaryCard(label: 'Delivered', value: _stats['delivered'].toString(), color: Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _SummaryCard(label: 'Cancelled', value: _stats['cancelled'].toString(), color: Colors.red)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recent Deliveries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _loadingDeliveries
              ? const Center(child: CircularProgressIndicator(color: Colors.orange))
              : Column(
            children: _deliveries.take(3).map((delivery) {
              final status = delivery['status'] ?? 'pending';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.local_shipping, color: _statusColor(status), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('#DEL${delivery['id'].toString().padLeft(3, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(delivery['customer_name'] ?? 'Unknown',
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_statusLabel(status),
                          style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUsers() {
    if (_loadingUsers) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _userSearchController,
            onChanged: _filterUsers,
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: _filteredUsers.isEmpty
              ? const Center(child: Text('No users found', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              final role = user['role'] ?? 'customer';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: role == 'driver' ? Colors.blue : role == 'admin' ? Colors.purple : Colors.orange,
                      child: Icon(
                        role == 'driver' ? Icons.drive_eta : role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(user['email'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (role == 'driver' ? Colors.blue : role == 'admin' ? Colors.purple : Colors.orange).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(role,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: role == 'driver' ? Colors.blue : role == 'admin' ? Colors.purple : Colors.orange,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveries() {
    if (_loadingDeliveries) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _deliverySearchController,
            onChanged: _filterDeliveries,
            decoration: InputDecoration(
              hintText: 'Search by location, customer or ID...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: _filteredDeliveries.isEmpty
              ? const Center(child: Text('No deliveries found', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredDeliveries.length,
            itemBuilder: (context, index) {
              final delivery = _filteredDeliveries[index];
              final status = delivery['status'] ?? 'pending';
              final driverId = delivery['driver_id'];
              final driverName = delivery['driver_name'];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('#DEL${delivery['id'].toString().padLeft(3, '0')}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_statusLabel(status),
                              style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.person, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text('Customer: ${delivery['customer_name'] ?? 'Unknown'}',
                          style: const TextStyle(color: Colors.grey)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.drive_eta, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        driverName != null ? 'Driver: $driverName' : 'Unassigned',
                        style: TextStyle(color: driverName != null ? Colors.grey : Colors.red),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.circle, color: Colors.green, size: 12),
                      const SizedBox(width: 4),
                      Expanded(child: Text(delivery['pickup_location'] ?? '', style: const TextStyle(fontSize: 12))),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 12),
                      const SizedBox(width: 4),
                      Expanded(child: Text(delivery['delivery_location'] ?? 'N/A', style: const TextStyle(fontSize: 12))),
                    ]),
                    if (driverId == null && status == 'pending') ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAssignDriver(delivery['id']),
                          icon: const Icon(Icons.person_add, color: Colors.white, size: 16),
                          label: const Text('Assign Driver', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAssignDriver(int deliveryId) async {
    // Get AI suggested best driver
    final bestResult = await ApiService.getBestDriver();
    int? bestDriverId;
    if (bestResult['success']) {
      bestDriverId = bestResult['data']['best_driver']['id'];
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign Driver to #DEL${deliveryId.toString().padLeft(3, '0')}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (bestDriverId != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'AI recommended driver is highlighted',
                      style: TextStyle(color: Colors.orange[700], fontSize: 12),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _drivers.isEmpty
                  ? const Text('No available drivers.', style: TextStyle(color: Colors.grey))
                  : Column(
                children: _drivers.map((driver) {
                  final isRecommended = driver['id'] == bestDriverId;
                  return GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await ApiService.assignDriver(deliveryId, driver['id']);
                      if (result['success']) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${driver['name']} assigned successfully!'),
                          backgroundColor: Colors.green,
                        ));
                        _loadDeliveries();
                        _loadStats();
                        _loadUsers();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(result['message'] ?? 'Failed to assign driver'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isRecommended
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isRecommended ? Colors.orange : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.drive_eta, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(driver['name'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    if (isRecommended) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'AI Pick',
                                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(driver['email'] ?? '',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}