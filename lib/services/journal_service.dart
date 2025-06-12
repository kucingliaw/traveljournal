import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:traveljournal/models/journal.dart';

class JournalService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all journals for current user
  Future<List<Journal>> getJournals() async {
    try {
      final response = await _supabase
          .from('journals')
          .select()
          .order('created_at', ascending: false);

      return response.map<Journal>((json) => Journal.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get journals: $e');
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
      String? imageUrl;

      // Upload image if provided
      if (imagePath != null) {
        final file = File(imagePath);
        final fileExt = path.extension(imagePath);
        final fileName = '${DateTime.now().toIso8601String()}$fileExt';

        await _supabase.storage.from('journal_images').upload(fileName, file);

        imageUrl = _supabase.storage
            .from('journal_images')
            .getPublicUrl(fileName);
      }

      // Create journal entry
      final response = await _supabase
          .from('journals')
          .insert({
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
      throw Exception('Failed to create journal: $e');
    }
  }

  // Update existing journal
  Future<Journal> updateJournal({
    required String id,
    String? title,
    String? content,
    String? locationName,
    double? latitude,
    double? longitude,
    String? imagePath,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (locationName != null) updates['location_name'] = locationName;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;

      // Handle new image upload
      if (imagePath != null) {
        final file = File(imagePath);
        final fileExt = path.extension(imagePath);
        final fileName = '${DateTime.now().toIso8601String()}$fileExt';

        await _supabase.storage.from('journal_images').upload(fileName, file);

        updates['image_url'] = _supabase.storage
            .from('journal_images')
            .getPublicUrl(fileName);
      }

      final response = await _supabase
          .from('journals')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return Journal.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update journal: $e');
    }
  }

  // Delete journal
  Future<void> deleteJournal(String id) async {
    try {
      await _supabase.from('journals').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete journal: $e');
    }
  }
}
