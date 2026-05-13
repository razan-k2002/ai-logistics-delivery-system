import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.10.77:3000';
  static String? token;

  static Map<String, String> get publicHeaders => {
    'Content-Type': 'application/json',
  };

  static Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ==================== AUTH ====================

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: publicHeaders,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
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

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/register'),
            headers: publicHeaders,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'role': role,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
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

  // ==================== DELIVERIES ====================

  static Future<Map<String, dynamic>> createDelivery({
    required String pickupLocation,
    required String deliveryLocation,
    required int customerId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/deliveries'),
            headers: authHeaders,
            body: jsonEncode({
              'pickup_location': pickupLocation,
              'delivery_location': deliveryLocation,
              'customer_id': customerId,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
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

  static Future<Map<String, dynamic>> getDelivery(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/deliveries/$id'), headers: authHeaders)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
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

  static Future<Map<String, dynamic>> trackDelivery(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/deliveries/$id/track'),
            headers: authHeaders,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
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

  static Future<Map<String, dynamic>> updateDeliveryStatus(
    int id,
    String status,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/api/deliveries/$id/status'),
            headers: authHeaders,
            body: jsonEncode({'status': status}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
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

  static Future<Map<String, dynamic>> assignDriver(
    int deliveryId,
    int driverId,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/deliveries/$deliveryId/assign'),
            headers: authHeaders,
            body: jsonEncode({'driver_id': driverId}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
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

  // ==================== DRIVERS ====================

  static Future<Map<String, dynamic>> getDriverDeliveries(int driverId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/drivers/$driverId/deliveries'),
            headers: authHeaders,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
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

  // ==================== ADMIN ====================

  static Future<Map<String, dynamic>> getAdminDashboard() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/admin/dashboard'), headers: authHeaders)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
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
