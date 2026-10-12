import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/barber.dart';
import '../../data/models/review.dart';
import '../../data/repositories/barber_repository.dart';
import '../../data/repositories/review_repository.dart';

final barbersProvider = FutureProvider.autoDispose<List<Barber>>((ref) async {
  final repo = ref.watch(barberRepositoryProvider);
  return repo.getBarbers();
});

final barberDetailProvider = FutureProvider.family.autoDispose<Barber?, String>((ref, id) async {
  final repo = ref.watch(barberRepositoryProvider);
  return repo.getBarberById(id);
});

final barberReviewsProvider = FutureProvider.family.autoDispose<List<Review>, String>((ref, barberId) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getReviewsForBarber(barberId);
});
