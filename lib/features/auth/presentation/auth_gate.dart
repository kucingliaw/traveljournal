import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveljournal/features/home/presentation/homescreen.dart';
import 'package:traveljournal/features/auth/presentation/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listen to authentication state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,
      // Build the UI based on the authentication state
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Check if the user is authenticated
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          // User is authenticated, navigate to the home screen
          return const HomeScreen();
        } else {
          // User is not authenticated, navigate to the login screen
          return const LoginScreen();
        }
      },
    );
  }
} 