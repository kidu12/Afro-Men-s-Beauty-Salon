import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_item.dart';
import '../models/service_category.dart';
import '../services/supabase_service.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository();
});

class ServiceRepository {
  Future<List<ServiceCategory>> getCategories() async {
    try {
      final res = await SupabaseService.client
          .from('service_categories')
          .select()
          .eq('is_active', true)
          .order('display_order');

      return (res as List<dynamic>)
          .map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[SERVICE] getCategories error: $e');
      return [];
    }
  }

  Future<List<ServiceItem>> getServices({String? categoryId}) async {
    try {
      var query = SupabaseService.client
          .from('services')
          .select()
          .eq('is_active', true)
          .isFilter('deleted_at', null);

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }

      final res = await query.order('display_order');
      return (res as List<dynamic>)
          .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[SERVICE] getServices error: $e');
      return [];
    }
  }

  Future<ServiceItem?> getServiceById(String id) async {
    try {
      final res = await SupabaseService.client
          .from('services')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (res == null) return null;
      return ServiceItem.fromJson(res);
    } catch (e) {
      if (kDebugMode) debugPrint('[SERVICE] getServiceById error: $e');
      return null;
    }
  }

  Future<void> saveService(ServiceItem service) async {
    await SupabaseService.client.from('services').upsert(service.toJson());
  }

  Future<void> deleteService(String id) async {
    // Soft-delete by setting deleted_at timestamp
    await SupabaseService.client
        .from('services')
        .update({'deleted_at': DateTime.now().toIso8601String(), 'is_active': false})
        .eq('id', id);
  }
}
