import 'package:flutter/material.dart';

class TrackDeliveryScreen extends StatefulWidget {
  const TrackDeliveryScreen({super.key});

  @override
  State<TrackDeliveryScreen> createState() => _TrackDeliveryScreenState();
}

class _TrackDeliveryScreenState extends State<TrackDeliveryScreen> {
  // Simulated delivery status
  final String _currentStatus = 'In Transit';
  final int _currentStep = 2;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Order Placed',
      'subtitle': 'Your delivery request was created',
      'time': '10:00 AM',
      'icon': Icons.check_circle,
      'done': true,
    },
    {
      'title': 'Driver Assigned',
      'subtitle': 'Ali Hassan is your driver',
      'time': '10:05 AM',
      'icon': Icons.person,
      'done': true,
    },
    {
      'title': 'Package Picked Up',
      'subtitle': 'Driver picked up your package',
      'time': '10:30 AM',
      'icon': Icons.inventory,
      'done': true,
    },
    {
      'title': 'In Transit',
      'subtitle': 'Your package is on the way',
      'time': '10:45 AM',
      'icon': Icons.local_shipping,
      'done': false,
    },
    {
      'title': 'Delivered',
      'subtitle': 'Package delivered successfully',
      'time': 'Pending',
      'icon': Icons.home,
      'done': false,
    },
  ];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery ID & Status Card
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
                  const Text(
                    'Delivery #DEL001',
                    style: TextStyle(
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
                      _currentStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Estimated Arrival: 25 mins',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Map Placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Map placeholder background
                    Container(
                      color: Colors.blue[50],
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
                              'Google Maps will be integrated here',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Driver location indicator
                    Positioned(
                      top: 80,
                      left: 150,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Driver Info Card
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ali Hassan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Your Driver',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 16),
                            Text(' 4.8 Rating'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Call Button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.call, color: Colors.green),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Delivery Route
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 14),
                      SizedBox(width: 8),
                      Expanded(child: Text('123 Main St - Pickup Location')),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: SizedBox(
                      height: 20,
                      child: VerticalDivider(color: Colors.grey),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 14),
                      SizedBox(width: 8),
                      Expanded(child: Text('456 Oak Ave - Drop-off Location')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tracking Steps
            const Text(
              'Delivery Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: _steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isLast = index == _steps.length - 1;
                  final isCurrent = index == _currentStep;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: step['done']
                                  ? Colors.orange
                                  : isCurrent
                                  ? Colors.orange.withOpacity(0.3)
                                  : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              step['icon'],
                              size: 18,
                              color: step['done']
                                  ? Colors.white
                                  : isCurrent
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 40,
                              color: step['done']
                                  ? Colors.orange
                                  : Colors.grey[300],
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: step['done']
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                              Text(
                                step['subtitle'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                step['time'],
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
