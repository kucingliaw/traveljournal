import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveljournal/features/auth/data/auth_exceptions.dart'; // Import custom exceptions

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
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials') || e.statusCode == '400') {
        throw AuthPasswordIncorrectException();
      } else if (e.message.contains('not found') || e.statusCode == '404') {
        throw AuthAccountNotFoundException();
      } else {
        throw AuthLoginFailedException(e.message);
      }
    } catch (e) {
      throw AuthLoginFailedException('An unexpected error occurred: ${e.toString()}');
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

      if (response.user != null) {
        // Create initial profile
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // Sign out immediately to prevent auto-login
      await _supabase.auth.signOut();
      return response;
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        throw AuthEmailAlreadyRegisteredException();
      } else {
        throw AuthSignUpFailedException(e.message);
      }
    } catch (e) {
      throw AuthSignUpFailedException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthSignOutFailedException(e.toString());
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      return session?.user;
    } catch (e) {
      throw AuthGetCurrentUserFailedException(e.toString());
    }
  }
} 