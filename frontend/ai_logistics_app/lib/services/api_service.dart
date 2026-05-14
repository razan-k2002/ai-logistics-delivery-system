import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For Android emulator use: http://10.0.2.2:3000
  static const String baseUrl = 'http://192.168.0.111:3000';

  // Store token after login
  static String? token;

  static Map<String, String> get publicHeaders => {
    'Content-Type': 'application/json',
  };

  // Headers with token (for protected routes)
  static Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ==================== AUTH ====================

  // Login
  static Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: publicHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        token = data['token'];
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Is the server running?',
      };
    }
  }

  // Register
  static Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      String role,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: publicHeaders,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Is the server running?',
      };
    }
  }

  // Save FCM Token (for push notifications)
  static Future<Map<String, dynamic>> saveFcmToken(String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/fcm-token'),
        headers: authHeaders,
        body: jsonEncode({'fcm_token': fcmToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to save FCM token',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // ==================== DELIVERIES ====================

  // Create Delivery
  static Future<Map<String, dynamic>> createDelivery({
    required String pickupLocation,
    required String deliveryLocation,
    required int customerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/deliveries'),
        headers: authHeaders,
        body: jsonEncode({
          'pickup_location': pickupLocation,
          'delivery_location': deliveryLocation,
          'customer_id': customerId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create delivery',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // Get Delivery by ID
  static Future<Map<String, dynamic>> getDelivery(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/deliveries/$id'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get delivery',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // Track Delivery
  static Future<Map<String, dynamic>> trackDelivery(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/deliveries/$id/track'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to track delivery',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // Update Delivery Status
  static Future<Map<String, dynamic>> updateDeliveryStatus(
      int id,
      String status,
      ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/deliveries/$id/status'),
        headers: authHeaders,
        body: jsonEncode({'status': status}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update status',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // Assign Driver to Delivery
  static Future<Map<String, dynamic>> assignDriver(
      int deliveryId,
      int driverId,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/deliveries/$deliveryId/assign'),
        headers: authHeaders,
        body: jsonEncode({'driver_id': driverId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to assign driver',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // Verify Delivery by Tracking ID (OCR)
  static Future<Map<String, dynamic>> verifyDelivery(
      int deliveryId,
      String scannedId,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/deliveries/$deliveryId/verify'),
        headers: authHeaders,
        body: jsonEncode({'scanned_id': scannedId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Verification failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // ==================== DRIVERS ====================

  // Get Driver Deliveries
  static Future<Map<String, dynamic>> getDriverDeliveries(int driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/drivers/$driverId/deliveries'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get deliveries',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // Get Driver Performance
  static Future<Map<String, dynamic>> getDriverPerformance(int driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/drivers/$driverId/performance'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get performance',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // ==================== ADMIN ====================

  // Admin Dashboard
  static Future<Map<String, dynamic>> getAdminDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/dashboard'),
        headers: authHeaders,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load dashboard',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }
}