class FavoriteItem {
  final String id;
  final String userId;
  final String itemType; // 'style' or 'barber' or 'service'
  final String itemId;
  final DateTime createdAt;

  const FavoriteItem({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    required this.createdAt,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      itemType: json['item_type'] as String,
      itemId: json['item_id'] as String,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_type': itemType,
      'item_id': itemId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
