import 'package:flutter/material.dart';

class CreateDeliveryScreen extends StatefulWidget {
  const CreateDeliveryScreen({super.key});

  @override
  State<CreateDeliveryScreen> createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends State<CreateDeliveryScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _packageDetailsController = TextEditingController();
  String _selectedPackageType = 'Small';
  bool _isLoading = false;

  final List<String> _packageTypes = ['Small', 'Medium', 'Large', 'Fragile'];

  void _submitDelivery() {
    if (_pickupController.text.isEmpty ||
        _dropoffController.text.isEmpty ||
        _packageDetailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: connect to your friend's API later
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);

      // Show success then go back to home
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 70),
              const SizedBox(height: 16),
              const Text(
                'Delivery Request Created!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'A driver will be assigned to your delivery shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // Show estimated time
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Estimated Time: 30-45 mins',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/customer');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go to Home',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'New Delivery Request',
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
            // Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI will automatically assign the best driver and optimize the route for you!',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pickup Location
            const Text(
              'Pickup Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pickupController,
              decoration: InputDecoration(
                hintText: 'Enter pickup address',
                prefixIcon: const Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 16,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Dropoff Location
            const Text(
              'Drop-off Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dropoffController,
              decoration: InputDecoration(
                hintText: 'Enter drop-off address',
                prefixIcon: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Package Type
            const Text(
              'Package Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: _packageTypes.map((type) {
                final isSelected = _selectedPackageType == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedPackageType = type);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        type,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Package Details
            const Text(
              'Package Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _packageDetailsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your package (e.g. Books, Electronics...)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // AI Route Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Route Optimization',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.route, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Fastest route will be calculated automatically'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_pin, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Best available driver will be assigned'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('ETA will be estimated using AI'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitDelivery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Create Delivery Request',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
