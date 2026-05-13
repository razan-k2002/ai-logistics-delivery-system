import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TrackDeliveryScreen extends StatefulWidget {
  const TrackDeliveryScreen({super.key});

  @override
  State<TrackDeliveryScreen> createState() => _TrackDeliveryScreenState();
}

class _TrackDeliveryScreenState extends State<TrackDeliveryScreen> {
  Map<String, dynamic>? _deliveryData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTracking();
  }

  void _loadTracking() async {
    final result = await ApiService.trackDelivery(1);
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _deliveryData = result['data'];
      }
    });
  }

  Color getStatusColor(String status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Track Delivery',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _deliveryData == null
          ? const Center(child: Text('Could not load delivery data'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery #DEL00${_deliveryData!['delivery_id']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _deliveryData!['status'] ?? 'pending',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            'Google Maps integration coming soon',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_deliveryData!['driver'] != null)
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
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _deliveryData!['driver']['name'] ?? 'Driver',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Text(
                                  'Your Driver',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  _deliveryData!['driver']['vehicle_type'] ??
                                      '',
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
                    ),
                  const SizedBox(height: 20),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _deliveryData!['pickup_location'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _deliveryData!['delivery_location'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
