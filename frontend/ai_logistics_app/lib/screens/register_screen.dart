import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _selectedRole = 'customer'; // default role

  void _register() {
    setState(() => _isLoading = true);

    // TODO: connect to your friend's API later
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);

      // After register, go to login
      Navigator.pushReplacementNamed(context, '/login');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Please login.'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 28),
              ),

              const SizedBox(height: 24),

              // Title
              const Icon(Icons.local_shipping, size: 60, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Register to get started',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 32),

              // Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Role Selection
              const Text(
                'I am a:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Customer Option
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedRole = 'customer');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'customer'
                              ? Colors.orange
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedRole == 'customer'
                                ? Colors.orange
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person,
                              size: 32,
                              color: _selectedRole == 'customer'
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Customer',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedRole == 'customer'
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Driver Option
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedRole = 'driver');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'driver'
                              ? Colors.orange
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedRole == 'driver'
                                ? Colors.orange
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.drive_eta,
                              size: 32,
                              color: _selectedRole == 'driver'
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Driver',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedRole == 'driver'
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
