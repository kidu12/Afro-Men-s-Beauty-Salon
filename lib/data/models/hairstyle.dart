import 'hairstyle_media.dart';

class Hairstyle {
  final String id;
  final String? branchId;
  final String name;
  final String? description;
  final String category;
  final String? recommendedServiceId;
  final bool isFeatured;
  final bool isTrending;
  final bool isActive;
  final int displayOrder;
  final List<HairstyleMedia> media;

  const Hairstyle({
    required this.id,
    this.branchId,
    required this.name,
    this.description,
    required this.category,
    this.recommendedServiceId,
    this.isFeatured = false,
    this.isTrending = false,
    this.isActive = true,
    this.displayOrder = 0,
    this.media = const [],
  });

  String? get primaryImageUrl {
    if (media.isEmpty) return null;
    final img = media.firstWhere((m) => !m.isVideo, orElse: () => media.first);
    return img.isVideo ? (img.thumbnailUrl ?? img.mediaUrl) : img.mediaUrl;
  }

  bool get hasVideo => media.any((m) => m.isVideo);

  factory Hairstyle.fromJson(Map<String, dynamic> json) {
    var mediaList = <HairstyleMedia>[];
    if (json['hairstyle_media'] != null) {
      final rawList = json['hairstyle_media'] as List<dynamic>;
      mediaList = rawList.map((m) => HairstyleMedia.fromJson(m as Map<String, dynamic>)).toList();
    }

    return Hairstyle(
      id: json['id'] as String,
      branchId: json['branch_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'Classic',
      recommendedServiceId: json['recommended_service_id'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      isTrending: json['is_trending'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
      media: mediaList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'name': name,
      'description': description,
      'category': category,
      'recommended_service_id': recommendedServiceId,
      'is_featured': isFeatured,
      'is_trending': isTrending,
      'is_active': isActive,
      'display_order': displayOrder,
      'hairstyle_media': media.map((m) => m.toJson()).toList(),
    };
  }
}
