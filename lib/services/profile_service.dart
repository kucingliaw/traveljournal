import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:traveljournal/features/profile/models/user_profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user profile
  Future<UserProfile?> getProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get profile');
    }
  }

  // Create or update user profile
  Future<UserProfile> upsertProfile({
    String? username,
    File? avatarFile,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

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
            } catch (e) {
              // Non-critical error
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

          // Wait a moment for storage propagation
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          throw Exception('Failed to upload avatar');
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
    } catch (e) {
      throw Exception('Failed to update profile');
    }
  }

  // Delete avatar
  Future<void> deleteAvatar() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final profile = await getProfile();
      if (profile?.avatarUrl == null) return;

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
      } catch (e) {
        // Non-critical error
      }
    } catch (e) {
      throw Exception('Failed to delete avatar');
    }
  }
}
