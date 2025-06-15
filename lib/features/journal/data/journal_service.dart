import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveljournal/features/journal/models/journal.dart';
import 'package:traveljournal/features/journal/data/journal_exceptions.dart'; // Import custom exceptions

class JournalService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all journals for current user
  Future<List<Journal>> getJournals() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const JournalUserNotAuthenticatedException(
            'User must be authenticated to get journals');
      }

      final response = await _supabase
          .from('journals')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map<Journal>((json) => Journal.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw JournalFetchFailedException(e.message);
    } catch (_) {
      throw JournalFetchFailedException(
          'An unexpected error occurred: ');
    }
  }

  // Upload image to storage
  Future<String?> _uploadImage(String imagePath) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const JournalUserNotAuthenticatedException(
            'User must be authenticated to upload images');
      }

      final file = File(imagePath);
      final fileExt = path.extension(imagePath).toLowerCase();
      final fileName =
          '${DateTime.now().toIso8601String()}_${user.id}$fileExt';

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
    } on StorageException catch (e) {
      throw JournalUploadImageFailedException(e.message);
    } catch (_) {
      throw JournalUploadImageFailedException(
          'An unexpected error occurred: ');
    }
  }

  // Delete image from storage
  Future<void> _deleteImage(String imageUrl) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const JournalUserNotAuthenticatedException(
            'User must be authenticated to delete images');
      }

      final uri = Uri.parse(imageUrl);
      final fileName = path.basename(uri.path);
      await _supabase.storage.from('journal_images').remove([fileName]);
    } on StorageException catch (_) {
      // This is a non-critical error for journal deletion, log it instead of throwing
      // print('Error deleting image: ${e.message}'); // Commented out print statement
    } catch (_) {
      throw JournalUploadImageFailedException(
          'An unexpected error occurred: ');
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
        throw const JournalUserNotAuthenticatedException(
            'User must be authenticated to create a journal');
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
    } on PostgrestException catch (e) {
      throw JournalCreateFailedException(e.message);
    } catch (_) {
      throw JournalCreateFailedException(
          'An unexpected error occurred: ');
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
        throw const JournalUserNotAuthenticatedException(
            'User must be authenticated to update journal');
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
    } on PostgrestException catch (e) {
      throw JournalUpdateFailedException(e.message);
    } catch (_) {
      throw JournalUpdateFailedException(
          'An unexpected error occurred: ');
    }
  }

  // Delete journal
  Future<void> deleteJournal(Journal journal) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const JournalUserNotAuthenticatedException(
            'User must be authenticated to delete journal');
      }

      if (journal.imageUrl != null) {
        await _deleteImage(journal.imageUrl!);
      }

      await _supabase
          .from('journals')
          .delete()
          .eq('id', journal.id)
          .eq('user_id', user.id); // Ensure user owns this journal
    } on PostgrestException catch (e) {
      throw JournalDeleteFailedException(e.message);
    } catch (_) {
      throw JournalDeleteFailedException(
          'An unexpected error occurred: ');
    }
  }
}
