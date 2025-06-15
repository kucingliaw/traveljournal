import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:traveljournal/features/profile/models/user_profile.dart';
import 'package:traveljournal/features/profile/data/profile_exceptions.dart'; // Import custom exceptions

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user profile
  Future<UserProfile?> getProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return null;
      }

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(response);
    } on PostgrestException catch (e) {
      throw ProfileFetchFailedException(e.message);
    } catch (_) {
      throw ProfileFetchFailedException(
          'An unexpected error occurred: ');
    }
  }

  // Create or update user profile
  Future<UserProfile> upsertProfile({
    String? username,
    File? avatarFile,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const ProfileUserNotAuthenticatedException(
            'User not authenticated');
      }

      String? avatarUrl;
      if (avatarFile != null) {
        try {
          // Delete old avatar if exists
          final currentProfile = await getProfile();
          if (currentProfile?.avatarUrl != null) {
            try {
              // Clear the avatar URL from the database first
              await _supabase
                  .from('profiles')
                  .update({'avatar_url': null})
                  .eq('id', user.id);

              // Then try to delete the old file
              final oldUri = Uri.parse(currentProfile!.avatarUrl!);
              final oldFileName = path.basename(oldUri.path);
              await _supabase.storage.from('avatars').remove([oldFileName]);
            } on StorageException catch (_) {
              // Non-critical error, log it instead of throwing
              // print('Error deleting old avatar: ${e.message}'); // Commented out print statement
            } catch (_) {
              // print('An unexpected error occurred during old avatar deletion: ${e.toString()}'); // Commented out print statement
            }
          }

          // Prepare new file name with simpler timestamp
          final fileExt = path.extension(avatarFile.path).toLowerCase();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'avatar_${timestamp}_${user.id}$fileExt';

          // Upload new avatar
          await _supabase.storage
              .from('avatars')
              .upload(
                fileName,
                avatarFile,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: true,
                ),
              );

          // Get public URL
          avatarUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);

          // TODO: [Refactor] Consider a more robust solution than Future.delayed for storage propagation.
          // This delay is a workaround to ensure the public URL is available before it's used.
          // A better approach would be to listen for storage events or implement a retry mechanism.
          await Future.delayed(const Duration(milliseconds: 500));
        } on StorageException catch (e) {
          throw ProfileUploadAvatarFailedException(e.message);
        } catch (_) {
          throw ProfileUploadAvatarFailedException(
              'An unexpected error occurred during avatar upload: ');
        }
      }

      // Prepare profile data
      final updates = {
        'id': user.id,
        'email': user.email,
        if (username != null) 'username': username,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Upsert the profile
      final response = await _supabase
          .from('profiles')
          .upsert(updates)
          .select()
          .single();

      final profile = UserProfile.fromJson(response);

      return profile;
    } on PostgrestException catch (e) {
      throw ProfileUpdateFailedException(e.message);
    } catch (_) {
      throw ProfileUpdateFailedException(
          'An unexpected error occurred: ');
    }
  }

  // Delete avatar
  Future<void> deleteAvatar() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const ProfileUserNotAuthenticatedException(
            'User not authenticated');
      }

      final profile = await getProfile();
      if (profile?.avatarUrl == null) {
        return;
      }

      // Clear the URL from the database first
      await _supabase
          .from('profiles')
          .update({'avatar_url': null})
          .eq('id', user.id);

      // Then try to delete the file
      try {
        final uri = Uri.parse(profile!.avatarUrl!);
        final fileName = path.basename(uri.path);
        await _supabase.storage.from('avatars').remove([fileName]);
      } on StorageException catch (_) {
        // Non-critical error, log it instead of throwing
        // print('Error deleting avatar from storage: ${e.message}'); // Commented out print statement
      } catch (_) {
        // print('An unexpected error occurred during avatar file deletion: ${e.toString()}'); // Commented out print statement
      }
    } on PostgrestException catch (e) {
      throw ProfileDeleteAvatarFailedException(e.message);
    } catch (_) {
      throw ProfileDeleteAvatarFailedException(
          'An unexpected error occurred: ');
    }
  }
} 