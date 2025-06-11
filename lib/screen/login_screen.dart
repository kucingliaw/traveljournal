import 'package:flutter/material.dart';
import 'package:traveljournal/auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Get Auth service
  final authService = AuthService();

  // Controllers for email and password input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Login button handler
  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Attempt to sign in with email and password
    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      // Handle login error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 100),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: login, child: const Text('Login')),
        ],
      ),
    );
  }
}
