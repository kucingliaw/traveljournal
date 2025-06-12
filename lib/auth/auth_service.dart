import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('password_incorrect');
      } else if (e.toString().contains('not found')) {
        throw Exception('account_not_found');
      } else {
        throw Exception('login_failed');
      }
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      // Sign out immediately to prevent auto-login
      await _supabase.auth.signOut();
      return response;
    } catch (e) {
      if (e.toString().contains('already registered')) {
        throw Exception('email_registered');
      } else {
        throw Exception('signup_failed');
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      return session?.user;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }
}
