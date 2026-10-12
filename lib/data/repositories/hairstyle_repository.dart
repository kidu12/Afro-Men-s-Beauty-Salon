import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hairstyle.dart';
import '../services/supabase_service.dart';

final hairstyleRepositoryProvider = Provider<HairstyleRepository>((ref) {
  return HairstyleRepository();
});

class HairstyleRepository {
  Future<List<Hairstyle>> getHairstyles({
    String? category,
    bool? isFeatured,
    bool? isTrending,
  }) async {
    try {
      var query = SupabaseService.client
          .from('hairstyles')
          .select('*, hairstyle_media(*)')
          .eq('is_active', true)
          .isFilter('deleted_at', null);

      if (category != null && category != 'All') {
        query = query.eq('category', category);
      }
      if (isFeatured == true) {
        query = query.eq('is_featured', true);
      }
      if (isTrending == true) {
        query = query.eq('is_trending', true);
      }

      final res = await query.order('display_order');
      return (res as List<dynamic>)
          .map((e) => Hairstyle.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[HAIRSTYLE] getHairstyles error: $e');
      return [];
    }
  }

  Future<Hairstyle?> getHairstyleById(String id) async {
    try {
      final res = await SupabaseService.client
          .from('hairstyles')
          .select('*, hairstyle_media(*)')
          .eq('id', id)
          .maybeSingle();

      if (res == null) return null;
      return Hairstyle.fromJson(res);
    } catch (e) {
      if (kDebugMode) debugPrint('[HAIRSTYLE] getHairstyleById error: $e');
      return null;
    }
  }

  Future<void> saveHairstyle(Hairstyle style) async {
    // 1. Upsert the hairstyle row (without nested media)
    final styleJson = style.toJson()..remove('hairstyle_media');
    await SupabaseService.client.from('hairstyles').upsert(styleJson);

    // 2. Replace all media rows for this hairstyle
    if (style.media.isNotEmpty) {
      await SupabaseService.client
          .from('hairstyle_media')
          .delete()
          .eq('hairstyle_id', style.id);

      await SupabaseService.client.from('hairstyle_media').upsert(
        style.media.map((m) => m.toJson()).toList(),
      );
    }
  }
}
