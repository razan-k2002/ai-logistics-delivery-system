import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  const DeliveryDetailsScreen({super.key});

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  String _currentStatus = '';
  int _deliveryId = 0;
  Map<String, dynamic> _delivery = {};
  bool _isUpdating = false;
  bool _isVerified = false;
  bool _initialized = false;
  final _trackingIdController = TextEditingController();

  final List<String> _statusOptions = [
    'pending',
    'in_progress',
    'delivered',
    'cancelled',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        _delivery = args;
        _deliveryId = _delivery['id'] ?? 0;
        _currentStatus = _delivery['status'] ?? 'pending';
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _trackingIdController.dispose();
    super.dispose();
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

  void _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    final result = await ApiService.updateDeliveryStatus(_deliveryId, newStatus);
    if (!mounted) return;
    setState(() {
      _isUpdating = false;
      if (result['success']) {
        _currentStatus = newStatus;
      }
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['success']
              ? 'Status updated to ${_getStatusLabel(newStatus)} ✅'
              : result['message'] ?? 'Failed to update status',
        ),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );
  }

  void _showStatusUpdate() {
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
              const Text(
                'Update Delivery Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._statusOptions.map((status) {
                final isSelected = _currentStatus == status;
                return GestureDetector(
                  onTap: () => _updateStatus(status),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getStatusColor(status).withValues(alpha: 0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? _getStatusColor(status)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected
                              ? _getStatusColor(status)
                              : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getStatusLabel(status),
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? _getStatusColor(status)
                                : Colors.black,
                          ),
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

  void _showVerification() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verify Delivery',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the package tracking ID to verify delivery.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _trackingIdController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Tracking ID',
                  hintText: 'e.g. TRK-FB003707',
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final scannedId = _trackingIdController.text.trim();
                    if (scannedId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter the tracking ID'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    final result = await ApiService.verifyDelivery(
                        _deliveryId, scannedId);
                    if (!mounted) return;
                    Navigator.pop(context);
                    if (result['success'] &&
                        result['data']['verified'] == true) {
                      setState(() => _isVerified = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Delivery verified successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '❌ Tracking ID does not match. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.verified, color: Colors.white),
                  label: const Text(
                    'Verify',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          '#DEL${_deliveryId.toString().padLeft(3, '0')}',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getStatusColor(_currentStatus),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Status',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    _getStatusLabel(_currentStatus),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Route Details
            Container(
              width: double.infinity,
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
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.circle,
                          color: Colors.green, size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pickup',
                                style: TextStyle(color: Colors.grey)),
                            Text(
                              _delivery['pickup_location'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
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
                              _delivery['delivery_location'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_delivery['estimated_time'] != null) ...[
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.timer,
                            color: Colors.orange, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'Estimated Time: ${_delivery['estimated_time']} mins',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ],
                  if (_delivery['tracking_id'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.qr_code,
                            color: Colors.grey, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'Tracking ID: ${_delivery['tracking_id']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Verification Badge
            if (_isVerified)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Delivery Verified ✅',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Map Placeholder
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 50, color: Colors.orange),
                    SizedBox(height: 8),
                    Text(
                      'AI Optimized Route Map',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                    ),
                    Text(
                      'Google Maps coming soon',
                      style:
                      TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Update Status Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : _showStatusUpdate,
                icon: _isUpdating
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.update, color: Colors.white),
                label: const Text(
                  'Update Delivery Status',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Verify Delivery Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isVerified ? null : _showVerification,
                icon: Icon(
                  _isVerified ? Icons.verified : Icons.camera_alt,
                  color: Colors.white,
                ),
                label: Text(
                  _isVerified
                      ? 'Already Verified ✅'
                      : 'Verify Delivery',
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _isVerified ? Colors.grey : Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}