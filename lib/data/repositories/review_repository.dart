import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review.dart';
import '../services/supabase_service.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

class ReviewRepository {
  Future<List<Review>> getReviewsForBarber(String barberId) async {
    try {
      final res = await SupabaseService.client
          .from('reviews')
          .select('*, profiles(full_name, avatar_url)')
          .eq('barber_id', barberId)
          .eq('is_published', true)
          .order('created_at', ascending: false);

      return (res as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[REVIEW] getReviewsForBarber error: $e');
      return [];
    }
  }

  Future<void> submitReview({
    required String appointmentId,
    required String customerId,
    required String barberId,
    required int rating,
    String? comment,
  }) async {
    await SupabaseService.client.from('reviews').insert({
      'appointment_id': appointmentId,
      'customer_id': customerId,
      'barber_id': barberId,
      'rating': rating,
      'comment': comment,
      'is_published': true,
    });
    // The DB trigger `trigger_review_rating_sync` auto-updates barbers.rating_avg
  }
}
