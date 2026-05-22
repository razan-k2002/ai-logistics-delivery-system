import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Razan's PC:     http://192.168.0.111:3000
  // Teammate's PC:  http://192.168.10.77:3000
  // Android Emulator: http://10.0.2.2:3000
  static const String baseUrl = 'http://192.168.0.113:3000';

  static String? token;
  static int? userId;
  static String? userRole;

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
        userId = data['user']['id'];
        userRole = data['user']['role'];
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
// Get Notifications
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/notifications'), headers: authHeaders)
          .timeout(const Duration(seconds: 10),
          onTimeout: () => throw Exception('Connection timeout'));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to get notifications'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

// Mark all notifications as read
  static Future<Map<String, dynamic>> markAllNotificationsRead() async {
    try {
      final response = await http
          .patch(Uri.parse('$baseUrl/api/notifications/read-all'), headers: authHeaders)
          .timeout(const Duration(seconds: 10),
          onTimeout: () => throw Exception('Connection timeout'));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to mark as read'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
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

  static Future<Map<String, dynamic>> saveFcmToken(String fcmToken) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/api/auth/fcm-token'),
        headers: authHeaders,
        body: jsonEncode({'fcm_token': fcmToken}),
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
          'message': data['message'] ?? 'Failed to save FCM token',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  // ==================== DELIVERIES ====================

  static Future<Map<String, dynamic>> createDelivery({
    required String pickupLocation,
    required String deliveryLocation,
    required int customerId,
    List<double>? pickupCoords,
    List<double>? deliveryCoords,
  }) async {
    try {
      final body = {
        'pickup_location': pickupLocation,
        'delivery_location': deliveryLocation,
        'customer_id': customerId,
        'pickup_coords': pickupCoords ?? [35.5018, 33.8938],
        'delivery_coords': deliveryCoords ?? [35.5197, 33.8886],
      };

      final response = await http
          .post(
        Uri.parse('$baseUrl/api/deliveries'),
        headers: authHeaders,
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 10),
          onTimeout: () => throw Exception('Connection timeout'));

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to create delivery'};
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
  static Future<Map<String, dynamic>> getAllDrivers() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/admin/drivers'), headers: authHeaders)
          .timeout(const Duration(seconds: 10),
          onTimeout: () => throw Exception('Connection timeout'));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to get drivers'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }
  static Future<Map<String, dynamic>> getDriverByUserId(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/drivers/by-user/$userId'), headers: authHeaders)
          .timeout(const Duration(seconds: 10),
          onTimeout: () => throw Exception('Connection timeout'));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Driver not found'};
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

  static Future<Map<String, dynamic>> verifyDelivery(
      int deliveryId,
      String scannedId,
      ) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/api/deliveries/$deliveryId/verify'),
        headers: authHeaders,
        body: jsonEncode({'scanned_id': scannedId}),
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
          'message': data['message'] ?? 'Verification failed',
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

  static Future<Map<String, dynamic>> getDriverPerformance(int driverId) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/api/drivers/$driverId/performance'),
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
          'message': data['message'] ?? 'Failed to get performance',
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
          .get(
        Uri.parse('$baseUrl/api/admin/dashboard'),
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
          'message': data['message'] ?? 'Failed to load dashboard',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }

  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/admin/users'), headers: authHeaders)
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
          'message': data['message'] ?? 'Failed to get users',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }
  static Future<Map<String, dynamic>> getCustomerDeliveries(int customerId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/deliveries/customer/$customerId'), headers: authHeaders)
          .timeout(const Duration(seconds: 10),
          onTimeout: () => throw Exception('Connection timeout'));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to get deliveries'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }
  static Future<Map<String, dynamic>> getAllDeliveries() async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/api/admin/deliveries'),
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
  static Future<Map<String, dynamic>> getBestDriver() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/drivers/best'), headers: authHeaders)
          .timeout(const Duration(seconds: 10),
          onTimeout: () => throw Exception('Connection timeout'));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'No available drivers'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }
static Future<Map<String, dynamic>> updateDriverAvailability(
int driverId, bool isAvailable) async {
try {
final response = await http
    .patch(
Uri.parse('$baseUrl/api/drivers/$driverId/availability'),
headers: authHeaders,
body: jsonEncode({'is_available': isAvailable}),
)
    .timeout(const Duration(seconds: 10),
onTimeout: () => throw Exception('Connection timeout'));
final data = jsonDecode(response.body);
if (response.statusCode == 200) {
return {'success': true, 'data': data};
} else {
return {'success': false, 'message': data['message'] ?? 'Failed to update'};
}
} catch (e) {
return {'success': false, 'message': 'Connection error.'};
}
}

}
