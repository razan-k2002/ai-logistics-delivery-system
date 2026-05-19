import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/customer_home_screen.dart';
import 'screens/create_delivery_screen.dart';
import 'screens/track_delivery_screen.dart';
import 'screens/driver_home_screen.dart';
import 'screens/delivery_details_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore token and user data from storage on app start
  final token = await StorageService.getToken();
  final userId = await StorageService.getUserId();
  final userRole = await StorageService.getRole();

  if (token != null) {
    ApiService.token = token;
    ApiService.userId = userId;
    ApiService.userRole = userRole;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Logistics Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/customer': (context) => const CustomerHomeScreen(),
        '/create-delivery': (context) => const CreateDeliveryScreen(),
        '/track-delivery': (context) => const TrackDeliveryScreen(),
        '/driver': (context) => const DriverHomeScreen(),
        '/delivery-details': (context) => const DeliveryDetailsScreen(),
        '/admin': (context) => const AdminHomeScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}