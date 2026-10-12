import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/service_item.dart';
import '../../data/models/service_category.dart';
import '../../data/repositories/service_repository.dart';

final serviceCategoriesProvider = FutureProvider.autoDispose<List<ServiceCategory>>((ref) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.getCategories();
});

final selectedServiceCategoryProvider = StateProvider<String?>((ref) => null);

final servicesProvider = FutureProvider.autoDispose<List<ServiceItem>>((ref) async {
  final repo = ref.watch(serviceRepositoryProvider);
  final categoryId = ref.watch(selectedServiceCategoryProvider);
  return repo.getServices(categoryId: categoryId);
});

final serviceDetailProvider = FutureProvider.family.autoDispose<ServiceItem?, String>((ref, id) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.getServiceById(id);
});
