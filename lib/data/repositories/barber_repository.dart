import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/barber.dart';
import '../services/supabase_service.dart';

final barberRepositoryProvider = Provider<BarberRepository>((ref) {
  return BarberRepository();
});

class BarberRepository {
  Future<List<Barber>> getBarbers() async {
    try {
      final res = await SupabaseService.client
          .from('barbers')
          .select('*, profiles(full_name, avatar_url)')
          .eq('is_active', true)
          .isFilter('deleted_at', null)
          .order('rating_avg', ascending: false);

      final list = (res as List<dynamic>)
          .map((e) => Barber.fromJson(e as Map<String, dynamic>))
          .toList();

      list.sort((a, b) {
        final aIsTeddy = a.name.toLowerCase().contains('ted');
        final bIsTeddy = b.name.toLowerCase().contains('ted');
        if (aIsTeddy && !bIsTeddy) return -1;
        if (!aIsTeddy && bIsTeddy) return 1;
        return 0;
      });

      return list;
    } catch (e) {
      if (kDebugMode) debugPrint('[BARBER] getBarbers error: $e');
      return [];
    }
  }

  Future<Barber?> getBarberById(String id) async {
    try {
      final res = await SupabaseService.client
          .from('barbers')
          .select('*, profiles(full_name, avatar_url)')
          .eq('id', id)
          .maybeSingle();

      if (res == null) return null;
      return Barber.fromJson(res);
    } catch (e) {
      if (kDebugMode) debugPrint('[BARBER] getBarberById error: $e');
      return null;
    }
  }

  Future<void> saveBarber(Barber barber) async {
    // 1. Update profiles table (where full_name and avatar_url are stored)
    if (barber.profileId.isNotEmpty) {
      try {
        final profileUpdate = <String, dynamic>{
          'full_name': barber.name,
        };
        if (barber.avatarUrl != null && barber.avatarUrl!.isNotEmpty) {
          profileUpdate['avatar_url'] = barber.avatarUrl;
        }
        await SupabaseService.client
            .from('profiles')
            .update(profileUpdate)
            .eq('id', barber.profileId);
      } catch (e) {
        if (kDebugMode) debugPrint('[BARBER] profiles update error: $e');
      }
    }

    // 2. Upsert barbers table
    final barberData = <String, dynamic>{
      'name': barber.name,
      if (barber.avatarUrl != null && barber.avatarUrl!.isNotEmpty)
        'avatar_url': barber.avatarUrl,
      'bio': barber.bio,
      'experience_years': barber.experienceYears,
      'rating_avg': barber.ratingAvg,
      'total_reviews': barber.totalReviews,
      'is_active': barber.isActive,
      'portfolio_urls': barber.portfolioUrls,
    };

    if (barber.id.isNotEmpty && !barber.id.startsWith('barber-')) {
      barberData['id'] = barber.id;
    }
    if (barber.profileId.isNotEmpty && !barber.profileId.startsWith('prof-')) {
      barberData['profile_id'] = barber.profileId;
    }
    if (barber.branchId != null && barber.branchId!.isNotEmpty) {
      barberData['branch_id'] = barber.branchId;
    }

    try {
      await SupabaseService.client.from('barbers').upsert(barberData);
    } catch (e) {
      // If name or avatar_url columns don't exist yet on barbers table, retry without them
      if (e.toString().contains('name') || e.toString().contains('avatar_url')) {
        barberData.remove('name');
        barberData.remove('avatar_url');
        await SupabaseService.client.from('barbers').upsert(barberData);
      } else {
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>> getBarberDaysOff(String barberId) async {
    try {
      final res = await SupabaseService.client
          .from('barber_days_off')
          .select()
          .eq('barber_id', barberId)
          .order('off_date');

      return (res as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[BARBER] getBarberDaysOff error: $e');
      return [];
    }
  }

  Future<void> addBarberDayOff(String barberId, DateTime date, String reason) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    await SupabaseService.client.from('barber_days_off').insert({
      'barber_id': barberId,
      'off_date': dateStr,
      'reason': reason,
    });
  }

  Future<void> deleteBarberDayOff(String barberId, String dayOffId) async {
    await SupabaseService.client
        .from('barber_days_off')
        .delete()
        .eq('id', dayOffId)
        .eq('barber_id', barberId);
  }
}
