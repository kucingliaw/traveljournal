import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../models/user_profile.dart';

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

      print('Profile response from DB: $response'); // Debug log
      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error getting profile: $e'); // Debug log
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
        print('Starting avatar upload process...'); // Debug log

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
              print('Removing old avatar: $oldFileName'); // Debug log
              await _supabase.storage.from('avatars').remove([oldFileName]);
              print('Successfully removed old avatar'); // Debug log
            } catch (e) {
              print('Error removing old avatar: $e'); // Non-critical error
            }
          }

          // Prepare new file name with simpler timestamp
          final fileExt = path.extension(avatarFile.path).toLowerCase();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'avatar_${timestamp}_${user.id}$fileExt';

          print('Uploading new avatar: $fileName'); // Debug log

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

          print('Successfully uploaded avatar file'); // Debug log

          // Get public URL
          avatarUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
          print('Generated avatar URL: $avatarUrl'); // Debug log

          // Wait a moment for storage propagation
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          print('Error in avatar upload process: $e');
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

      print('Upserting profile with data: $updates'); // Debug log

      // Upsert the profile
      final response = await _supabase
          .from('profiles')
          .upsert(updates)
          .select()
          .single();

      print('Profile upsert response: $response'); // Debug log

      final profile = UserProfile.fromJson(response);
      print(
        'Created UserProfile object with avatarUrl: ${profile.avatarUrl}',
      ); // Debug log

      return profile;
    } catch (e) {
      print('Error in upsertProfile: $e'); // Debug log
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
        print('Deleting avatar file: $fileName'); // Debug log
        await _supabase.storage.from('avatars').remove([fileName]);
        print('Successfully deleted avatar file'); // Debug log
      } catch (e) {
        print('Error deleting avatar file: $e'); // Non-critical error
      }
    } catch (e) {
      print('Error in deleteAvatar: $e'); // Debug log
      throw Exception('Failed to delete avatar');
    }
  }
}
