import 'package:flutter/material.dart';

class DeliveryTimeline extends StatelessWidget {
  final String currentStatus;

  const DeliveryTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'status': 'pending', 'label': 'Order Placed', 'icon': Icons.add_circle},
      {'status': 'assigned', 'label': 'Driver Assigned', 'icon': Icons.person},
      {'status': 'in_progress', 'label': 'In Transit', 'icon': Icons.local_shipping},
      {'status': 'delivered', 'label': 'Delivered', 'icon': Icons.check_circle},
    ];

    int currentStep = _getCurrentStep(currentStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Progress',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isDone = index < currentStep;
            final isCurrent = index == currentStep;
            final isPending = index > currentStep;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side — icon and line
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDone
                            ? Colors.green
                            : isCurrent
                            ? Colors.orange
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDone
                            ? Icons.check
                            : step['icon'] as IconData,
                        color: isDone || isCurrent ? Colors.white : Colors.grey,
                        size: 18,
                      ),
                    ),
                    if (index < steps.length - 1)
                      Container(
                        width: 2,
                        height: 32,
                        color: isDone ? Colors.green : Colors.grey[200],
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Right side — label
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['label'] as String,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isDone
                              ? Colors.green
                              : isCurrent
                              ? Colors.orange
                              : Colors.grey,
                        ),
                      ),
                      if (isCurrent)
                        const Text(
                          'Current Status',
                          style: TextStyle(color: Colors.orange, fontSize: 11),
                        ),
                      if (isDone)
                        const Text(
                          'Completed',
                          style: TextStyle(color: Colors.green, fontSize: 11),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }),

          // Cancelled state
          if (currentStatus == 'cancelled')
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('This delivery was cancelled',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  int _getCurrentStep(String status) {
    switch (status) {
      case 'pending': return 0;
      case 'in_progress': return 2;
      case 'delivered': return 4;
      case 'cancelled': return 0;
      default: return 0;
    }
  }
}