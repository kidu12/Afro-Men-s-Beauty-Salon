class ServiceItem {
  final String id;
  final String? branchId;
  final String? categoryId;
  final String name;
  final String? description;
  final num? price; // Strictly nullable!
  final int? durationMinutes; // Strictly nullable!
  final String? imageUrl;
  final bool isActive;
  final int displayOrder;

  const ServiceItem({
    required this.id,
    this.branchId,
    this.categoryId,
    required this.name,
    this.description,
    this.price,
    this.durationMinutes,
    this.imageUrl,
    this.isActive = true,
    this.displayOrder = 0,
  });

  /// Check if the service is ready for customer booking
  bool get isBookingConfigured => durationMinutes != null && durationMinutes! > 0;
  bool get hasPrice => price != null && price! > 0;

  /// Only "Home to Home" / "Home Service" variants ever show a price on UI.
  /// Checks for "home to home" OR "home service" in the name (case-insensitive).
  bool get isHomeToHome {
    final n = name.toLowerCase();
    return n.contains('home to home') || n.contains('home service');
  }

  /// HARD RULE: price is NEVER shown unless the service is explicitly Home-to-Home.
  bool get shouldShowPrice => isHomeToHome && hasPrice;

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as String,
      branchId: json['branch_id'] as String?,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: json['price'] != null ? (json['price'] as num) : null,
      durationMinutes: json['duration_minutes'] as int?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
      'image_url': imageUrl,
      'is_active': isActive,
      'display_order': displayOrder,
    };
  }

  ServiceItem copyWith({
    String? name,
    String? description,
    num? price,
    int? durationMinutes,
    String? imageUrl,
    bool? isActive,
    String? categoryId,
  }) {
    return ServiceItem(
      id: id,
      branchId: branchId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder,
    );
  }
}
