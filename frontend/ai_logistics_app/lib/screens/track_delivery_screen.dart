import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/delivery_timeline.dart';

class TrackDeliveryScreen extends StatefulWidget {
  const TrackDeliveryScreen({super.key});

  @override
  State<TrackDeliveryScreen> createState() => _TrackDeliveryScreenState();
}

class _TrackDeliveryScreenState extends State<TrackDeliveryScreen> {
  Map<String, dynamic>? _deliveryData;
  List<dynamic> _deliveries = [];
  bool _isLoading = true;
  bool _showList = false;
  int? _selectedDeliveryId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      if (args.containsKey('mode') && args['mode'] == 'list') {
        // Came from bottom nav
        _loadCustomerDeliveries();
      } else {
        // Came from tapping a delivery card
        _selectedDeliveryId = args['id'];
        _loadTracking(_selectedDeliveryId!);
      }
    } else {
      _loadCustomerDeliveries();
    }
  }

  void _loadTracking(int deliveryId) async {
    setState(() {
      _isLoading = true;
      _showList = false;
    });
    final result = await ApiService.trackDelivery(deliveryId);
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _deliveryData = result['data'];
      }
    });
  }

  void _loadCustomerDeliveries() async {
    final customerId = await StorageService.getUserId();
    if (customerId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final result = await ApiService.getCustomerDeliveries(customerId);
    setState(() {
      _isLoading = false;
      _showList = true;
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
        return 'In Transit';
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
        title: Text(
          _showList ? 'My Deliveries' : 'Track Delivery',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_showList && _deliveryData != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _loadTracking(_deliveryData!['delivery_id']),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Colors.orange))
          : _showList
          ? _buildDeliveryList()
          : _deliveryData == null
          ? const Center(child: Text('Could not load delivery data'))
          : _buildTrackingView(),
    );
  }

  Widget _buildDeliveryList() {
    if (_deliveries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text('No deliveries yet',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _deliveries.length,
      itemBuilder: (context, index) {
        final delivery = _deliveries[index];
        final status = delivery['status'] ?? 'pending';
        return GestureDetector(
          onTap: () => _loadTracking(delivery['id']),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#DEL${delivery['id'].toString().padLeft(3, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
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
                    const Icon(Icons.circle, color: Colors.green, size: 12),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        delivery['pickup_location'] ?? '',
                        style: const TextStyle(color: Colors.grey),
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
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackingView() {
    final delivery = _deliveryData!;
    final status = delivery['status'] ?? 'pending';
    final driver = delivery['driver'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#DEL${delivery['delivery_id'].toString().padLeft(3, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (delivery['estimated_time'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'ETA: ${delivery['estimated_time']} mins',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Map Placeholder
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 60, color: Colors.orange),
                  SizedBox(height: 8),
                  Text(
                    'Live Map View',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  Text(
                    'Google Maps integration coming soon',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DeliveryTimeline(currentStatus: status),
          const SizedBox(height: 16),

          // Driver Info
          if (driver != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver['name'] ?? 'Driver',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text('Your Driver',
                            style: TextStyle(color: Colors.grey)),
                        Text(
                          driver['vehicle_type'] ?? '',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.call, color: Colors.green),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_empty, color: Colors.orange),
                  SizedBox(width: 12),
                  Text(
                    'Waiting for driver assignment...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Route Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Route Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.green, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pickup',
                              style: TextStyle(color: Colors.grey)),
                          Text(
                            delivery['pickup_location'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.red, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Drop-off',
                              style: TextStyle(color: Colors.grey)),
                          Text(
                            delivery['delivery_location'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (delivery['created_at'] != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: Colors.grey, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'Created: ${delivery['created_at'].toString().substring(0, 10)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}