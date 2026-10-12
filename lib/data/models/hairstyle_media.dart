class HairstyleMedia {
  final String id;
  final String hairstyleId;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final String? thumbnailUrl;
  final int displayOrder;

  const HairstyleMedia({
    required this.id,
    required this.hairstyleId,
    required this.mediaUrl,
    required this.mediaType,
    this.thumbnailUrl,
    this.displayOrder = 0,
  });

  bool get isVideo => mediaType == 'video';

  factory HairstyleMedia.fromJson(Map<String, dynamic> json) {
    return HairstyleMedia(
      id: json['id'] as String,
      hairstyleId: json['hairstyle_id'] as String,
      mediaUrl: json['media_url'] as String,
      mediaType: json['media_type'] as String? ?? 'image',
      thumbnailUrl: json['thumbnail_url'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hairstyle_id': hairstyleId,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'thumbnail_url': thumbnailUrl,
      'display_order': displayOrder,
    };
  }
}
