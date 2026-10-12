import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/hairstyle.dart';
import '../../data/repositories/hairstyle_repository.dart';

final selectedStyleCategoryProvider = StateProvider<String>((ref) => 'All');

final hairstylesProvider = FutureProvider.autoDispose<List<Hairstyle>>((ref) async {
  final repo = ref.watch(hairstyleRepositoryProvider);
  final category = ref.watch(selectedStyleCategoryProvider);
  return repo.getHairstyles(category: category == 'All' ? null : category);
});

final featuredStylesProvider = FutureProvider.autoDispose<List<Hairstyle>>((ref) async {
  final repo = ref.watch(hairstyleRepositoryProvider);
  return repo.getHairstyles(isFeatured: true);
});

final hairstyleDetailProvider = FutureProvider.family.autoDispose<Hairstyle?, String>((ref, id) async {
  final repo = ref.watch(hairstyleRepositoryProvider);
  return repo.getHairstyleById(id);
});
