import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveljournal/features/journal/models/journal.dart';

class JournalService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all journals for current user
  Future<List<Journal>> getJournals() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to get journals');
      }

      final response = await _supabase
          .from('journals')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map<Journal>((json) => Journal.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get journals');
    }
  }

  // Upload image to storage
  Future<String?> _uploadImage(String imagePath) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to upload images');
      }

      final file = File(imagePath);
      path.extension(imagePath);
      final fileName =
          '${DateTime.now().toIso8601String()}_${user.id}\$fileExt';

      await _supabase.storage
          .from('journal_images')
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String publicUrl = _supabase.storage
          .from('journal_images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image');
    }
  }

  // Delete image from storage
  Future<void> _deleteImage(String imageUrl) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to delete images');
      }

      final uri = Uri.parse(imageUrl);
      final fileName = path.basename(uri.path);
      await _supabase.storage.from('journal_images').remove([fileName]);
    } catch (e) {
      // print('Error deleting image: $e');
    }
  }

  // Create new journal
  Future<Journal> createJournal({
    required String title,
    required String content,
    String? locationName,
    double? latitude,
    double? longitude,
    String? imagePath,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to create a journal');
      }

      String? imageUrl;
      if (imagePath != null) {
        imageUrl = await _uploadImage(imagePath);
      }

      final response = await _supabase
          .from('journals')
          .insert({
            'user_id': user.id,
            'title': title,
            'content': content,
            'location_name': locationName,
            'latitude': latitude,
            'longitude': longitude,
            'image_url': imageUrl,
          })
          .select()
          .single();

      return Journal.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create journal');
    }
  }

  // Update existing journal
  Future<Journal> updateJournal({
    required String id,
    required String title,
    required String content,
    String? locationName,
    double? latitude,
    double? longitude,
    String? imagePath,
    String? currentImageUrl,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to update journal');
      }

      String? imageUrl = currentImageUrl;
      if (imagePath != null) {
        if (currentImageUrl != null) {
          await _deleteImage(currentImageUrl);
        }
        imageUrl = await _uploadImage(imagePath);
      }

      final response = await _supabase
          .from('journals')
          .update({
            'title': title,
            'content': content,
            'location_name': locationName,
            'latitude': latitude,
            'longitude': longitude,
            'image_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', user.id) // Ensure user owns this journal
          .select()
          .single();

      return Journal.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update journal');
    }
  }

  // Delete journal
  Future<void> deleteJournal(Journal journal) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to delete journal');
      }

      if (journal.imageUrl != null) {
        await _deleteImage(journal.imageUrl!);
      }

      await _supabase
          .from('journals')
          .delete()
          .eq('id', journal.id)
          .eq('user_id', user.id); // Ensure user owns this journal
    } catch (e) {
      throw Exception('Failed to delete journal');
    }
  }
}
